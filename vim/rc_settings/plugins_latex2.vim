

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
