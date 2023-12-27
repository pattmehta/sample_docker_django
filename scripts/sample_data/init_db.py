'''
for manual run in django shell:
- python manage.py shell --settings=temph.settings_base
- > from ... import bulk_create_users
- > bulk_create_users()
'''

from django.contrib.auth.hashers import make_password
from django.contrib.auth.models import User
from subprocess import run

def bulk_create_users(fnames = ['first','second','third','fourth','fifth']):
    users = []
    for name in fnames:
        record = {'first_name':name, 'last_name':'user', 'username':f'user_{name}', 'email':f'{name}@user.com', 'password':make_password('pwd')}
        users.append(User(**record))
    
    created = False
    
    try:
        User.objects.bulk_create(users)
        print(f'created {len(users)} records in user table')
        created = True
    except Exception as e:
        print('exception in bulk_create')
        print(e)
    
    return created

def init_db():
    users_created = bulk_create_users()
    if users_created:
        print('bulk_create_users: success')
        exit(0)
    else:
        print('bulk_create_users: failure')
        exit(1)