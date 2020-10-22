"-------------------------
" PLUGIN: NERDTree 

func! NERD_TREE_WITH_BAT()
Python2or3 << EOF
import vim
def nerdtree_withbat():
    # Define ignored suffixes
    ignore_suffix_types = {
        'python': [
            '.pyo', '.pyc', '.shelf'
        ],
        'latex': [
            '.aux', '.masv', '.bbl', '.bst', '.bcf', '.blg', '.brf',
            '.synctex', '.upa', '.upb', '.pdf', '.glo', '.toc', '.xdy',
            '.lof', '.lot', '.fls', '.fdb_latexmk',
        ],
        'images': [
            '.png'
        ],
    }
    ignore_suffixes = [val for vals in ignore_suffix_types.values()
                       for val in vals]

    # Define ignored files
    ignore_files = [
        #'README.md', 
        #'LICENCE',
        #"\'", 
        #"~", 
    ]

    # Convert files and suffixes to regexes
    ignore_suffix_regexes = [suffix.replace('.', '\\\\.') + '$' for suffix in ignore_suffixes]
    ignore_file_regexes   = ['^' + fname + '$' for fname in ignore_files]
    ignore_regexes = ignore_suffix_regexes + ignore_file_regexes

    # build nerdtreeignore command
    nerdtree_ignore = '[%s]' % (','.join(['"%s"' % str(regex) for regex in ignore_regexes]))
    nerdtree_ignore_cmd = 'let g:NERDTreeIgnore = %s' % nerdtree_ignore
    vim.command(nerdtree_ignore_cmd)
nerdtree_withbat()
EOF
endfu

call NERD_TREE_WITH_BAT()


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
" SyntasticInfo
let g:syntastic_python_checkers=['flake8'] " ignores lines containng # NOQA

Python2or3 << EOF
import vim
flake8_errors = [
    'E123',  # closing braket indentation
    'E126',  # continuation line hanging-indent
    'E127',  # continuation line over-indented for visual indent
    'E201',  # whitespace after '('
    'E202',  # whitespace before ']'
    'E203',  # whitespace before ', '
    'E221',  # multiple spaces before operator  (TODO: I wish I could make an exception for the equals operator. Is there a way to do this?) 
    'E222',  # multiple spaces after operator
    'E241',  # multiple spaces after ,
    'E265',  # block comment should start with "# "
    'E271',  # multiple spaces after keyword
    'E272',  # multiple spaces before keyword
    'E301',  # expected 1 blank line, found 0
    'E305',  # expected 1 blank line after class / func
    'E306',  # expected 1 blank line before func
    #'E402',  # module import not at top
    'E501',  # line length > 79
    'W602',  # Old reraise syntax
    'E266',  # too many leading '#' for block comment
    'N801',  # function name should be lowercase [N806]
    'N802',  # function name should be lowercase [N806]
    'N803',  # argument should be lowercase [N806]
    'N805',  # first argument of a method should be named 'self'
    'N806',  # variable in function should be lowercase [N806]
    'N811',  # constant name imported as non constant
    'N813',  # camel case
    'W503',  # line break before binary operator
    'W504',  # line break after binary operator

    'I201',  # Newline between Third party import groups
    'I100',  # Wrong import order
] 
flake8_args_list = [
    '--max-line-length 79',
    '--ignore=' + ','.join(flake8_errors)
]
flake8_args = ' '.join(flake8_args_list)
vim.command('let g:syntastic_python_flake8_args = "%s"' % flake8_args)

# Needed to hack syntastic cython checker
vim.command('let g:syntastic_cython_checkers = ["flake8"]')
cython_flake8_errors = flake8_errors + [
    'E901', 
    'E225',
    'E226',
    'E227',
    'E251',
    'E402',
    'E999',
]
cython_flake8_args_list = [
    '--max-line-length 79',
    '--ignore=' + ','.join(cython_flake8_errors)
]
cython_flake8_args = ' '.join(cython_flake8_args_list)
vim.command('let g:syntastic_cython_flake8_args = "%s"' % cython_flake8_args)
EOF

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


" Tagbar for Markdown
" https://github.com/majutsushi/tagbar/issues/70
let g:tagbar_type_markdown = {
            \ 'ctagstype' : 'markdown',
            \ 'kinds' : [
                \ 'h:headings',
                \ 'l:links',
                \ 'i:images'
            \ ],
    \ "sort" : 0
\ }

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


let g:tagbar_type_cmake = {
    \ 'ctagstype' : 'cmake',
    \ 'kinds'     : [
        \ 'f:functions:0:1',
    \ ],
    \ 'sro'        : '.',
    \ 'kind2scope' : {
        \ 'f' : 'function',
    \ },
    \ 'scope2kind' : {
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

"let g:jedi#goto_command = "<leader>d"
"let g:jedi#goto_assignments_command = "<leader>g"
let g:jedi#goto_definitions_command = "<leader>gd"
"let g:jedi#documentation_command = "K"
"let g:jedi#usages_command = "<leader>n"
"let g:jedi#completions_command = "<C-Space>"
"let g:jedi#rename_command = "<leader>r"

"command! JediShowFuncOn :let g:jedi#show_call_signatures = 1
"command! JediShowFuncOff :let g:jedi#show_call_signatures2= 0
"command! JediDotPopOn :let g:jedi#popup_on_dot = 1
"command! JediDotPopOff :let g:jedi#popup_on_dot = 0

"-------------------------
" PLUGIN: Supertab
" python autocomplete for supertab
let g:SuperTabDefaultCompletionType = "context"


"-------------------------
" PLUGIN: Autopep8
" https://github.com/tell-k/vim-autopep8

let g:autopep8_aggressive=1



" References:
"     SCRIPTING VIM IN PYTHON - http://orestis.gr/blog/2008/08/10/scripting-vim-with-python/
