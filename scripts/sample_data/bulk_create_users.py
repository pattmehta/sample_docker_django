'''
for manual run in django shell:
- python manage.py shell --settings=temph.settings_base
- > from temphapis.bulk_create_users import bulk_create_users
- > bulk_create_users()
'''


from django.contrib.auth.hashers import make_password
from subprocess import run


py = None
def find_python_with_manage_cmd(cmd, settings_module):
    completed_process = None
    progs = ['python','python3']
    global py
    if py is None:
        for prog in progs:
            try: completed_process = run(f'which {prog}', shell=True, capture_output=True)
            except Exception: pass
            if completed_process is not None and completed_process.returncode == 0:
                print(f'executing command with {prog}')
                py = prog
                break

    completed_process = None
    try: completed_process = run(f'{py} -m {cmd} --settings={settings_module}', shell=True, capture_output=True)
    except Exception: pass
    return True if completed_process is not None and completed_process.returncode == 0 else False

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


if __name__ == '__main__':
    import os
    import sys
    import django

    django_setup = False
    try:
        settings_module = sys.argv[1]
        os.environ.setdefault('DJANGO_SETTINGS_MODULE', f'{settings_module}')
        django.setup()
        django_setup = True
    except Exception: pass
    if not django_setup:
        print('empty or invalid settings_module')
        exit(1)
    from django.contrib.auth.models import User

    if find_python_with_manage_cmd('manage.py makemigrations', settings_module):
        if find_python_with_manage_cmd('manage.py migrate', settings_module):
            users_created = bulk_create_users()
            if users_created and find_python_with_manage_cmd('manage.py create_sample_data', settings_module):
                print('db setup with success!')
                exit(0)
            else:
                print('could not setup db')
                exit(1)