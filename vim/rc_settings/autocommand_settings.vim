" au autocommand

" UNDOO ALL AUTOCOMMANDS
"au!


" Define python autocommands
"au FileType python set omnifunc=pythoncomplete#Complete
au FileType python set nosmartindent
au FileType python filetype indent on
au FileType python set textwidth=80
au FileType python set foldmethod=indent
"au FileType python set foldmethod=syntax
au FileType python set foldnestmax=2
"au FileType python call PythonInvert()
"au BufNewFile,BufRead *.py :%s/\t/    /g

"au BufNewFile,BufRead *.tex call LatexInitialize() 
au SwapExists * let v:swapchoice = 'e'

:call AuOnReadPatterns('set ft=cpp', '*.txx')
:call AuOnReadPatterns('set ft=cmake', '*.poly', '*.node', '.ele')
:call AuOnReadPatterns('set ft=cython', '*.pyx', '.pxd')
:call AuOnReadPatterns('set ft=Autohotkey', '*.ahk')
":call AuCmdPatterns('set ft=vidtkconf', '*.conf')

"au BufNewFile,BufRead *.txx  set ft=cpp
"au BufNewFile,BufRead *.poly set ft=cmake
"au BufNewFile,BufRead *.pyx  set ft=cython
"au BufNewFile,BufRead *.spec set ft=python
"au BufNewFile,BufRead *.node set ft=cmake
"au BufNewFile,BufRead *.ele  set ft=cmake
"au BufNewFile,BufRead *.ahk, set ft=Autohotkey
""Read vidtk config files as vidtk config file
"au BufRead,BufNewFile *.conf setfiletype vidtkconf

" Remove trailing whitespace
"au BufWritePre *.py :%s/\t/    /g
" e supresses errors  if  nonthing is found
":call AuPreWritePatterns(':%s/\s\+$//e', '*.py', '*.c', '*.cxx', '*.cpp', '*.h', '*.hpp', '*.hxx')
:call AuPreWritePatterns(':%s/  *$//e', '*.py', '*.c', '*.cxx', '*.cpp', '*.h', '*.hpp', '*.hxx')
"au! BufWritePre *.py :%s/\s\+$//e
au BufWritePre *.py :%s/\s\+$//e
"au BufWritePre *.c :%s/\s\+$//e
"au BufWritePre *.cxx :%s/\s\+$//e
"au BufWritePre *.cpp :%s/\s\+$//e
"au BufWritePre *.h :%s/\s\+$//e
"au BufWritePre *.hpp :%s/\s\+$//e
"au BufWritePre *.hxx :%s/\s\+$//e

" C++ indenting and folding
au FileType cpp set cino=i-s
au FileType cpp set cinkeys=0{,0},0),:,!^F,o,O,e
au FileType cpp set cinkeys-=0#
au FileType cpp set smartindent
"au FileType cpp set foldmethod=syntax

"au CursorMoved * call WordHighlightFun()
"au InsertLeave * hi Cursor guibg=red
"au InsertEnter * hi Cursor guibg=green


" Use shell syntax for markdown files
"au BufNewFile,BufRead *.md set ft=sh
"au BufNewFile,BufRead *.md set ft=markdown
"
"

"autocmd FileType c,cpp,java,php,ruby,python autocmd BufWritePre <buffer> :call <SID>StripTrailingWhitespaces()
