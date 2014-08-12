func! FUNC_Remap(lhs, rhs)
    " Function which remaps keys in all modes
    "
    ":echom 'inoremap '.a:lhs.' '.a:rhs
    "http://vim.wikia.com/wiki/Mapping_keys_in_Vim_-_Tutorial_(Part_1)
    "--------------
    " Normal Mode
    :exec 'noremap '.a:lhs.' '.a:rhs
    " Insert and Replace Mode
    :exec 'inoremap '.a:lhs.' '.a:rhs
    " Visual and Select Mode
    :exec 'vnoremap '.a:lhs.' '.a:rhs
    " Command Line Mode
    ":exec 'cnoremap '.a:lhs.' '.a:rhs
    " Operator Pending Mode
    :exec 'onoremap '.a:lhs.' '.a:rhs
endfu
command! -nargs=* CMDREMAP call FUNC_Remap(<f-args>)


func! FUNC_Swap(lhs, rhs)
    " Normal Mode
    :exec 'noremap '.a:lhs.' '.a:rhs
    :exec 'noremap '.a:rhs.' '.a:lhs
    " Insert and Replace Mode
    :exec 'inoremap '.a:lhs.' '.a:rhs
    :exec 'inoremap '.a:rhs.' '.a:lhs
    " Visual and Select Mode
    :exec 'vnoremap '.a:lhs.' '.a:rhs
    :exec 'vnoremap '.a:rhs.' '.a:lhs
    " Operator Pending Mode
    :exec 'onoremap '.a:lhs.' '.a:rhs
    :exec 'onoremap '.a:rhs.' '.a:lhs
endfu
command! -nargs=* CMDSWAP call FUNC_Swap(<f-args>)


func! FUNC_Unswap(lhs, rhs)
    " Normal Mode
    :exec 'noremap '.a:rhs.' '.a:rhs
    :exec 'noremap '.a:lhs.' '.a:lhs
    " Insert and Replace Mode
    :exec 'inoremap '.a:rhs.' '.a:rhs
    :exec 'inoremap '.a:lhs.' '.a:lhs
    " Visual and Select Mode
    :exec 'vnoremap '.a:rhs.' '.a:rhs
    :exec 'vnoremap '.a:lhs.' '.a:lhs
    " Operator Pending Mode
    :exec 'onoremap '.a:rhs.' '.a:rhs
    :exec 'onoremap '.a:lhs.' '.a:lhs
endfu
command! -nargs=* CMDUNSWAP call FUNC_Unswap(<f-args>)


func! FUNC_Swap2(lhs, rhs)
    " Function which remaps keys in all modes
    ":exec 'noremap '.a:lhs.' '.a:rhs
    :exec 'inoremap '.a:lhs.' '.a:rhs
    :exec 'inoremap '.a:rhs.' '.a:lhs
    ":exec 'vnoremap '.a:lhs.' '.a:rhs
    ":exec 'vnoremap '.a:rhs.' '.a:lhs
    ":exec 'onoremap '.a:lhs.' '.a:rhs
    ":exec 'onoremap '.a:rhs.' '.a:lhs
endfu
command! -nargs=* CMDSWAP2 call FUNC_Swap2(<f-args>)

func! FUNC_Unswap2(lhs, rhs)
    " Normal Mode
    ":exec 'noremap '.a:rhs.' '.a:rhs
    ":exec 'noremap '.a:lhs.' '.a:lhs
    " Insert and Replace Mode
    :exec 'inoremap '.a:rhs.' '.a:rhs
    :exec 'inoremap '.a:lhs.' '.a:lhs
    " Visual and Select Mode
    ":exec 'vnoremap '.a:rhs.' '.a:rhs
    ":exec 'vnoremap '.a:lhs.' '.a:lhs
    " Operator Pending Mode
    ":exec 'onoremap '.a:rhs.' '.a:rhs
    ":exec 'onoremap '.a:lhs.' '.a:lhs
endfu
command! -nargs=* CMDUNSWAP2 call FUNC_Unswap2(<f-args>)


func! NumberLineInvert()
    "map each number to its shift-key character
    :CMDSWAP2 : ;
    :CMDSWAP 1 !
    :CMDSWAP 2 @
    :CMDSWAP 3 #
    :CMDSWAP 4 $
    :CMDSWAP 5 %
    :CMDSWAP 6 ^
    :CMDSWAP 7 &
    :CMDSWAP 8 *
    :CMDSWAP 9 (
    :CMDSWAP 0 )
    :CMDSWAP - _
    " and then the opposite
endfu


func! NumberLineRevert()
    "map each number to its shift-key character
    ":exec 'inoremap : :'
    ":exec 'inoremap ; ;'
    :CMDUNSWAP2 : ;
    :CMDUNSWAP 1 !
    :CMDUNSWAP 2 @
    :CMDUNSWAP 3 #
    :CMDUNSWAP 4 $
    :CMDUNSWAP 5 %
    :CMDUNSWAP 6 ^
    :CMDUNSWAP 7 &
    :CMDUNSWAP 8 *
    :CMDUNSWAP 9 (
    :CMDUNSWAP 0 )
    :CMDUNSWAP - _
endfu


func! ToggleNumberLineInvert()
    if !exists("g:toginvnum") 
        let g:toginvnum=1
    endif
    let g:toginvnum = 1 - g:toginvnum 
    if (g:toginvnum)
        ":echom "INVERT"
        ":echom g:toginvnum
        call NumberLineInvert()
    else
        ":echom g:toginvnum
        ":echom "REVERT"
        call NumberLineRevert()
    endif
endfu
