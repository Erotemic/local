" au autocommand

" UNDOO ALL AUTOCOMMANDS
"au!

" e supresses errors  if  nonthing is found
au SwapExists * let v:swapchoice = 'e'

" Python indenting, folding, etc...
"au FileType python set omnifunc=pythoncomplete#Complete
au FileType python set nosmartindent
au FileType python filetype indent on
"au FileType python set textwidth=80
au FileType python set foldmethod=indent
au FileType python set foldnestmax=3
au FileType python set nospell
"au FileType python call PythonInvert()

" C++ indenting, folding, etc...
au FileType cpp set cino=i-s
au FileType cpp set cinkeys=0{,0},0),:,!^F,o,O,e
au FileType cpp set cinkeys-=0#
au FileType cpp set smartindent

" Latex
"au BufNewFile,BufRead *.tex call LatexInitialize() 
autocmd Filetype tex,latex set spell
autocmd Filetype tex,latex set spell spelllang=en_us
" http://stackoverflow.com/questions/18219444/remove-underscore-as-a-word-separator-in-vim
autocmd Filetype tex,latex set iskeyword+=_
"g:tex_isk='48-57,a-z,A-Z,192-255,_

" AuOnReadPatterns is defined in custom_misc_functions
:call AuOnReadPatterns('set ft=cpp', '*.txx')
:call AuOnReadPatterns('set ft=python', '*.py.tpl')
:call AuOnReadPatterns('set ft=cmake', '*.poly', '*.node', '.ele')
:call AuOnReadPatterns('set ft=cython', '*.pyx', '.pxd')
:call AuOnReadPatterns('set ft=Autohotkey', '*.ahk')

" Reference http://stackoverflow.com/questions/6671199/gvim-long-multiline-string-highlighting
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
au BufNewFile,BufRead *.spec set ft=python
au BufNewFile,BufRead *.py.tpl set ft=python
"au BufNewFile,BufRead *.node set ft=cmake
"au BufNewFile,BufRead *.ele  set ft=cmake
"au BufNewFile,BufRead *.ahk, set ft=Autohotkey
""Read vidtk config files as vidtk config file
"au BufRead,BufNewFile *.conf setfiletype vidtkconf
"
au FileType cpp set foldmethod=syntax
"autocmd FileType cpp if getfsize(@%) > 200 | set foldmethod=syntax | endif
"autocmd FileType cpp if getfsize(@%) > 200 | normal zR | endif
autocmd FileType cpp normal zR


"au CursorMoved * call WordHighlightFun()
"au InsertLeave * hi Cursor guibg=red
"au InsertEnter * hi Cursor guibg=green


" Use shell syntax for markdown files
"au BufNewFile,BufRead *.md set ft=sh
"au BufNewFile,BufRead *.md set ft=markdown
"
"
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
