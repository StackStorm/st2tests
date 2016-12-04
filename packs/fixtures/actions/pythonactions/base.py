import datetime

__all__ = [
    'DummyClass'
]

class DummyClass(object):

    def now(self):
        return datetime.datetime.utcnow()
