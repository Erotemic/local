"-------------------------
"""
" SeeAlso:
"     ~/local/vim/rc/custom_misc_functions.vim
"     ~/local/vim/rc/custom_py_functions.vim
"     ~/local/vim/rc/custom_ipy_interact_funcs.vim
"""
" Function Remaps
"map <F1> :call  ToggleWordHighlight()<CR>
"Map Ctrl+W (navkey) to Ctrl+(navkey) (for split windows)


"-------------------------
" CUSOM VIM COMMAND PREFIX
"
" Remap colon to semicolon in normal and visual mode, but not interactive mode
":call vimtk#remap_all_modes(':',';')
":call vimtk#swap_keys : ;
"VimTK_swap_keys : ;
"CMDSWAP : ;
"-------------------------

"---------------------
" CUSOM VIM LEADER KEY
"
" Map leader key to comma (in all contexts)
let mapleader = ","
let maplocalleader = ","
noremap \ ,
"----------------------

" Generally helpful

" Search and replace under cursor
noremap <leader>ss :%s/\<<C-r><C-w>\>/
"Surround word with quotes
noremap <leader>qw ciw'<C-r>"'<Esc>
noremap <leader>qc ciw`<C-r>"`<Esc>


" File navigation
noremap <C-T> :NERDTree<CR>
noremap <leader>. :NERDTree<CR>
noremap <leader>h :NERDTreeToggle<CR>
"noremap <leader>h :Tlist<CR>
noremap <leader>j :Tagbar<CR>


" Text formatting
"vnoremap <leader>fp :call PyFormatParagraph()<CR>
"vnoremap <leader>fe :call PyFormatParagraph()<CR>
"vnoremap ge :call PyFormatParagraph()<CR>
"noremap <leader>ge :call PySelectAndFormatParagraph()<CR>
"noremap <c-g> :call PySelectAndFormatParagraph('max_width=110')<CR>
"noremap <c-f> :call PySelectAndFormatParagraph('max_width=80,myprefix=False,sentence_break=False')<CR>

vnoremap ge :call vimtk#py_select_and_format_paragraph()<CR>
vnoremap fe :call vimtk#py_select_and_format_paragraph()<CR>
vnoremap fp :call vimtk#py_select_and_format_paragraph()<CR>
noremap <leader>ge :call vimtk#py_select_and_format_paragraph()<CR>
noremap <c-g> :call vimtk#py_select_and_format_paragraph('{"max_width": 110}')<CR>
noremap <c-f> :call vimtk#py_select_and_format_paragraph('{"max_width": 80, "myprefix": False, "sentence_break": False}')<CR>

noremap <c-M-G> :call PySelectAndFormatParagraphNoBreak()<CR>

" Quick reference jumping
noremap <leader>el :call PyCiteLookup()<CR>

"noremap <leader>es :call SmartSearchWordAtCursor()<CR>
noremap <leader>eg :call GrepWordAtCursor('normal')<CR>
noremap <leader>ep :call GrepWordAtCursor('project')<CR>
"noremap <leader>egg :call GrepWordAtCursor('normal')<CR>

" Python Debugging Snippets
"noremap  <c-b>   :call PyMakeEmbed()<CR><Esc>
"inoremap <c-b>   <Esc>:call PyMakeEmbed()<CR>i
noremap  <c-b>   :call vimtk_snippets#insert_xdev_embed()<CR><Esc>
inoremap <c-b>   <Esc>:call vimtk_snippets#insert_xdev_embed()<CR>i

"noremap  <m-b>   :call PyMakeWithEmbed(mode())<CR><Esc>
"vnoremap <m-b>   :call PyMakeWithEmbed(visualmode())<CR><Esc>
"inoremap <m-b> <Esc>:call PyMakeWithEmbed()<CR>i
noremap  <m-b>   :call vimtk_snippets#insert_xdev_embed_on_exception_context(mode())<CR><Esc>
vnoremap <m-b>   :call vimtk_snippets#insert_xdev_embed_on_exception_context(visualmode())<CR><Esc>
inoremap <m-b> <Esc>:call vimtk_snippets#insert_xdev_embed_on_exception_context()<CR>i

" Timing
"noremap  <c-M-B> :call PyMakeTimerit(mode())<CR><Esc>
"vnoremap <c-M-B> :call PyMakeTimerit(visualmode())<CR><Esc>

noremap  <c-M-B> :call vimtk_snippets#insert_timerit(mode())<CR><Esc>
vnoremap <c-M-B> :call vimtk_snippets#insert_timerit(visualmode())<CR><Esc>

" Python Autogen Snippets
noremap <leader>d  :call InsertDocstr()<CR>
noremap <leader>ed :call InsertDocstr()<CR>
noremap <leader>ea :call InsertDocstrOnlyArgs()<CR>
"noremap <leader>ec :call InsertDocstrOnlyCommandLine()<CR>
noremap <leader>ec :call vimtk_snippets#insert_docstr_commandline()<CR>

"noremap <leader>em :call InsertPyMain()<CR>
"noremap <leader>eh :call PyInsertHeader()<CR>
"noremap <leader>eH :call PyInsertHeader('script')<CR>
"noremap <leader>ek :call PyMakeXDevKwargs()<CR>
noremap <leader>em :call vimtk_snippets#insert_python_main()<CR>
noremap <leader>eh :call vimtk_snippets#insert_python_header()<CR>
noremap <leader>eH :call vimtk_snippets#insert_python_header('script')<CR>
noremap <leader>ek :call vimtk_snippets#insert_xdev_global_kwargs()<CR>


noremap <c-d> :call InsertDocstr()<CR>
noremap <c-1> :call InsertDocstr()<CR>
inoremap <c-1> :call InsertDocstr()<CR>

"inoremap <c-2> :call AutoPep8Block()<CR>
"noremap <c-2> :call AutoPep8Block()<CR>

" Misc python snippets
"noremap <leader>pv :call MakePrintVar()<CR>
"noremap <leader>pv :call vimtk_snippets#insert_print_var_at_cursor()<CR>

noremap <leader>pl :call MakePrintLine()<CR>
" insert a NOQA
noremap <leader>n A  # NOQA<Esc>
" Change dictionary body to ordered dictionary
noremap <leader>ro :s/^\( *\)\([^ ]\)/\1(\2/ <bar> '<,'>s/,$/),/ <bar> '<,'>s/:/,/<CR>

" Doctest editing
"vnoremap gd :call PyFormatDoctest()<CR>
"vnoremap gu :call PyUnFormatDoctest()<CR>


" -------- Interactive Editing
" copy whatever is in clipboard to terminal
noremap  <leader>z :call CopyGVimToTerminalDev('clipboard', 1)<CR>
" DO line in ipython and RETURN to vim

let g:vimtk_default_mappings=1
"noremap  <leader>a :call CopyGVimToTerminalDev(mode(), 1)<CR>
"vnoremap <leader>a :call CopyGVimToTerminalDev(visualmode(), 1)<CR>
"noremap  <leader>w :call CopyGVimToTerminalDev('word', 1)<CR>
"noremap  <leader>m :call CopyGVimToTerminalDev('word', 1)<CR>

"noremap <leader>C :call CopyCurrentFpath()<Esc>

"noremap  <leader>M :call IPythonImportAll()<CR>
noremap  <leader>x :call IPyFixEmbedGlobals()<CR>


"+========= Not so used 
noremap  <leader>pd :call CopyGVimToTerminalDev(mode(), 1)<CR>
vnoremap <leader>pd :call CopyGVimToTerminalDev(visualmode(), 1)<CR>
noremap  <leader>pg vip :call CopyGVimToTerminalDev('v', 1)<CR>
" Paste to ipython and STAY in ipython
noremap  <leader>ps :call CopyGVimToTerminalDev(mode(), 0)<CR>
vnoremap <leader>ps :call CopyGVimToTerminalDev(visualmode(), 0)<CR>
" Re-paste selection
noremap  <leader>pr :call CopyGVimToTerminalDev('v', 1)<CR>
" paste single word / var
noremap  <leader>pw :call CopyGVimToTerminalDev('word', 1)<CR>

" Focus on terminal
noremap  <leader>ft :call FocusTerm()<CR>
"noremap  <leader>pt :call FocusTerm()<CR>

" Hotkey:
" Refreshing the vim RC / syntax
noremap <leader>r :source ~/local/vim/portable_vimrc<CR>
noremap <leader>R :source ~/local/vim/portable_vimrc<CR>


" Hack to reload vimtk plugin as well

"let g:loaded_vimtk=0
"let g:loaded_vimtk_autoload=0
"source ~/local/vim/vimfiles/bundle/vimtk/plugin/vimtk.vim
"source ~/local/vim/vimfiles/bundle/vimtk/autoload/vimtk.vim


noremap <leader>rs :syntax sync minlines=500.<CR>

" for python doctests
inoremap ,,, >>> 
noremap <leader>> :s/^\( *[^ ].*\)\([^ ]\)>>>/\1\2/g<CR>
":noremap <leader>> :'<,'>s/^\( *[^ ].*\)\([^ ]\)>>>/\1\2/g<CR>


" Search in non-doctests
noremap <leader>/ :/\(^.*>>> .*\)\@<!
":noremap <leader>/ :/\(^.*>>>\)\@!

" Function Keys

" === F2 ===
call FKeyFuncMap('<F2>', ':call PythonRevert()<CR>')
call FKeyFuncMap('<F3>', ':call PythonInvert()<CR>')

" === F3 ===
call FKeyFuncMap('<c-F2>', ':call NumberLineRevert()<CR>')
call FKeyFuncMap('<c-F3>', ':call NumberLineInvert()<CR>')
" === F4 ===
"http://vim.1045645.n5.nabble.com/How-to-map-two-commands-on-one-key-td1162164.html
noremap <F4> :call ToggleFont(1) <Bar> redraw <Bar> call FUNC_ECHOVAR("gfn")<CR>
noremap <S-F4> :call ToggleFont(-1) <Bar> redraw <Bar> call FUNC_ECHOVAR("gfn")<CR>
":noremap <C-F4> <Esc>:tabclose<CR>

" === F5, 6, 7
noremap <F5> :call ViewDirectory()<CR>
noremap <F6> :call CmdHere()<CR>

"vim-latex-suit overwrites f5, give it an alt
noremap <F8> :call Tex_RunViewLaTeX()<CR>
noremap <F12> :call ToggleAlpha()<CR>


" Remap Alt+q to escape
inoremap <silent><A-q> <ESC>
" Remap Alt+p to paste
inoremap <silent><A-p> <C-p>

" Window navication
" Alt + jklh
map <silent><A-j> <c-w>j
map <silent><A-k> <c-w>k
map <silent><A-l> <c-w>l
map <silent><A-h> <c-w>h
" Control + jklh
map <c-j> <c-w>j
map <c-k> <c-w>k
map <c-l> <c-w>l
" Move in split windows
" Press leader twice to move between windows
noremap <leader>, <C-w>w
map <c-h> <c-w>h

" Open file under cursor

" In current v/split or new tab
"noremap <leader>go :call OpenPathAtCursor("e")<CR>
"noremap <leader>gf :call OpenPathAtCursor("e")<CR>
"noremap <leader>gi :call OpenPathAtCursor("split")<CR>
"noremap <leader>gv :call OpenPathAtCursor("vsplit")<CR>
"noremap <leader>gv :call OpenPathAtCursor("vsplit")<CR>
"noremap <leader>gt :call OpenPathAtCursor("tabe")<CR>
"noremap gi :call OpenPathAtCursor("split")<CR>

"noremap <leader>gi :wincmd f<CR> 
"noremap gi :wincmd f<CR> 

nnoremap <leader>p :call Tex_RunViewLaTeX()<CR>
nmap <C-P> :call Tex_RunViewLaTeX() <CR>
imap <C-P> :call Tex_RunViewLaTeX() <CR>

" Folds:
" Map space to toggle current fold
noremap <space> za
"noremap <leader>z zR
"noremap <leader>a zA
"noremap <leader>m zM


" goto next syntastic error
noremap <leader>e :SyntasticCheck<CR> :Errors<CR>


" RESIZE VSPLIT
noremap <leader>+ :30winc ><CR>
noremap <leader>_ :30winc <<CR>
noremap <leader>= :FontIncrease<CR>
noremap <leader>- :FontDecrease<CR>


"noremap <leader>H :call vimtk#helloworld()<Esc>


" UNSURE OF THESE 
" VVVVV




" Macro for surround word with quotes
let @q=',qw'
let @r='VG;<c-p>'

" Close a tab
noremap <leader>qt :tabclose<CR>
map <c-`> <c-o>

" Don't use Ex mode, use Q for formatting
map Q gq

" CTRL-U in insert mode deletes a lot.  Use CTRL-G u to first break undo,
" so that you can undo CTRL-U after inserting a line break.
inoremap <C-U> <C-G>u<C-U>

" Remap execute macro from @ to \
nmap <leader>2 @

" Define Macros
"let @q=',qw'
"let @2=',qw'

"let @1='40j'
"let @2='40k'

" write a self. in normal mode
"let@s='iself.'
"let@e=':Align ='


"""""""""""
" OLD STUFF
" VVVVVVVVVVVV

" This is one special character which means escape
" I got this by typing Ctrl+Q<ESC> 
" 
" 


"nmap <leader>u :call ToggleNumberLineInvert()<CR>


" TODO: http://stackoverflow.com/questions/3638542/any-way-to-delete-in-vim-without-overwriting-your-last-yank
"noremap d "_d
":noremap <leader><F1> :normal i =%r' % (,)<ESC>hh
" Copy
":noremap <F3> "+y
":inoremap <F3> <ESC>"+ya
" Paste
" Map in both normal and interactive mode
" paseting form clibpard is "+p or "*p
":noremap <F2> "+p
":inoremap <F2> <ESC>"+pa

":noremap <leader><F2> "+y
":inoremap <leader><F2> <ESC>"+ya

" OLD
"noremap <leader>. i>>> 
"
":noremap y "+y
"CMDUNMAP y y

" Remap ESCAPE key to?  ":imap ` <Esc>
"noremap <Del> <Esc>
"noremap <Home> <Esc>
":imap <Del> <Esc>
":call PythonInvert()
":call TeckInvert()
"CMDUNSWAP : ;


"useful funcs for leaderkeys
"noremap <F9> <s-v>
"noremap <F10> <s-v>

"noremap <leader>ge vip:call PyFormatParagraph()<CR>
":noremap <c-g> vip:call PyFormatParagraph()<CR>
":noremap <c-M-B> oimport utool<CR>with utool.embed_on_exception_context:<CR><Esc>
":noremap <c-b> oimport utool<CR>utool.embed()<CR><Esc>
"inoremap <c-M-B> import utool<CR>with utool.embed_on_exception_context:<CR>
"inoremap <c-b> import utool<CR>utool.embed()<CR>
"noremap <leader>/ /\c
"inoremap <leader>d :call InsertDocstr()<CR>
"L__________ Not so used 
"noremap  1 :call CopyGVimToTerminalDev(mode(), 1)<CR>
"noremap  2 :call CopyGVimToTerminalDev(mode() 1)<CR>
"-range PassRange <line1>,<line2>call PrintGivenRange()

" alt-u
"inoremap <M-u> ut.
"inoremap <M-i> import
"inoremap <M-y> from import

" Tabs:
" change next/prev tab
"noremap <leader><Tab> gt
"noremap <leader>` gT
"" <alt+num>: change to the num\th tab
"noremap <M-1> 1gt
"noremap <M-2> 2gt
"noremap <M-3> 3gt
"noremap <M-4> 4gt
"noremap <M-5> 5gt
"noremap <M-6> 6gt
"noremap <M-7> 7gt
"noremap <M-8> 8gt
"noremap <M-9> 9gt
"noremap <M-0> 10gt
"" <leader+num>: change to the num\th tab
"noremap <leader>1 1gt
"noremap <leader>2 2gt
"noremap <leader>3 3gt
"noremap <leader>4 4gt
"noremap <leader>5 5gt
"noremap <leader>6 6gt
"noremap <leader>7 7gt
"noremap <leader>8 8gt
"noremap <leader>9 9gt



" K goes to the help for the object under the cursor.
" This is anoying. Kill the behavior
" Or learn how to use it?
" :noremap K k

" Find lone double quotes
":noremap <leader>"/ :/\([^"]\)"\([^"]\)<CR>
"noremap <leader>"/ :/\([^"]\)\@<="\([^"]\)\@=<CR>
"noremap <leader>s' :%s/\([^"]\)"\([^"]\)/\1'\2/gc<CR>
"
" === F1 ===
" Search
"remap F1 to search for word under cursor
"call FKeyFuncMap('<F1>', '*')
" custom command for opening setupfiles
"noremap  <leader><F1> :call OpenSetups()<CR>
