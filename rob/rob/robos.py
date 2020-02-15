# raise Exception('dont use me')
import sys

if sys.platform == 'win32':
    print('importing windows')
    try:
        from rob.rob_helpers_windows import *
    except ImportError as ex:
        print(ex)
else:
    print('importing linux')
    from rob.rob_linux_helpers import *
