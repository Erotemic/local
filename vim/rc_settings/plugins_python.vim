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

"-------------------------
" PLUGIN: JEDI 
let g:jedi#popup_on_dot = 1
let g:jedi#show_call_signatures = 0
command! JediShowFuncOn :let g:jedi#show_call_signatures = 1
command! JediShowFuncOff :let g:jedi#show_call_signatures2= 0
command! JediDotPopOn :let g:jedi#popup_on_dot = 1
command! JediDotPopOff :let g:jedi#popup_on_dot = 0

"-------------------------
" PLUGIN: Supertab
" python autocomplete for supertab
let g:SuperTabDefaultCompletionType = "context"
func! SpellcheckOn()
    :set spell
    :setlocal spell spelllang=en_us
endfu

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
    'E127', # continuation line over-indented for visual indent
    'E201', # whitespace after '('
    'E202', # whitespace before ']'
    'E203', # whitespace before ', '
    'E221', # multiple spaces before operator
    'E222', # multiple spaces after operator
    'E241', # multiple spaces after ,
    'E265', # block comment should start with "# "
    'E271', # multiple spaces after keyword 
    'E272', # multiple spaces before keyword
    'E301', # expected 1 blank line, found 0
    'E501', # > 79
    'W602', # Old reraise syntax
] 
flake8_ignore = '--ignore=' + ','.join(flake8_errors)
vim.command('let g:syntastic_python_flake8_args = "%s"' % flake8_ignore)
endpython

