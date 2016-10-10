"-------------------------
" PLUGIN: NERDTree 

func! NERD_TREE_WITH_BAT()
python << endpython
import vim
def nerdtree_withbat():
    # Define ignored suffixes
    ignore_pysuffix  = [
        '.pyo', '.pyc', '.shelf'
    ]
    ignore_texsuffix = [
        '.aux', '.masv', '.bbl', '.bst', '.bcf', '.blg', '.brf',
        '.synctex', '.upa', '.upb',
        '.pdf', 
        #'.out',
        #'.log',
        #'.latexmain',
        '.glo', '.toc', '.xdy', '.lof', '.lot',
        #'.bib',
    ]
    ignore_imgsuffix = ['.png']
    ignore_suffixes = ignore_pysuffix + ignore_texsuffix + ignore_imgsuffix

    # Define ignored files
    ignore_files = [
    #'README.md', 
    'LICENCE',
    "\'", 
    #"~", 
    ]
    # FIXME: Fix the tilde

    # Convert files and suffixes to regexes
    ignore_suffix_regexes = [suffix.replace('.', '\\.') + '$' for suffix in ignore_suffixes]
    ignore_file_regexes   = ['^' + fname + '$' for fname in ignore_files]
    ignore_regexes = ignore_suffix_regexes + ignore_file_regexes

    # build nerdtreeignore command
    nerdtree_ignore = '[%s]' % (','.join(['"%s"' % str(regex) for regex in ignore_regexes]))
    nerdtree_ignore_cmd = 'let g:NERDTreeIgnore = %s' % nerdtree_ignore
    #print(nerdtree_ignore_cmd)
    vim.command(nerdtree_ignore_cmd)
nerdtree_withbat()
endpython
"let NERDTreeIgnore = ['\.o$', '\~$', '\.pyc$',  '\.pyo$', '\.aux$', '\.masv$', '\.bbl$', '\.bcf$', '\.blg$', '\.brf$', '\.synctex$', '\.upa$', '\.upb$', '\.pdf$', '\.out$', '\.log', '\.latexmain', '\.bib', '\.shelf', 'README.md', 'LICENSE']
endfu

call NERD_TREE_WITH_BAT()

"
"
"-------------------------
" PLUGIN: Syntastic C++
"let g:syntastic_gpp_include_dirs=['$INSTALL_32/OpenCV/include']
"let g:syntastic_cpp_include_dirs=['C:/Program Files (x86)/OpenCV/include']
let g:syntastic_cpp_check_header = 0
let g:syntastic_cpp_no_include_search = 1
let g:syntastic_cpp_no_default_include_dirs =1
let g:syntastic_cpp_remove_include_errors = 1
"let g:syntastic_cpp_compiler = 'clang++'
let g:syntastic_cpp_compiler_options = ' -std=c++11 -stdlib=libc++ -lstdc++'
let g:syntastic_cpp_compiler_options = ' -std=c++11 -stdlib=libc++'

"let g:syntastic_cpp_include_dirs = ['include', '../include']
"let g:syntastic_cpp_compiler = 'clang++'
"let g:syntastic_c_include_dirs = ['include', '../include']
"let g:syntastic_c_compiler = 'clang'

"-------------------------
" PLUGIN: Tagbar
" https://github.com/majutsushi/tagbar/blob/master/doc/tagbar.txt
" TODO : https://www.reddit.com/r/vim/comments/1ho5qy/uniteoutline_is_tagbar_on_steroids/
"let g:tagbar_indent = 1
let g:tagbar_sort=0
let g:tagbar_compact = 1
"let g:tagbar_compact = 0
let g:tagbar_hide_nonpublic=0
let g:tagbar_autoshowtag = 1
"let g:tagbar_left = 1
let g:tagbar_left = 0

" http://stackoverflow.com/questions/26145505/using-vims-tagbar-plugin-for-latex-files
let g:tagbar_type_tex = {
    \ 'ctagstype' : 'tex2',
\ }

" Remove imports from tagbar
"\ 'i:imports:1:0',
let g:tagbar_type_python = {
    \ 'ctagstype' : 'python',
    \ 'kinds'     : [
        \ 'c:classes:0:1',
        \ 'f:functions:0:1',
        \ 'm:members:0:1',
        \ 'v:variables:0:0',
    \ ],
    \ 'sro'        : '.',
    \ 'kind2scope' : {
        \ 'c' : 'class',
        \ 'f' : 'function',
        \ 'm' : 'function',
    \ },
    \ 'scope2kind' : {
        \ 'class'    : 'c',
        \ 'function' : 'f',
    \ }
\ }

"let g:tagbar_type_python = {
    "\ 'ctagstype' : 'python',
    "\ 'kinds'     : [
        "\ {'short' : 'i', 'long' : 'imports',   'fold' : 1, 'stl' : 0},
        "\ {'short' : 'c', 'long' : 'classes',   'fold' : 0, 'stl' : 1},
        "\ {'short' : 'f', 'long' : 'functions', 'fold' : 0, 'stl' : 1},
        "\ {'short' : 'm', 'long' : 'members',   'fold' : 0, 'stl' : 1},
        "\ {'short' : 'v', 'long' : 'variables', 'fold' : 0, 'stl' : 0}
    "\ ],
    "\ 'sro'        : '.',
    "\ 'kind2scope' : {
        "\ 'c' : 'class',
        "\ 'f' : 'function',
        "\ 'm' : 'function',
    "\ },
    "\ 'scope2kind' : {
        "\ 'class'    : 'c',
        "\ 'function' : 'f',
    "\ }
"\ }


"let g:tagbar_type_tex = {
"    \ 'ctagstype' : 'tex2',
"    \ 'kinds' : [
"        \ 'c:chapters',
"        \ 's:sections',
"        \ 'u:subsections',
"        \ 'b:subsubsections',
"        \ 'P:paragraphs',
"        \ 'l:labels:0:0',
"    \ ],
"    \ 'sort'    : 0,
"\ }

"\ 'i:includes:1:0',
"\ 'p:parts',
"\ 'G:subparagraphs:0:0',

"-------------------------
" PLUGIN: Taglist
" https://justin.abrah.ms/vim/vim_and_python.html
let Tlist_GainFocus_On_ToggleOpen = 1
let Tlist_Close_On_Select = 0
let Tlist_Use_Right_Window = 0
let Tlist_File_Fold_Auto_Close = 1
"let Tlist_Sort_Type = "name"
let Tlist_Sort_Type="order"
let Tlist_Show_One_File=1
let Tlist_Auto_Update=1
let Tlist_Auto_Highlight_Tag = 1
"let Tlist_tex_settings = 'latex;s:sections;t:subsections;u:subsubsections'

" Only for latex
"set iskeyword=@,48-57,_,-,:,192-255


"-------------------------
" PLUGIN: Unimpaired
"https://github.com/tpope/vim-unimpaired


"-------------------------
" PLUGIN: Buffergator
" https://github.com/jeetsukumaran/vim-buffergator/blob/master/doc/buffergator.txt
" Remove mappings that I dont like 
if index(g:pathogen_disabled, 'vim-buffergator') < 0
    echo "BAD"
    silent! unmap!  <leader><S-Down>  
    silent! unmap!  <leader><S-Right>  
    silent! unmap!  <leader><S-Up>     
    silent! unmap!  <leader><S-Left>   
    silent! unmap!  <leader><Down>     
    silent! unmap!  <leader><Right>    
    silent! unmap!  <leader><Up>       
    silent! unmap!  <leader><Left>     
    silent! unmap!  <leader>T          
    silent! unmap!  <leader>tc         
    silent! unmap!  <leader>to         
    silent! unmap!  <leader>t          
endif 
" 

" VimTweak
let g:vimtweak_focus_transparency=0
let s:ft=0


"-------------------------
"# Jedi?
" Prevent insertion of netrwLeftMouse when clicking on GUI vim (bug introduced
" https://github.com/jrid/vim-jrid/blob/master/vimrc-netrw
" with later netrw plugin)
let g:netrw_mousemaps=0

let g:netrw_altv          = 1
let g:netrw_fastbrowse    = 2
let g:netrw_keepdir       = 0
let g:netrw_liststyle     = 0
let g:netrw_retmap        = 1
let g:netrw_silent        = 1
let g:netrw_special_syntax= 1


"-------------------------
"# vim-virutalenv
"
let g:virtualenv_directory = $HOME
let g:virtualenv_auto_activate = 1
" Add venv to statusline

if exists("*virtualenv#statusline")
    set statusline+=\ \%{virtualenv#statusline()} 
endif
"set statusline+=\ %{g:matchnum}\ matches

"powerline
" show line in single buffer
set laststatus=2

""""""""""" PYTHON BASED PLUGINS """"""""""""

"-------------------------
" PLUGIN: JEDI 
let g:jedi#popup_on_dot = 0
let g:jedi#show_call_signatures = 0
"command! JediShowFuncOn :let g:jedi#show_call_signatures = 1
"command! JediShowFuncOff :let g:jedi#show_call_signatures2= 0
"command! JediDotPopOn :let g:jedi#popup_on_dot = 1
"command! JediDotPopOff :let g:jedi#popup_on_dot = 0

"-------------------------
" PLUGIN: Supertab
" python autocomplete for supertab
let g:SuperTabDefaultCompletionType = "context"

"-------------------------
"PLUGIN: Synstastic General
let g:syntastic_aggregate_errors = 1
let g:syntastic_check_on_open = 1
let g:syntastic_warning_symbol = 'W>'
let g:syntastic_error_symbol = '!>'
let g:syntastic_style_error_symbol = 'S>'
let g:syntastic_style_warning_symbol = 's>'
let g:syntastic_always_populate_loc_list = 1

"-------------------------
" PLUGIN: Syntastic Python
let g:syntastic_python_checkers=['flake8'] " ignores lines containng # NOQA

" SCRIPTING VIM IN PYTHON 
" http://orestis.gr/blog/2008/08/10/scripting-vim-with-python/

python << endpython
import vim
flake8_errors = [
    'E126',  # continuation line hanging-indent
    'E127',  # continuation line over-indented for visual indent
    'E201',  # whitespace after '('
    'E202',  # whitespace before ']'
    'E203',  # whitespace before ', '
    'E221',  # multiple spaces before operator
    'E222',  # multiple spaces after operator
    'E241',  # multiple spaces after ,
    'E265',  # block comment should start with "# "
    'E271',  # multiple spaces after keyword
    'E272',  # multiple spaces before keyword
    'E301',  # expected 1 blank line, found 0
    #'E501',  # line length > 79
    'W602',  # Old reraise syntax
    'E266',  # too many leading '#' for block comment
    'N801',  # function name should be lowercase [N806]
    'N802',  # function name should be lowercase [N806]
    'N803',  # argument should be lowercase [N806]
    'N805',  # first argument of a method should be named 'self'
    'N806',  # variable in function should be lowercase [N806]
    'N811',  # constant name imported as non constant
    'N813',  # camel case
] 
flake8_args_list = [
    '--max-line-length 79',
    #'--max-line-length 100',
    '--ignore=' + ','.join(flake8_errors)
]
flake8_args = ' '.join(flake8_args_list)
vim.command('let g:syntastic_python_flake8_args = "%s"' % flake8_args)
endpython



"-------------------------
" PLUGIN: IPython Vim




"-------------------------
" PLUGIN: PYMODE
"let g:pymode_rope = 0
" Python-mode
" Activate rope
" Keys:
" K             Show python docs
" <Ctrl-Space>  Rope autocomplete
" <Ctrl-c>g     Rope goto definition
" <Ctrl-c>d     Rope show documentation
" <Ctrl-c>f     Rope find occurrences
" <Leader>b     Set, unset breakpoint (g:pymode_breakpoint enabled)
" [[            Jump on previous class or function (normal, visual, operator modes)
" ]]            Jump on next class or function (normal, visual, operator modes)
" [M            Jump on previous class or method (normal, visual, operator modes)
" ]M            Jump on next class or method (normal, visual, operator modes)
"let g:pymode_rope = 1

"" Documentation
"let g:pymode_doc = 1
"let g:pymode_doc_key = 'K'

""Linting
"let g:pymode_lint = 1
"let g:pymode_lint_checker = "pyflakes,pep8"
"" Auto check on save
"let g:pymode_lint_write = 0

"" Support virtualenv
"let g:pymode_virtualenv = 1

"" Enable breakpoints plugin
"let g:pymode_breakpoint = 1
"let g:pymode_breakpoint_key = '<leader>b'

"" syntax highlighting
"let g:pymode_syntax = 1
"let g:pymode_syntax_all = 1
"let g:pymode_syntax_indent_errors = g:pymode_syntax_all
"let g:pymode_syntax_space_errors = g:pymode_syntax_all

"" Don't autofold code
"let g:pymode_folding = 0
