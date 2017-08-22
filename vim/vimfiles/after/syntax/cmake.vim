"syn region cmakeTrippleQuotes start=+[uU]\=\z('''\|"""\)+ end="\z1" keepend matchgroup=NONE

" syn region cmakeTrippleQuotesComment start=+[uU]\=\z(# """\)+ end="\z1" keepend contains=CONTAINED
"
"SeeAlso: $VIMRUNTIME/syntax/cmake.vim

syn region cmakeTrippleQuotesComment start=+[uU]\=\z(# \?"""\)+ end="\z1" keepend contains=CONTAINED,cmakeTodo,cmakeOperators

command -nargs=+ HiLink hi def link <args>
HiLink cmakeTrippleQuotesComment PreProc
"HiLink cmakeTrippleQuotesComment String
delcommand HiLink
