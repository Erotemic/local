" =========== LATEX =========== "
" LATEX: Functions

" vim-latex lives in
" ~/local/vim/vimfiles/ftplugin/latex-suite
" SumatraPDF forward search
" References: http://forums.fofou.org/sumatrapdf/topic?id=3184510&comments=2

"if has("win32") || has("win16")
"    set shellslash
"endif


" -------------------------------------------------------------------------
" HISTORICAL: vim-latex compile-rule switching
"
" These functions belonged to the old vim-latex compile path.
" My current compile workflow is LaTeXBox:
"
"   ,ll -> :Latexmk
"   ,lv -> :LatexView
"
" Keep these implementations here so the old setup is reconstructable.
" -------------------------------------------------------------------------

" Remove open dyslexic
"
" References:
" http://vim-latex.sourceforge.net/documentation/latex-suite/customizing-compiling.html
"
" func! SetLaTeX()
"     let g:Tex_CompileRule_pdf = 'pdflatex -shell-escape --synctex=-1 -src-specials -interaction=nonstopmode $*'
"     let g:Tex_CompileRule_pdf = 'lualatex -shell-escape --synctex=-1 -src-specials --output-directory=auxdir -interaction=nonstopmode $*'
" endfu

" Set open dyslexic
"
" func! SetXeTeX()
"     let g:Tex_CompileRule_pdf = 'xelatex -shell-escape --output-directory=auxdir -interaction=nonstopmode $*'
" endfu

" func! Tex_RunViewLaTeX()
"     call Tex_RunLaTeX()
"     call Tex_ViewLaTeX()
" endfu


" -------------------------------------------------------------------------
" LaTeXBox
"
" Active workflow:
"
"   <localleader>ll -> LaTeXBox :Latexmk
"   <localleader>lv -> LaTeXBox :LatexView
"
" latexmk controls compilation.  The matching output-directory policy should
" live in ~/.latexmkrc:
"
"   $out_dir = 'build';
"
" LaTeXBox_build_dir tells LaTeXBox where to find the resulting .aux, .log,
" and PDF files.  It must therefore agree with latexmk.
" -------------------------------------------------------------------------

" New LatexBox stuff
let g:LatexBox_Folding = 0
let g:LatexBox_personal_latexmkrc = 1
let g:LatexBox_latexmk_async = 1
let g:LatexBox_viewer = "okular --unique"

"let g:LatexBox_latexmk_preview_continuously = 1
let g:LatexBox_latexmk_preview_continuously = 0

" Historically this was:
" let g:LatexBox_build_dir="auxdir"
"
" Standardize generated LaTeX artifacts under build/.
let g:LatexBox_build_dir = "build"

let g:LatexBox_quickfix = 2


" -------------------------------------------------------------------------
" HISTORICAL: custom Okular SyncTeX forward search
"
" I do not currently use this mapping; ,lv is the current viewing workflow.
" Keep the implementation with its original references so it is easy to
" reconstruct if forward-search is wanted again.
" -------------------------------------------------------------------------

" function! MySyncTexForward()
"     # okular --unique /media/joncrall/flash1/smart_watch_dvc/papers/smart_phase1_final_report/watch-ph1-final.pdf\#src:1000/media/joncrall/flash1/smart_watch_dvc/papers/smart_phase1_final_report/TA-2/task-1.5.1-bas.tex
"
"   " Note: this command is overloaded and not run
"   " https://www.reddit.com/r/viplugins/comments/32t0xc/forward_search_with_latexbox/
"
"   let g:syncfile = LatexBox_GetOutputFile()
"   let execstr = "silent !okular --unique ".g:syncfile."\\#src:".line(".").expand("%\:p").' &'
"
" Python2or3 << EOF
" import vim
" execstr = vim.eval('execstr')
" syncfile = vim.eval('g:syncfile')
" print(f'syncfile={syncfile}')
" print(f'execstr={execstr}')
" EOF
"
"   exec execstr
"
" "Python2or3 << EOF
" "import vim
" "execstr = vim.eval('execstr')
" "print(f'execstr={execstr}')
" "vim.command(execstr)
" "EOF
" endfunction
"
" Note: this command is overloaded and not run
" nnoremap <localleader>ls :call MySyncTexForward()<CR>


" -------------------------------------------------------------------------
" General TeX settings
" -------------------------------------------------------------------------

let g:tex_flavor = 'latex'


" -------------------------------------------------------------------------
" HISTORICAL: vim-latex compilation configuration
"
" References:
" http://tex.stackexchange.com/questions/95026/vim-latex-does-not-run-bibtex
"
" This was the compile path before ,ll / LaTeXBox became the workflow.
" It is intentionally disabled, but retained here with the settings it used.
" -------------------------------------------------------------------------

" let g:Tex_DefaultTargetFormat='pdf'

"let g:Tex_MultipleCompileFormats='pdf'

" Historical lualatex version:
" let g:Tex_CompileRule_pdf = 'lualatex -shell-escape --synctex=-1 -src-specials --output-directory=auxdir -interaction=nonstopmode $*'

" Historical pdflatex version:
" let g:Tex_MultipleCompileFormats='pdf,bib,pdf'
" let g:Tex_CompileRule_pdf = 'pdflatex -shell-escape --synctex=-1 -src-specials --output-directory=auxdir -interaction=nonstopmode $*'

" Use main.tex.mainfile to compile
" let g:Tex_UseMakefile = 1

" let g:Tex_IgnoreLevel = 8
" let g:Tex_IgnoreUnmatched = 1
" let g:Tex_ShowallLines = 0

" Debug / alternative historical settings:
"let g:Tex_UseMakefile = 0
"let g:Tex_IgnoreLevel = 0
"let g:Tex_IgnoreUnmatched = 0
"let g:Tex_ShowallLines = 1


" -------------------------------------------------------------------------
" TeX spell checking
" -------------------------------------------------------------------------

" No comment spellcheck
let g:tex_nospell = 0
let g:tex_comment_nospell = 1


" -------------------------------------------------------------------------
" HISTORICAL: vim-latex key behavior
" -------------------------------------------------------------------------

" Autocomplete off
" let g:Tex_SmartKeyDot = 0
" let g:Tex_GotoError = 0

" DISABLE <++>
" http://tex.stackexchange.com/questions/62134/how-to-disable-all-vim-latex-mappings
"
" let g:Imap_UsePlaceHolders = 0
" let g:Tex_SmartKeyBS = 0
" let g:Tex_SmartKeyQuote = 0


" -------------------------------------------------------------------------
" HISTORICAL: vim-latex PDF viewer selection
"
" This predates g:LatexBox_viewer above.
" -------------------------------------------------------------------------

" Cross Platform view rules
"
" if has("win32") || has("win16")
"     let g:Tex_ViewRule_pdf = 'C:\Program Files (x86)\SumatraPDF\SumatraPDF -reuse-instance -inverse-search "gvim -c \":RemoteOpen +\%l \%f\""'
" else
"     let g:Tex_ViewRule_pdf = 'okular --unique'
" endif


" -------------------------------------------------------------------------
" LaTeXBox warning filtering
"
" References for warnings:
" http://sourceforge.net/p/vim-latex/vim-latex/ci/6607de98f5c05e50956b62f43cd67ac257f7b51f/tree/compiler/tex.vim?diff=841cfca18443ccbb07bbdfffeb9847be6e0f3f1d
"
" The old implementation below generated both g:Tex_IgnoredWarnings and
" g:LatexBox_ignore_warnings using embedded Python.
"
" The LaTeXBox list is now written directly in Vimscript because the old
" vim-latex value is no longer used.
" -------------------------------------------------------------------------

let g:LatexBox_ignore_warnings = [
    \ 'Underfull',
    \ 'Overfull',
    \ 'specifier changed to',
    \ 'You have requested',
    \ 'only contains floats',
    \ 'Missing number, treated as zero.',
    \ 'There were undefined references',
    \ 'Unused global option',
    \ 'Marginpar on page',
    \ 'undefined on input',
    \ 'Citation %.%# undefined',
    \ 'Unsupported document class',
    \ 'natbib',
    \ ]


" Historical Python implementation.
"
" Note that the original had a missing comma after 'only contains floats',
" which caused Python to concatenate that string with the following one.
"
" Python2or3 << EOF
" import vim
" ignore_warnings = [
"     'Underfull',
"     'Overfull',
"     'specifier changed to',
"     'You have requested',
"     'only contains floats',
"     'Missing number, treated as zero.',
"     'There were undefined references',
"     'Unused global option',
"     'Marginpar on page',
"     'undefined on input',
"     'Citation %.%# undefined',
"     'Unsupported document class',
"     'natbib',
" ]
" args1 = '\n'.join(ignore_warnings)
" args2 = ','.join(["'%s'" % x for x in ignore_warnings])
" vim.command('let g:Tex_IgnoredWarnings = "%s"' % args1)
" vim.command('let g:LatexBox_ignore_warnings = [%s]' % args2)
" EOF

" Historical literal version:
"
"let g:Tex_IgnoredWarnings =
"    \'Underfull'."\n".
"    \'Overfull'."\n".
"    \'specifier changed to'."\n".
"    \'You have requested'."\n".
"    \'Missing number, treated as zero.'."\n".
"    \'There were undefined references'."\n".
"    \'undefined on input'."\n".
"    \'Citation %.%# undefined'


" -------------------------------------------------------------------------
" HISTORICAL: compiler/error experiments
" -------------------------------------------------------------------------

" Turn of XeLaTeX errors
"set makeprg=texwrapper
"set errorformat=%f:%l:%c:%m
"set conceallevel=0


" Toggle Compile to OpenDyslexic
"command! LATEXCompileRuleLaTeX :call SetLaTeX()
"command! LATEXCompileRuleXeTeX :call SetXeTeX()


" -------------------------------------------------------------------------
" Conceal / TeX display settings
"
" These came from plugins_latex2.vim.  Keep them here so removing that second
" file does not silently drop display-related behavior.
" -------------------------------------------------------------------------

" Concealing subscripts and backslash chars with unicode equivalents
" https://b4winckler.wordpress.com/2010/08/07/using-the-conceal-vim-feature-with-latex/
hi Conceal guibg=Black guifg=Orange

" This was historically buffer-local:
let b:tex_stylish = 1

"set ft=tex

" Other settings are contained in
" ~/.latexmkrc

" For latex tex_conceal
let g:tex_superscripts = '[0-9a-zA-W.,:;+-<>/()=]'
let g:tex_subscripts = '[0-9ABCabcdehijklmnoprstuvx,+-/().]'

" Always do conceal
"let g:concellevel=2


" -------------------------------------------------------------------------
" HISTORICAL: second SyncTeX implementation from plugins_latex2.vim
"
" This was the later/smaller implementation of the same forward-search idea.
" It is retained beside the reference and original mapping.
" -------------------------------------------------------------------------

" function! SyncTexForward()
"   " https://www.reddit.com/r/vimplugins/comments/32t0xc/forward_search_with_latexbox/
"   let s:syncfile = LatexBox_GetOutputFile()
"   let execstr = "silent !okular --unique ".s:syncfile."\\#src:".line(".").expand("%\:p").' &'
"   exec execstr
" endfunction
" nnoremap <localleader>ls :call SyncTexForward()<CR>


" -------------------------------------------------------------------------
" HISTORICAL: Syntastic
"
" Syntastic itself is no longer enabled in the main vimrc, but preserve the
" configuration in the context where it was used.
" -------------------------------------------------------------------------

"-------------------------
"PLUGIN: Synstastic General
"
" let g:syntastic_aggregate_errors = 1
" let g:syntastic_check_on_open = 1
" let g:syntastic_warning_symbol = 'W>'
" let g:syntastic_error_symbol = '!>'
" let g:syntastic_style_error_symbol = 'S>'
" let g:syntastic_style_warning_symbol = 's>'
" let g:syntastic_always_populate_loc_list = 1

"-------------------------
" PLUGIN: Syntastic Python
"
"let g:syntastic_tex_checkers=['lacheck']
"let g:syntastic_tex_checkers=['']
"let g:syntastic_tex_checkers=['chktex']

" plugins_latex2.vim eventually disabled the TeX checker:
" let g:syntastic_tex_checkers=['']


" -------------------------------------------------------------------------
" HISTORICAL: scripting Vim in Python / chktex experiments
" -------------------------------------------------------------------------

" SCRIPTING VIM IN PYTHON
" http://orestis.gr/blog/2008/08/10/scripting-vim-with-python/

"Python2or3 << EOF
"import vim
"latex_errors = [
"]
"ccktex_args_list = [
"    #'--max-line-length 80',
"]
"args = ' '.join(ccktex_args_list)
"#vim.command('let g:syntastic_tex_chktex_args = "%s"' % args)
"EOF
