" =========== LATEX =========== "
" LATEX: Functions

" vim-latex lives in
" ~/local/vim/vimfiles/ftplugin/latex-suite
" SumatraPDF forward search
" References: http://forums.fofou.org/sumatrapdf/topic?id=3184510&comments=2

if has("win32") || has("win16")
    set shellslash
endif

" Remove open dyslexic
func! SetLaTeX()
    " References: http://vim-latex.sourceforge.net/documentation/latex-suite/customizing-compiling.html
    "let g:Tex_CompileRule_pdf = 'pdflatex -shell-escape --synctex=-1 -src-specials -interaction=nonstopmode $*'
    let g:Tex_CompileRule_pdf = 'lualatex -shell-escape --synctex=-1 -src-specials -interaction=nonstopmode $*'
endfu   

" Set open dyslexic
func! SetXeTeX()
    let g:Tex_CompileRule_pdf = 'xelatex -shell-escape -interaction=nonstopmode $*'
endfu   

func! Tex_RunViewLaTeX()
    call Tex_RunLaTeX()
    call Tex_ViewLaTeX()
endfu


" New LatexBox stuff
let g:LatexBox_Folding=1
let g:LatexBox_personal_latexmkrc=1
let g:LatexBox_latexmk_async = 1
let g:LatexBox_viewer = "okular --unique"
let g:LatexBox_latexmk_preview_continuously = 0

function! SyncTexForward()
  " https://www.reddit.com/r/vimplugins/comments/32t0xc/forward_search_with_latexbox/
  let s:syncfile = LatexBox_GetOutputFile()
  let execstr = "silent !okular --unique ".s:syncfile."\\#src:".line(".").expand("%\:p").' &'
  exec execstr
endfunction
nnoremap <localleader>ls :call SyncTexForward()<CR>


let g:tex_flavor='latex'
let g:Tex_DefaultTargetFormat='pdf'
"References: http://tex.stackexchange.com/questions/95026/vim-latex-does-not-run-bibtex
"let g:Tex_MultipleCompileFormats='pdf'
"let g:Tex_CompileRule_pdf = 'pdflatex -shell-escape --synctex=-1 -src-specials -interaction=nonstopmode $*'
let g:Tex_MultipleCompileFormats='pdf,bib,pdf'
let g:Tex_CompileRule_pdf = 'lualatex -shell-escape --synctex=-1 -src-specials -interaction=nonstopmode $*'
" Use main.tex.mainfile to compile
let g:Tex_UseMakefile = 1
"let g:Tex_IgnoredWarnings =
"    \'Underfull'."\n".
"    \'Overfull'."\n".
"    \'specifier changed to'."\n".
"    \'You have requested'."\n".
"    \'Missing number, treated as zero.'."\n".
"    \'There were undefined references'."\n".
"    \'undefined on input'."\n".
"    \'Citation %.%# undefined'
let g:Tex_IgnoreLevel = 8
let g:Tex_IgnoreUnmatched = 1
let g:Tex_ShowallLines = 0
" No comment spellcheck
let g:tex_comment_nospell= 1
"Autocomplete off
let g:Tex_SmartKeyDot=0
let g:Tex_GotoError=0
" DISABLE <++>
" http://tex.stackexchange.com/questions/62134/how-to-disable-all-vim-latex-mappings
let g:Imap_UsePlaceHolders = 0
let g:Tex_SmartKeyBS = 0
let g:Tex_SmartKeyQuote = 0
" Cross Platform view rules
if has("win32") || has("win16")
    let g:Tex_ViewRule_pdf = 'C:\Program Files (x86)\SumatraPDF\SumatraPDF -reuse-instance -inverse-search "gvim -c \":RemoteOpen +\%l \%f\""'
else
    let g:Tex_ViewRule_pdf = 'okular --unique'
endif

" References for warnings
"# http://sourceforge.net/p/vim-latex/vim-latex/ci/6607de98f5c05e50956b62f43cd67ac257f7b51f/tree/compiler/tex.vim?diff=841cfca18443ccbb07bbdfffeb9847be6e0f3f1d
python << endpython
import vim
ignore_warnings = [
    'Underfull',
    'Overfull',
    'specifier changed to',
    'You have requested',
    'only contains floats'
    'Missing number, treated as zero.',
    'There were undefined references',
    'undefined on input',
    'Citation %.%# undefined',
    'Unsupported document class',
    'natbib',
] 
args1 = '\n'.join(ignore_warnings)
args2 = ','.join(["'%s'" % x for x in ignore_warnings])
vim.command('let g:Tex_IgnoredWarnings = "%s"' % args1)
vim.command('let g:LatexBox_ignore_warnings = [%s]' % args2)
endpython

" Turn of XeLaTeX errors
set makeprg=texwrapper
set errorformat=%f:%l:%c:%m


" Toggle Compile to OpenDyslexic
command! LATEXCompileRuleLaTeX :call SetLaTeX()
command! LATEXCompileRuleXeTeX :call SetXeTeX()


set conceallevel=0

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
"let g:syntastic_tex_checkers=['lacheck']
let g:syntastic_tex_checkers=['']
let g:syntastic_tex_checkers=['chktex']

" SCRIPTING VIM IN PYTHON 
" http://orestis.gr/blog/2008/08/10/scripting-vim-with-python/

python << endpython
import vim
latex_errors = [
] 
ccktex_args_list = [
    #'--max-line-length 80',
]
args = ' '.join(ccktex_args_list)
#vim.command('let g:syntastic_tex_chktex_args = "%s"' % args)
endpython


":inoremap <leader>* \item 
" http://mirrors.ctan.org/install/macros/latex/contrib/mathtools.tds.zip


" Initialize
"func! LatexInitialize()
"    ":set textwidth=80
"    ":set spell
"    ":setlocal spell spelllang=en_us
"    ":call SetFontMonoDyslexic()
"    "set wildignore=*.o, *~, *.pyc, *.pyo, *.aux, *.masv, *.bbl, *.bcf, *.blg, *.brf, *.synctex, *.upa, *.upb, *.pdf, *.out, *.log
"    "set wildignore=*.o, *.pyc, *.pyo, *.aux, *.masv, *.bbl, *.bcf, *.blg, *.brf, *.synctex, *.upa, *.upb, *.pdf, *.out, *.log
"    "let NERDTreeIgnore = ['\.o$', '\~$', '\.pyc$',  '\.pyo$', '\.aux$', '\.masv$', '\.bbl$', '\.bcf$', '\.blg$', '\.brf$', '\.synctex$', '\.upa$', '\.upb$', '\.pdf$', '\.out$', '\.log', '\.latexmain', '\.bib', '\.shelf', 'README.md', 'LICENSE']
"    "let NERDTreeIgnore = ['\.o$', '\~$', '\.pyc$',  '\.pyo$', '\.aux$', '\.masv$', '\.bbl$', '\.bcf$', '\.blg$', '\.brf$', '\.synctex$', '\.upa$', '\.upb$', '\.pdf$', '\.out$', '\.log', '\.shelf', 'README.md', 'LICENSE', '\.glo$', '\.toc$', '\.xdy$']
"endfu
"
"
"
"
"
" Turn off LATEX code folding
":let Tex_FoldedSections=""
":let Tex_FoldedEnvironments=""
":let Tex_FoldedMisc=""




" ============================================================================== " Customization of 'efm':  {{{
" This section contains the customization variables which the user can set.
" g:Tex_IgnoredWarnings: This variable contains a seperated list of
" patterns which will be ignored in the TeX compiler's output.
" This is the number of warnings in the g:Tex_IgnoredWarnings string which
" will be ignored.
" There will be lots of stuff in a typical compiler output which will
" completely fall through the 'efm' parsing. This options sets whether or not
" you will be shown those lines.


" https://caffeinatedcode.wordpress.com/2009/11/16/simple-latex-ctags-and-taglist/
