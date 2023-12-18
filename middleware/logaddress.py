from django.http import Http404, HttpResponse
from middleware.utils import utils

class LogAddressMiddleware:
    
    def __init__(self, get_response):
        self.get_response = get_response # one-time config and init

    def __call__(self, request):
        # executed before the view (and later middleware) are called
        ip = utils.get_ip(request)
        print('request from ip',ip)
        response = self.get_response(request)
        # executed after the view is called
        return response

    def process_exception(self, request, exception):
        if isinstance(exception, Http404): return HttpResponse(str(exception), status=404)