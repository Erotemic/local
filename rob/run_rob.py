#!/bin/bash/python
import sys
import platform

import rob_helpers
import rob_settings
#from rob_helpers   import *
from rob_interface import *

class ROB:
    def __init__(r):
        r.computer_name = platform.node()
        r.d = rob_settings.ROB_Directories();
        r.f = rob_settings.ROB_Files(r.d);
        # Populate Envirornment Variables
        r.env_vars_list   = rob_settings.get_ENVVARS(r)
        r.path_vars_list  = rob_settings.get_PATH(r)

def is_string_int(string):
    print "CHECKING "+string
    try: 
        int(string.strip())
    except ValueError:
        return False
    return True
def process_args(r, argv):
    if len(argv) > 0:
        cmd_name = argv[0]
        if len(argv) == 1:
            if cmd_name == 'help':
                cmd_name = 'info'
            cmd = cmd_name+'(r)'
        else:
            args = argv[1:]
            if cmd_name == 'write_research':
                print "WRITING RESEARCH"
                arg_str = ',"' + (' '.join(args)).replace('"','').replace('\'','')+'"'
                print arg_str
            elif cmd_name == 'speak':
                rate_of_speach = -5
                if is_string_int(args[-1]):
                    rate_of_speach = int(args[-1])
                    args[-1] = ''

                arg_str = ","+ens(' '.join(args),'"')+","+str(rate_of_speach)
                #arg_str = arg_str + ', -5'
            else:
                arg_str = ''
                for a in args:
                    arg_str = arg_str + ', \''+a+'\''
                #arg_str = ','.join(args)
            cmd = 'print '+cmd_name+'(r'+arg_str+' )'
        print 'R.O.B. is executing: \n    '+cmd
        print "__________________________________"
        exec(cmd)

def main():
    r = ROB()
    if len(sys.argv) > 1:
        ARG_SEP = ';'
        #Arguemnts are broken up with semicolons
        semi_pos = [i for i,a in enumerate(sys.argv) if a==ARG_SEP]+[-1]
        pre = 1
        for post in semi_pos:
            if post == -1:
                process_args(r, sys.argv[pre:])
            else:
                process_args(r, sys.argv[pre:post])
    return r


if __name__ == '__main__':
    ascii_rob_small = """


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
__________________________________"""

    import signal
    import sys
    def signal_handler(signal, frame):
            print 'Rob caught Ctrl+C'
            sys.exit(0)
    signal.signal(signal.SIGINT, signal_handler)


    print ascii_rob_small
    r = main()
    print '\n\nR.O.B. signing off'
    print "================"



