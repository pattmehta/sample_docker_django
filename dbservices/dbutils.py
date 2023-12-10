import time
from temphapis.models import History, UserHistory

class DbUtils:
    
    def __init__(self,k):
        DbUtils.k = k

    @staticmethod
    def sleep(): time.sleep(DbUtils.k)

    def get_history(self,count):
        objects = History.objects.all()[:count]
        for i in range(count):
            yield f"item-{i+1}: {objects[i].item}"
            DbUtils.sleep()

    def get_user_history(self,request_user,count):
        objects = UserHistory.objects.all()
        user_objects = objects.filter(user=request_user)[:count]
        for i in range(count):
            yield f"item-{i+1}: {user_objects[i].item}"
            DbUtils.sleep()

dbutils = DbUtils(2)