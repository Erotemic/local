" Website showing commands to list env settings
"http://vim.wikia.com/wiki/Displaying_the_current_Vim_environment
" Show global variables
":let          - all variables
":let FooBar   - variable FooBar
":let g:       - global variables
":let v:       - Vim variables

" Dump all settings to file
":mkv vim-settings-dump.vim
"
"
"THis is how to actually do it
":redir @a " Redirect into buffer a
"< DO COMMAND> 
"redir NED
""ap


" Send 1 arg to function
command! -nargs=1 ECHOVAR :call FUNC_ECHOVAR(<f-args>)


" Pass arg to func
fu! FUNC_DICT_TO_ATTR(dictstr)
    let dictstr=a:dictstr
endfu


" Pass range to command
command! -range PEP8ALIGNDICT <line1>,<line2>call PEP8ALIGNDICT()<CR>


" PYTHON IN VIM
func! OpenSetups()
"http://orestis.gr/blog/2008/08/10/scripting-vim-with-python/
python << endpython
import vim
vim.command(":exec comand stuff")
vim.command(":set nofoldenable")
#vim.command - execute a vim command
#vim.eval - evaluate a vim expression and return the result
#vim.current.window.cursor - get the cursor position as (row, col) (row is 1-based, col is 0-based)
#vim.current.buffer - a list of the lines in the current buffer (0-based, unfortunately)
endpython
endfu



" Multiple arguments
func! QUICKOPEN_leader_tvio(...)
    let key = a:1
    let fname = a:2
endfu
" 
