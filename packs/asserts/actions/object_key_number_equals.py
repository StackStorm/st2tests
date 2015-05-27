import sys

from st2actions.runners.pythonrunner import Action

__all__ = [
    'AssertObjectKeyIntEquals'
]


class AssertObjectKeyIntEquals(Action):
    def run(self, object, key, value):
        if not isinstance(object, dict):
            raise ValueError('object shoud be of type "dict".')
        if key not in object:
            sys.stderr.write('KEY %s DOESN\'T EXIST.' % key)
            return False
        result = (object[key] == value)
        if result:
            sys.stdout.write('EQUAL')
        else:
            sys.stdout.write('NOT EQUAL')
        return result
