
fu! FUNC_PEP8_SAFE()
    :%s/^\([^#']*\)\([^ +\(]\)+\([^ +\(=]\)/\1\2 + \3/gc
    "        1          2     +      3
    :%s/^\([^#']*\)\([^ \-\(]\)-\([^ \-\(=]\)/\1\2 - \3/gc
    "        1          2      -      3
    :%s/^\([^#']*\)\([^ \*\(]\)\*\([^ \*\(=]\)/\1\2 * \3/gc
    "        1          2      -      3
endfu

fu! FUNC_PEP8_OPSPACE()
    :%s/\([^ \(*]\)\*\([^ =]\)/\1 * \2/gc
    :%s/\([^ \(]\)+\([^ =]\)/\1 + \2/gc
    :%s/\([^ \(]\)-\([^ =]\)/\1 - \2/gc
    :%s/\([^ \(]\)\/\([^ =]\)/\1 \/ \2/gc
endfu


fu! PEP8COMMASPACE()
    " Finds commas without a space or left paren right after
    let m_not_space_lparen='\([^ )]\)'
    :execute '%s/,'.m_not_space_lparen.'/, \1/gc'
endfu
command! PEP8COMMASPACE :call PEP8COMMASPACE()<CR>

fu! PEP8ALIGNDICT()
    " Aligns colon to the left
    :execute 's/\( *\):/:\1'
endfu
command! -range PEP8ALIGNDICT <line1>,<line2>call PEP8ALIGNDICT()<CR>

fu! PEP8TWOSPACECOMMENT()
    " Finds commas without a space or left paren right after
    "let m_spaces='\( *\)'
    "let m_twonotspace='[^ #][^ #]\)'
    "let m_notquotehash='[^'."'".'#]'
    ":execute '%s/'.m_twonotspace.'#'.m_notquotehash.'*/\1  # \2, \1/gc'
    :execute '%s/\([^ ]\) \(#[^#]*$\)/\1  \2/gc'
    :execute '%s/\([^ ]\)\(#[^#]*$\)/\1  \2/gc'
    :execute '%s/\([^ ]\)#\([^ ][^#]*$\)/\1  # \2/gc'
endfu
command! PEP8TWOSPACECOMMENT :call PEP8COMMASPACE()<CR>


"--------Pristine and DOCUMENTED commands-----
fu! PEP8PRINT()
    "Changes all 2.7 prints to v3'
    let m_spaces='\( *\)'
    let m_anys='\(.*\)'
    let m_endl=' *$'
    :execute 's/'.m_spaces.'print '.m_anys.m_endl.'/\1print(\2)'
endfu
command! -range PEP8PRINT <line1>,<line2>call PEP8PRINT()<CR>

