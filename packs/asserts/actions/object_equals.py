import pprint
import sys

from st2actions.runners.pythonrunner import Action

__all__ = [
    'AssertObjectEquals'
]


class AssertObjectEquals(Action):
    def run(self, object, expected):
        ret = cmp(object, expected)

        if ret == 0:
            sys.stdout.write('EQUAL.')
        else:
            pprint.pprint('Input: \n%s' % object, stream=sys.stderr)
            pprint.pprint('Expected: \n%s' % expected, stream=sys.stderr)
            raise ValueError('Objects not equal. Input: %s, Expected: %s.' % (object, expected))
