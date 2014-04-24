"-------------------------
"BIBTEX PAPERS
command! BIBSPACE :call CopyiedRefsSpacings()
func! CopyiedRefsSpacings()
    %s/\([^\r]\)\[/\r\[/g
    %s/\(\<[^ ]\+\>\)- \(\<[^ ]\+\>\)/\1\2/g
endfu
"-------------------------
func! ToCamelCase()
    %s/\<\([a-zA-Z_]*\)_bit/is_\1/gc
    %s/_\([a-zA-Z]\)\([a-zA-Z]*\)/\U\1\L\2/gc
endfu


fu! FUNC_BadCapsSearch()
    :/[^.}] *\n *[A-Z]\|[^\.]  *[A-Z]
    :Highlight 7 [^.}] *\n *[A-Z]\|[^\.]  *[A-Z]
    :Hclear [^.}] *\n
endfu
fu! FUNC_SELPAPER()
    "Select 2 lines, Delete move to next window paste move back 
    :d3
    :wincmd l
    :put
    :wincmd h
endfu

fu! FUNC_MAKE_BRAK_EQUATIONS()
    :execute '%s/\<\\\[\>/\\begin{equation}\r/gc'
    :execute '%s/\<\\]\>/\r\\end{equation}/gc'
endfu

fu! FUNC_MOVE_CITENUM_BRAK()
    " changes (cite) to [cite]
    :%s/(\([0-9]*\) [Cc]it[ae][a-z]*)/[\1 cites]/gc
    " Moves cite after (CITE PATTERN)

    " CITEATION PATTERN
    " \([^)]*)\)
    "
    "   AuthorName    PUBLISHER       YEAR
    :%s/(\([^)]*\) \([A-Z][A-Z][A-Z]*\) \([12][0-9][0-9][0-9]\))/(\2 \3, \1)/gc

    " Captialize Journals
    :%s/cvpr/CVPR/gc

    "     CITATION     TITLE   CITES
    :%s/{\(([^)]*)\) \(.*\) \(\[[0-9]* cites\]\)}/{\1 \3 \2}/gc
                
endfu

fu! FUNC_CHANGE_PARAGRAPH()
    :%s/\\paragraph{\([^}]*\)}/\\PaperCategory/gc
endfu


fu! FUNC_MOVE_CITATION_TO_FRONT()
    " changes (cite) to the front
    :%s/{ *\([^(]*\) *\(([^)]*)\) *}/{\2 \1}/gc
endfu


fu! FUNC_REPL_PAREN_WITH_BRACE(funcname)
    " Replaces normal(hi) with normal{hi}
    let fnstr=a:funcname
    :execute '%s/\<\('.fnstr.'\)\>(\([^(]*\))/\1{\2}/gc'
endfu
command! REPLPARENBRACE :call FUNC_REPL_PAREN_WITH_BRACE()<CR>
command! REPLnormal :call FUNC_REPL_PAREN_WITH_BRACE('normal')<CR>
command! REPLprobibility :call FUNC_REPL_PAREN_WITH_BRACE('Pr')<CR>

"http://vim.wikia.com/wiki/Converting_variables_to_or_from_camel_case
command! CamelCase :call UnderscoresToCamelCase()
func! UnderscoresToCamelCaseFirstUp()
    " Convert each name_like_this to NameLikeThis in current line.
    :s#\(\%(\<\l\+\)\%(_\)\@=\)\|_\(\l\)#\u\1\2#g
endfu
func! UnderscoresToCamelCase()
    " Convert each name_like_this to nameLikeThis in current line.
    :s#_\(\l\)#\u\1#g
endfu

"http://vim.wikia.com/wiki/Converting_variables_to_or_from_camel_case
command! CamelCase :call UnderscoresToCamelCase()
func! UnderscoresToCamelCaseFirstUp()
    " Convert each name_like_this to NameLikeThis in current line.
    :s#\(\%(\<\l\+\)\%(_\)\@=\)\|_\(\l\)#\u\1\2#g
endfu
func! UnderscoresToCamelCase()
    " Convert each name_like_this to nameLikeThis in current line.
    :s#_\(\l\)#\u\1#g
endfu


command! MAKEBRAKEQUATIONS :call FUNC_MAKE_BRAK_EQUATIONS()<CR>
