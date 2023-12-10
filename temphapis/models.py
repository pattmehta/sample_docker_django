from django.db import models
from django.contrib.auth.models import User

class History(models.Model):
    item = models.CharField(max_length=100)

class UserHistory(models.Model):
    user = models.ForeignKey(User,on_delete=models.CASCADE)
    item = models.CharField(max_length=100)
