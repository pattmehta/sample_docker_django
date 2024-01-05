from django.core.management.base import BaseCommand
from dotenv import set_key, unset_key
# from envconfig import envconfig


HOST_ARG = "cloud-public-host" # could be called anything
ENV_PATH = "env/.env"
ENV_HOST = "CLOUD_PUBLIC_HOST"

class Command(BaseCommand):
    verbosity = 0

    def add_arguments(self, parser):
        parser.add_argument(HOST_ARG, type=str)

    def handle(self, *args, **options):
        self.verbosity = options.get('verbosity')
        host = options.get(HOST_ARG)
        if len(host) > 0: self.update_env(host)

    def update_env(self, host):
        '''
        update env before envconfig is loaded
        '''
        try:
            unset_key(ENV_PATH, ENV_HOST, quote_mode="never")
            set_key(ENV_PATH, ENV_HOST, host, quote_mode="never")
        except: pass