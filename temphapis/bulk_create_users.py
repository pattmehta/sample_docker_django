'''
run method in django shell:
- python manage.py shell --settings=temph.settings_base
- > from temphapis.bulk_create_users import bulk_create_users
- > bulk_create_users()
'''

from django.contrib.auth.models import User
from django.contrib.auth.hashers import make_password
 
def bulk_create_users(fnames = ['first','second','third','fourth','fifth']):
    users = []
    for name in fnames:
        record = {'first_name':name, 'last_name':'user', 'username':f'user_{name}', 'email':f'{name}@user.com', 'password':make_password('pwd')}
        users.append(User(**record))
    try:
        User.objects.bulk_create(users)
        print(f'created {len(users)} records in User table')
    except Exception as e:
        print('Exception in bulk_create')
        print(e)
