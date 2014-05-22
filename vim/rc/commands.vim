" ========= Functions ========= "
"command! TextWidthMarkerOn call FUNC_TextWidthMarkerOn()
" Textwidth command
"command! TextWidth80 set textwidth=80
command! TextWidthLineOn call FUNC_TextWidthLineOn()

"-------------------------
command! HexmodeOn :%!xxd
command! HexmodeOff :%!xxd -r 
"-------------------------
command! MYINFOCMD call MYINFO() <C-R>
command! -nargs=1 ECHOVAR :call FUNC_ECHOVAR(<f-args>)

command! Bufloadpy :args *.py
command! SAVESESSION :mksession ~/mysession.vim
command! LOADSESSION :mksession ~/mysession.vim

command! SAVEHSSESSION :mksession ~/vim_hotspotter_session.vim
command! LOADHSSESSION :source ~/vim_hotspotter_session.vim


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
