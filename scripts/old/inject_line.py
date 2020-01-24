#!/usr/bin/env python
from __future__ import division, print_function
import sys
import re

SEARCH_MODE = 'PLAIN'

if __name__ == '__main__':
    if sys.argv[0] == __file__:
        offset = 0
    else:
        offset = 1
    pattern = sys.argv[1 + offset]
    insert  = sys.argv[2 + offset]
    fname   = sys.argv[3 + offset]

    print('--- injecting ---')
    print('pattern = %r' % pattern)
    print('insert = %r' % insert)

    def matches_pattern(line, pattern):
        if pattern is None:
            return False
        if SEARCH_MODE == 'REGEX':
            return  re.search(line, pattern)
        elif SEARCH_MODE == 'PLAIN':
            return line.find(pattern) != -1

    output_lines = []
    # Read lines
    with open(fname, 'r') as file_:
        line_list = file_.readlines()
    # Parse lines
    for line in line_list:
        output_lines.append(line)
        if matches_pattern(line, pattern):
            output_lines.append(insert + '\n')
            pattern = None

    output_text = ''.join(output_lines)
    print('done')
    print(output_text)
    with open(fname, 'w') as file_:
        file_.write(output_text)
