"""
" SeeAlso; 
"     ~/local/vim/rc_settings/remap_settings.vim
"
"""


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
    text = ut.make_default_module_maintest(modname, modpath)
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


func! SpellcheckOn()
    :set spell
    :setlocal spell spelllang=en_us
endfu

func! <SID>StripTrailingWhitespaces()
    "http://stackoverflow.com/questions/356126/how-can-you-automatically-remove-trailing-whitespace-in-vim
    let l = line(".")
    let c = col(".")
    %s/\s\+$//e
    call cursor(l, c)
endfun

" Open OS window
function! ViewDirectory()
    if has("win32") || has("win16")
        silent !explorer .
    else
        silent !nautilus .&
    endif
    redraw!
endfunction

" Open OS command prompt
function! CmdHere()
    if has("win32") || has("win16")
        silent !cmd /c start cmd
    else
        silent !gnome-terminal .
    endif
    redraw!
endfunction

" Windows Transparency
func! ToggleAlpha() 
    if !exists("g:togalpha") 
        let g:togalpha=1 
    else 
        let g:togalpha = 1 - g:togalpha 
    endif 
    if has("win32") || has("win16")
        if (g:togalpha) 
            :TweakAlpha 220
            "call libcallnr("~/local/vim/rc/vimtweak.dll", "SetAlpha", 220) 
        else 
            :TweakAlpha 255
            "call libcallnr("~/local/vim/rc/vimtweak.dll", "SetAlpha", 255) 
        endif 
    endif
endfu 

func! BeginAlpha() 
    if !exists("g:togalpha") 
        let g:togalpha=1 
        if has("win32") || has("win16") 
            call libcallnr("~/local/vim/rc/vimtweak.dll", "SetAlpha", 240) 
        endif
    endif
endfu 


func! WordHighlightFun()
    if !exists("g:togwordhighlight") 
        let g:togwordhighlight=0
    elseif (g:togwordhighlight)     
        exe printf('match DiffChange /\V\<%s\>/', escape(expand('<cword>'), '/\'))
    endif
endfu

func! ToggleWordHighlight()
    if !exists("g:togwordhighlight") 
        let g:togwordhighlight=1 
    else 
        let g:togwordhighlight = 1 - g:togwordhighlight 
    endif 
endfu

function! FUNC_TextWidthMarkerOn()
    highlight OverLength ctermbg=red ctermfg=white guibg=#592929
    highlight OverLength ctermbg=red ctermfg=white guibg=#502020
    match OverLength /\%81v.\+/
endfunction


function! FUNC_TextWidthLineOn()
if exists('+colorcolumn')
  set colorcolumn=81
else
  au! BufWinEnter * let w:m2=matchadd('ErrorMsg', '\%>80v.\+', -1)
endif
endfunction
command! TextWidthLineOn call FUNC_TextWidthLineOn()


""""""""""""""""""""""""""""""""""
" NAVIGATION


func! EnsureCustomPyModPath()
Python2or3 << EOF
import sys
from os.path import expanduser
path = expanduser('~/local/vim/rc')
if path not in sys.path:
    sys.path.append(path)
EOF
endfu

call EnsureCustomPyModPath()


func! OpenSetups()
"pyfile pyvim_funcs.py
Python2or3 << EOF
import vim
import pyvim_funcs, imp; imp.reload(pyvim_funcs)
fpath_list = [
        '~/code/ibeis/setup.py',
        '~/code/utool/setup.py',
        '~/code/vtool/setup.py',
        '~/code/hesaff/setup.py',
        '~/code/detecttools/setup.py',
        '~/code/pyrf/setup.py',
        '~/code/guitool/setup.py',
        '~/code/plottool/setup.py',
    ]
pyvim_funcs.open_fpath_list(fpath_list, num_hsplits=2)
EOF
endfu


func! OpenGitIgnores()
Python2or3 << EOF
import vim
import pyvim_funcs, imp; imp.reload(pyvim_funcs)
fpath_list = [
        '~/code/ibeis/.gitignore',
        '~/code/utool/.gitignore',
        '~/code/vtool/.gitignore',
        '~/code/hesaff/.gitignore',
        '~/code/detecttools/.gitignore',
        '~/code/pyrf/.gitignore',
        '~/code/guitool/.gitignore',
        '~/code/plottool/.gitignore',
    ]
pyvim_funcs.open_fpath_list(fpath_list, num_hsplits=2)
EOF
endfu

""""""""""""""""""""""""""""""""""


func! MagicPython()
    "https://dev.launchpad.net/UltimateVimPythonSetup
    let python_highlight_all = 1
    set smartindent cinwords=if,elif,else,for,while,try,except,finally,def,class
python << EOF
import os
import sys
import vim
for p in sys.path:
    if os.path.isdir(p):
        vim.command(r"set path+=%s" % (p.replace(" ", r"\ ")))
EOF
endfu 



"""""""""""""
" VIM INFO

func! PrintPlugins()
    " where was an option set
    :scriptnames " list all plugins, _vimrcs loaded (super)
    :verbose set history? " reveals value of history and where set
    :function " list functions
    :func SearchCompl " List particular function
endfu

func! DumpMappings()
    :redir! > vim_maps_dump.txt
    :map
    :map!
    :redir END
endfu


fu! FUNC_ECHOVAR(varname)
    :let varstr=a:varname
    :exec 'let g:foo = &'.varstr
    :echo varstr.' = '.g:foo
endfu
command! -nargs=1 ECHOVAR :call FUNC_ECHOVAR(<f-args>)


func! MYINFO()
    :ECHOVAR cino
    :ECHOVAR cinkeys
    :ECHOVAR foldmethod
    :ECHOVAR filetype
    :ECHOVAR smartindent
endfu
command! MYINFOCMD call MYINFO() <C-R>


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


func! PyMakePrintVar() 
Python2or3 << EOF
import vim
import pyvim_funcs, imp; imp.reload(pyvim_funcs)
import utool as ut
expr = pyvim_funcs.get_expr_at_cursor()
indent = pyvim_funcs.get_cursor_py_indent()
newline = indent + "print('{expr} = %r' % ({expr},))".format(expr=expr)
pyvim_funcs.insert_codeblock_under_cursor(newline)
EOF
endfunc

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
    indent + 'import utool',
    indent + 'with utool.embed_on_exception_context:'
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

func! PyMakePrintLine() 
Python2or3 << EOF
import vim
import pyvim_funcs, imp; imp.reload(pyvim_funcs)
import utool as ut
line = pyvim_funcs.get_line_at_cursor()
expr = line.strip(' ')
indent = pyvim_funcs.get_cursor_py_indent()
newline = indent + "print('{expr} = %r' % ({expr},))".format(expr=expr)
pyvim_funcs.insert_codeblock_under_cursor(newline)
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

func! PyCiteLookup() 
Python2or3 << EOF
"""
SeeAlso:
    ~/local/vim/rc_settings/remap_settings.vim
"""
import vim
import pyvim_funcs, imp; imp.reload(pyvim_funcs)
import utool as ut
word = pyvim_funcs.get_word_at_cursor()
# HACK: custom current bibtex file
bib_fpath = ut.truepath('~/latex/crall-thesis-2017/My_Library_clean.bib')

import bibtexparser
from bibtexparser import bparser
parser = bparser.BibTexParser(ignore_nonstandard_types=False)
bibtex_dict = parser.parse(ut.read_from(bib_fpath), partial=False).get_entry_dict()
#bibtex_dict = ut.get_bibtex_dict(bib_fpath)
title = bibtex_dict[word]['title'].replace('{', '').replace('}', '')
ut.copy_text_to_clipboard(title)
print(title)
#print(repr(word))
EOF
endfunc


func! MarkdownPreview() 
Python2or3 << EOF
import vim
import pyvim_funcs, imp; imp.reload(pyvim_funcs)
import utool as ut
ut.rrrr(verbose=False)
buffer_name = vim.current.buffer.name
print('mdview buffer_name = %r' % (buffer_name,))
os.system('mdview ' + buffer_name + '&')
EOF
endfunc


func! PyCiteScholarSearch() 
Python2or3 << EOF
import vim
import pyvim_funcs, imp; imp.reload(pyvim_funcs)
import utool as ut
ut.rrrr(verbose=False)
word = pyvim_funcs.get_word_at_cursor()
# HACK: custom current bibtex file
bib_fpath = ut.truepath('~/latex/crall-thesis-2017/My_Library_clean.bib')

import bibtexparser
from bibtexparser import bparser
parser = bparser.BibTexParser(ignore_nonstandard_types=False)
bibtex_dict = parser.parse(ut.read_from(bib_fpath), partial=False).get_entry_dict()

#bibtex_dict = ut.get_bibtex_dict(bib_fpath)
#title = bibtex_dict[word]['title'].replace('{', '').replace('}', '').
ut.copy_text_to_clipboard(title)
# scholar search
baseurl = r'https://scholar.google.com/scholar?hl=en&q='
suffix = '+'.join(title.split(' '))
url = baseurl + suffix
#import webbrowser
#ut.open_url_in_browser(url, 'windows-default')
#ut.open_url_in_browser(url, 'windows-default')
print(title)
ut.open_url_in_browser(url, 'google-chrome')
#webbrowser.open(url)
EOF
endfunc


func! SmartSearchWordAtCursor() 
Python2or3 << EOF
import vim
import pyvim_funcs, imp; imp.reload(pyvim_funcs)
import utool as ut
ut.rrrr(verbose=False)
word = pyvim_funcs.get_word_at_cursor(url_ok=True)
# HACK: custom current bibtex file

if ut.is_url(word):
    url = word
    print(url)
else:
    _fpath = '~/latex/crall-thesis-2017/My_Library_clean.bib'
    bib_fpath = ut.truepath(_fpath)
    #bibtex_dict = ut.get_bibtex_dict(bib_fpath)

    import bibtexparser
    from bibtexparser import bparser
    parser = bparser.BibTexParser(ignore_nonstandard_types=False)
    bibtex_dict = parser.parse(ut.read_from(bib_fpath), partial=False).get_entry_dict()

    title = bibtex_dict[word]['title'].replace('{', '').replace('}', '')
    ut.copy_text_to_clipboard(title)
    # scholar search
    baseurl = r'https://scholar.google.com/scholar?hl=en&q='
    suffix = '+'.join(title.split(' '))
    url = baseurl + suffix
    print(title)
#import webbrowser
#ut.open_url_in_browser(url, 'windows-default')
#ut.open_url_in_browser(url, 'windows-default')
ut.open_url_in_browser(url, 'google-chrome')
#webbrowser.open(url)
EOF
endfunc


func! GrepProjectWordAtCursor() 
Python2or3 << EOF
import vim
import pyvim_funcs, imp; imp.reload(pyvim_funcs)
import utool as ut
import re
ut.rrrr(verbose=False)
word = pyvim_funcs.get_word_at_cursor(url_ok=False)
#msg_list = ut.grep_projects(['\\b' + re.escape(word) + '\\b'], verbose=False)
print('Grepping for pattern = %r' % (word,))
pat = r'\b' + re.escape(word) + r'\b'
pyvim_funcs.vim_grep_project(pat, word)
EOF
endfunc


func! FUNC_UtoolReload(...) 
Python2or3 << EOF
import pyvim_funcs, imp; imp.reload(pyvim_funcs)
import utool as ut
print('reloading utool')
ut.rrrr(0)
EOF
endfunc
command! UtoolReload call FUNC_UtoolReload()


func! FUNC_GrepProject(...) 
Python2or3 << EOF
import vim
import pyvim_funcs, imp; imp.reload(pyvim_funcs)
pat = vim.eval('a:1')
pyvim_funcs.vim_grep_project(pat)
EOF
endfunc
command! -nargs=1 GrepProject call FUNC_GrepProject(<f-args>)<CR>


func! PyFormatParagraph() range
Python2or3 << EOF
import vim
import pyvim_funcs, imp; imp.reload(pyvim_funcs)
import utool as ut
#ut.rrrr(0)
text = pyvim_funcs.get_selected_text(select_at_cursor=False)
##wrapped_text = ut.format_single_paragraph_sentences(text)
wrapped_text = ut.format_multiple_paragraph_sentences(text)
pyvim_funcs.insert_codeblock_over_selection(wrapped_text)
EOF
endfunc


func! SortLinesByFloat() range
'<,'>!sort -n -k 2
"Python2or3 << EOF
"import vim
"import pyvim_funcs, imp; imp.reload(pyvim_funcs)
"text = pyvim_funcs.get_selected_text(select_at_cursor=False)
"##wrapped_text = ut.format_single_paragraph_sentences(text)
"wrapped_text = ut.format_multiple_paragraph_sentences(text)
"pyvim_funcs.insert_codeblock_over_selection(wrapped_text)
"endpython
endfunc


func! PySelectAndFormatParagraph(...) 
Python2or3 << EOF
import vim
import pyvim_funcs, imp; imp.reload(pyvim_funcs)
import utool as ut
#ut.rrrr(0)
nargs = int(vim.eval('a:0'))
# Simulate kwargs with cfgdict-like strings
default_kwargs = {
    'max_width': 80,
    'myprefix': True,
    'sentence_break': True,
}
if nargs == 1:
    cfgstr = vim.eval('a:1')
    cfgdict = ut.parse_cfgstr3(cfgstr)
    kwargs = ut.update_existing(default_kwargs, cfgdict, assert_exists=True)
else:
    kwargs = default_kwargs
ut.rrrr(0)

# Remember curor location as best as possible
(row, col) = vim.current.window.cursor

row1, row2 = pyvim_funcs.get_paragraph_line_range_at_cursor()
text = pyvim_funcs.get_text_between_lines(row1, row2)
text = ut.ensure_unicode(text)

#wrapped_text = ut.format_multiple_paragraph_sentences(text, max_width=100)
wrapped_text = ut.format_multiple_paragraph_sentences(text, **kwargs)
pyvim_funcs.insert_codeblock_between_lines(wrapped_text, row1, row2)

# Reset cursor position as best as possible
pyvim_funcs.move_cursor(row, col)

EOF
endfunc


func! PySelectAndFormatParagraphNoBreak() 
Python2or3 << EOF
import vim
import pyvim_funcs, imp; imp.reload(pyvim_funcs)
import utool as ut
#ut.rrrr(0)
ut.rrrr(0)
row1, row2 = pyvim_funcs.get_paragraph_line_range_at_cursor()
text = pyvim_funcs.get_text_between_lines(row1, row2)
text = ut.ensure_unicode(text)
wrapped_text = ut.format_multiple_paragraph_sentences(text, max_width=None)
pyvim_funcs.insert_codeblock_between_lines(wrapped_text, row1, row2)
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

"-------------------------
command! HexmodeOn :%!xxd
command! HexmodeOff :%!xxd -r 
"-------------------------

" http://vim.wikia.com/wiki/View_text_file_in_two_columns
:noremap <silent> <Leader>b :<C-u>let @z=&so<CR>:set so=0 noscb<CR>:bo vs<CR>Ljzt:setl scb<CR><C-w>p:setl scb<CR>:let &so=@z<CR>
"command! TwoColumnEdit :<C-u>let @z=&so<CR>:set so=0 noscb<CR>:bo vs<CR>Ljzt:setl scb<CR><C-w>p:setl scb<CR>:let &so=@z<CR>



"https://vi.stackexchange.com/questions/8378/dump-the-output-of-internal-vim-command-into-buffer
"command! -nargs=+ -complete=command Redir let s:reg = @@ | redir @"> | silent execute <q-args> | redir END | new | pu | 1,2d_ | let @@ = s:reg
" INSTEAD USE
" put = execute('au')
