"-------------------------
" Function Remaps
"map <F1> :call  ToggleWordHighlight()<CR> 
"Map Ctrl+W (navkey) to Ctrl+(navkey) (for split windows)

" Remap LEADER from \ to ,
let mapleader = ","
" Remap COLOn colon to semicolon
nmap ; :
" Remap ESCAPE key to?  ":imap ` <Esc>

" Hotkey: <Leader>rrr Reload the vimrc
noremap <Leader>rrr :source ~/local/vim/portable_vimrc<CR>

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
map <Leader>gi :wincmd f<CR> " In vsplit-split window
map <Leader>gs :vertical wincmd f<CR>

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
nnoremap <Leader>p :call Tex_RunViewLaTeX()<CR>
nmap <C-P> :call Tex_RunViewLaTeX() <CR>
imap <C-P> :call Tex_RunViewLaTeX() <CR>

nnoremap <Leader>d :FontDecrease<c-w> <c-w>

" Move in split windows
"nnoremap <Leader>w w :<c-w> <c-w>
noremap <Leader>w <C-w>w
noremap <Leader>, <C-w>w
noremap <Leader>j :NERDTreeToggle<CR>
noremap <Leader>J :NERDTree<CR>

"noremap <Leader>r zR<CR>
"

" Folds: 
" Map space to toggle current fold
noremap <space> za  
noremap <Leader>z zR
noremap <Leader>a zA
noremap <Leader>m zM

" Tabs: 
" change next/prev tab
noremap <Leader><Tab> gt
noremap <Leader>` gT
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
" <Leader+num>: change to the num\th tab
noremap <Leader>1 1gt
noremap <Leader>2 2gt
noremap <Leader>3 3gt
noremap <Leader>4 4gt
noremap <Leader>5 5gt
noremap <Leader>6 6gt
noremap <Leader>7 7gt
noremap <Leader>8 8gt
noremap <Leader>9 9gt


" Search and replace under cursor
:noremap <Leader>s :%s/\<<C-r><C-w>\>/

" goto next syntastic error 
:noremap <Leader>e :Errors<CR>
