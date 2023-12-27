from django.db import models
from django.contrib.auth.models import User

class History(models.Model):
    item = models.CharField(max_length=100)

class UserHistory(models.Model):
    user = models.ForeignKey(User,on_delete=models.CASCADE)
    item = models.CharField(max_length=100)

class Image(models.Model):
    # OneToOneField causes error with django_sample_generator so
    # ForeignKey with `unique=True` is used instead
    user = models.ForeignKey(User, unique=True, on_delete=models.CASCADE)
    thumbnail = models.SlugField(null=True, blank=True, max_length=100)
