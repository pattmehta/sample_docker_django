from django_sample_generator import generator
from .models import History, UserHistory, Image

class HistoryGenerator(generator.ModelGenerator):
    class Meta:
        model = History

class UserHistoryGenerator(generator.ModelGenerator):
    class Meta:
        model = UserHistory

class ImageGenerator(generator.ModelGenerator):
    class Meta:
        model = Image

generators = [
    HistoryGenerator(100),
    UserHistoryGenerator(100),
    ImageGenerator(5)
]