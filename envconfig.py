import os
from dotenv import dotenv_values

class EnvConfig:

    def __init__(self):
        self._config = {
            **dotenv_values("env/.env"),  # load shared development variables
            **EnvConfig.get_secret_pairs("env/.env.secret"),  # load sensitive variables
            **os.environ,  # override loaded values with environment variables
        }
        self._keys = list(self._config.keys())

    @staticmethod
    def get_secret_pairs(filename):
        return dotenv_values(filename) if os.path.exists(filename) else {'DBUSER':'app_user','DBPASS':'app_password','SECRET_KEY':'longstring','JWT_SIGNING_KEY':'longstring'}

    def keys(self,count = 0):
        self._keys = list(self._config.keys())
        if count == 0: return self._keys
        else: return self._keys[:count]

    def value(self,key = 'HOME'):
        if not key in self.keys(): return None
        return self._config[key]

envconfig = EnvConfig()