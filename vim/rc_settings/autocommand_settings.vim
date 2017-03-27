" au autocommand

" UNDOO ALL AUTOCOMMANDS
"au!

func! AuOnReadPatterns(aucmdstr, ...)
Python2or3 << endpython3
# Executes pre-read `aucmdstr` on files matching `pattern`
import vim
aucmdstr = vim.eval('a:aucmdstr')
N = int(vim.eval('a:0'))
for ix in range(1, N + 1):
    pattern = vim.eval('a:%d' % ix)
    cmdfmt = "au BufNewFile,BufRead {pattern} {aucmdstr}"
    cmd = cmdfmt.format(pattern=pattern, aucmdstr=aucmdstr)
    vim.command(cmd)
endpython3
endfu

func! AuPreWritePatterns(aucmdstr, ...)
Python2or3 << endpython3
# Executes pre-write `aucmdstr` on files matching `pattern`
import vim
aucmdstr = vim.eval('a:aucmdstr')
N = int(vim.eval('a:0'))
for ix in range(1, N + 1):
    pattern = vim.eval('a:%d' % ix)
    cmdfmt = "au BufWritePre {pattern} {aucmdstr}"
    cmdstr = cmdfmt.format(pattern=pattern, aucmdstr=aucmdstr)
    vim.command(cmdstr)
endpython3
endfu


func! AuFileType(aucmdstr, ...)
Python2or3 << endpython3
# Executes `aucmdstr` on `filtypes`
import vim
aucmdstr = vim.eval('a:aucmdstr')
N = int(vim.eval('a:0'))
for ix in range(1, N + 1):
    filetype = vim.eval('a:%d' % ix)
    cmdfmt = "au FileType {filetype} {aucmdstr}"
    cmdstr = cmdfmt.format(filetype=filetype, aucmdstr=aucmdstr)
    vim.command(cmdstr)
endpython3
endfu

" Associate extensions with vim filetypes
:call AuOnReadPatterns('set ft=cpp', '*.txx')
:call AuOnReadPatterns('set ft=tex', '*.tex')
:call AuOnReadPatterns('set ft=python', '*.py.tpl')
:call AuOnReadPatterns('set ft=cmake', '*.poly', '*.node', '.ele')
:call AuOnReadPatterns('set ft=cython', '*.pyx', '.pxd')
:call AuOnReadPatterns('set ft=Autohotkey', '*.ahk')
":call AuOnReadPatterns('set ft=markdown', '*.md')
autocmd BufNewFile,BufReadPost *.md set filetype=markdown

let g:markdown_syntax_conceal = 0
let g:markdown_fenced_languages = ['html', 'python', 'bash=sh']


" e supresses errors  if  nonthing is found
au SwapExists * let v:swapchoice = 'e'

if exists('+colorcolumn')
    :call AuFileType('setlocal colorcolumn=', 'text', 'markdown', 'latex', 'tex')
    :call AuFileType('setlocal colorcolumn=81', 'python', 'vim', 'cpp')
    "au FileType text setlocal colorcolumn=
    "au FileType python setlocal colorcolumn=81
    "au FileType vim setlocal colorcolumn=81
endif

" Python indenting, folding, etc...
"au FileType python set omnifunc=pythoncomplete#Complete
au FileType python setlocal nosmartindent
au FileType python filetype indent on
au FileType python setlocal foldmethod=indent
au FileType python setlocal foldnestmax=3
au FileType python setlocal nospell

" C++ indenting, folding, etc...
au FileType cpp setlocal cino=i-s
au FileType cpp setlocal cinkeys=0{,0},0),:,!^F,o,O,e
au FileType cpp setlocal cinkeys-=0#
au FileType cpp setlocal smartindent

" Latex
autocmd Filetype tex,latex setlocal spell
" http://stackoverflow.com/questions/18219444/remove-underscore-as-a-word-separator-in-vim
autocmd Filetype tex,latex setlocal iskeyword+=_

" Reference http://stackoverflow.com/questions/6671199/vim-multiline-highlight
:call AuOnReadPatterns('syntax sync minlines=500', '*.py')


" Prewrite Modifications
" Remove trailing whitespace
":call AuPreWritePatterns(':%s/  *$//e', '*.py', '*.c', '*.cxx', '*.cpp', '*.h', '*.hpp', '*.hxx')
au BufWritePre *.py :%s/\s\+$//e
au BufWritePre *.py :%s///e


"au! BufWritePre *.py :%s/\s\+$//e
"au BufWritePre *.c :%s/\s\+$//e
"au BufWritePre *.cxx :%s/\s\+$//e
"au BufWritePre *.cpp :%s/\s\+$//e
"au BufWritePre *.h :%s/\s\+$//e
"au BufWritePre *.hpp :%s/\s\+$//e
"au BufWritePre *.hxx :%s/\s\+$//e

" =========== OLD ==============
"autocmd FileType c,cpp,java,php,ruby,python autocmd BufWritePre <buffer> :call <SID>StripTrailingWhitespaces()

"au BufNewFile,BufRead *.txx  set ft=cpp
"au BufNewFile,BufRead *.poly set ft=cmake
"au BufNewFile,BufRead *.pyx  set ft=cython
"au BufNewFile,BufRead *.spec set ft=python
"au BufNewFile,BufRead *.py.tpl set ft=python
"au BufNewFile,BufRead *.md set ft=markdown
"au BufNewFile,BufRead *.node set ft=cmake
"au BufNewFile,BufRead *.ele  set ft=cmake
"au BufNewFile,BufRead *.ahk, set ft=Autohotkey
""Read vidtk config files as vidtk config file
"au BufRead,BufNewFile *.conf setfiletype vidtkconf
"
au FileType cpp setlocal foldmethod=syntax
au FileType cpp normal zR
"autocmd FileType cpp if getfsize(@%) > 200 | set foldmethod=syntax | endif
"autocmd FileType cpp if getfsize(@%) > 200 | normal zR | endif


"au CursorMoved * call WordHighlightFun()
"au InsertLeave * hi Cursor guibg=red
"au InsertEnter * hi Cursor guibg=green

":call AuPreWritePatterns(':%s/\s\+$//e', '*.py', '*.c', '*.cxx', '*.cpp', '*.h', '*.hpp', '*.hxx')
":call AuCmdPatterns('set ft=vidtkconf', '*.conf')
"au BufWritePre *.py :%s/\t/    /g
"au BufNewFile,BufRead *.py :%s/\t/    /g
"au FileType python set foldmethod=syntax
"


" Save folds between runs 
" http://vim.wikia.com/wiki/VimTip991
"autocmd BufWinLeave *.* mkview
"autocmd BufWinEnter *.* silent loadview 
"
"au BufNewFile,BufRead *.tex call LatexInitialize() 
"autocmd Filetype tex,latex set spell spelllang=en_us
"autocmd Filetype tex,latex set iskeyword+=@,48-57,_,-,:,192-255
"autocmd Filetype python set iskeyword-=@,48-57,_,-,:,192-255
"g:tex_isk='48-57,a-z,A-Z,192-255,_
"au FileType python call PythonInvert()
"au FileType python set textwidth=80
