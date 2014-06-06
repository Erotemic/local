"-------------------------
" Function Remaps
"map <F1> :call  ToggleWordHighlight()<CR>
"Map Ctrl+W (navkey) to Ctrl+(navkey) (for split windows)

" Remap LEADER from \ to ,
let mapleader = ","
":nmap \ ,
" Remap COLOn colon to semicolon (in normal and visual mode)
nmap ; :
vmap ; :
" Remap ESCAPE key to?  ":imap ` <Esc>

" Hotkey: <leader>rrr Reload the vimrc
noremap <leader>rrr :source ~/local/vim/portable_vimrc<CR>
noremap <leader>R :source ~/local/vim/portable_vimrc<CR>

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
map <leader>gi :wincmd f<CR> " In vsplit-split window
map <leader>gs :vertical wincmd f<CR>

" Function Keys
map <F1> :call PEP8PRINT()<CR>
map <F2> :call ToggleAlpha()<CR>
map <F3> :call ToggleFont()<CR>
map <F4> :call OpenWindow()<CR>
map <F5> :call CmdHere()<CR>
"vim-latex-suit overwrites f5, give it an alt
map <F6> :call  CmdHere()<CR>
" Compile Command Remaps
map <F8> :call  Tex_RunViewLaTeX()<CR>
nnoremap <leader>p :call Tex_RunViewLaTeX()<CR>
nmap <C-P> :call Tex_RunViewLaTeX() <CR>
imap <C-P> :call Tex_RunViewLaTeX() <CR>

nnoremap <leader>d :FontDecrease<c-w> <c-w>

" Move in split windows
"nnoremap <leader>w w :<c-w> <c-w>
noremap <leader>w <C-w>w
noremap <leader>, <C-w>w
noremap <leader>j :NERDTreeToggle<CR>
noremap <leader>J :NERDTree<CR>

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

:noremap <leader><F1> :normal i =%r' % (,)<ESC>hh
:noremap <leader>. :NERDTree<CR>


" RESIZE VSPLIT
:noremap <leader>+ :30winc ><CR>
:noremap <leader>- :30winc <<CR>


"Surround word with quotes
:noremap <leader>qw ciw'<C-r>"'<Esc>


" Macro for surround word with quotes
let @q=',qw'
let @r='VG;<c-p>'

func! FIXQT_DOC()
:s/\t/    /gc
:s/ * Qt::\([^0-9]*\)\([0-9]\)/\2: '\1' #/gc
endfu

" K goes to the help for the object under the cursor.
" This is anoying. Kill the behavior
" Or learn how to use it?
" :noremap K k

" custom command for opening setupfiles
noremap <leader><F1> :call OpenSetups()<CR>

" Close a tab
noremap <leader>qt :tabclose<CR>
map <C-F4> <Esc>:tabclose<CR>

map <c-`> <c-o>


" Don't use Ex mode, use Q for formatting
map Q gq

" CTRL-U in insert mode deletes a lot.  Use CTRL-G u to first break undo,
" so that you can undo CTRL-U after inserting a line break.
inoremap <C-U> <C-G>u<C-U>
