" Functions that interact with an IPython terminal

func! CopyGVimToTerminalDev(...) range
    " Interactive scripting function. Takes part of the file you are editing
    " and pastes it into a terminal and then returns the editor to focus.
Python2or3 << EOF
import vim
#vim.command(':echom %r' % ('dbmsg: ' + dbgmsg,))
import pyvim_funcs, imp; imp.reload(pyvim_funcs)
import utool.util_ubuntu
import utool as ut
ut.rrrr(0)
ut.util_ubuntu.rrr(0)

# Hack to determine mode
mode = vim.eval('a:1')
return_to_vim = vim.eval('a:2')

def dprint(msg):
    if False:
        print(msg)
    if True:
        from os.path import expanduser
        with open(expanduser('~/vim-misc-debug.txt'), 'a') as f:
            f.write(msg + '\n')

dprint('\n----\nCopyGVimToTerminalDev')
dprint('mode = %r' % (mode,))
dprint('return_to_vim = %r' % (return_to_vim,))

if mode == 'clipboard':
    dprint('Text is already in clipboard')
    # Using pyperclip seems to freeze.
    # Good thing we can access the system clipboard via vim
    # text = ut.get_clipboard()
    text = vim.eval('@+')
    dprint('got text')
    dprint('text = %r' % (text,))
else:
    if mode == 'word':
        text = pyvim_funcs.get_word_at_cursor()
    else:
        if 'v' in mode.lower():
            dprint('grabbing selected text')
            text = pyvim_funcs.get_selected_text()
        else:
            dprint('grabbing text at current line')
            text = pyvim_funcs.get_line_at_cursor()
    # Prepare to send text to xdotool
    dprint('preparing text')
    text = ut.unindent(text)
    dprint('copying text to clipboard')
    ut.copy_text_to_clipboard(text)
    dprint('copied text to clipboard')

# Build xdtool script
doscript = [
    ('remember_window_id', 'ACTIVE_GVIM'),
    ('focus', 'x-terminal-emulator.X-terminal-emulator'),
    ('key', 'ctrl+shift+v'),
    ('key', 'KP_Enter'),
]
if '\n' in text:
    # Press enter twice for multiline texts
    doscript += [
        ('key', 'KP_Enter'),
    ]
if return_to_vim == "1":
    doscript += [
        ('focus_id', '$ACTIVE_GVIM'),
    ]
# execute script
dprint('Running script')
ut.util_ubuntu.XCtrl.do(*doscript, sleeptime=.01)
dprint('Finished script')
#L______________
EOF
endfu 


func! IPythonImportAll()
    " Imports global variables from current module into IPython session
Python2or3 << EOF
import vim
import pyvim_funcs, imp; imp.reload(pyvim_funcs)
import utool as ut
import utool.util_ubuntu
from os.path import dirname
ut.rrrr(verbose=False)

return_to_vim = True

if pyvim_funcs.is_module_pythonfile():
    modpath = vim.current.buffer.name
    modname = ut.get_modname_from_modpath(modpath)
    lines = []
    if not ut.check_module_installed(modname):
        lines.append('import sys')
        lines.append('sys.path.append(%r)' % (dirname(modpath),))
    lines.append("from {} import *".format(modname))
    # Add private and protected functions
    try:
        sourcecode = ut.readfrom(modpath, verbose=False)
        func_names = ut.parse_function_names(sourcecode)
        private_funcs = [name for name in func_names if name.startswith('_')]
        if len(private_funcs) > 0:
            lines.append("from {} import {}".format(
                modname, ', '.join(private_funcs)))
    except Exception as ex:
        ut.printex(ex, 'ast parsing failed', tb=True)
        print('ast parsing failed')
    # Prepare to send text to xdotool
    text = ut.unindent('\n'.join(lines))
    ut.copy_text_to_clipboard(text)
    # Build xdtool script
    doscript = [
        ('remember_window_id', 'ACTIVE_GVIM'),
        ('focus', 'x-terminal-emulator.X-terminal-emulator'),
        ('key', 'ctrl+shift+v'),
        ('key', 'KP_Enter'),
    ]
    if '\n' in text:
        # Press enter twice for multiline texts
        doscript += [
            ('key', 'KP_Enter'),
        ]
    if return_to_vim:
        doscript += [
            ('focus_id', '$ACTIVE_GVIM'),
        ]
    ut.util_ubuntu.XCtrl.do(*doscript, sleeptime=.01)
else:
    print('current file is not a pythonfile')
#L______________
EOF
endfu 


func! IPyFixEmbedGlobals(...) range
Python2or3 << EOF
import vim
import pyvim_funcs, imp; imp.reload(pyvim_funcs)
import utool.util_ubuntu
import utool as ut
ut.rrrr(0)
ut.util_ubuntu.rrr(0)
ut.copy_text_to_clipboard('ut.fix_embed_globals()')
doscript = [
    ('remember_window_id', 'ACTIVE_GVIM'),
    ('focus', 'x-terminal-emulator.X-terminal-emulator'),
    ('key', 'ctrl+shift+v'),
    ('key', 'KP_Enter'),
    ('focus_id', '$ACTIVE_GVIM'),
]
ut.util_ubuntu.XCtrl.do(*doscript, sleeptime=.01)
#L______________
EOF
endfu 


func! FocusTerm(...) range
Python2or3 << EOF
import vim
#vim.command(':echom %r' % ('dbmsg: ' + dbgmsg,))
import pyvim_funcs, imp; imp.reload(pyvim_funcs)
import utool.util_ubuntu
import utool as ut
ut.util_ubuntu.XCtrl.do(('focus', 'x-terminal-emulator.X-terminal-emulator'))
EOF
endfu


