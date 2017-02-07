

" Concealing subscripts and backslash chars with unicode equivalents
"https://b4winckler.wordpress.com/2010/08/07/using-the-conceal-vim-feature-with-latex/
hi Conceal guibg=Black guifg=Orange

let b:tex_stylish = 1
"set ft=tex



" For latex tex_conceal
let g:tex_superscripts= '[0-9a-zA-W.,:;+-<>/()=]'
let g:tex_subscripts= '[0-9ABCabcdehijklmnoprstuvx,+-/().]'


" Always do conceal
let g:concellevel=2

" New LatexBox stuff
let g:LatexBox_Folding=1
let g:LatexBox_personal_latexmkrc=1
let g:LatexBox_latexmk_async = 1
let g:LatexBox_viewer = "okular --unique"
"let g:LatexBox_latexmk_preview_continuously = 1
let g:LatexBox_latexmk_preview_continuously = 0
let g:LatexBox_build_dir="auxdir"
let g:LatexBox_quickfix=2
"let g:LatexBox_build_dir="auxdir"


function! SyncTexForward()
  " https://www.reddit.com/r/vimplugins/comments/32t0xc/forward_search_with_latexbox/
  let s:syncfile = LatexBox_GetOutputFile()
  let execstr = "silent !okular --unique ".s:syncfile."\\#src:".line(".").expand("%\:p").' &'
  exec execstr
endfunction
nnoremap <localleader>ls :call SyncTexForward()<CR>

Python2or3 << EOF
import vim
ignore_warnings = [
    'Underfull',
    'Overfull',
    'specifier changed to',
    'You have requested',
    'only contains floats'
    'Missing number, treated as zero.',
    'There were undefined references',
    'Unused global option',
    'Marginpar on page',
    'undefined on input',
    'Citation %.%# undefined',
    'Unsupported document class',
    'natbib',
] 
args1 = '\n'.join(ignore_warnings)
args2 = ','.join(["'%s'" % x for x in ignore_warnings])
vim.command('let g:LatexBox_ignore_warnings = [%s]' % args2)
EOF


" Turn of syntastic for latex
let g:syntastic_tex_checkers=['']
