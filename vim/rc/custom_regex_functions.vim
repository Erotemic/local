func! FUNC_APPEND(word)
    " Insert Last word Every Line
    let word = a:word
    let regex = '\(.*\) *$/\1'
    let repl = '\1'.word
    :exec 's/'.regex.'/'.repl.'/gc'
endfunc


" call FUNC_APPEND(', (')


func! FUNC_APEND_RANGE(word) range
    " Insert Last word Every Line
    let word = a:word
    let regex = '\(.*\) *$/\1'
    let repl = '\1'.word
    for linenum in range(a:firstline, a:lastline)
        let curr_line   = getline(linenum)
        let replacement = substitute(curr_line, regex, repl, 'g')
        call setline(linenum, replacement)
    endfor
endfunc

"Align var:WORD
command! -range APPEND <line1>,<line2>call FUNC_APEND()<CR>
