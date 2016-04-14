" au autocommand

" UNDOO ALL AUTOCOMMANDS
"au!

" e supresses errors  if  nonthing is found
au SwapExists * let v:swapchoice = 'e'

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

func! AuOnReadPatterns(aucmdstr, ...)
python << endpython
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
endpython
endfu

func! AuPreWritePatterns(aucmdstr, ...)
python << endpython
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
endpython
endfu

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
au FileType cpp setlocal foldmethod=syntax
autocmd FileType cpp normal zR
"autocmd FileType cpp if getfsize(@%) > 200 | set foldmethod=syntax | endif
"autocmd FileType cpp if getfsize(@%) > 200 | normal zR | endif


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
"
"au BufNewFile,BufRead *.tex call LatexInitialize() 
"autocmd Filetype tex,latex set spell spelllang=en_us
"autocmd Filetype tex,latex set iskeyword+=@,48-57,_,-,:,192-255
"autocmd Filetype python set iskeyword-=@,48-57,_,-,:,192-255
"g:tex_isk='48-57,a-z,A-Z,192-255,_
"au FileType python call PythonInvert()
"au FileType python set textwidth=80
"


"function! GetPythonTextWidth()
"    " http://stackoverflow.com/questions/4027222/vim-use-shorter-textwidth-in-comments-and-docstrings
"    if !exists('g:python_normal_text_width')
"        let normal_text_width = 79
"    else
"        let normal_text_width = g:python_normal_text_width
"    endif

"    if !exists('g:python_comment_text_width')
"        let comment_text_width = 72
"    else
"        let comment_text_width = g:python_comment_text_width
"    endif

"    let cur_syntax = synIDattr(synIDtrans(synID(line("."), col("."), 0)), "name")
"    if cur_syntax == "Comment"
"        return comment_text_width
"    elseif cur_syntax == "String"
"        " Check to see if we're in a docstring
"        let lnum = line(".")
"        while lnum >= 1 && (synIDattr(synIDtrans(synID(lnum, col([lnum, "$"]) - 1, 0)), "name") == "String" || match(getline(lnum), '\v^\s*$') > -1)
"            if match(getline(lnum), "\\('''\\|\"\"\"\\)") > -1
"                " Assume that any longstring is a docstring
"                return comment_text_width
"            endif
"            let lnum -= 1
"        endwhile
"    endif

"    return normal_text_width
"endfunction

"augroup pep8
"    au!
"    autocmd CursorMoved,CursorMovedI * :if &ft == 'python' | :exe 'setlocal textwidth='.GetPythonTextWidth() | :endif
"augroup END


"autocmd BufRead,BufNewFile *.tex setlocal textwidth=72

