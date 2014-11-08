" ========= VIM PREFERENCES ========= "


" allow backspacing over everything in insert mode
set backspace=indent,eol,start

" In many terminal emulators the mouse works just fine, thus enable it.
if has('mouse')
  set mouse=a
endif


set ff=unix
set ffs=unix,dos

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
if has("gui_running")
    colorscheme synic
else
    colorscheme murphy
endif

" Gray Line Numbering
:set nu 
if has("gui_running")
    :highlight LineNr guifg=#333333
endif

"-------------------------
set nobackup
set autochdir

set nomousehide
set nowb
set noswapfile
" Do not open these sort of files
set wildignore=*.o,*~,*.pyc,*.aux,*.masv,*.bbl,*.bcf,*.blg,*.brf,*.synctex,*.upa,*.upb,*.pdf,*.dvi

set wildmode=longest,list,full
set wildmenu

set shellslash
set grepprg=grep\ -nH\ $*

set shiftwidth=4
set tabstop=4
set expandtab
set cino={1s
set autoread
set lbr " Linebreak on 500 characters
set tw=500
set history=5000  " keep 5000 lines of command line history
set ruler
set showcmd	
set incsearch
set hlsearch

"Windows symlink problems
set bkc=yes
set nowritebackup

hi StatusLine ctermbg=red ctermfg=green
hi StatusLine guibg=gray10 guifg=green

" why wont this work
highlight Cursor guifg=blue guibg=orange


" Set the font to one I like if it hasn't been done already
" Dont change it if I've already got one I like
if !exists("g:togfont") 
    :exec "call ToggleFont()"
endif

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

"
