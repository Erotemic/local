command! SAVESESSION :mksession ~/mysession.vim
command! LOADSESSION :mksession ~/mysession.vim

command! SAVEHSSESSION :mksession ~/vim_hotspotter_session.vim
command! LOADHSSESSION :source ~/vim_hotspotter_session.vim

func! WordHighlightFun()
    if !exists("g:togwordhighlight") 
        let g:togwordhighlight=0
    end
    if (g:togwordhighlight)     
        exe printf('match DiffChange /\V\<%s\>/', escape(expand('<cword>'), '/\'))
    endif
endfu

func! ToggleWordHighlight()
    if !exists("g:togwordhighlight") 
        let g:togwordhighlight=1 
    else 
        let g:togwordhighlight = 1 - g:togwordhighlight 
    endif 
endfu

function! FUNC_TextWidthMarkerOn()
    highlight OverLength ctermbg=red ctermfg=white guibg=#592929
    highlight OverLength ctermbg=red ctermfg=white guibg=#502020
    match OverLength /\%81v.\+/
endfunction


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



function! FUNC_TextWidthLineOn()
if exists('+colorcolumn')
  set colorcolumn=81
else
  au! BufWinEnter * let w:m2=matchadd('ErrorMsg', '\%>80v.\+', -1)
endif
endfunction


fu! FUNC_BadCapsSearch()
    :/[^.}] *\n *[A-Z]\|[^\.]  *[A-Z]
    :Highlight 7 [^.}] *\n *[A-Z]\|[^\.]  *[A-Z]
    :Hclear [^.}] *\n
endfu

"perl -pi -e 's/[[:^ascii:]]//g' wiki_scale_list.py


fu! FUNC_MYCOMMAND()

endfu

fu! FUNC_MOVE_CITATION_TO_FRONT()
    " changes (cite) to the front
    :%s/{ *\([^(]*\) *\(([^)]*)\) *}/{\2 \1}/gc
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

fu! FUNC_MAKE_BRAK_EQUATIONS()
    :execute '%s/\<\\\[\>/\\begin{equation}\r/gc'
    :execute '%s/\<\\]\>/\r\\end{equation}/gc'
endfu

fu! FUNC_REPL_PAREN_BRACE(funcname)
    " Replaces normal(hi) with normal{hi}
    let fnstr=a:funcname
    :execute '%s/\<\('.fnstr.'\)\>(\([^(]*\))/\1{\2}/gc'
endfu

fu! FUNC_REPLACE_BACKSLASH()
    :s/\\/\//g
endfu

fu! FUNC_RELOAD_VIMRC()
    source $pvimrc 
endfu

fu! FUNC_SELPAPER()
    "Select 2 lines, Delete move to next window paste move back 
    :d3
    :wincmd l
    :put
    :wincmd h
endfu

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

fu! REVERSE_DICT()
    :s/\([^{ :]*\): \([^,]*\),/\2: \1,/gc
    :s/
endfu

fu! FUNC_DICT_TO_ATTR(dictstr)
    let dictstr=a:dictstr
    ":execute '%s/'.dictstr.'[''\<\(\[A-Za-z_]*\)'']\>\([^(]\)/'.dictstr.'.\1\2/gc'
    :execute '%s/'.dictstr.'\[.\([^'."'".']*\)../'.dictstr.'.\1 /gc'
    " THIS ONE
    "%s/_cfg\[.\([^']*\)../_cfg.\1 /gc
endfu

fu! FUNC_FIX_ATTR_TO_DICT(attrstr)
    let attrstr=a:attrstr
    :execute '%s/'.attrstr.'\.\<\(\[A-Za-z_]*\)\>\([^(]\)/'.attrstr.'["\1"]\2/gc'
endfu

fu! FUNC_np_Style_Check(npcmd)
    let npcmdstr=a:npcmd
    :execute '%s/\([^.a-zA-Z]\)\(\<'.npcmdstr.'\>\)/\1np.\2/gc'
endfu

fu! FUNC_np_Style_NoCheck(npcmd)
    let npcmdstr=a:npcmd
    :execute '%s/\([^.a-zA-Z]\)\(\<'.npcmdstr.'\>\)/\1np.\2/g'
endfu

fu! FUNC_np_FIX_COMMON()
    :call FUNC_np_Style_NoCheck("array")
    :call FUNC_np_Style_NoCheck("load")
    :call FUNC_np_Style_NoCheck("savez")
    :call FUNC_np_Style_NoCheck("asarray")
    :call FUNC_np_Style_NoCheck("append")
    :call FUNC_np_Style_NoCheck("zeros")
    :call FUNC_np_Style_NoCheck("ones")
    :call FUNC_np_Style_NoCheck("empty")
    :call FUNC_np_Style_NoCheck("uint32")
    :call FUNC_np_Style_NoCheck("bool")
    :call FUNC_np_Style_NoCheck("sum")
    :call FUNC_np_Style_NoCheck("linalg")
    :call FUNC_np_Style_NoCheck("float32")
    :call FUNC_np_Style_NoCheck("bitwise_or")
    :call FUNC_np_Style_NoCheck("iterable")
endfu

"--------Pristine and DOCUMENTED commands-----
fu! PEP8PRINT()
    "Changes all 2.7 prints to v3'
    let m_spaces='\( *\)'
    let m_anys='\(.*\)'
    let m_endl=' *$'
    :execute 's/'.m_spaces.'print '.m_anys.m_endl.'/\1print(\2)'
endfu
command! -range PEP8PRINT <line1>,<line2>call PEP8PRINT()<CR>

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

" Mappings
"nnoremap <Leader>r :call FUNC_RELOAD_VIMRC()<CR>
nnoremap <Leader>f :call FUNC_SELPAPER()<CR>
nnoremap <Leader>q :call UnderscoresToCamelCase()<CR>

command! REPLPARENBRACE :call FUNC_REPL_PAREN_BRACE()<CR>
command! REPLnormal :call FUNC_REPL_PAREN_BRACE('normal')<CR>
command! REPLprobibility :call FUNC_REPL_PAREN_BRACE('Pr')<CR>
command! TextWidthMarkerOn call FUNC_TextWidthMarkerOn()
" Textwidth command
command! TextWidth80 set textwidth=80
command! TextWidthLineOn call FUNC_TextWidthLineOn()
command! MAKEBRAKEQUATIONS :call FUNC_MAKE_BRAK_EQUATIONS()<CR>
