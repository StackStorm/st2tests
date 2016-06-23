import pprint
import sys

from st2actions.runners.pythonrunner import Action

__all__ = [
    'AssertObjectContains'
]


class AssertObjectContains(Action):
    def run(self, object, expected):
        for obj in expected:
            input_obj = object[obj]
            expected_obj = expected[obj]
            for item in expected_obj:
                if not item in input_obj:
                    pprint.pprint('Key not found: %s' % item, stream=sys.stderr)
                    raise ValueError('Objects not equal. Input: %s, Expected: %s.' % (object, expected))
                else:
                    if expected_obj[item] != input_obj[item]:
                        pprint.pprint('Input: \n%s:%s' % (item, input_obj[item]), stream=sys.stderr)
                        pprint.pprint('Expected: \n%s:%s' % (item, expected_obj[item]), stream=sys.stderr)
                        raise ValueError('Objects not equal. Input: %s, Expected: %s.' % (object, expected))
                    
        sys.stdout.write('EQUAL.')

