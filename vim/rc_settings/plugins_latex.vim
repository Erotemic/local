" =========== LATEX =========== "
" LATEX: Functions

if has("win32") || has("win16")
    set shellslash
endif

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

" Remove open dyslexic
func! SetLaTeX()
    " References: http://vim-latex.sourceforge.net/documentation/latex-suite/customizing-compiling.html
    let g:Tex_CompileRule_pdf = 'pdflatex -shell-escape --synctex=-1 -src-specials -interaction=nonstopmode $*'
endfu   

" Set open dyslexic
func! SetXeTeX()
    let g:Tex_CompileRule_pdf = 'xelatex -shell-escape -interaction=nonstopmode $*'
endfu   

func! Tex_RunViewLaTeX()
    call Tex_RunLaTeX()
    call Tex_ViewLaTeX()
endfu


let g:Tex_SmartKeyDot=0
let g:tex_flavor='latex'
let g:Tex_DefaultTargetFormat='pdf'
"# http://tex.stackexchange.com/questions/95026/vim-latex-does-not-run-bibtex
"let g:Tex_MultipleCompileFormats='pdf'
let g:Tex_MultipleCompileFormats='pdf,bib,pdf'
let g:Tex_CompileRule_pdf = 'pdflatex -shell-escape --synctex=-1 -src-specials -interaction=nonstopmode $*'
" Use main.tex.mainfile to compile
let g:Tex_UseMakefile = 1
"let g:Tex_IgnoredWarnings='undefined on input'
" References for warnings
"# http://sourceforge.net/p/vim-latex/vim-latex/ci/6607de98f5c05e50956b62f43cd67ac257f7b51f/tree/compiler/tex.vim?diff=841cfca18443ccbb07bbdfffeb9847be6e0f3f1d
" ==============================================================================
" Customization of 'efm':  {{{
" This section contains the customization variables which the user can set.
" g:Tex_IgnoredWarnings: This variable contains a seperated list of
" patterns which will be ignored in the TeX compiler's output. Use this
" carefully, otherwise you might end up losing valuable information.
if !exists('g:Tex_IgnoredWarnings')
 let g:Tex_IgnoredWarnings =
  \'Underfull'."\n".
  \'Overfull'."\n".
  \'specifier changed to'."\n".
  \'You have requested'."\n".
  \'Missing number, treated as zero.'."\n".
  \'There were undefined references'."\n".
  \'Citation %.%# undefined'
endif
" This is the number of warnings in the g:Tex_IgnoredWarnings string which
" will be ignored.
if !exists('g:Tex_IgnoreLevel')
 let g:Tex_IgnoreLevel = 7
endif
" There will be lots of stuff in a typical compiler output which will
" completely fall through the 'efm' parsing. This options sets whether or not
" you will be shown those lines.
if !exists('g:Tex_IgnoreUnmatched')
    let g:Tex_IgnoreUnmatched = 1
endif
" With all this customization, there is a slight risk that you might be
" ignoring valid warnings or errors. Therefore before getting the final copy
" of your work, you might want to reset the 'efm' with this variable set to 1.
" With that value, all the lines from the compiler are shown irrespective of
" whether they match the error or warning patterns.
" NOTE: An easier way of resetting the 'efm' to show everything is to do
"       TCLevel strict
if !exists('g:Tex_ShowallLines')
    let g:Tex_ShowallLines = 0
endif

" No comment spellcheck
let g:tex_comment_nospell= 1

" }}}

"Autocomplete off
let g:Tex_SmartKeyDot=0

" Turn off LATEX code folding
":let Tex_FoldedSections=""
":let Tex_FoldedEnvironments=""
":let Tex_FoldedMisc=""

" Turn of XeLaTeX errors
set makeprg=texwrapper
set errorformat=%f:%l:%c:%m


" Cross Platform view rules
if has("win32") || has("win16")
    let g:Tex_ViewRule_pdf = 'C:\Program Files (x86)\SumatraPDF\SumatraPDF -reuse-instance -inverse-search "gvim -c \":RemoteOpen +\%l \%f\""'
else
    let g:Tex_ViewRule_pdf = 'okular --unique'
endif

" Toggle Compile to OpenDyslexic
command! LATEXCompileRuleLaTeX :call SetLaTeX()
command! LATEXCompileRuleXeTeX :call SetXeTeX()

":inoremap <leader>* \item 
" http://mirrors.ctan.org/install/macros/latex/contrib/mathtools.tds.zip
