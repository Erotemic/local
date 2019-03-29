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
import imp
import pyvim_funcs; pyvim_funcs.reload(pyvim_funcs)

if pyvim_funcs.is_module_pythonfile():
    print('building docstr')
    text = pyvim_funcs.auto_cmdline()
    pyvim_funcs.insert_codeblock_under_cursor(text)
else:
    print('current file is not a pythonfile')
EOF
endfu 


func! PyMakeEmbed() 
Python2or3 << EOF
import vim
import pyvim_funcs; pyvim_funcs.reload(pyvim_funcs)
import ubelt as ub

indent = pyvim_funcs.get_cursor_py_indent()
newtext = '\n'.join([
    indent + 'import xdev',
    indent + 'xdev.embed()'
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
    indent + 'import xdev',
    indent + 'with xdev.embed_on_exception_context:'
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


func! PyMakeXDevKwargs() 
Python2or3 << EOF
import vim
import pyvim_funcs; pyvim_funcs.reload(pyvim_funcs)
import ubelt as ub
findfunc_info = pyvim_funcs.find_pyfunc_above_cursor()
funcname = findfunc_info['funcname']
newtext = '\n'.join([
    indent + 'import xdev',
    indent + 'globals().update(xdev.get_func_kwargs({}))'.format(funcname)
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
    #indent + 'import utool',
    #indent + 'with utool.embed_on_exception_context:'
    indent + 'import xdev',
    indent + 'with xdev.embed_on_exception_context:'
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
    indent + 'ti = ub.Timerit(100, bestof=10, verbose=2)',
    indent + 'for timer in ti.reset(\'time\'):',
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

# TODO
# - [ ] Push to vimtk
import vim
import pyvim_funcs; pyvim_funcs.reload(pyvim_funcs)
import xinspect
import ubelt as ub

from xinspect.autogen import Importables

if True:
    import imp
    imp.reload(xinspect)
    imp.reload(xinspect.autogen)

pyvim_funcs.ensure_normalmode()

if pyvim_funcs.is_module_pythonfile():
    importable = Importables()  
    importable._use_recommended_defaults()
    importable.known.update({  
        'it': 'import itertools as it',
        'nh': 'import netharn as nh',
        'np': 'import numpy as np',
        'pd': 'import pandas as pd',
        'ub': 'import ubelt as ub',
        'nx': 'import networkx as nx',
        'Image': 'from PIL import Image',
        'mpl': 'import matplotlib as mpl',
        'nn': 'from torch import nn',
        'torch_data': 'import torch.utils.data as torch_data',
        'F': 'import torch.nn.functional as F',
        'math': 'import math',
        # 'Variable': 'from torch.autograd import Variable',
    })
    fpath = pyvim_funcs.get_current_fpath()
    lines = xinspect.autogen_imports(fpath=fpath, importable=importable)


    x = ub.group_items(lines, [x.startswith('from ') for x in lines])
    ordered_lines = []
    ordered_lines += sorted(x.get(False, []))
    ordered_lines += sorted(x.get(True, []))
    import_block = '\n'.join(ordered_lines)
    # FIXME: doesnt work right when row=0
    with pyvim_funcs.CursorContext(offset=len(lines)):
        pyvim_funcs.prepend_import_block(import_block)
else:
    print('current file is not a pythonfile')
#L______________
EOF
endfu 
command! AutoImport call FUNC_AutoImport()

