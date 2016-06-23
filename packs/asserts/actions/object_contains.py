import pprint
import sys

from st2actions.runners.pythonrunner import Action

__all__ = [
    'AssertObjectContains'
]


class AssertObjectContains(Action):
    def run(self, object, expected):
        for item in expected:
            if hasattr(object, item):
                if not expected[item] == object[item]:
                    pprint.pprint('Input: \n%s:%s' % (item, object[item]), stream=sys.stderr)
                    pprint.pprint('Expected: \n%s:%s' % (item, expected[item]), stream=sys.stderr)
                    raise ValueError('Objects not equal. Input: %s, Expected: %s.' % (object, expected))
                else:
                    sys.stdout.write('EQUAL.')

