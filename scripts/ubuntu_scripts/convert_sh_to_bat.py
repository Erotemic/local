#!/usr/env python
import sys

fpath = sys.argv[1]
with open(fpath, 'r') as file_:
    lines = file_.read()
    for line_in in lines.split('\n'):
        line_out = line_out.replace('export', 'set')
