from django.urls import path
from . import views
from django.conf import settings
from django.conf.urls.static import static

urlpatterns = [
    path("", views.index),
    path("health/", views.health),
    path("token/", views.token),
    path("history/", views.history),
    path("user_history/", views.user_history),
    path("reset_lockout/", views.reset_lockout, name='reset-lockout'),
    path("upload_image/", views.upload_image)
] + static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)

# on localhost uploaded image is at:
# http://127.0.0.1:8095/api/media/images/user_third_img.png
