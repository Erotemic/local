# raise Exception('dont use me')
import sys

if sys.platform == 'win32':
    print('importing windows')
    try:
        from rob.rob_helpers_win32s import *
    except ImportError as ex:
        print(ex)
else:
    print('importing linux')
    from rob.rob_helpers_linux import *
