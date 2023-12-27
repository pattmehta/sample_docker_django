from django.conf import settings
from django.core.management.base import BaseCommand
from django.utils.module_loading import import_string


class Command(BaseCommand):
    verbosity = 0

    def add_arguments(self, parser):
        parser.add_argument("script", type=str)

    def handle(self, *args, **options):
        self.verbosity = options.get('verbosity')
        self.script = options.get('script')
        if len(self.script) < 3 or self.script is None: exit(1)
        self.script = self.script.replace('/','.').rstrip('.')
        try:
            init_db = import_string(self.script + '.init_db.init_db')
            init_db()
        except Exception as e:
            print('could not build db!')
            print('exception:',e)
            exit(1)