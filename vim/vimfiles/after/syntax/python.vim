" Custom Folding 
" References: http://vim.wikia.com/wiki/Syntax_folding_of_Vim_scripts


"syn cluster pythonNoFold contains=pythonStatement,pythonDoctest,pythonConditional,pythonRepeat,pythonOperator,pythonException,pythonInclude,pythonDecorator,pythonFunction,pythonComment,pythonString,pythonRawString,pythonFmtString,pythonUtoolStartBlock,pythonUtoolEndBlock,pythonEscape,pythonTodo,pythonBuiltin,pythonExceptions,pythonSpaceError
"syn cluster pythonNoFold contains=pythonBuiltin
" 


"" fold for CommandLine
"syn region pythonFoldCommandLine
"      \ start="\vCommandLine:"
"      \ end="\<endfo\%[r]\>"
"      \ transparent fold
"      \ keepend extend
"      \ containedin=ALLBUT,@pythonNoFold
"      \ skip=+"\%(\\"\|[^"]\)\{-}\%("\|$\)\|'[^']\{-}'+ 
