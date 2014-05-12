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


func! FUNC_IBS_REPL()
    " Replace hs with ibs
    :%s/\<hs\>/ibs/g
    :%s/\<qcxs\>/qrids/g
    :%s/\<qcx\>/qrid/g
    :%s/\<qcx_list\>/qrid_list/g
    :%s/\<cx_list\>/rid_list/g
    :%s/\<cx\>/rid/g
    :%s/\<cxs\>/rids/g
    :%s/\<res\>/qres/g
    :%s/\<qcx2_res\>/qrid2_qres/g
    :%s/\<res2_/qres2_/g
    :%s/_cxs\>/_rids/g
    :%s/_cx\>/_rid/g
endfunc


func! FUNC_CUSTOM_CLEANUP()
python << endpython
import vim

indentation = '^  *'
alpha_    = '[A-Za-z_]' #  alphabet and underscore
alphanum_ = '[0-9A-Za-z_]' # alphanumerics and underscore
alphanumdot_ = '[0-9A-Za-z_.]' # alphanumerics and underscore
var = '\\<[' + alpha_ + alphanum_ + '*\\>'
chainedvar = '\\<[' + alpha_ + alphanumdot_ + '*\\>'

simplestr = r"'[^']*'"

def group(regex):
    return '\\(' + regex + '\\)'

def bref(num):
    return '\\' + str(num)

def resub(regex, repl, modifiers='gce'):
    print(regex)
    vim.command('%s/' + regex + '/' + repl + '/' + modifiers)

# Comments / Removes explicit new actions
regex = group(indentation) + group('ui\\.action' + alphanum_ + '* = ') + group('.*newAction')
repl_comment = bref(1) + '#' + bref(2) + '\r' + bref(1) + bref(3)
repl_remove = bref(1) + bref(3)
comment_newaction_def = (regex, repl_comment)
remove_newaction_def  = (regex, repl_remove)

# Call specified regexes
# resub(*remove_newaction_def)


# Fix not <word> is
fix_notis_regex = ' \\<not\\> ' + group(chainedvar) + ' is '
repl = ' ' + bref(1) + ' is not '
resub(fix_notis_regex, repl)


fix_notin_regex1 = ' \\<not\\> ' + group(chainedvar) + ' in '
fix_notin_regex2 = ' \\<not\\> ' + group(simplestr)  + ' in '
repl = ' ' + bref(1) + ' not in '
resub(fix_notin_regex1, repl)
resub(fix_notin_regex2, repl)


endpython
endfunc
command! CUSTOMCLEANUP call FUNC_CUSTOM_CLEANUP()<CR>


func! FUNC_CLEAN_WHITESPACE()
    :%s/ *$//g
endfunc


func! <SID>StripTrailingWhitespaces()
    "http://stackoverflow.com/questions/356126/how-can-you-automatically-remove-trailing-whitespace-in-vim
    let l = line(".")
    let c = col(".")
    %s/\s\+$//e
    call cursor(l, c)
endfun

autocmd FileType c,cpp,java,php,ruby,python autocmd BufWritePre <buffer> :call <SID>StripTrailingWhitespaces()
