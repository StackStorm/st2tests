#!/usr/bin/env python

import argparse
import sys
import ast
import re

from lib.exceptions import CustomException


class StreamWriter(object):

    def run(self, stream):
        if stream.upper() == 'STDOUT':
            sys.stdout.write('STREAM IS STDOUT.')
            return stream

        if stream.upper() == 'STDERR':
            sys.stderr.write('STREAM IS STDERR.')
            return stream

        raise CustomException('Invalid stream specified.')


def main(args):
    stream = args.stream
    writer = StreamWriter()
    stream = writer.run(stream)

    str_arg = args.str_arg
    int_arg = args.int_arg
    obj_arg = args.obj_arg

    if str_arg:
        sys.stdout.write(' STR: %s' % str_arg)
    if int_arg:
        sys.stdout.write(' INT: %d' % int_arg)

    if obj_arg:
        # Remove any u'' so it works consistently under Python 2 and 3.x
        obj_arg_str = str(obj_arg)
        value = re.sub("u'(.*?)'", r"'\1'", obj_arg_str)
        sys.stdout.write(' OBJ: %s' % value)


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='')
    parser.add_argument('--stream', help='Stream.', required=True)
    parser.add_argument('--str_arg', help='Some string arg.')
    parser.add_argument('--int_arg', help='Some int arg.', type=float)
    parser.add_argument('--obj_arg', help='Some dict arg.', type=ast.literal_eval)
    args = parser.parse_args()
    main(args)
