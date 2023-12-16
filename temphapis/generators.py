from django_sample_generator import generator
from .models import History, UserHistory

class HistoryGenerator(generator.ModelGenerator):
    class Meta:
        model = History

class UserHistoryGenerator(generator.ModelGenerator):
    class Meta:
        model = UserHistory

generators = [
    HistoryGenerator(10),
    UserHistoryGenerator(100)
]