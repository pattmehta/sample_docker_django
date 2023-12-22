import os
import shutil
from secrets import token_urlsafe


src_dir = 'env'
dest_dir = 'dst'
if os.path.exists(dest_dir): shutil.rmtree(dest_dir)
files = os.listdir('env')
moved = shutil.copytree(src_dir, dest_dir)
if moved is None: exit(1) # error with copy/move


def build_env_keys(envfilename):
    '''
    -   host has a set of keys for dev only
        this stage simply copies keys and resets them with temp values
        to be overwritten later

    -   dockerignore ensures nothing from env is copied to the image

    -   so this stage ensures to make a new env directory (using a new name)
        which is later on renamed to `env` by dockerfile build-stage
    '''
    values = []
    with open(envfilename,'r') as envfile:  
        for line in envfile.readlines():    
            k,v = line.strip().split('=')   
            values.append((k,v))

    os.remove(envfilename)

    with open(envfilename,'a') as envfile:  
        for pair in values:
            k,v = pair
            if k.lower().find('key') != -1: 
                v = f"'{token_urlsafe(48)}'"
            envfile.write(f"{k}={v}\n")

build_env_keys(f'{dest_dir}/.env.secret')