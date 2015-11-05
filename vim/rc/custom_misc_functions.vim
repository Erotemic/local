


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

"perl -pi -e 's/[[:^ascii:]]//g' wiki_scale_list.py

fu! FUNC_REPLACE_BACKSLASH()
    :s/\\/\//g
endfu


""""""""""""""""""""""""""""""""""
" NAVIGATION

func! QUICKOPEN_leader_tvio(...)
    " TODO: remove for plugin
    " Maps <leader>t<key> to tab open a filename
    " Maps <leader>s<key> to vsplit open a filename
    " Maps <leader>i<key> to split open a filename
    let key = a:1
    let fname = a:2
    :exec 'noremap <leader>t'.key.' :tabe '.fname.'<CR>'
    :exec 'noremap <leader>v'.key.' :vsplit '.fname.'<CR>'
    :exec 'noremap <leader>i'.key.' :split '.fname.'<CR>'
    :exec 'noremap <leader>o'.key.' :e '.fname.'<CR>'
endfu


func! EnsureCustomPyModPath()
python << endpython
import sys
from os.path import expanduser
path = expanduser('~/local/vim/rc')
if path not in sys.path:
    sys.path.append(path)
endpython
endfu

call EnsureCustomPyModPath()


func! OpenSetups()
"pyfile pyvim_funcs.py
python << endpython
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
endpython
endfu


func! OpenGitIgnores()
python << endpython
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
endpython
endfu


func! OpenControllerParts()
"pyfile pyvim_funcs.py
python << endpython
import vim
import pyvim_funcs, imp; imp.reload(pyvim_funcs)
fpath_list = [
    '~/code/ibeis/ibeis/control/manual_annot_funcs.py',
    '~/code/ibeis/ibeis/control/manual_dependant_funcs.py',
    '~/code/ibeis/ibeis/control/manual_ibeiscontrol_funcs.py',
    '~/code/ibeis/ibeis/control/manual_image_funcs.py',
    '~/code/ibeis/ibeis/control/manual_lblannot_funcs.py',
    '~/code/ibeis/ibeis/control/manual_lblimage_funcs.py',
    '~/code/ibeis/ibeis/control/manual_lbltype_funcs.py',
    '~/code/ibeis/ibeis/control/manual_meta_funcs.py',
    '~/code/ibeis/ibeis/control/manual_name_species_funcs.py',
    '~/code/ibeis/ibeis/control/_autogen_featweight_funcs.py',
    ]
pyvim_funcs.open_fpath_list(fpath_list, num_hsplits=2)
endpython
endfu
command! Tocontrolparts call OpenControllerParts()


func! TabOpenDev()
python << endpython
import vim
import pyvim_funcs, imp; imp.reload(pyvim_funcs)
fpath_list = [
        '~/code/ibeis/README.md',
        '~/code/ibeis/dev.py',
        '~/code/ibeis/ibeis/control/IBEISControl.py',
    ]
pyvim_funcs.open_fpath_list(fpath_list, num_hsplits=3)
endpython
endfu
command! Todev call TabOpenDev()


func! TabOpenHotsPipeline()
python << endpython
import vim
import pyvim_funcs, imp; imp.reload(pyvim_funcs)
fpath_list = [
        '~/code/ibeis/ibeis/model/hots/query_request.py',
        '~/code/ibeis/ibeis/model/hots/neighbor_index.py',
        '~/code/ibeis/ibeis/model/hots/multi_index.py',
        '~/code/ibeis/ibeis/model/hots/score_normalization.py',
        #'~/code/ibeis/ibeis/model/hots/pipeline.py',
        #'~/code/ibeis/ibeis/model/hots/match_chips4.py',
        #'~/code/ibeis/ibeis/control/manual_annot_funcs.py',
    ]
pyvim_funcs.open_fpath_list(fpath_list, num_hsplits=2)
endpython
endfu
command! Tohotspipeline call TabOpenHotsPipeline()


func! TabOpenVimRC()
python << endpython
import vim
import pyvim_funcs, imp; imp.reload(pyvim_funcs)
fpath_list = [
        '~/local/vim/portable_vimrc',
        '~/local/vim/rc_settings/remap_settings.vim',
        '~/local/vim/rc/custom_misc_functions.vim',
        #'~/local/vim/rc/pyvim_funcs.py',
    ]
pyvim_funcs.open_fpath_list(fpath_list, num_hsplits=3)
endpython
endfu
command! Tovimrc call TabOpenVimRC()


""""""""""""""""""""""""""""""""""

func! TabOpenAutogen()
python << endpython
import vim
import pyvim_funcs, imp; imp.reload(pyvim_funcs)
fpath_list = [
        '~/code/utool/utool/util_inspect.py',
        '~/code/utool/utool/util_autogen.py',
    ]
pyvim_funcs.open_fpath_list(fpath_list, num_hsplits=2)
endpython
endfu
command! Toautogen call TabOpenAutogen()


""""""""""""""""""""""""""""""""""

func! TabOpenCyth()
python << endpython
import vim
import pyvim_funcs, imp; imp.reload(pyvim_funcs)
fpath_list = [
        '~/code/cyth/cyth/cyth_pragmas.py',
        '~/code/vtool/vtool/keypoint.py',
        '~/code/vtool/vtool/spatial_verification.py',
    ]
pyvim_funcs.open_fpath_list(fpath_list, num_hsplits=3)
endpython
endfu
command! Tocyth call TabOpenCyth()


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

func! AuOnReadPatterns(aucmdstr, ...)
python << EOF
import vim
ix = 0
while True:
    try:
        pattern = vim.eval('a:%d' % ix)
        cmdfmt = ":exec au BufNewFile,BufRead {pattern} {aucmdstr}"
        cmd = cmdfmt.format(pattern=pattern, aucmdstr=aucmdstr)
        vim.command(cmd)
    except Exception:
        break
    ix += 1
EOF
endfu

func! AuPreWritePatterns(aucmdstr, ...)
python << EOF
import vim
ix = 0
while True:
    try:
        pattern = vim.eval('a:%d' % ix)
        cmdfmt = ":exec au BufWritePre {pattern} {aucmdstr}"
        cmdstr = cmdfmt.format(pattern=pattern, aucmdstr=aucmdstr)
        vim.command(cmdstr)
    except Exception:
        break
    ix += 1
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


func! InsertDocstr() 
python << endpython
import vim
#vim.command(':echom %r' % ('dbmsg: ' + dbgmsg,))
import utool
import pyvim_funcs, imp; imp.reload(pyvim_funcs)

if pyvim_funcs.is_module_pythonfile():
    print('building docstr')
    text = pyvim_funcs.auto_docstr()
    pyvim_funcs.insert_codeblock_at_cursor(text)
else:
    print('current file is not a pythonfile')
#L______________
endpython
endfu 


func! InsertKWargsDoc() 
python << endpython
import vim
#vim.command(':echom %r' % ('dbmsg: ' + dbgmsg,))
import utool
import pyvim_funcs, imp; imp.reload(pyvim_funcs)

if pyvim_funcs.is_module_pythonfile():
    print('building docstr')
    text = pyvim_funcs.auto_docstr()
    pyvim_funcs.insert_codeblock_at_cursor(text)
else:
    print('current file is not a pythonfile')
#L______________
endpython
endfu 


func! InsertDocstrOnlyArgs() 
python << endpython
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
    pyvim_funcs.insert_codeblock_at_cursor(text)
else:
    print('current file is not a pythonfile')
#L______________
endpython
endfu 


func! InsertDocstrOnlyCommandLine() 
python << endpython
import vim
#vim.command(':echom %r' % ('dbmsg: ' + dbgmsg,))
import utool as ut
imp.reload(ut._internal)
imp.reload(ut._internal.meta_util_six)
import imp
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
    pyvim_funcs.insert_codeblock_at_cursor(text)
else:
    print('current file is not a pythonfile')
#L______________
endpython
endfu 


func! InsertMainPyTest() 
python << endpython
import vim
import pyvim_funcs, imp; imp.reload(pyvim_funcs)
import utool as ut
ut.rrrr(verbose=False)
pyvim_funcs.ensure_normalmode()
if pyvim_funcs.is_module_pythonfile():
    modpath = vim.current.buffer.name
    modname = ut.get_modname_from_modpath(modpath)
    text = ut.make_default_module_maintest(modname, modpath)
    pyvim_funcs.insert_codeblock_at_cursor(text)
else:
    print('current file is not a pythonfile')
#L______________
endpython
endfu 


func! InsertIBEISExample() 
python << endpython
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
    pyvim_funcs.insert_codeblock_at_cursor(text)
else:
    print('current file is not a pythonfile')
#L______________
endpython
endfu 


func! AutoPep8Block() 
python << endpython
# FIXME: Unfinished
import vim
import pyvim_funcs, imp; imp.reload(pyvim_funcs)
import utool

pyvim_funcs.ensure_normalmode()

if pyvim_funcs.is_module_pythonfile():
    print('autopep8ing file')
    text = pyvim_funcs.get_codelines_around_buffer()
    pyvim_funcs.insert_codeblock_at_cursor(text)
else:
    print('current file is not a pythonfile')
#L______________
endpython
endfu 


func! ReloadVIMRC()
    source ~/local/vim/portable_vimrc
endfu


"func! GetSelectedText()
"  normal gv"xy
"  let result = getreg("x")
"  normal gv
"  return result
"endfunc


func! PyMakePrintVar() 
python << endpython
import vim
import pyvim_funcs, imp; imp.reload(pyvim_funcs)
import utool as ut
expr = pyvim_funcs.get_expr_at_cursor()
line = pyvim_funcs.get_line_at_cursor()
min_indent = ut.get_minimum_indentation(line)
newline = ' ' * min_indent + "print('{expr} = %r' % ({expr},))".format(expr=expr)
pyvim_funcs.insert_codeblock_at_cursor(newline)
endpython
endfunc

func! PyCiteLookup() 
python << endpython
"""
SeeAlso:
    ~/local/vim/rc_settings/remap_settings.vim
"""
import vim
import pyvim_funcs, imp; imp.reload(pyvim_funcs)
import utool as ut
word = pyvim_funcs.get_word_at_cursor()
# HACK: custom current bibtex file
bib_fpath = ut.truepath('~/latex/crall-candidacy-2015/My_Library_clean.bib')
bibtex_dict = ut.get_bibtex_dict(bib_fpath)
title = bibtex_dict[word]['title'].replace('{', '').replace('}', '')
ut.copy_text_to_clipboard(title)
print(title)
#print(repr(word))
endpython
endfunc


func! PyCiteScholarSearch() 
python << endpython
import vim
import pyvim_funcs, imp; imp.reload(pyvim_funcs)
import utool as ut
ut.rrrr(verbose=False)
word = pyvim_funcs.get_word_at_cursor()
# HACK: custom current bibtex file
bib_fpath = ut.truepath('~/latex/crall-candidacy-2015/My_Library_clean.bib')
bibtex_dict = ut.get_bibtex_dict(bib_fpath)
title = bibtex_dict[word]['title'].replace('{', '').replace('}', '')
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
endpython
endfunc


func! SmartSearchWordAtCursor() 
python << endpython
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
    bib_fpath = ut.truepath('~/latex/crall-candidacy-2015/My_Library_clean.bib')
    bibtex_dict = ut.get_bibtex_dict(bib_fpath)
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
endpython
endfunc


func! GrepProjectWordAtCursor() 
python << endpython
import vim
import pyvim_funcs, imp; imp.reload(pyvim_funcs)
import utool as ut
import re
ut.rrrr(verbose=False)
word = pyvim_funcs.get_word_at_cursor(url_ok=False)
#msg_list = ut.grep_projects(['\\b' + re.escape(word) + '\\b'], verbose=False)
print('Grepping for pattern = %r' % (word,))
pat = r'\b' + re.escape(word) + r'\b'
msg_list = ut.grep_projects([pat], verbose=False)
fpath = ut.unixjoin(ut.get_app_resource_dir('utool'), 'tmp_grep_' + word + '.txt')
#pyvim_funcs.vim_fpath_cmd('split', fpath)
pyvim_funcs.vim_fpath_cmd('new', fpath)
text = '\n'.join(msg_list)
pyvim_funcs.overwrite_text(text)
vim.command(":exec ':w'")
endpython
endfunc


func! PyFormatParagraph() range
python << endpython
import vim
import pyvim_funcs, imp; imp.reload(pyvim_funcs)
text = pyvim_funcs.get_selected_text(select_at_cursor=False)
##wrapped_text = pyvim_funcs.format_single_paragraph_sentences(text)
wrapped_text = pyvim_funcs.format_multiple_paragraph_sentences(text)
pyvim_funcs.insert_codeblock_over_selection(wrapped_text)
endpython
endfunc


func! SortLinesByFloat() range
'<,'>!sort -n -k 2
"python << endpython
"import vim
"import pyvim_funcs, imp; imp.reload(pyvim_funcs)
"text = pyvim_funcs.get_selected_text(select_at_cursor=False)
"##wrapped_text = pyvim_funcs.format_single_paragraph_sentences(text)
"wrapped_text = pyvim_funcs.format_multiple_paragraph_sentences(text)
"pyvim_funcs.insert_codeblock_over_selection(wrapped_text)
"endpython
endfunc


func! PySelectAndFormatParagraph() 
python << endpython
import vim
import pyvim_funcs, imp; imp.reload(pyvim_funcs)
row1, row2 = pyvim_funcs.get_paragraph_line_range_at_cursor()
text = pyvim_funcs.get_text_between_lines(row1, row2)
wrapped_text = pyvim_funcs.format_multiple_paragraph_sentences(text)
pyvim_funcs.insert_codeblock_between_lines(wrapped_text, row1, row2)
endpython
endfunc


func! PyFormatDoctest() range
python << endpython
import vim
import pyvim_funcs, imp; imp.reload(pyvim_funcs)
import utool as ut
text = pyvim_funcs.get_selected_text()
formated_text = ut.format_text_as_docstr(text)
pyvim_funcs.insert_codeblock_over_selection(formated_text)
endpython
endfunc

func! PyUnFormatDoctest() range
python << endpython
import vim
import pyvim_funcs, imp; imp.reload(pyvim_funcs)
import utool as ut
text = pyvim_funcs.get_selected_text()
formated_text = ut.unformat_text_as_docstr(text)
pyvim_funcs.insert_codeblock_over_selection(formated_text)
endpython
endfunc


" ========= Functions ========= "
"command! TextWidthMarkerOn call FUNC_TextWidthMarkerOn()
" Textwidth command
"command! TextWidth80 set textwidth=80
command! TextWidthLineOn call FUNC_TextWidthLineOn()

"-------------------------
command! HexmodeOn :%!xxd
command! HexmodeOff :%!xxd -r 
"-------------------------

command! Bufloadpy :args *.py
"command! SAVESESSION :mksession ~/mysession.vim
"command! LOADSESSION :mksession ~/mysession.vim

"command! SAVEHSSESSION :mksession ~/vim_hotspotter_session.vim
"command! LOADHSSESSION :source ~/vim_hotspotter_session.vim
