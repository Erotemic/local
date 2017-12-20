" Custom Folding 
" References: http://vim.wikia.com/wiki/Syntax_folding_of_Vim_scripts


"syn region pythonGoogleDocblock
"        \ start="^\s*Args:[\n ]*" end="\n\n"
"  \ contained contains=


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



syn region  pythonSingleStringMulti
      \ start=+[uU]\=\z('''\)+ end="\z1" keepend
      \ contains=pythonEscape,pythonSpaceError,pythonDoctest,@Spell
syn region  pythonDoubleStringMulti
      \ start=+[uU]\=\z("""\)+ end="\z1" keepend
      \ contains=pythonEscape,pythonSpaceError,pythonDoctest,@Spell
syn region  pythonRawSingleStringMulti
      \ start=+[uU]\=[rR]\z('''\)+ end="\z1" keepend
      \ contains=pythonSpaceError,pythonDoctest,@Spell
syn region  pythonRawDoubleStringMulti
      \ start=+[uU]\=[rR]\z('''\)+ end="\z1" keepend
      \ contains=pythonSpaceError,pythonDoctest,@Spell



"""" <UTOOL THINGS> """"
" TODO: put in after/syntax/python.vim


syn match pythonFmtString "{[A-Za-z][A-Za-z_]*}" contained 
"syn region pythonFmtString start="{[A-Za-z][A-Za-z_]*" end="}" contained 

"syn match pythonUtoolStartBlock "^\s*# STARTBLOCK[\n ]*" contained
"syn match pythonUtoolEndBlock   "^\s*# ENDBLOCK[\n ]*" contained

"syn region pythonUToolCodeblock
"        \ start="^\s*# STARTBLOCK[\n ]*" end="# ENDBLOCK"
"        \ containedin=pythonSingleStringMulti,pythonDoubleStringMulti,pythonRawSingleStringMulti,pythonRawDoubleStringMulti
"  \ contained contains=pythonStatement,pythonDoctest,pythonConditional,pythonRepeat,pythonOperator,pythonException,pythonInclude,pythonDecorator,pythonFunction,pythonComment,pythonString,pythonRawString,pythonFmtString, pythonUtoolStartBlock, pythonUtoolEndBlock, pythonEscape, pythonTodo, pythonBuiltin, pythonExceptions, pythonSpaceError

function! MyTextEnableCodeSnip(filetype,start,end,parent) abort
  " http://vim.wikia.com/wiki/Different_syntax_highlighting_within_regions_of_a_file
  let ft=toupper(a:filetype)
  let group='textGroup'.ft
  if exists('b:current_syntax')
    let s:current_syntax=b:current_syntax
    " Remove current syntax definition, as some syntax files (e.g. cpp.vim)
    " do nothing if b:current_syntax is defined.
    unlet b:current_syntax
  endif
  execute 'syntax include @'.group.' syntax/'.a:filetype.'.vim'
  try
    execute 'syntax include @'.group.' after/syntax/'.a:filetype.'.vim'
  catch
  endtry
  if exists('s:current_syntax')
    let b:current_syntax=s:current_syntax
  else
    unlet b:current_syntax
  endif
  execute 'syntax region textSnip'.ft.
  \' matchgroup=SpecialNested'.a:filetype.
  \' start="'.a:start.'" end="'.a:end.'"'.
  \' containedin='.a:parent.
  \' contains=@'.group
  "let tsq="'''"
  "let tdq='"""'
  "let tq=tsq.'\|'.tdq
  "let tqstr_start='[uU]\=[rR]\z('.tq.'\)'

  "execute 'syntax region textSnip'.ft.
  "            \' matchgroup='.a:textSnipHl.
  "            \' start=+'.tqstr_start.'\s*#!'.a:start.'+'.
  "            \' end="'.a:end.'\z1"'.
  "            \' contains=@'.group
endfunction

        "\ start=+\z('''\|"""\)\s*#!/+ end=+\z1+
        "\ start="^\s*#!/" end="'''"
        "\ start="^\s*#!" end="\(!\)\@<=\_.*" keepend


"\ start=+[uU]\=[rR]\z('''\|"""\)+ end="\z1" keepend
"\ start=+[uU]\=\z('''\|"""\)+ end="\z1" keepend


"call MyTextEnableCodeSnip('sh', "'''".'\s*#!/bin/sh', "'''", 'SpecialBashComment')
"call MyTextEnableCodeSnip('sh', "'''".'\s*#!/bin/sh', "'''", 'SpecialBashComment')


"syn region DUMMYREGION
"      \ start=+\z('''\|"""\)\s*#+ end="!" keepend
"      \ contains=pythonSpaceError


let single_multi='pythonSingleStringMulti,pythonRawSingleStringMulti'
let double_multi='pythonDoubleStringMulti,pythonRawDoubleStringMulti'

call MyTextEnableCodeSnip('sh', '\s*\(#!/bin/sh\)\@=', "'''", single_multi) 
call MyTextEnableCodeSnip('sh', '\s*\(#!/bin/bash\)\@=', "'''", single_multi)
call MyTextEnableCodeSnip('sh', '\s*\(#!/bin/sh\)\@=', '"""', double_multi) 
call MyTextEnableCodeSnip('sh', '\s*\(#!/bin/bash\)\@=', '"""', double_multi)
        
        "\ start="\(\s* # STARTBLOCK\)\@<=" end="# ENDBLOCK"
        "\ start="^\s*#\s*CODEBLOCK[\n ]*" end="#\s*ENDBLOCK"
syn region pythonCodeblockSnippet
        \ start="\(^\s*#\s*STARTBLOCK *.*\)\@<=\n" end="\(# ENDBLOCK\)\@="
        \ containedin=pythonSingleStringMulti,pythonDoubleStringMulti,pythonRawSingleStringMulti,pythonRawDoubleStringMulti
        \ contained contains=pythonStatement,pythonDoctest,pythonConditional,pythonRepeat,pythonOperator,pythonException,pythonInclude,pythonDecorator,pythonFunction,pythonComment,pythonString,pythonRawString,pythonFmtString,pythonEscape, pythonTodo, pythonBuiltin, pythonExceptions, pythonSpaceError


" Within a multiline string check if it starts with a shebang #!  e.g.
" #!/bin/bash. The end pattern is a bit hacky and might fail for nested tripple
" quotes.
"syn region pythonShebangCodeblock
"    \ start="^\s*#!" end=+('''|""")+ keepend
"  \ contained contains=pythonStatement,pythonDoctest,pythonConditional,pythonRepeat,pythonOperator,pythonException,pythonInclude,pythonDecorator,pythonFunction,pythonComment,pythonString,pythonRawString,pythonFmtString, pythonEscape, pythonTodo, pythonBuiltin, pythonExceptions, pythonSpaceError
"ALLBUT,@Spell
"
"""" </UTOOL THINGS> """"



" IF THIS BREAKS LOOK INTO REPLACE hi def link with HiLink (see python.vim for
" definition)
hi def link pythonAsync			Statement

hi def link pythonSingleStringMulti String
hi def link pythonDoubleStringMulti String
hi def link pythonRawSingleStringMulti String
hi def link pythonRawDoubleStringMulti String

hi def link pythonCodeblockSnippet Special
