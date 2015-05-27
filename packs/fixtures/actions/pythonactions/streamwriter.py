import sys

from st2actions.runners.pythonrunner import Action

__all__ = [
    'StreamWriter'
]


class StreamWriter(Action):

    def run(self, stream):
        if stream.upper() == 'STDOUT':
            sys.stdout.write('STREAM IS STDOUT.')
            return stream

        if stream.upper() == 'STDERR':
            sys.stderr.write('STREAM IS STDERR.')
            return stream

        raise ValueError('Invalid stream specified.')
