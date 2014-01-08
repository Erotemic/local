"source $PORT_SETTINGS/vim/re_matlab2python.vim


" for some reason the csscolor plugin is very slow when run on the terminal
" but not in GVim, so disable it if no GUI is running
"if !has('gui_running')
    "call add(g:pathogen_disabled, 'csscolor')
"endif
"" Gundo requires at least vim 7.3
"if v:version < '703' || !has('python')
    "call add(g:pathogen_disabled, 'gundo')
"endif
"if v:version < '702'
    "call add(g:pathogen_disabled, 'autocomplpop')
    "call add(g:pathogen_disabled, 'fuzzyfinder')
    "call add(g:pathogen_disabled, 'l9')
"endif
"
" LATEX MODE
"let NERDTreeIgnore = ['\.o$','\~$','\.pyc$','\.aux$','\.masv$','\.bbl$','\.bcf$','\.blg$','\.brf$','\.synctex$','\.upa$','\.upb$','\.pdf$','\.out$','\.log','\.latexmain','\.bib','\.bst$']


"let g:syntastic_ignore_files = ['^/usr/include/', '\c\.h$']
"
"
" -------------- Commands I use A Lot -------------
"
"
"
"http://vim.wikia.com/wiki/VimTip1572
" Remove highlight for visual selection (if any), or current word.
":Hclear
"" Remove highlight 24.
":Hclear 24
"" Remove all highlights for pattern '\c\<th'.
":Hclear \c\<th
"" Remove all highlights.
":Hclear *


"
"
"
"
" Reloads vimrc on save
"autocmd BufWritePost portable_vimrc source %

" CVS SORT
" :sort/^[^,]*,/|g/^[^,]*,\([^,]*\),.*\n[^,]*,\1,.*/d_
" http://stackoverflow.com/questions/10237612/sort-u-but-only-on-one-column-in-a-csv
"
" sort n/^[^,]*,/
"
" sort n/.*\%3v/


" The last command entered with ':' can be repeated with @: and further repeats can be done with @@
"This is useful for commands like :bnext or :cNext.


