" au autocommand
"
" to dump all autocommands into current buffer
" put = execute('au')
" vim myau.vim -c "put = execute('au MyVimRC')"
" vim myau.vim -c "put = execute('au PostMyVimRC')"

" UNDOO ALL AUTOCOMMANDS
"au!

:augroup MyVimRC

func! AuOnReadPatterns(aucmdstr, ...)
Python2or3 << endpython3
# Executes pre-read `aucmdstr` on files matching `pattern`
import vim
aucmdstr = vim.eval('a:aucmdstr')
N = int(vim.eval('a:0'))
for ix in range(1, N + 1):
    pattern = vim.eval('a:%d' % ix)
    cmdfmt = "au MyVimRC BufNewFile,BufRead {pattern} {aucmdstr}"
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
    cmdfmt = "au MyVimRC BufWritePre {pattern} {aucmdstr}"
    cmdstr = cmdfmt.format(pattern=pattern, aucmdstr=aucmdstr)
    vim.command(cmdstr)
endpython3
endfu


func! AuFileType(aucmdstr, ...)
Python2or3 << endpython3
# Executes `aucmdstr` on `filetype`
import vim
aucmdstr = vim.eval('a:aucmdstr')
N = int(vim.eval('a:0'))
for ix in range(1, N + 1):
    filetype = vim.eval('a:%d' % ix)
    cmdfmt = "au MyVimRC FileType {filetype} {aucmdstr}"
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
au MyVimRC BufNewFile,BufReadPost *.md set filetype=markdown

let g:markdown_syntax_conceal = 0
let g:markdown_fenced_languages = ['html', 'python', 'bash=sh']


" e supresses errors  if  nonthing is found
au MyVimRC SwapExists * let v:swapchoice = 'e'

if exists('+colorcolumn')
    :call AuFileType('setlocal colorcolumn=', 'text', 'markdown', 'tex')
    :call AuFileType('setlocal colorcolumn=81', 'python', 'vim', 'cpp')
    "au FileType text setlocal colorcolumn=
    "au FileType python setlocal colorcolumn=81
    "au FileType vim setlocal colorcolumn=81
endif

" Python indenting, folding, etc...
"au FileType python set omnifunc=pythoncomplete#Complete
au MyVimRC FileType python setlocal nosmartindent
au MyVimRC FileType python filetype indent on
au MyVimRC FileType python setlocal foldmethod=indent
au MyVimRC FileType python setlocal foldnestmax=3
au MyVimRC FileType python setlocal nospell

au MyVimRC FileType vim setlocal nospell

" C++ indenting, folding, etc...
au MyVimRC FileType cpp setlocal cino=i-s
au MyVimRC FileType cpp setlocal cinkeys=0{,0},0),:,!^F,o,O,e
au MyVimRC FileType cpp setlocal cinkeys-=0#
au MyVimRC FileType cpp setlocal smartindent
au MyVimRC Filetype cpp setlocal shiftwidth=2
au MyVimRC Filetype cpp setlocal tabstop=2

" Latex

" Make latex files a bit more responsive
" https://bbs.archlinux.org/viewtopic.php?id=111647
"au MyVimRC FileType tex :NoMatchParen
"au MyVimRC FileType tex setlocal nocursorline

" http://stackoverflow.com/questions/18219444/remove-underscore-as-a-word-separator-in-vim
au MyVimRC Filetype tex setlocal iskeyword+=_
au MyVimRC Filetype tex setlocal spell
au MyVimRC Filetype tex setlocal conceallevel=0


" CMAKE
au MyVimRC Filetype cmake setlocal shiftwidth=2
au MyVimRC Filetype cmake setlocal tabstop=2

" Reference http://stackoverflow.com/questions/6671199/vim-multiline-highlight
":call AuOnReadPatterns('syntax sync minlines=500', '*.py')


" Prewrite Modifications
" Remove trailing whitespace
":call AuPreWritePatterns(':%s/  *$//e', '*.py', '*.c', '*.cxx', '*.cpp', '*.h', '*.hpp', '*.hxx')
au MyVimRC BufWritePre *.py :%s/\s\+$//e
au MyVimRC BufWritePre *.py :%s///e


"au! BufWritePre *.py :%s/\s\+$//e
"au BufWritePre *.c :%s/\s\+$//e
"au BufWritePre *.cxx :%s/\s\+$//e
"au BufWritePre *.cpp :%s/\s\+$//e
"au BufWritePre *.h :%s/\s\+$//e
"au BufWritePre *.hpp :%s/\s\+$//e
"au BufWritePre *.hxx :%s/\s\+$//e

" =========== OLD ==============
"au FileType c,cpp,java,php,ruby,python au BufWritePre <buffer> :call <SID>StripTrailingWhitespaces()

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
au MyVimRC FileType cpp setlocal foldmethod=syntax
au MyVimRC FileType cpp normal zR
"au FileType cpp if getfsize(@%) > 200 | set foldmethod=syntax | endif
"au FileType cpp if getfsize(@%) > 200 | normal zR | endif


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
"au BufWinLeave *.* mkview
"au BufWinEnter *.* silent loadview 
"
"au BufNewFile,BufRead *.tex call LatexInitialize() 
"au Filetype tex set spell spelllang=en_us
"au Filetype tex set iskeyword+=@,48-57,_,-,:,192-255
"au Filetype python set iskeyword-=@,48-57,_,-,:,192-255
"g:tex_isk='48-57,a-z,A-Z,192-255,_
"au FileType python call PythonInvert()
"au FileType python set textwidth=80


:augroup PostMyVimRC
