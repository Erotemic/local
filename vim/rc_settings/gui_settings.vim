"-------------------------
"GUI Options (go=guioptions)
" default "egmrLtT"   (MS-Windows)
"         "aegimrLtT" (GTK, Motif and Athena))
:set go-=m  " MENUBAR
:set go+=g  " gray menu items
:set go+=r go+=R  " RIGHT_VERT_SCROLL
:set go-=l go-=L  " LEFT_VERT_SCROLL
:set go-=b go-=B  " BOT_VERT_SCROLL 
:set go+=e  " GUI_TABS
:set go-=T  " GUI_TOOLBAR (useless anyway)
:set go-=a  " autoselect (automatic copy to clipboard)
:set clipboard-=autoselect


set hlsearch
" :s/\( *\):/:\1/gc
":set guitablabel=%N/\ %t
:set guitablabel=%N/\ %t\ %M



