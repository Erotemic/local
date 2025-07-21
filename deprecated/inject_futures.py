import sys
from os.path import *
sys.path.append(expanduser('~/local/rob'))
import rob_nav

tofind_list = ['__future__']

future_line = 'from __future__ import absolute_import, division, print_function\n'

FORCE = False
if len(sys.argv) == 2:
    FORCE = sys.argv[1] == 'True'

found_fpaths = rob_nav._grep(None, tofind_list, recursive=True, invert=True)

for fpath in found_fpaths:
    print('inject futures fpath=%r' % fpath)
    output_lines = []
    # Read basic input
    with open(fpath, 'r') as file_:
        input_lines = file_.readlines()
    output_lines = [future_line] + input_lines
    output_text = ''.join(output_lines)
    # Write injected output
    if FORCE:
        with open(fpath, 'w') as file_:
            file_.write(output_text)
