"-------------------------
" PLUGIN: NERDTree 
"


func! NERD_TREE_WITH_BAT()
python << endpython
import vim
# Define ignored suffixes
ignore_pysuffix  = ['.pyo', '.pyc', '.shelf']
ignore_texsuffix = ['.aux', '.masv', '.bbl', '.bst', '.bcf', '.blg', '.brf',
                    '.synctex', '.upa', '.upb', '.pdf', '.out', '.log',
                    '.latexmain', '.bib']
ignore_imgsuffix = ['.png']
ignore_suffixes = ignore_pysuffix + ignore_texsuffix + ignore_imgsuffix

# Define ignored files
ignore_files = [
#'README.md', 
'LICENCE',
"'", '~',]

# Convert files and suffixes to regexes
ignore_suffix_regexes = [suffix.replace('.', '\\.') + '$' for suffix in ignore_suffixes]
ignore_file_regexes   = ['^' + fname + '$' for fname in ignore_files]
ignore_regexes = ignore_suffix_regexes + ignore_file_regexes

# build nerdtreeignore command
nerdtree_ignore = '[%s]' % (', '.join(['"%s"' % str(regex) for regex in ignore_regexes]))
vim.command('let g:NERDTreeIgnore = %s' % nerdtree_ignore)
endpython
endfu

call NERD_TREE_WITH_BAT()

"-------------------------
" PLUGIN: JEDI 
let g:jedi#popup_on_dot = 0
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
"let g:syntastic_cpp_include_dirs = ['include', '../include']
"let g:syntastic_cpp_compiler = 'clang++'
"let g:syntastic_c_include_dirs = ['include', '../include']
"let g:syntastic_c_compiler = 'clang'

"-------------------------
" PLUGIN: Unimpaired
"https://github.com/tpope/vim-unimpaired


" =========== LATEX =========== "
" LATEX: Functions

" Initialize
func! LatexInitialize()
    :set textwidth=80
    :set spell
    :setlocal spell spelllang=en_us
    :call SetFontMonoDyslexic()
    set wildignore=*.o, *~, *.pyc, *.pyo, *.aux, *.masv, *.bbl, *.bcf, *.blg, *.brf, *.synctex, *.upa, *.upb, *.pdf, *.out, *.log
    let NERDTreeIgnore = ['\.o$', '\~$', '\.pyc$',  '\.pyo$', '\.aux$', '\.masv$', '\.bbl$', '\.bcf$', '\.blg$', '\.brf$', '\.synctex$', '\.upa$', '\.upb$', '\.pdf$', '\.out$', '\.log', '\.latexmain', '\.bib', '\.shelf', 'README.md', 'LICENSE']
endfu

" Remove open dyslexic
func! SetLaTeX()
    let g:Tex_CompileRule_pdf = 'pdflatex -shell-escape --synctex=-1 -src-specials -interaction=nonstopmode $*'
endfu   

" Set open dyslexic
func! SetXeTeX()
    let g:Tex_CompileRule_pdf = 'xelatex -shell-escape -interaction=nonstopmode $*'
endfu   

let g:Tex_SmartKeyDot=0
let g:tex_flavor='latex'
let g:Tex_DefaultTargetFormat='pdf'
let g:Tex_MultipleCompileFormats='pdf'
let g:Tex_CompileRule_pdf = 'pdflatex -shell-escape --synctex=-1 -src-specials -interaction=nonstopmode $*'

" Cross Platform view rules
if has("win32") || has("win16")
    let g:Tex_ViewRule_pdf = 'C:\Program Files (x86)\SumatraPDF\SumatraPDF -reuse-instance -inverse-search "gvim -c \":RemoteOpen +\%l \%f\""'
else
    let g:Tex_ViewRule_pdf = 'okular --unique'
endif

" Use main.tex.mainfile to compile
let g:Tex_UseMakefile = 1

func! Tex_RunViewLaTeX()
    call Tex_RunLaTeX()
    call Tex_ViewLaTeX()
endfu

" Turn of XeLaTeX errors
set makeprg=texwrapper
set errorformat=%f:%l:%c:%m

" Turn off LATEX code folding
:let Tex_FoldedSections=""
:let Tex_FoldedEnvironments=""
:let Tex_FoldedMisc=""

" Toggle Compile to OpenDyslexic
command! LATEXCompileRuleLaTeX :call SetLaTeX()
command! LATEXCompileRuleXeTeX :call SetXeTeX()

"Autocomplete off
let g:Tex_SmartKeyDot=0


" VimTweak
let g:vimtweak_focus_transparency=0
let s:ft=0
