"""
" SeeAlso; 
"     ~/local/vim/rc_settings/remap_settings.vim
"
"""


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
        "silent !gnome-terminal .
        silent !terminator --working-directory=.&
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


func! FUNC_UtoolReload(...) 
Python2or3 << EOF
import pyvim_funcs, imp; imp.reload(pyvim_funcs)
import utool as ut
print('reloading utool')
ut.rrrr(0)
EOF
endfunc
command! UtoolReload call FUNC_UtoolReload()


func! CopyCurrentFpath()
Python2or3 << EOF
import vim
import pyvim_funcs, imp; imp.reload(pyvim_funcs)
import utool as ut
fpath = pyvim_funcs.get_current_fpath()
if not ut.WIN32:
    homedir = ut.truepath('~')
    if fpath.startswith(homedir):
        fpath = '~' + fpath[len(homedir):]


print('fpath = {!r}'.format(fpath))
ut.copy_text_to_clipboard(fpath)
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

bibtex_dict = pyvim_funcs.get_bibtex_dict()

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


func! SmartSearchWordAtCursor() 
Python2or3 << EOF
import vim
import pyvim_funcs, imp; imp.reload(pyvim_funcs)
import utool as ut
ut.rrrr(verbose=False)
word = pyvim_funcs.get_word_at_cursor(url_ok=True)

if word.startswith('<') and word.endswith('>`_'):
    print('word = %r' % (word,))
    word = word[1:-3]
    print('word = %r' % (word,))

if ut.is_url(word):
    url = word
    print(url)

else:
    bibtex_dict = pyvim_funcs.get_bibtex_dict()
    title = bibtex_dict[word]['title'].replace('{', '').replace('}', '')
    ut.copy_text_to_clipboard(title)
    # scholar search
    baseurl = r'https://scholar.google.com/scholar?hl=en&q='
    suffix = '+'.join(title.split(' '))
    url = baseurl + suffix
    print(title)

#import webbrowser
#webbrowser.open(url)
#ut.open_url_in_browser(url, 'windows-default')
ut.open_url_in_browser(url, 'google-chrome')
EOF
endfunc


func! FUNC_OpenPath(...)

Python2or3 << EOF
import vim
import pyvim_funcs, imp; imp.reload(pyvim_funcs)
import utool as ut
import re
from os.path import exists, expanduser
ut.rrrr(verbose=False)

argv = pyvim_funcs.vim_argv(defaults=[None, 'split'])
path, mode = argv[0:2]

pyvim_funcs.find_and_open_path(path, mode=mode, verbose=0)

EOF
endfunc
command! -nargs=1 SplitPath call FUNC_OpenPath(<f-args>, 'split')
command! -nargs=1 OpenPath call FUNC_OpenPath(<f-args>, 'e')
command! -nargs=1 EE call FUNC_OpenPath(<f-args>, 'e')



func! OpenPathAtCursor(...) 

Python2or3 << EOF
import vim
import pyvim_funcs, imp; imp.reload(pyvim_funcs)
import utool as ut
import re
from os.path import exists, expanduser
ut.rrrr(verbose=False)


argv = pyvim_funcs.vim_argv(defaults=['split'])
mode = argv[0]

path = pyvim_funcs.get_word_at_cursor(url_ok=True)
verbose = 0

if verbose:
    print('path = {!r}'.format(path))

pyvim_funcs.find_and_open_path(path, mode=mode, verbose=verbose)

EOF
endfunc


func! GrepWordAtCursor(...) 
Python2or3 << EOF
import vim
import pyvim_funcs, imp; imp.reload(pyvim_funcs)
import utool as ut
import re
ut.rrrr(verbose=False)

argv = pyvim_funcs.vim_argv(defaults=['project'])
mode = argv[0]

word = pyvim_funcs.get_word_at_cursor(url_ok=False)
#msg_list = ut.grep_projects(['\\b' + re.escape(word) + '\\b'], verbose=False)
print('Grepping for pattern = %r' % (word,))
pat = r'\b' + re.escape(word) + r'\b'

pyvim_funcs.vim_grep(pat, mode=mode, hashid=word)
EOF
endfunc


func! FUNC_GrepProject(...) 
Python2or3 << EOF
import vim
import pyvim_funcs, imp; imp.reload(pyvim_funcs)

argv = pyvim_funcs.vim_argv(defaults=[None])
pat = argv[0]
#pat, mode = argv
pyvim_funcs.vim_grep(pat, mode='project')

EOF
endfunc
command! -nargs=1 GrepProject call FUNC_GrepProject(<f-args>)


func! FUNC_Grep(...) 
Python2or3 << EOF
import vim
import pyvim_funcs, imp; imp.reload(pyvim_funcs)

argv = pyvim_funcs.vim_argv(defaults=[None])
pat = argv[0]
#pat, mode = argv
pyvim_funcs.vim_grep(pat, mode='normal')

EOF
endfunc
command! -nargs=1 Grep call FUNC_Grep(<f-args>)


func! FUNC_GrepRepo(...) 
Python2or3 << EOF
import vim
import pyvim_funcs, imp; imp.reload(pyvim_funcs)

argv = pyvim_funcs.vim_argv(defaults=[None])
pat = argv[0]
#pat, mode = argv
pyvim_funcs.vim_grep(pat, mode='repo')

EOF
endfunc
command! -nargs=1 GrepRepo call FUNC_GrepRepo(<f-args>)


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




func! MakePrintVar() 
Python2or3 << EOF
import vim
import pyvim_funcs, imp; imp.reload(pyvim_funcs)
import utool as ut

expr = pyvim_funcs.get_word_at_cursor()
indent = pyvim_funcs.get_cursor_py_indent()

filetype = pyvim_funcs.get_current_filetype()
print('filetype = {!r}'.format(filetype))
if filetype == 'sh':
    statement = 'echo "{expr} = ${expr}"'.format(expr=expr)
elif filetype in {'cmake'}:
    statement = 'message(STATUS "{expr} = ${{{expr}}}")'.format(expr=expr)
elif filetype in {'cpp', 'cxx', 'h'}:
    current_fpath = pyvim_funcs.get_current_fpath()
    if any(n in current_fpath for n in ['vital', 'kwiver', 'sprokit']):
        if pyvim_funcs.find_pattern_above_row(
            '\s*auto logger = kwiver::vital::get_logger.*') is None:
            statement = ut.codeblock(
                '''
                auto logger = kwiver::vital::get_logger("temp.logger");
                LOG_INFO(logger, "{expr} = " << {expr} );
                '''
            ).format(expr=expr)
        else:
            statement = ut.codeblock(
                '''
                LOG_INFO(logger, "{expr} = " << {expr} );
                '''
            ).format(expr=expr)
    else:
        cout = 'std::cout'
        endl = 'std::endl'
        #statement = '{cout} << "{expr} = \\"" << {expr} << "\\"" << {endl};'.format(
        #    expr=expr, cout=cout, endl=endl)
        statement = '{cout} << "{expr} = " << {expr} << {endl};'.format(
            expr=expr, cout=cout, endl=endl)
    # statement = 'printf("{expr} = %s\\n", {expr});'.format(expr=expr)
    pass
else:
    # Default to python
    #newline = indent + "print('{expr} = %r' % ({expr},))".format(expr=expr)
    statement = "print('{expr} = {{!r}}'.format({expr}))".format(expr=expr)

newline = indent + statement.replace('\n', '\n' + indent)
pyvim_funcs.insert_codeblock_under_cursor(newline)
EOF
endfunc


func! MakePrintLine() 
Python2or3 << EOF
import vim
import pyvim_funcs, imp; imp.reload(pyvim_funcs)
import utool as ut
line = pyvim_funcs.get_line_at_cursor()
expr = line.strip(' ')
indent = pyvim_funcs.get_cursor_py_indent()
newline = indent + "print('{expr} = %r' % ({expr},))".format(expr=expr)
pyvim_funcs.insert_codeblock_under_cursor(newline)
if filetype == 'cxx':
    pass
else:
    # Default to python
    #newline = indent + "print('{expr} = %r' % ({expr},))".format(expr=expr)
    newline = indent + "print('{expr} = {{!r}}'.format({expr}))".format(expr=expr)
    pyvim_funcs.insert_codeblock_under_cursor(newline)
EOF
endfunc


" Support python 2 and 3 
if has('python')
    command! -nargs=1 Python2or3 python <args>
elseif has('python3')
    command! -nargs=1 Python2or3 python3 <args>
else
    echo "Error: Requires Vim compiled with +python or +python3"
    finish
endif


func! FoldCopyrightHeader()
Python2or3 << EOF
"""
References:
    https://stackoverflow.com/questions/2250011/can-i-have-vim-ignore-a-license-block-at-the-top-of-a-file

Ignore:
    >>> import os, sys
    >>> sys.path.append(os.path.expanduser('~/local/vim/rc'))
    >>> import pyvim_funcs
    >>> pyvim_funcs.dummy_import_vim('~/code/kwiver/vital/logger/kwiver_logger.cxx')
    >>> import vim
"""
import pyvim_funcs, imp; imp.reload(pyvim_funcs)
pattern = 'Copyright .* by .* THE POSSIBILITY OF SUCH DAMAGE'
pyvim_funcs.close_folds_matching_pattern(pattern, limit=1,
                                         search_range=slice(0, 50))
EOF
endfunc



"-------------------------
command! HexmodeOn :%!xxd
command! HexmodeOff :%!xxd -r 


func! PyResize(...) 
Python2or3 << EOF
import vim
percent = float(vim.eval('a:1'))

dim = float(vim.eval('winheight(0)'))
frac = float(percent / 100.0)
newdim = dim * frac
newdim = max(1, int(newdim))

cmd = 'resize {}'.format(newdim)
print('cmd = {!r}'.format(cmd))
vim.command(cmd)

EOF
endfunc

command! MinimizeSplit resize 10<CR>
command! MaximizeSplit resize 117<CR>

"command! MinimizeSplit call PyResize(20)<CR>
"command! MaximizeSplit call PyResize(100)<CR>
"-------------------------

" http://vim.wikia.com/wiki/View_text_file_in_two_columns
:noremap <silent> <Leader>b :<C-u>let @z=&so<CR>:set so=0 noscb<CR>:bo vs<CR>Ljzt:setl scb<CR><C-w>p:setl scb<CR>:let &so=@z<CR>
"command! TwoColumnEdit :<C-u>let @z=&so<CR>:set so=0 noscb<CR>:bo vs<CR>Ljzt:setl scb<CR><C-w>p:setl scb<CR>:let &so=@z<CR>



"https://vi.stackexchange.com/questions/8378/dump-the-output-of-internal-vim-command-into-buffer
"command! -nargs=+ -complete=command Redir let s:reg = @@ | redir @"> | silent execute <q-args> | redir END | new | pu | 1,2d_ | let @@ = s:reg
" INSTEAD USE
" put = execute('au')
