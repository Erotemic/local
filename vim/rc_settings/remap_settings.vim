"-------------------------
" Function Remaps
"map <F1> :call  ToggleWordHighlight()<CR>
"Map Ctrl+W (navkey) to Ctrl+(navkey) (for split windows)


"useful funcs for leaderkeys
" Remap COLOn colon to semicolon (in normal and visual mode)

:noremap <F9> <s-v>
:noremap <F10> <s-v>

":call PythonInvert()
":call TeckInvert()
CMDSWAP : ;
"CMDUNSWAP : ;

" Map to several leaderkeys with the main being ","
let mapleader = ","
noremap \ ,
":noremap y "+y
"CMDUNMAP y y

" Remap ESCAPE key to?  ":imap ` <Esc>
"noremap <Del> <Esc>
"noremap <Home> <Esc>
":imap <Del> <Esc>
"
vnoremap <leader>fp :call PyFormatParagraph()<CR>
vnoremap <leader>fe :call PyFormatParagraph()<CR>
noremap <leader>ge vip:call PyFormatParagraph()<CR>
vnoremap ge :call PyFormatParagraph()<CR>

noremap <leader>d :call InsertDocstr()<CR>
noremap <leader>ed :call InsertDocstr()<CR>
noremap <leader>ea :call InsertDocstrOnlyArgs()<CR>
noremap <leader>ec :call InsertDocstrOnlyCommandLine()<CR>
noremap <leader>ex :call InsertIBEISExample()<CR>
noremap <leader>em :call InsertMainPyTest()<CR>
"inoremap <leader>d :call InsertDocstr()<CR>

:noremap <c-d> :call InsertDocstr()<CR>
:noremap <c-1> :call InsertDocstr()<CR>
:inoremap <c-1> :call InsertDocstr()<CR>

:noremap <c-e> :call InsertDocstr()<CR>
:inoremap <c-2> :call AutoPep8Block()<CR>
:noremap <c-2> :call AutoPep8Block()<CR>
":inoremap <c-d> :call InsertDocstr()<CR>

" Hotkey: <leader>rrr Reload the vimrc
"noremap <leader>rrr :source ~/local/vim/portable_vimrc<CR>
noremap <leader>r :source ~/local/vim/portable_vimrc<CR>
noremap <leader>R :source ~/local/vim/portable_vimrc<CR>


" for python doctests
:inoremap ,,, >>> 
:noremap <leader>> :s/^\( *[^ ].*\)\([^ ]\)>>>/\1\2/g<CR>
":noremap <leader>> :'<,'>s/^\( *[^ ].*\)\([^ ]\)>>>/\1\2/g<CR>

" Function Keys
"
" === F1 ===
" Search
"remap F1 to search for word under cursor
:call FKeyFuncMap('<F1>', '*')
" custom command for opening setupfiles
:noremap  <leader><F1> :call OpenSetups()<CR>

" === F2 ===
:call FKeyFuncMap('<F2>', ':call PythonRevert()<CR>')
:call FKeyFuncMap('<F3>', ':call PythonInvert()<CR>')

" === F3 ===
:call FKeyFuncMap('<c-F2>', ':call NumberLineRevert()<CR>')
:call FKeyFuncMap('<c-F3>', ':call NumberLineInvert()<CR>')
" === F4 ===
"http://vim.1045645.n5.nabble.com/How-to-map-two-commands-on-one-key-td1162164.html
:noremap <F4> :call ToggleFont() <Bar> redraw <Bar> call FUNC_ECHOVAR("gfn")<CR>
:noremap <C-F4> <Esc>:tabclose<CR>

" === F5, 6, 7
:noremap <F5> :call ViewDirectory()<CR>
:noremap <F6> :call CmdHere()<CR>

"vim-latex-suit overwrites f5, give it an alt
:noremap <F8> :call Tex_RunViewLaTeX()<CR>
:noremap <F12> :call ToggleAlpha()<CR>


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
map <c-h> <c-w>h

" Open file under cursor

" In split window
" In vsplit-split window
noremap <leader>gi :wincmd f<CR> 
noremap <leader>gs :vertical wincmd f<CR>

nnoremap <leader>p :call Tex_RunViewLaTeX()<CR>
nmap <C-P> :call Tex_RunViewLaTeX() <CR>
imap <C-P> :call Tex_RunViewLaTeX() <CR>

"nnoremap <leader>d :FontDecrease<c-w> <c-w>

" Move in split windows
"nnoremap <leader>w w :<c-w> <c-w>
noremap <leader>w <C-w>w
noremap <leader>, <C-w>w
noremap <leader>j :NERDTreeToggle<CR>
noremap <leader>h :Tlist<CR>
"noremap <leader>J :NERDTree<CR>

"noremap <leader>r zR<CR>
"

" Folds:
" Map space to toggle current fold
noremap <space> za
noremap <leader>z zR
noremap <leader>a zA
noremap <leader>m zM

" Tabs:
" change next/prev tab
noremap <leader><Tab> gt
noremap <leader>` gT
" <alt+num>: change to the num\th tab
noremap <M-1> 1gt
noremap <M-2> 2gt
noremap <M-3> 3gt
noremap <M-4> 4gt
noremap <M-5> 5gt
noremap <M-6> 6gt
noremap <M-7> 7gt
noremap <M-8> 8gt
noremap <M-9> 9gt
noremap <M-0> 10gt
" <leader+num>: change to the num\th tab
noremap <leader>1 1gt
noremap <leader>2 2gt
noremap <leader>3 3gt
noremap <leader>4 4gt
noremap <leader>5 5gt
noremap <leader>6 6gt
noremap <leader>7 7gt
noremap <leader>8 8gt
noremap <leader>9 9gt


" Search and replace under cursor
":noremap <leader>s :%s/\<<C-r><C-w>\>/
" Add ss which does the same thing but is specific
:noremap <leader>ss :%s/\<<C-r><C-w>\>/

" goto next syntastic error
:noremap <leader>e :SyntasticCheck<CR> :Errors<CR>
:noremap <C-T> :NERDTree<CR>

:noremap <leader>. :NERDTree<CR>


" RESIZE VSPLIT
:noremap <leader>+ :30winc ><CR>
:noremap <leader>_ :30winc <<CR>
:noremap <leader>= :FontIncrease<CR>
:noremap <leader>- :FontDecrease<CR>


"Surround word with quotes
:noremap <leader>qw ciw'<C-r>"'<Esc>


" Macro for surround word with quotes
let @q=',qw'
let @r='VG;<c-p>'

" K goes to the help for the object under the cursor.
" This is anoying. Kill the behavior
" Or learn how to use it?
" :noremap K k

" Close a tab
noremap <leader>qt :tabclose<CR>
map <c-`> <c-o>


" Don't use Ex mode, use Q for formatting
map Q gq

" CTRL-U in insert mode deletes a lot.  Use CTRL-G u to first break undo,
" so that you can undo CTRL-U after inserting a line break.
inoremap <C-U> <C-G>u<C-U>

" Remap execute macro from @ to \
:nmap <leader>2 @

" Define Macros
let @q=',qw'
let @2=',qw'

"let @1='40j'
"let @2='40k'

" write a self. in normal mode
let@s='iself.'
let@e=':Align ='

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
