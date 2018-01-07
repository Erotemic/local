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

argv = pyvim_funcs.vim_argv(defaults=['clipboard', '1'])
mode = argv[0]
return_to_vim = argv[1] != '0'

DEBUG_STDOUT = False
DEBUG_FILE = False
DEBUG = DEBUG_FILE or DEBUG_STDOUT

def dprint(msg):
    if DEBUG_STDOUT or DEBUG_FILE:
        import time
        stamp = str(time.time())
        msg = stamp + ' ' + msg

    if DEBUG_STDOUT:
        print(msg)

    if DEBUG_FILE:
        file.write(msg + '\n')

def _context_func(file=None):
    dprint('\n----\nCopyGVimToTerminalDev')
    dprint('mode = %r' % (mode,))
    dprint('return_to_vim = %r' % (return_to_vim,))

    if mode == 'clipboard':
        dprint('Text is already in clipboard')
        # Using pyperclip seems to freeze.
        # text = ut.get_clipboard()
        # Access clipboard via vim instead
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
        text = ut.unindent(text)
        #dprint('copying text to clipboard')
        #ut.copy_text_to_clipboard(text)
        #dprint('copied text to clipboard')

    # Strip docstring prefix
    dprint('preparing text')
    lines = text.splitlines(True)
    if all(line.startswith(('>>> ', '...')) for line in lines):
        lines = [line[4:] for line in lines]
        text = ''.join(lines)
    text = ut.unindent(text)

    pyvim_funcs.enter_text_in_terminal(text, return_to_vim=return_to_vim)

    # # Build xdtool script
    # import re
    # # Make sure regexes are bash escaped
    # terminal_pattern = r'\|'.join([
    #     'terminal',
    #     re.escape('terminator.Terminator'),  # gtk3 terminator
    #     re.escape('x-terminal-emulator.X-terminal-emulator'),  # gtk2 terminator
    # ])

    # doscript = [
    #     ('remember_window_id', 'ACTIVE_GVIM'),
    #     #('focus', 'x-terminal-emulator.X-terminal-emulator'),
    #     ('focus', terminal_pattern),
    #     ('key', 'ctrl+shift+v'),
    #     ('key', 'KP_Enter'),
    # ]
    # if '\n' in text:
    #     # Press enter twice for multiline texts
    #     doscript += [
    #         ('key', 'KP_Enter'),
    #     ]
    # if return_to_vim == "1":
    #     doscript += [
    #         ('focus_id', '$ACTIVE_GVIM'),
    #     ]
    # # execute script
    # dprint('Running script')
    # ut.util_ubuntu.XCtrl.do(*doscript, sleeptime=.01, file=file, verbose=DEBUG)
    # dprint('Finished script')

if DEBUG_STDOUT:
    from os.path import expanduser
    with open(expanduser('~/vim-misc-debug.txt'), 'a') as file:
        _context_func(file)
else:
    _context_func()
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
from os.path import basename, splitext
ut.rrrr(verbose=False)

return_to_vim = True

if pyvim_funcs.is_module_pythonfile():
    modpath = vim.current.buffer.name
    modname = ut.get_modname_from_modpath(modpath)
    lines = []

    try:
        needs_path = not ut.check_module_installed(modname)
    except Exception:
        needs_path = True

    if needs_path:
        from xdoctest import static_analysis
        basepath = static_analysis.split_modpath(modpath)[0]

        #mod_subdirs = ut.get_module_subdir_list(modpath)
        #basepath = modpath
        #for _ in range(len(mod_subdirs)):
        #    basepath = dirname(basepath)
        lines.append('import sys')
        #lines.append('sys.path.append(%r)' % (dirname(modpath),))
        lines.append('sys.path.append(%r)' % (basepath,))

    lines.append("from {} import *".format(modname))
    # Add private and protected functions
    try:
        sourcecode = ut.readfrom(modpath, verbose=False)
        # TODO get classes and whatnot
        func_names = ut.parse_function_names(sourcecode)
        #print('func_names = {!r}'.format(func_names))
        if '__all__' in sourcecode:
            import_names, modules = ut.parse_import_names(sourcecode, branch=False)
            #extra_names = func_names + import_names
            #import_names, modules = ut.parse_import_names(sourcecode, ignore_if=True)
            extra_names = list(func_names) + list(import_names)
        else:
            extra_names = [name for name in func_names if name.startswith('_')]
        if len(extra_names) > 0:
            lines.append("from {} import {}".format(
                modname, ', '.join(extra_names)))
    except Exception as ex:
        #print(repr(ex))
        import traceback
        tbtext = traceback.format_exc()
        print(tbtext)
        print(repr(ex))
        #ut.printex(ex, 'ast parsing failed', tb=True, colored=False)
        #print('ast parsing failed')
        raise
    # Prepare to send text to xdotool
    text = ut.unindent('\n'.join(lines))
    pyvim_funcs.enter_text_in_terminal(text, return_to_vim=True)
    # ut.copy_text_to_clipboard(text)
    # # Build xdtool script
    # doscript = [
    #     ('remember_window_id', 'ACTIVE_GVIM'),
    #     ('focus', 'x-terminal-emulator.X-terminal-emulator'),
    #     ('key', 'ctrl+shift+v'),
    #     ('key', 'KP_Enter'),
    # ]
    # if '\n' in text:
    #     # Press enter twice for multiline texts
    #     doscript += [
    #         ('key', 'KP_Enter'),
    #     ]
    # if return_to_vim:
    #     doscript += [
    #         ('focus_id', '$ACTIVE_GVIM'),
    #     ]
    # ut.util_ubuntu.XCtrl.do(*doscript, sleeptime=.01)
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
pyvim_funcs.enter_text_in_terminal('ut.fix_embed_globals()')
#ut.copy_text_to_clipboard('ut.fix_embed_globals()')
#doscript = [
#    ('remember_window_id', 'ACTIVE_GVIM'),
#    ('focus', 'x-terminal-emulator.X-terminal-emulator'),
#    ('key', 'ctrl+shift+v'),
#    ('key', 'KP_Enter'),
#    ('focus_id', '$ACTIVE_GVIM'),
#]
#ut.util_ubuntu.XCtrl.do(*doscript, sleeptime=.01)
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
terminal_pattern = pyvim_funcs.wmctrl_terminal_pattern()
ut.util_ubuntu.XCtrl.do(('focus', terminal_pattern))
EOF
endfu
