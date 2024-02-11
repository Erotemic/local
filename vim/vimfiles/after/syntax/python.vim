" Custom Folding 
" References: http://vim.wikia.com/wiki/Syntax_folding_of_Vim_scripts



" highlight format string repl locations inside codeblock strings
syn match pythonFmtString "{[A-Za-z][A-Za-z_]*}" contained 

" Override pythonString and PythonRawString to differentiate between triple
" and single quoted strings 
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

"==== DEFINE CODEBLOCK HIGHLIGHT PATTERNS ====


function! MyTextEnableCodeSnip(filetype,start,end,parent) abort
  let __doc__=<< DOC

  Args:
      filetype : what language the internal text should be highlighted as
      start : the pattern that starts the filetype syntax highlighting
      end : the pattern that ends the filetype syntax highlighting
      parent : the syntax tags that this rule applies inside of

  References:
      http://vim.wikia.com/wiki/Different_syntax_highlighting_within_regions_of_a_file

DOC
  " 
  let ft=toupper(a:filetype)
  let group='textGroup'.ft
  if exists('b:current_syntax')
    let s:current_syntax=b:current_syntax
    " Remove current syntax definition, as some syntax files (e.g. cpp.vim)
    " do nothing if b:current_syntax is defined.
    unlet b:current_syntax
  endif
  execute 'syn include @'.group.' syntax/'.a:filetype.'.vim'
  try
    execute 'syn include @'.group.' after/syntax/'.a:filetype.'.vim'
  catch
  endtry
  if exists('s:current_syntax')
    let b:current_syntax=s:current_syntax
  else
    unlet b:current_syntax
  endif
  execute 'syn region textSnip'.ft.
      \' matchgroup=SpecialNested'.a:filetype.
      \' keepend start="'.a:start.'" end="'.a:end.'"'.  
      \' containedin='.a:parent.
      \' contains=@'.group
endfunction

let single_multi='pythonSingleStringMulti,pythonRawSingleStringMulti'
let double_multi='pythonDoubleStringMulti,pythonRawDoubleStringMulti'

" Look Ahead Behind Notes:
"     Look ahead leading character: @
"     Look behind leading character: @<
"     Trailing = means positive
"     Trailing ! means negative 
"
"     Concrete Examples:
"         positive behind: @<=
"         negative behind: @<!
"         positive ahead:  @=
"         negative ahead:  @!

python3 << EOF

if 0:
    import xdev
    import re
    import ubelt as ub

    b = xdev.RegexBuilder.coerce('vim')

    syntax_infos = [
        {'filetype': 'sh', 'header': '#!/usr/bin/env bash'},
        {'filetype': 'sh', 'header': '#!/bin/sh'},
        {'filetype': 'python', 'header': '#!/usr/bin/env python'},
    ]

    end_pattern_infos = [
        {'end_pattern': "'''", 'parent': 'single_multi'},
        {'end_pattern': '"""', 'parent': 'double_multi'},
    ]

    template = "call MyTextEnableCodeSnip('{filetype}', '{start_pattern}', {end_pattern!r}, {parent})"
    for info in syntax_infos:
        info['start_pattern'] = r'\s*' + b.lookahead(re.escape(info['header']).replace('/', r'\/'))
        for end_info in end_pattern_infos:
            fmtkw = ub.udict(info) | end_info
            line = template.format(**fmtkw)
            print(line)

            #region_template = ub.codeblock(f'''
            #    syn region {region_name}
            #    matchgroup={matchgroup_name}
            #    keepend
            #    start="{start_pattern}"
            #    end="{end_pattern}"
            #    containedin="{parent_name}"
            #    contains="{group_name}"
            #    ''').replace('\n', ' ')
            #print(region_template)
EOF

"~/local/vim/vimfiles/after/syntax/python.vim
" ------------
" TODO: figure out how to correctly highlight docstrings with a shebang.
"  See ~/misc/tests/python/test_highlight.py for a testing file

"                    filetype |      start              |  end   |   parent
call MyTextEnableCodeSnip('sh', '\#!\/bin\/bash', "'''", single_multi)
"call MyTextEnableCodeSnip('sh', '\s*\(\#!\/bin\/bash\)\@=', '"""', double_multi)
"call MyTextEnableCodeSnip('sh', '\s*\(\#!\/bin\/sh\)\@=', "'''", single_multi)
"call MyTextEnableCodeSnip('sh', '\s*\(\#!\/bin\/sh\)\@=', '"""', double_multi)
"call MyTextEnableCodeSnip('python', '\s*\(\#!\/usr\/bin\/env\ python\)\@=', "'''", single_multi)
"call MyTextEnableCodeSnip('python', '\s*\(\#!\/usr\/bin\/env\ python\)\@=', '"""', double_multi)


" OLD MANUAL CALLS
"call MyTextEnableCodeSnip('sh', '\s*\(#!/bin/sh\)\@=',   "'''", single_multi) 
"call MyTextEnableCodeSnip('sh', '\s*\(\#!/usr/bin/env bash\)\@=', "'''", single_multi)
"call MyTextEnableCodeSnip('sh', 'bash', "'''", single_multi)
"call MyTextEnableCodeSnip('sh', '\s*\(#!/bin/sh\)\@=',   '"""', double_multi) 
"call MyTextEnableCodeSnip('sh', '\s*\(#!/usr/bin/env bash\)\@=', '"""', double_multi)

" Try escaping quotes, move leading space inside lookbehind
"call MyTextEnableCodeSnip('sh', '\(\s*#!\/bin\/sh\)\@=',   "'''", single_multi) 
"call MyTextEnableCodeSnip('sh', '\(\s*#!\/bin\/bash\)\@=', "'''", single_multi)
"call MyTextEnableCodeSnip('sh', '\(\s*#!\/bin\/sh\)\@=',   '"""', double_multi) 
"call MyTextEnableCodeSnip('sh', '\(\s*#!\/bin\/bash\)\@=', '"""', double_multi)

"call MyTextEnableCodeSnip('sh', '\s*#!/bin/sh',   "'''", single_multi) 
"call MyTextEnableCodeSnip('sh', '\s*#!/usr/bin/env bash', "'''", single_multi)
"call MyTextEnableCodeSnip('sh', '\s*#!/bin/sh',   '"""', double_multi) 
"call MyTextEnableCodeSnip('sh', '\s*#!/usr/bin/env bash', '"""', double_multi)

"call MyTextEnableCodeSnip('sh', '+\s*#!\/bin\/sh+',   "+\('''\)\@=+", single_multi) 
"call MyTextEnableCodeSnip('sh', '+\s*#!\/bin\/sh+',   '+\("""\)\@=+', double_multi) 

"call MyTextEnableCodeSnip('sh', '+\s*#!\/bin\/bash+', "+\('''\)\@=+", single_multi)
"call MyTextEnableCodeSnip('sh', '+\s*#!\/bin\/bash+', '+\("""\)\@=+', double_multi)

"call MyTextEnableCodeSnip('python', '+\s*#!\/usr\/bin\/env python+', "+\('''\)\@=+", single_multi)
"call MyTextEnableCodeSnip('python', '+\s*#!\/usr\/bin\/env python+', '+\("""\)\@=+', double_multi)
" ------------
        
syn region pythonCodeblockSnippet
        \ start="\(^\s*#\s*STARTBLOCK *.*\)\@<=\n" end="\(# ENDBLOCK\)\@="
        \ containedin=pythonSingleStringMulti,pythonDoubleStringMulti,pythonRawSingleStringMulti,pythonRawDoubleStringMulti
        \ contained contains=pythonStatement,pythonDoctest,pythonConditional,pythonRepeat,pythonOperator,pythonException,pythonInclude,pythonDecorator,pythonFunction,pythonComment,pythonString,pythonRawString,pythonFmtString,pythonEscape, pythonTodo, pythonBuiltin, pythonExceptions, pythonSpaceError

" Within a multiline string check if it starts with a shebang #!  e.g.
" #!/usr/bin/env bash. The end pattern is a bit hacky and might fail for nested tripple
" quotes.
"syn region pythonShebangCodeblock
"    \ start="^\s*#!" end=+('''|""")+ keepend
"  \ contained contains=pythonStatement,pythonDoctest,pythonConditional,pythonRepeat,pythonOperator,pythonException,pythonInclude,pythonDecorator,pythonFunction,pythonComment,pythonString,pythonRawString,pythonFmtString, pythonEscape, pythonTodo, pythonBuiltin, pythonExceptions, pythonSpaceError
"ALLBUT,@Spell


"==== DEFINE HIGHLIGHT COLOR-TYPES ====

" IF THIS BREAKS, REPLACE hi def link with HiLink (see python.vim for details)
hi def link pythonSingleStringMulti String
hi def link pythonDoubleStringMulti String
hi def link pythonRawSingleStringMulti String
hi def link pythonRawDoubleStringMulti String

hi def link pythonCodeblockSnippet Special

hi def link pythonFmtString Type



" DONT AVOID HIGHLIGHTING ATTRIBUTES AS BUILTIN
" NEED TO MODIFY `syn match   pythonAttribute` to remove pythonBuiltin in
" the main syntax file. Not sure how to do it here.
" TODO: ask question on SO
