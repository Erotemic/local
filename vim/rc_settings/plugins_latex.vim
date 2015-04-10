" =========== LATEX =========== "
" LATEX: Functions

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
