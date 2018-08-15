" Functions that help program python code. 
" These are mostly snippet-like things, there is some navigation stuff,
" some autoformating

fu! REVERSE_DICT()
    :s/\([^{ :]*\): \([^,]*\),/\2: \1,/gc
    :s/
endfu

fu! FUNC_DICT_TO_ATTR(dictstr)
    let dictstr=a:dictstr
    ":execute '%s/'.dictstr.'[''\<\(\[A-Za-z_]*\)'']\>\([^(]\)/'.dictstr.'.\1\2/gc'
    :execute '%s/'.dictstr.'\[.\([^'."'".']*\)../'.dictstr.'.\1 /gc'
    " THIS ONE
    "%s/_cfg\[.\([^']*\)../_cfg.\1 /gc
endfu

fu! FUNC_FIX_ATTR_TO_DICT(attrstr)
    let attrstr=a:attrstr
    :execute '%s/'.attrstr.'\.\<\(\[A-Za-z_]*\)\>\([^(]\)/'.attrstr.'["\1"]\2/gc'
endfu

fu! FUNC_np_Style_Check(npcmd)
    let npcmdstr=a:npcmd
    :execute '%s/\([^.a-zA-Z]\)\(\<'.npcmdstr.'\>\)/\1np.\2/gc'
endfu

func! FIXQT_DOC()
    :s/\t/    /gc
    :s/ * Qt::\([^0-9]*\)\([0-9]\)/\2: '\1' #/gc
endfu


func! InsertDocstr() 
Python2or3 << EOF
import vim
#vim.command(':echom %r' % ('dbmsg: ' + dbgmsg,))
import pyvim_funcs; pyvim_funcs.reload(pyvim_funcs)

if pyvim_funcs.is_module_pythonfile():
    print('building docstr')
    text = pyvim_funcs.auto_docstr()
    pyvim_funcs.insert_codeblock_under_cursor(text)
else:
    print('current file is not a pythonfile')
#L______________
EOF
endfu 


func! InsertPyUtMain() 
    " Imports a python __main__ block 
Python2or3 << EOF
import vim
import pyvim_funcs; pyvim_funcs.reload(pyvim_funcs)
import ubelt as ub
#import ubelt, xdoctest; imp.reload(ubelt); imp.reload(xdoctest.static_analysis)

pyvim_funcs.ensure_normalmode()
if pyvim_funcs.is_module_pythonfile():
    modpath = vim.current.buffer.name
    #test_code = ub.codeblock(
    #    r'''
    #    import pytest
    #    pytest.main([__file__, '--xdoc'])
    #    ''')
    test_code = ub.codeblock(
        r'''
        import xdoctest
        xdoctest.doctest_module(__file__)
        ''')
    text = pyvim_funcs.make_default_module_maintest(
        modpath, test_code=test_code, argv=[])
    pyvim_funcs.insert_codeblock_under_cursor(text)
else:
    print('current file is not a pythonfile')
#L______________
EOF
endfu 


func! PyInsertHeader(...) 
    " Imports a standard python header
Python2or3 << EOF
mode = vim.eval('(a:0 >= 1) ? a:1 : 0')
import ubelt as ub
import vim
import pyvim_funcs; pyvim_funcs.reload(pyvim_funcs)
pyvim_funcs.ensure_normalmode()
if pyvim_funcs.is_module_pythonfile():
    modpath = vim.current.buffer.name
    modname = ub.modpath_to_modname(modpath)
    lines = []
    if mode == 'script':
        lines += ['#!/usr/bin/env python']
    lines += [
        '# -*- coding: utf-8 -*-',
        'from __future__ import print_function, division, absolute_import, unicode_literals',
    ]
    text = '\n'.join(lines)
    pyvim_funcs.insert_codeblock_above_cursor(text)
else:
    print('current file is not a pythonfile')
#L______________
EOF
endfu 


func! AutoPep8Block() 
Python2or3 << EOF
# FIXME: Unfinished
import vim
import pyvim_funcs; pyvim_funcs.reload(pyvim_funcs)

pyvim_funcs.ensure_normalmode()

if pyvim_funcs.is_module_pythonfile():
    print('autopep8ing file')
    text = pyvim_funcs.get_codelines_around_buffer()
    pyvim_funcs.insert_codeblock_under_cursor(text)
else:
    print('current file is not a pythonfile')
#L______________
EOF
endfu 


func! InsertKWargsDoc() 
Python2or3 << EOF
import vim
#vim.command(':echom %r' % ('dbmsg: ' + dbgmsg,))
import pyvim_funcs; pyvim_funcs.reload(pyvim_funcs)

if pyvim_funcs.is_module_pythonfile():
    print('building docstr')
    text = pyvim_funcs.auto_docstr()
    pyvim_funcs.insert_codeblock_under_cursor(text)
else:
    print('current file is not a pythonfile')
#L______________
EOF
endfu 


func! InsertDocstrOnlyArgs() 
Python2or3 << EOF
import vim
#vim.command(':echom %r' % ('dbmsg: ' + dbgmsg,))
import pyvim_funcs; pyvim_funcs.reload(pyvim_funcs)

if pyvim_funcs.is_module_pythonfile():
    print('building docstr')
    text = pyvim_funcs.auto_docstr( 
        with_args=True,
        with_ret=False,
        with_commandline=False,
        with_example=False,
        with_header=False)
    pyvim_funcs.insert_codeblock_under_cursor(text)
else:
    print('current file is not a pythonfile')
#L______________
EOF
endfu 


func! InsertDocstrOnlyCommandLine() 
Python2or3 << EOF
import vim
#vim.command(':echom %r' % ('dbmsg: ' + dbgmsg,))
import imp
import pyvim_funcs; pyvim_funcs.reload(pyvim_funcs)

if pyvim_funcs.is_module_pythonfile():
    print('building docstr')
    text = pyvim_funcs.auto_cmdline()
    #text = pyvim_funcs.auto_docstr( 
    #    with_args=False,
    #    with_ret=False,
    #    with_commandline=True,
    #    with_example=False,
    #    with_header=False)
    pyvim_funcs.insert_codeblock_under_cursor(text)
else:
    print('current file is not a pythonfile')
#L______________
EOF
endfu 


func! PyMakeEmbed() 
Python2or3 << EOF
import vim
import pyvim_funcs; pyvim_funcs.reload(pyvim_funcs)
import ubelt as ub

indent = pyvim_funcs.get_cursor_py_indent()
newtext = '\n'.join([
    indent + 'import utool',
    indent + 'utool.embed()'
])
pyvim_funcs.insert_codeblock_under_cursor(newtext)
EOF
endfunc


func! PyMakeWithEmbed(...) range
Python2or3 << EOF
import vim
import pyvim_funcs; pyvim_funcs.reload(pyvim_funcs)
import ubelt as ub

mode = vim.eval('a:1')


indent = pyvim_funcs.get_cursor_py_indent()
newtext = '\n'.join([
    indent + 'import utool',
    indent + 'with utool.embed_on_exception_context:'
    #indent + 'import ipdb',
    #indent + 'with ipdb.launch_ipdb_on_exception():'
])
if 'v' in mode.lower():
    newtext += '\n' + ub.indent(pyvim_funcs.get_selected_text())
    pyvim_funcs.insert_codeblock_over_selection(newtext)
else:
    pyvim_funcs.insert_codeblock_under_cursor(newtext)
EOF
endfunc


func! PyMakeTimerit(...) range
Python2or3 << EOF
import vim
import pyvim_funcs; pyvim_funcs.reload(pyvim_funcs)
import ubelt as ub
mode = vim.eval('a:1')
indent = pyvim_funcs.get_cursor_py_indent()
newtext = '\n'.join([
    indent + 'import ubelt as ub',
    indent + 'for timer in ub.Timerit(100, bestof=10, label=\'time\'):',
    indent + '    with timer:',
])
if 'v' in mode.lower():
    newtext += '\n' + ub.indent(pyvim_funcs.get_selected_text(), ' ' * 8)
    pyvim_funcs.insert_codeblock_over_selection(newtext)
else:
    pyvim_funcs.insert_codeblock_under_cursor(newtext)
EOF
endfunc

func! PyFormatDoctest() range
Python2or3 << EOF
import vim
import pyvim_funcs; pyvim_funcs.reload(pyvim_funcs)
text = pyvim_funcs.get_selected_text()
formated_text = pyvim_funcs.format_text_as_docstr(text)
pyvim_funcs.insert_codeblock_over_selection(formated_text)
EOF
endfunc

func! PyUnFormatDoctest() range
Python2or3 << EOF
import vim
import pyvim_funcs; pyvim_funcs.reload(pyvim_funcs)
text = pyvim_funcs.get_selected_text()
formated_text = pyvim_funcs.unformat_text_as_docstr(text)
pyvim_funcs.insert_codeblock_over_selection(formated_text)
EOF
endfunc


func! FUNC_AutoImport() 
Python2or3 << EOF
# FIXME: Unfinished
import vim
import pyvim_funcs; pyvim_funcs.reload(pyvim_funcs)
import ubelt as ub

def undefined_names(fpath):
    """
    Use a linter to find undefined names
    fpath = ub.truepath('~/code/utool/utool/util_inspect.py')
    """
    import pyflakes.api
    import pyflakes.reporter

    class CaptureReporter(pyflakes.reporter.Reporter):
        def __init__(reporter, warningStream, errorStream):
            reporter.syntax_errors = []
            reporter.messages = []
            reporter.unexpected = []

        def unexpectedError(reporter, filename, msg):
            reporter.unexpected.append(msg)

        def syntaxError(reporter, filename, msg, lineno, offset, text):
            reporter.syntax_errors.append(msg)

        def flake(reporter, message):
            reporter.messages.append(message)

    names = set()

    import ubelt as ub
    reporter = CaptureReporter(None, None)
    n = pyflakes.api.checkPath(fpath, reporter)
    for msg in reporter.messages:
        if msg.__class__.__name__.endswith('UndefinedName'):
            assert len(msg.message_args) == 1
            names.add(msg.message_args[0])
    return names
    #import parse
    #lint_patterns = [
    #    "{} undefined name '{varname}'"
    #]
    # TODO use pyflakes programtically
    #for line in ub.cmd('pyflakes ' + fpath)['out'].splitlines():
    #    for pat in lint_patterns:

known_imports = {
    'it': 'import itertools as it',
    'nh': 'import netharn as nh',
    'np': 'import numpy as np',
    'pd': 'import pandas as pd',
    'ub': 'import ubelt as ub',
    'Image': 'from PIL import Image',
    'mpl': 'import matplotlib as mpl',
    'nn': 'from torch import nn',
    'F': 'import torch.nn.functional as F',
    'Variable': 'from torch.autograd import Variable',
}
known_modules = [
    'cv2',
    'glob',
    'torch',
]
#import glob
#builtin_modnames = [
#    name_we for name_we, ext in map(splitext, map(basename, glob.glob(join(dirname(os.__file__), '*.py'))))
#]
#known_modules += builtin_modnames

for name in known_modules:
    known_imports[name] = 'import {}'.format(name)
for name in dir(os.path):
    if not name.startswith('_'):
        known_imports[name] = 'from os.path import {}'.format(name)

pyvim_funcs.ensure_normalmode()

from xdoctest import static_analysis as static

if pyvim_funcs.is_module_pythonfile():
    fpath = pyvim_funcs.get_current_fpath()
    names = undefined_names(fpath)

    # Add any unregistered names if they correspond with a findable module
    for n in names:
        if n not in known_imports:
            if static.modname_to_modpath(n) is not None:
                known_imports[n] = 'import {}'.format(n)

    have_names = sorted(set(known_imports).intersection(set(names)))
    missing = set(names) - set(have_names)
    if missing:
        print('Warning: unknown modules {}'.format(missing))

    import_block = '\n'.join([known_imports[n] for n in have_names])
    # FIXME: doesnt work right when row=0
    with pyvim_funcs.CursorContext(offset=len(have_names)):
        pyvim_funcs.prepend_import_block(import_block)
else:
    print('current file is not a pythonfile')
#L______________
EOF
endfu 
command! AutoImport call FUNC_AutoImport()

