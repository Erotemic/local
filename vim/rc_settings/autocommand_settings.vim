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
"au BufNewFile,BufRead *.py :%s/\t/    /g

au BufNewFile,BufRead *.tex call LatexInitialize() 
au SwapExists * let v:swapchoice = 'e'

au BufNewFile,BufRead *.txx  set ft=cpp
au BufNewFile,BufRead *.poly set ft=cmake
au BufNewFile,BufRead *.pyx  set ft=cython
au BufNewFile,BufRead *.spec set ft=python
au BufNewFile,BufRead *.node set ft=cmake
au BufNewFile,BufRead *.ele  set ft=cmake
au BufNewFile,BufRead *.ahk, set ft=Autohotkey
"Read vidtk config files as vidtk config file
au BufRead,BufNewFile *.conf setfiletype vidtkconf
" Remove trailing whitespace
"au BufWritePre *.py :%s/\t/    /g
au! BufWritePre *.py :%s/\s\+$//e
au BufWritePre *.py :%s/\s\+$//e
au BufWritePre *.c :%s/\s\+$//e
au BufWritePre *.cxx :%s/\s\+$//e
au BufWritePre *.cpp :%s/\s\+$//e
au BufWritePre *.h :%s/\s\+$//e
au BufWritePre *.hpp :%s/\s\+$//e
au BufWritePre *.hxx :%s/\s\+$//e

" C++ indenting and folding
au FileType cpp set cino=i-s
au FileType cpp set cinkeys=0{,0},0),:,!^F,o,O,e
au FileType cpp set cinkeys-=0#
au FileType cpp set smartindent
"au FileType cpp set foldmethod=syntax

au CursorMoved * call WordHighlightFun()
au InsertLeave * hi Cursor guibg=red
au InsertEnter * hi Cursor guibg=green


" Use shell syntax for markdown files
"au BufNewFile,BufRead *.md set ft=sh
"au BufNewFile,BufRead *.md set ft=markdown
"
"

func! <SID>StripTrailingWhitespaces()
    "http://stackoverflow.com/questions/356126/how-can-you-automatically-remove-trailing-whitespace-in-vim
    let l = line(".")
    let c = col(".")
    %s/\s\+$//e
    call cursor(l, c)
endfun

"autocmd FileType c,cpp,java,php,ruby,python autocmd BufWritePre <buffer> :call <SID>StripTrailingWhitespaces()
