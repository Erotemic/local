func! FUNC_Remap(lhs, rhs)
    :echom 'inoremap '.a:lhs.' '.a:rhs
    :exec 'noremap '.a:lhs.' '.a:rhs
    :exec 'inoremap '.a:lhs.' '.a:rhs
endfu


command! -nargs=* CMDREMAP call FUNC_Remap(<f-args>)

func! NumberLineInvert()
    "map each number to its shift-key character
    :CMDREMAP 1 !
    :CMDREMAP 2 @
    :CMDREMAP 3 #
    :CMDREMAP 4 $
    :CMDREMAP 5 %
    :CMDREMAP 6 ^
    :CMDREMAP 7 &
    :CMDREMAP 8 *
    :CMDREMAP 9 (
    :CMDREMAP 0 )
    :CMDREMAP - _
    " and then the opposite
    :CMDREMAP ! 1
    :CMDREMAP @ 2
    :CMDREMAP # 3
    :CMDREMAP $ 4
    :CMDREMAP % 5
    :CMDREMAP ^ 6
    :CMDREMAP & 7
    :CMDREMAP * 8
    :CMDREMAP ( 9
    :CMDREMAP ) 0
    :CMDREMAP _ -
endfu


func! NumberLineRevert()
    "map each number to its shift-key character
    :CMDREMAP ! !
    :CMDREMAP @ @
    :CMDREMAP # #
    :CMDREMAP $ $
    :CMDREMAP % %
    :CMDREMAP ^ ^
    :CMDREMAP & &
    :CMDREMAP * *
    :CMDREMAP ( (
    :CMDREMAP ) )
    :CMDREMAP _ _
    " and then the opposite
    :CMDREMAP 1 1
    :CMDREMAP 2 2
    :CMDREMAP 3 3
    :CMDREMAP 4 4
    :CMDREMAP 5 5
    :CMDREMAP 6 6
    :CMDREMAP 7 7
    :CMDREMAP 8 8
    :CMDREMAP 9 9
    :CMDREMAP 0 0
    :CMDREMAP - -
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
