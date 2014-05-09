
" Open OS window
function! OpenWindow()
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
            call libcallnr("~/local/vim/rc/vimtweak.dll", "SetAlpha", 220) 
        else 
            call libcallnr("~/local/vim/rc/vimtweak.dll", "SetAlpha", 255) 
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


fu! FUNC_ECHOVAR(varname)
    :let varstr=a:varname
    :exec 'let g:foo = &'.varstr
    :echo varstr.' = '.g:foo
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


func! MYINFO()
    :ECHOVAR cino
    :ECHOVAR cinkeys
    :ECHOVAR foldmethod
    :ECHOVAR filetype
    :ECHOVAR smartindent
endfu


func! QUICKOPEN_leader_tsio(...)
    " Maps <leader>t<key> to tab open a filename
    " Maps <leader>s<key> to vsplit open a filename
    " Maps <leader>i<key> to split open a filename
    let key = a:1
    let fname = a:2
    :exec 'noremap <leader>t'.key.' :tabe '.fname.'<CR>'
    :exec 'noremap <leader>s'.key.' :vsplit '.fname.'<CR>'
    :exec 'noremap <leader>i'.key.' :split '.fname.'<CR>'
    :exec 'noremap <leader>o'.key.' :e '.fname.'<CR>'
endfu



func! PrintPlugins()
    " where was an option set
    :scriptnames " list all plugins, _vimrcs loaded (super)
    :verbose set history? " reveals value of history and where set
    :function " list functions
    :func SearchCompl " List particular function
endfu
