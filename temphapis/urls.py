from django.urls import path
from . import views

urlpatterns = [
    path("", views.index),
    path("health/", views.health),
    path("token/", views.token),
    path("history/", views.history),
    path("user_history/", views.user_history),
    path("reset_lockout/", views.reset_lockout, name='reset-lockout')
]