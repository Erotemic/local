#!/usr/bin/env python
# PYTHON_ARGCOMPLETE_OK
# -*- coding: utf-8 -*-
import sys
import platform
import signal
from rob import rob_settings
from rob import rob_interface
# from rob_helpers import ens
# from rob_interface import *  # NOQA


class ROB(object):
    def __init__(r):
        r.computer_name = platform.node()
        r.d = rob_settings.ROB_Directories()
        r.f = rob_settings.ROB_Files(r.d)
        # Populate Envirornment Variables
        r.env_vars_list = rob_settings.get_ENVVARS(r)
        r.path_vars_list = rob_settings.get_PATH(r)


def process_args(r, argv):
    args = tuple()
    if len(argv) > 0:
        cmd_name = argv[0]
        if len(argv) == 1:
            if cmd_name == 'help':
                cmd_name = 'info'
            # cmd = cmd_name + '(r)'
        else:
            args = argv[1:]

        class dummy_r(object):
            def __repr__(self):
                return 'r'

        func = getattr(rob_interface, cmd_name)
        print('R.O.B. is evaling: ')
        print('    {!r}'.format(func))
        print('__________________________________')
        print()

        ret = func(r, *args)
        # py_command = 'rob_interface.' + cmd
        # print('py_command = %r' % (py_command,))
        # ret = eval(py_command)
        if ret is not None:
            print(ret)


def invoke():
    r = ROB()
    print('Run main: %r: ' % (sys.argv,))
    if len(sys.argv) > 1:
        ARG_SEP = ';'
        ARG_SEP = '--'
        # Arguemnts are broken up with semicolons
        semi_pos = [i for i, a in enumerate(sys.argv) if a == ARG_SEP] + [-1]
        pre = 1
        for post in semi_pos:
            if post == -1:
                process_args(r, sys.argv[pre:])
            else:
                process_args(r, sys.argv[pre:post])
            # ONLY DO ONE COMMAND
            break
    return r


def main():
    import textwrap
    ascii_rob_small = textwrap.dedent(r'''

    __________________________________

                         __________
                       |== ======|+
                       ||  ;|  ;||/
                        =========/
                            ||$
                          Z<$$$$$,
                       MMMMMMMNMO~R
                    MMM  MMMMMMMMM~R
                  MMM         |:| MM
                MMMMF     /MMMMMMMM9
                NMM   /MMMMMR |:|  8
                      MMMMM   |:|  9
                              |:| 6
                          /MMMMMMMM
                      MMMMMMMMMMMMMMM
                     MMMM.MMM. .M.MMMM
                    MMMMMMM.M..MMMMMMM
                        MMMMMMMMMMMM

    ____  ____  ___      _ ____    ____ _  _ _    _ _  _ ____
    |__/  |  |  |__]     | [__     |  | |\ | |    | |\ | |___
    |  \. |__| .|__] .   | ___]    |__| | \| |___ | | \| |___
    __________________________________''').strip('\n')

    def signal_handler(signal, frame):
        print('Rob caught Ctrl+C')
        sys.exit(0)
    signal.signal(signal.SIGINT, signal_handler)

    print(ascii_rob_small)
    r = invoke()
    print('\n\nR.O.B. signing off')
    print("================")
    return r


if __name__ == '__main__':
    main()
