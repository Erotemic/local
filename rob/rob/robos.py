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


# def get_clipboard():
#     """
#     References:
#         http://stackoverflow.com/questions/11063458/python-script-to-copy-text-to-clipboard
#     """
#     import pyperclip
#     _ensure_clipboard_backend()
#     text = pyperclip.paste()
#     # from Tkinter import Tk
#     # tk_inst = Tk()
#     # tk_inst.withdraw()
#     # text = tk_inst.clipboard_get()
#     # tk_inst.destroy()
#     return text
