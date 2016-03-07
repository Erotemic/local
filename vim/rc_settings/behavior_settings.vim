" ========= VIM PREFERENCES ========= "


" allow backspacing over everything in insert mode
set backspace=indent,eol,start

" In many terminal emulators the mouse works just fine, thus enable it.
if has('mouse')
  set mouse=a
endif


set fileformat=unix
set fileformats=unix,dos

" Set backup directory
if has("win32") || has("win16")
    set backupdir=D:/sys/vim_tmp/
    set undodir=D:/sys/vim_tmp/
else
    set backupdir=~/.vim_tmp/
endif

" MISC: win clipboard on linux
if has("win32") || has("win16")
    " pass
else
    set clipboard=unnamedplus
endif

" Good Colorschemes

"colorscheme solarized
colorscheme slate
set bg=light
set bg=dark
let g:solarized_contrast="normal"
"let g:solarized_contrast="high"
"let g:solarized_contrast="low"
let g:solarized_visibility="normal"
"let g:solarized_visibility="high"

if has("gui_running")
    "colorscheme synic
    let g:solarized_degrade=0
else
    colorscheme murphy
    let g:solarized_degrade=1
endif

" Gray Line Numbering
:set nu 
if has("gui_running")
    :highlight LineNr guifg=#333333
endif

"-------------------------
set nobackup
set nowritebackup
set autochdir
set noswapfile
"Windows symlink problems
set backupcopy=yes
set nowritebackup

set nomousehide
" Do not open these sort of files
set wildignore=*.o,*~,*.pyc,*.aux,*.masv,*.bbl,*.bcf,*.blg,*.brf,*.synctex,*.upa,*.upb,*.pdf,*.dvi

"h ttp://vim.wikia.com/wiki/Great_wildmode/wildmenu_and_console_mouse
set wildmode=longest,list,full
set wildmenu

set shellslash
set grepprg=grep\ -nH\ $*

set shiftwidth=4
set tabstop=4
set expandtab
set cino={1s
set autoread
"set lbr " Linebreak on 500 characters
set history=5000  " keep 5000 lines of command line history
set ruler
"set showcmd	
set incsearch
set hlsearch

hi StatusLine ctermbg=red ctermfg=green
hi StatusLine guibg=gray10 guifg=green

" why wont this work
highlight Cursor guifg=blue guibg=orange


" Set the font to one I like if it hasn't been done already
" Dont change it if I've already got one I like
:call ToggleFont(0)
"if !exists("g:myfontindex") 
"    :exec "call ToggleFont(0)"
"endif

"---------
" clean these up
"

if !exists(":DiffOrig")
  command DiffOrig vert new | set bt=nofile | r ++edit # | 0d_ | diffthis
		  \ | wincmd p | diffthis
endif


" MISC: win clipboard on linux
"if has("win32") || has("win16")
"    behave mswin
"endif
"else
"    source $VIMRUNTIME/mswin.vim
"endif
"
"
"
" Gray Line Numbering
":set nu 
"if has("gui_running")
    ":highlight LineNr guifg=#333333
    """ Cross platform fonts
    ""if has("win32") || has("win16")
        "":highlight LineNr font='Fixedsys'
    ""else
        "":highlight LineNr font='Monospace'
    ""endif
"endif


" References: http://blog.ezyang.com/2010/03/vim-textwidth/
" Set it so gq will reformat but no automatic breaking
set textwidth=0 formatoptions=cqt wrapmargin=0


" Remove Autocopy
" References: http://vim.wikia.com/wiki/Auto_copy_the_mouse_selection
 set guioptions-=a
 set guioptions-=A
 set guioptions-=aA


 " Turn off errobells
 " https://coderwall.com/p/sccmea/disable-error-sounds-and-screen-flashing-in-vim
 set visualbell
 set noeb vb t_vb=
 set t_vb=

function! SyntaxItem()
    "http://vim.wikia.com/wiki/Showing_syntax_highlight_group_in_statusline
    return synIDattr(synID(line("."),col("."),1),"name")
endfunction
"set statusline+=%{SyntaxItem()}
"
"


"set statusline=%F%m%r%h%w\ [TYPE=%Y\ %{&ff}]\ \ [%l/%L\ (%p%%)
"set statusline=%F%m%r%h%w\ [type=%Y\ %{&ff}]\ \ [%l/%L\ (%p%%)
"set statusline=%f%m%r%h%w\ [type=%Y\ %{&ff}]\ \ [%l/%L\ (%p%%) (%c)
set statusline=%f%m%r%h%w\ \ [%l/%L\ (%p%%),\ %c]

