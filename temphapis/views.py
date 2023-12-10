from rest_framework.decorators import api_view
from django.http.request import HttpRequest
from django.http.response import HttpResponse, JsonResponse
from django.http import StreamingHttpResponse
from dbservices.dbutils import dbutils
# Following import is default due to `DEFAULT_THROTTLE_CLASSES`
# from rest_framework.decorators import throttle_classes
# from rest_framework.throttling import AnonRateThrottle, UserRateThrottle
from rest_framework_simplejwt.tokens import RefreshToken

from django.contrib.auth.models import User

from rest_framework_simplejwt.authentication import JWTAuthentication
from functools import wraps

def token_required(func):
    @wraps(func)
    def inner(request, *args, **kwargs):
        invalid_response = HttpResponse("could not auth\n", status=401)
        try:
            auth = JWTAuthentication().authenticate(request)
            if auth is not None:
                return func(request, *args, **kwargs)
            else:
                return invalid_response
        except Exception:
            return invalid_response
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
    username = request.POST.get('username')
    password = request.POST.get('password')
    if username is None and password is None:
        return HttpResponse("invalid parameters\n")
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
