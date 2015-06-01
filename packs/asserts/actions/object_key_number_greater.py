import sys

from st2actions.runners.pythonrunner import Action

__all__ = [
    'AssertObjectKeyNumberGreater'
]


class AssertObjectKeyNumberGreater(Action):
    def run(self, object, key, value):
        if not isinstance(object, dict):
            raise ValueError('object shoud be of type "dict".')
        if key not in object:
            sys.stderr.write('KEY %s DOESN\'T EXIST.' % key)
            raise ValueError('Key %s doesn\'t exist in object %s' % (key, object))
        result = (object[key] > value)
        if result:
            sys.stdout.write('GREATER')
        else:
            sys.stdout.write('LESSER')
        return result
