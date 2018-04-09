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

    # Preprocess the strings a bit
    dprint('preprocesing the text')
    lines = text.splitlines(True)

    # Handle C++ pybind11 docs
    import re
    if all(re.match('" *(>>>)|(\.\.\.) .*', line) for line in lines):
        if all(line.strip().endswith('"') for line in lines):
            new_lines = []
            for line in lines:
                if line.endswith('\\n"\n'):
                    line = line[1:-4] + '\n'
                elif line.endswith('"\n'):
                    line = line[1:-2] + '\n'
                elif line.endswith('\\n"'):
                    line = line[1:-3]
                elif line.endswith('"'):
                    line = line[1:-1]
                else:
                    raise AssertionError('unknown case')
                new_lines.append(line)
            lines = new_lines
            text = ut.unindent(''.join(lines))
            text = ut.unindent(text)
            lines = text.splitlines(True)
            #[line[re.search('(>>>|\.\.\.)', line).end():-1] for line in lines]
            #if all(line.startswith('"') for line in lines):
            #pass

    # Strip docstring prefix
    if all(line.startswith(('>>> ', '...')) for line in lines):
        lines = [line[4:] for line in lines]
        text = ''.join(lines)
    text = ut.unindent(text)

    pyvim_funcs.enter_text_in_terminal(text, return_to_vim=return_to_vim)

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
from os.path import dirname, expanduser
from os.path import basename, splitext
ut.rrrr(verbose=False)

return_to_vim = True

if pyvim_funcs.is_module_pythonfile():
    from os.path import join, relpath
    modpath = vim.current.buffer.name
    modname = ut.get_modname_from_modpath(modpath)

    # HACK to add symlinks back into the paths for system uniformity
    special_symlinks = [
        ('/media/joncrall/raid/code', expanduser('~/code')),
    ]
    # Abstract via symlinks
    for real, link in special_symlinks:
        if modpath.startswith(real):
            modpath = join(link, relpath(modpath, real))

    lines = []

    import ubelt as ub
    try:
        needs_path = not ut.check_module_installed(modname)
        ub.modpath_to_modname(modname)  # hack for checking if importable
    except Exception:
        needs_path = True

    if needs_path:
        from xdoctest import static_analysis
        basepath = static_analysis.split_modpath(modpath)[0]

        user_basepath = ub.compressuser(basepath)
        if user_basepath != basepath:
            lines.append('import sys, ubelt')
            lines.append('sys.path.append(ubelt.truepath(%r))' % (user_basepath,))
        else:
            lines.append('import sys')
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
