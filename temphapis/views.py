from dbservices.dbutils import dbutils
# Following import is default due to `DEFAULT_THROTTLE_CLASSES`
# from rest_framework.decorators import throttle_classes
# from rest_framework.throttling import AnonRateThrottle, UserRateThrottle
from rest_framework_simplejwt.tokens import RefreshToken
from django.contrib.auth.models import User
from rest_framework_simplejwt.authentication import JWTAuthentication
from functools import wraps
# imports for login lockout
from rest_framework_simplejwt.exceptions import InvalidToken
from django.urls import reverse
from django.core.cache import cache
from envconfig import envconfig
from middleware.utils import utils
from datauri import DataURI
from django.conf import settings
from pathlib import Path
# imports for general request-response handling
from rest_framework.decorators import api_view
from django.http.request import HttpRequest
from django.http.response import HttpResponse, JsonResponse
from django.http import StreamingHttpResponse
from io import BytesIO
import json


def token_required(func):
    '''
    todo: combine with try_auth_with_track_attempts and make auth_callback types
    such as with JWTAuthentication or username/password parameters to
    a new decorator @auth_attempt('jwt|pwd')
    '''
    @wraps(func)
    def inner(request, *args, **kwargs):
        try:
            auth_callback = JWTAuthentication().authenticate
            result = try_auth_with_track_attempts(request, auth_callback)
            auth_failures = result["auth_failures"]
            print("auth_failures", auth_failures)
            return func(request, *args, **kwargs) if result["success"] else HttpResponse(f"could not auth (auth_failures:{auth_failures})\n", status=401)
        except Exception as e:
            reset_url = f"{request.scheme}://{request.get_host()}{reverse('reset-lockout')}"
            return HttpResponse(f"error: {e}\nvisit {reset_url} with username to reset lockout if login limit was exceeded\n", status=401)
    return inner

@api_view(['GET'])
# @throttle_classes([AnonRateThrottle])
def history(request: HttpRequest):
    count = request.GET.get('count')
    if count is None: count = 5
    count = int(count)
    return StreamingHttpResponse(dbutils.get_history(count))

@token_required
@api_view(['POST'])
# @throttle_classes([UserRateThrottle])
def user_history(request: HttpRequest):
    request_user = request.user
    count = None
    try: count, *_ = get_parsed_values(request, 'count')
    except Exception: return make_result("invalid params", False, 400)
    if request_user is not None and request_user.is_active:
        count = request.POST.get('count')
        if count is None: count = 5
        count = int(count)
        return StreamingHttpResponse(dbutils.get_user_history(request_user,count))

@api_view(['POST','GET'])
def health(_: HttpRequest):
    return JsonResponse({"data":{"health":1}})

@api_view(['GET'])
def index(_: HttpRequest):
    return HttpResponse("<h2>home page</h2><p>html page</p>", content_type="text/html")

@api_view(['POST'])
def token(request: HttpRequest):
    username = None
    password = None

    try: username, password, *_ = get_parsed_values(request, 'username', 'password')
    except Exception: return make_result("invalid params", False, 400)

    users = User.objects.all()
    try:
        request_user = users.get(username=username)
        if request_user is not None:
            print(request_user.first_name + " " + request_user.last_name)
            if User.check_password(request_user,password) and request_user.is_active:
                return JsonResponse(get_tokens_for_user(request_user), status=200)
        return HttpResponse("could not log in {username}!\n")
    except Exception:
        return HttpResponse("user not found!\n",status=301)

@api_view(['POST'])
def reset_lockout(request: HttpRequest):
    username = None

    try: username, *_ = get_parsed_values(request, 'username')
    except Exception: return make_result("invalid params", False, 400)

    ip_address = utils.get_ip(request)
    auth_failure_key = f"LOGIN_FAILURES_{ip_address}_{username}"
    if cache.has_key(auth_failure_key):
        cache.set(auth_failure_key, 0)
        return HttpResponse("lockout is reset!\n")
    else:
        return HttpResponse("try again later!\n")

@token_required
@api_view(['POST'])
def upload_image(request: HttpRequest):
    img_data = None
    img_name = None
    username = None

    try: img_data, img_name, username, *_ = get_parsed_values(request, 'img_data', 'img_name', 'username')
    except Exception: return make_result("invalid params", False, 400)

    try:
        if img_data is not None and username is not None:
            img_uri = DataURI(img_data)
            file_ext = img_uri.mimetype.split('/')[1]
            output_filename = Path(settings.MEDIA_ROOT).resolve().joinpath('images').joinpath(f'{username}_img_{img_name}.{file_ext}')
            with open(output_filename,'wb') as img_file: img_file.write(img_uri.data)
            return make_result("image uploaded", True, 200)
        else:
            return make_result("invalid params", False, 400)
    except Exception as e:
        print(f"exception: {e}")
        return make_result("could not upload image", False, 500)

def get_tokens_for_user(user):
    refresh = RefreshToken.for_user(user)
    access = str(refresh.access_token)
    return dict({
        "data":
            {
                'refresh': str(refresh),
                'access': access,
            }
        }
    )

def try_auth_with_track_attempts(request,auth_callback):
    ip_address = utils.get_ip(request)
    username = None

    try: username, *_ = get_parsed_values(request, 'username')
    except Exception: raise Exception("invalid params")

    auth_failure_key = f"LOGIN_FAILURES_{ip_address}_{username}"
    auth_failures = lambda: cache.get(auth_failure_key) or 0
    error_response = lambda: {"success":False,"auth_failures":auth_failures()}
    if username is None or len(username) == 0: return error_response()
    users = User.objects.all()
    request_user = None
    try: request_user = users.get(username=username)
    except Exception: raise Exception("user not found!")
    result = None
    try: result = auth_callback(request)
    except Exception as e: print('invalid token or token expired') if isinstance(e,InvalidToken) else print('other token error')
    if result is not None:
        result_user,_ = result
        if request_user.username != result_user.username: raise Exception("user not found!")
        if auth_failures() >= int(envconfig.value('AUTH_FAIL_ATTEMPTS')):
            raise Exception("auth lockout: previous failed attempts not reset!")
        cache.set(auth_failure_key, 0)
        return {"success":True,"auth_failures":auth_failures()}
    else:
        cache.set(auth_failure_key, auth_failures() + 1)
        if auth_failures() >= int(envconfig.value('AUTH_FAIL_ATTEMPTS')): raise Exception("auth lockout: too many failed attempts!")
        return error_response()

def get_parsed_values(request, *params):
    if match_content_type(request.content_type, "application/json"):
        # mobile clients use json encoders
        obj = json_bytes_to_dict(request.body)
        return tuple(obj[param] for param in params)
    else:
        post_param = lambda param: request.POST.get(param)
        return tuple(post_param(param) for param in params)

def json_bytes_to_dict(bytes):
    SIZE_LIMIT = 500
    try:
        bytes_stream = BytesIO(bytes)
        if len(bytes) > SIZE_LIMIT: return None
        if not bytes.isascii(): return None
        return json.load(bytes_stream)

    except: return None

def match_content_type(src_content_type, target_content_type):
    if src_content_type is None or len(src_content_type) < 1: return False
    return src_content_type.lower() == target_content_type.lower()

def make_result(message,success,code):
    print(message)
    return JsonResponse({"success": success, "detail": message}, status=code)