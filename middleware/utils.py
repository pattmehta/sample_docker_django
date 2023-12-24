from django.http.request import HttpRequest

class Utils:
    @staticmethod
    def get_ip(request: HttpRequest):
        x_forwarded_for = request.META.get('HTTP_X_FORWARDED_FOR')
        ip = x_forwarded_for.split(',')[0] if x_forwarded_for else request.META.get('REMOTE_ADDR')
        return ip

utils = Utils()