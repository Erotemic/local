"syn region cmakeTrippleQuotes start=+[uU]\=\z('''\|"""\)+ end="\z1" keepend matchgroup=NONE
" syn region cmakeTrippleQuotesComment start=+[uU]\=\z(# """\)+ end="\z1" keepend contains=CONTAINED
"syn region cmakeTrippleQuotesComment start=+[uU]\=\z(# \?"""\)+ end="\z1" keepend contains=CONTAINED,cmakeTodo,cmakeOperators
"
"SeeAlso: $VIMRUNTIME/syntax/cmake.vim

"syn region cmakeTrippleQuotesComment start='\z(# \?"""\)' end="\z1" keepend contains=CONTAINED,cmakeTodo,cmakeOperators
"syn region cmakeTrippleQuotesComment start="##" end='^\\(function\\)\\@=' contains=CONTAINED,cmakeTodo,cmakeOperators
"syn region cmakeTrippleQuotesComment start=+\z\(###\)+ end="\z1" keepend contains=CONTAINED,cmakeTodo,cmakeOperators


" end is a negative lookahead on a single comment char
syn region cmakeTrippleQuotesComment start=+\z\(###\)$+ end="^\(#\)\@!" keepend contains=CONTAINED,cmakeTodo,cmakeOperators



command -nargs=+ HiLink hi def link <args>

HiLink cmakeTrippleQuotesComment PreProc

"HiLink cmakeTrippleQuotesComment String
delcommand HiLink
