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
import utool as ut
import pyvim_funcs, imp; imp.reload(pyvim_funcs)

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
import pyvim_funcs, imp; imp.reload(pyvim_funcs)
import utool as ut
ut.rrrr(verbose=False)
pyvim_funcs.ensure_normalmode()
if pyvim_funcs.is_module_pythonfile():
    modpath = vim.current.buffer.name
    modname = ut.get_modname_from_modpath(modpath)
    test_code = ut.codeblock(
        r'''
        import pytest
        pytest.main([__file__, '--doctest-modules'])
        ''')
    text = ut.make_default_module_maintest(modname, modpath, test_code=test_code)
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

import vim
import pyvim_funcs, imp; imp.reload(pyvim_funcs)
import utool as ut
ut.rrrr(verbose=False)
pyvim_funcs.ensure_normalmode()
if pyvim_funcs.is_module_pythonfile():
    modpath = vim.current.buffer.name
    modname = ut.get_modname_from_modpath(modpath)
    lines = []
    if mode == 'script':
        lines += ['#!/usr/bin/env python']
    lines += [
        '# -*- coding: utf-8 -*-',
        'from __future__ import print_function, division, absolute_import, unicode_literals',
    ]
    if mode == 'utool':
        lines += [
            'import utool as ut'
            'print, rrr, profile = ut.inject2(__name__)'
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
import pyvim_funcs, imp; imp.reload(pyvim_funcs)
import utool as ut

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
import utool as ut
import pyvim_funcs, imp; imp.reload(pyvim_funcs)

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
import utool as ut
ut.rrrr(verbose=False)
import pyvim_funcs, imp; imp.reload(pyvim_funcs)

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
import utool as ut
import imp
#imp.reload(ut._internal)
#imp.reload(ut._internal.meta_util_six)
imp.reload(ut)
ut.rrrr(verbose=False)
import pyvim_funcs, imp; imp.reload(pyvim_funcs)

if pyvim_funcs.is_module_pythonfile():
    print('building docstr')
    text = pyvim_funcs.auto_docstr( 
        with_args=False,
        with_ret=False,
        with_commandline=True,
        with_example=False,
        with_header=False)
    pyvim_funcs.insert_codeblock_under_cursor(text)
else:
    print('current file is not a pythonfile')
#L______________
EOF
endfu 


func! InsertIBEISExample() 
Python2or3 << EOF
import vim
import pyvim_funcs, imp; imp.reload(pyvim_funcs)
import utool as ut
pyvim_funcs.ensure_normalmode()
if pyvim_funcs.is_module_pythonfile():
    modname = ut.get_modname_from_modpath(vim.current.buffer.name)
    #text = ut.indent(ut.codeblock(
    #    '''
    #    Example:
    #        >>> # DOCTEST_DISABLE
    #        >>> from {modname} import *   # NOQA
    #        >>> import ibeis
    #        >>> ibs = ibeis.opendb('testdb1')
    #        >>> aid_list = ibs.get_valid_aids()
    #    '''
    #)).format(modname=modname)
    text = pyvim_funcs.auto_docstr(with_args=False, with_ret=False)
    pyvim_funcs.insert_codeblock_under_cursor(text)
else:
    print('current file is not a pythonfile')
#L______________
EOF
endfu 


func! PyMakeEmbed() 
Python2or3 << EOF
import vim
import pyvim_funcs, imp; imp.reload(pyvim_funcs)
import utool as ut

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
import pyvim_funcs, imp; imp.reload(pyvim_funcs)
import utool as ut

mode = vim.eval('a:1')


indent = pyvim_funcs.get_cursor_py_indent()
newtext = '\n'.join([
    #indent + 'import utool',
    #indent + 'with utool.embed_on_exception_context:'
    indent + 'import ipdb',
    indent + 'with ipdb.launch_ipdb_on_exception():'
])
if 'v' in mode.lower():
    newtext += '\n' + ut.indent(pyvim_funcs.get_selected_text())
    pyvim_funcs.insert_codeblock_over_selection(newtext)
else:
    pyvim_funcs.insert_codeblock_under_cursor(newtext)
EOF
endfunc


func! PyMakeTimerit(...) range
Python2or3 << EOF
import vim
import pyvim_funcs, imp; imp.reload(pyvim_funcs)
import utool as ut
mode = vim.eval('a:1')
indent = pyvim_funcs.get_cursor_py_indent()
newtext = '\n'.join([
    indent + 'import ubelt',
    indent + 'for timer in ubelt.Timerit(10):',
    indent + '    with timer:',
])
if 'v' in mode.lower():
    newtext += '\n' + ut.indent(pyvim_funcs.get_selected_text(), ' ' * 8)
    pyvim_funcs.insert_codeblock_over_selection(newtext)
else:
    pyvim_funcs.insert_codeblock_under_cursor(newtext)
EOF
endfunc

func! PyOpenFileUnderCursor() 
Python2or3 << EOF
import vim
import pyvim_funcs, imp; imp.reload(pyvim_funcs)
import utool as ut
word = pyvim_funcs.get_word_at_cursor()
if ut.checkpath(word):
    pyvim_funcs.open_fpath(word)
else:
    modpath = ut.get_modpath_from_modname(word)
    print(modpath)
    # utool
    if ut.checkpath(modpath):
        pyvim_funcs.open_fpath(modpath, 'split')
    else:
        print(word)
    # TODO: infer modules from the context with jedi perhaps

EOF
endfunc

func! PyFormatDoctest() range
Python2or3 << EOF
import vim
import pyvim_funcs, imp; imp.reload(pyvim_funcs)
import utool as ut
text = pyvim_funcs.get_selected_text()
formated_text = ut.format_text_as_docstr(text)
pyvim_funcs.insert_codeblock_over_selection(formated_text)
EOF
endfunc

func! PyUnFormatDoctest() range
Python2or3 << EOF
import vim
import pyvim_funcs, imp; imp.reload(pyvim_funcs)
import utool as ut
text = pyvim_funcs.get_selected_text()
formated_text = ut.unformat_text_as_docstr(text)
pyvim_funcs.insert_codeblock_over_selection(formated_text)
EOF
endfunc

