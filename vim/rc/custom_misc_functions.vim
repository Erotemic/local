"""
" SeeAlso; 
"     ~/local/vim/rc_settings/remap_settings.vim
"
"""


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
        silent !terminator --working-directory=$(pwd)&
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


func! PyCiteLookup() 
Python2or3 << EOF
"""
SeeAlso:
    ~/local/vim/rc_settings/remap_settings.vim
"""
import vim
import pyvim_funcs
word = pyvim_funcs.get_word_at_cursor()

bibtex_dict = pyvim_funcs.get_bibtex_dict()

title = bibtex_dict[word]['title'].replace('{', '').replace('}', '')
pyvim_funcs.copy_text_to_clipboard(title)
print(title)
#print(repr(word))
EOF
endfunc


func! MarkdownPreview() 
Python2or3 << EOF
import vim
import pyvim_funcs
buffer_name = vim.current.buffer.name
print('mdview buffer_name = %r' % (buffer_name,))
os.system('mdview ' + buffer_name + '&')
EOF
endfunc



func! MakePrintLine() 
Python2or3 << EOF
import vim
import pyvim_funcs
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
import pyvim_funcs
pattern = 'Copyright .* by .* THE POSSIBILITY OF SUCH DAMAGE'
pyvim_funcs.close_matching_folds(pattern, search_range=(0, 50), limit=1)
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
":noremap <silent> <Leader>b :<C-u>let @z=&so<CR>:set so=0 noscb<CR>:bo vs<CR>Ljzt:setl scb<CR><C-w>p:setl scb<CR>:let &so=@z<CR>
"command! TwoColumnEdit :<C-u>let @z=&so<CR>:set so=0 noscb<CR>:bo vs<CR>Ljzt:setl scb<CR><C-w>p:setl scb<CR>:let &so=@z<CR>



"https://vi.stackexchange.com/questions/8378/dump-the-output-of-internal-vim-command-into-buffer
"command! -nargs=+ -complete=command Redir let s:reg = @@ | redir @"> | silent execute <q-args> | redir END | new | pu | 1,2d_ | let @@ = s:reg
" INSTEAD USE
" put = execute('au')
"
function! MathAndLiquid()
    " http://scottsievert.com/blog/2016/01/06/vim-jekyll-mathjax/
    "" Define certain regions
    " Block math. Look for "$$[anything]$$"
    syn region math start=/\$\$/ end=/\$\$/
    " inline math. Look for "$[not $][anything]$"
    syn match math_block '\$[^$].\{-}\$'

    " Liquid single line. Look for "{%[anything]%}"
    syn match liquid '{%.*%}'
    " Liquid multiline. Look for "{%[anything]%}[anything]{%[anything]%}"
    syn region highlight_block start='{% highlight .*%}' end='{%.*%}'
    " Fenced code blocks, used in GitHub Flavored Markdown (GFM)
    syn region highlight_block start='```' end='```'

    "" Actually highlight those regions.
    hi link math Statement
    hi link liquid Statement
    hi link highlight_block Function
    hi link math_block Function
    setlocal spell
endfunction
