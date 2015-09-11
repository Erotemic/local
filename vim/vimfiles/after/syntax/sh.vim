"" Here Documents: {{{1
"" =========================================
"if version < 600
" syn region shHereDoc matchgroup=shRedir01 start="<<\s*\**END[a-zA-Z_0-9]*\**" 		matchgroup=shRedir01 end="^END[a-zA-Z_0-9]*$"	contains=@shDblQuoteList
" syn region shHereDoc matchgroup=shRedir02 start="<<-\s*\**END[a-zA-Z_0-9]*\**"		matchgroup=shRedir02 end="^\s*END[a-zA-Z_0-9]*$"	contains=@shDblQuoteList
" syn region shHereDoc matchgroup=shRedir03 start="<<\s*\**EOF\**"		matchgroup=shRedir03	end="^EOF$"	contains=@shDblQuoteList
" syn region shHereDoc matchgroup=shRedir04 start="<<-\s*\**EOF\**"		matchgroup=shRedir04	end="^\s*EOF$"	contains=@shDblQuoteList
" syn region shHereDoc matchgroup=shRedir05 start="<<\s*\**\.\**"		matchgroup=shRedir05	end="^\.$"	contains=@shDblQuoteList
" syn region shHereDoc matchgroup=shRedir06 start="<<-\s*\**\.\**"		matchgroup=shRedir06	end="^\s*\.$"	contains=@shDblQuoteList

"elseif s:sh_fold_heredoc
" syn region shHereDoc matchgroup=shRedir07 fold start="<<\s*\z([^ \t|]*\)"		matchgroup=shRedir07 end="^\z1\s*$"	contains=@shDblQuoteList
" syn region shHereDoc matchgroup=shRedir08 fold start="<<\s*\"\z([^ \t|]*\)\""		matchgroup=shRedir08 end="^\z1\s*$"
" syn region shHereDoc matchgroup=shRedir09 fold start="<<\s*'\z([^ \t|]*\)'"		matchgroup=shRedir09 end="^\z1\s*$"
" syn region shHereDoc matchgroup=shRedir10 fold start="<<-\s*\z([^ \t|]*\)"		matchgroup=shRedir10 end="^\s*\z1\s*$"	contains=@shDblQuoteList
" syn region shHereDoc matchgroup=shRedir11 fold start="<<-\s*\"\z([^ \t|]*\)\""		matchgroup=shRedir11 end="^\s*\z1\s*$"
" syn region shHereDoc matchgroup=shRedir12 fold start="<<-\s*'\z([^ \t|]*\)'"		matchgroup=shRedir12 end="^\s*\z1\s*$"
" syn region shHereDoc matchgroup=shRedir13 fold start="<<\s*\\\_$\_s*\z([^ \t|]*\)"	matchgroup=shRedir13 end="^\z1\s*$"
" syn region shHereDoc matchgroup=shRedir14 fold start="<<\s*\\\_$\_s*\"\z([^ \t|]*\)\""	matchgroup=shRedir14 end="^\z1\s*$"
" syn region shHereDoc matchgroup=shRedir15 fold start="<<-\s*\\\_$\_s*'\z([^ \t|]*\)'"	matchgroup=shRedir15 end="^\s*\z1\s*$"
" syn region shHereDoc matchgroup=shRedir16 fold start="<<-\s*\\\_$\_s*\z([^ \t|]*\)"	matchgroup=shRedir16 end="^\s*\z1\s*$"
" syn region shHereDoc matchgroup=shRedir17 fold start="<<-\s*\\\_$\_s*\"\z([^ \t|]*\)\""	matchgroup=shRedir17 end="^\s*\z1\s*$"
" syn region shHereDoc matchgroup=shRedir18 fold start="<<\s*\\\_$\_s*'\z([^ \t|]*\)'"	matchgroup=shRedir18 end="^\z1\s*$"
" syn region shHereDoc matchgroup=shRedir19 fold start="<<\\\z([^ \t|]*\)"		matchgroup=shRedir19 end="^\z1\s*$"

"else
" syn region shHereDoc matchgroup=shRedir20 start="<<\s*\\\=\z([^ \t|]*\)"		matchgroup=shRedir20 end="^\z1\s*$"    contains=@shDblQuoteList
" syn region shHereDoc matchgroup=shRedir21 start="<<\s*\"\z([^ \t|]*\)\""		matchgroup=shRedir21 end="^\z1\s*$"
" syn region shHereDoc matchgroup=shRedir22 start="<<-\s*\z([^ \t|]*\)"		matchgroup=shRedir22 end="^\s*\z1\s*$" contains=@shDblQuoteList
" syn region shHereDoc matchgroup=shRedir23 start="<<-\s*'\z([^ \t|]*\)'"		matchgroup=shRedir23 end="^\s*\z1\s*$"
" syn region shHereDoc matchgroup=shRedir24 start="<<\s*'\z([^ \t|]*\)'"		matchgroup=shRedir24 end="^\z1\s*$"
" syn region shHereDoc matchgroup=shRedir25 start="<<-\s*\"\z([^ \t|]*\)\""		matchgroup=shRedir25 end="^\s*\z1\s*$"
" syn region shHereDoc matchgroup=shRedir26 start="<<\s*\\\_$\_s*\z([^ \t|]*\)"		matchgroup=shRedir26 end="^\z1\s*$"
" syn region shHereDoc matchgroup=shRedir27 start="<<-\s*\\\_$\_s*\z([^ \t|]*\)"		matchgroup=shRedir27 end="^\s*\z1\s*$"
" syn region shHereDoc matchgroup=shRedir28 start="<<-\s*\\\_$\_s*'\z([^ \t|]*\)'"	matchgroup=shRedir28 end="^\s*\z1\s*$"
" syn region shHereDoc matchgroup=shRedir29 start="<<\s*\\\_$\_s*'\z([^ \t|]*\)'"	matchgroup=shRedir29 end="^\z1\s*$"
" syn region shHereDoc matchgroup=shRedir30 start="<<\s*\\\_$\_s*\"\z([^ \t|]*\)\""	matchgroup=shRedir30 end="^\z1\s*$"
" syn region shHereDoc matchgroup=shRedir31 start="<<-\s*\\\_$\_s*\"\z([^ \t|]*\)\""	matchgroup=shRedir31 end="^\s*\z1\s*$"
" syn region shHereDoc matchgroup=shRedir32 start="<<\\\z([^ \t|]*\)"		matchgroup=shRedir32 end="^\z1\s*$"
"endif

"syn region  pythonRawString
"      \ start=+[uU]\=[rR]\z('''\|"""\)+ end="\z1" keepend
"      \ contains=pythonUToolCodeblock,pythonSpaceError,pythonDoctest,@Spell

"""" <UTOOL THINGS> """"
" References
" http://vim.1045645.n5.nabble.com/sh-bash-syntax-for-here-document-strings-embedding-other-languages-td5081687.html


"syn match pythonFmtString "{[A-Za-z][A-Za-z_]}" contained 
syn region pythonFmtString start="{[A-Za-z][A-Za-z_]*" end="}" contained 

syn match pythonUtoolStartBlock "^\s*# STARTBLOCK[\n ]*" contained
syn match pythonUtoolEndBlock   "^\s*# ENDBLOCK[\n ]*" contained

syn region pythonUToolCodeblock
        \ start="^\s*# STARTBLOCK[\n ]*" end="# ENDBLOCK"
  \ contained contains=pythonStatement,pythonDoctest,pythonConditional,pythonRepeat,pythonOperator,pythonException,pythonInclude,pythonDecorator,pythonFunction,pythonComment,pythonString,pythonRawString,pythonFmtString, pythonUtoolStartBlock, pythonUtoolEndBlock, pythonEscape, pythonTodo, pythonBuiltin, pythonExceptions, pythonSpaceError
"ALLBUT,@Spell
"
"""" </UTOOL THINGS> """"

  "HiLink pythonUToolCodeblock	Special
