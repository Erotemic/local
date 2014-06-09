func! NumberLineInvert()
    "map each number to its shift-key character
    inoremap 1 !
    inoremap 2 @
    inoremap 3 #
    inoremap 4 $
    inoremap 5 %
    inoremap 6 ^
    inoremap 7 &
    inoremap 8 *
    inoremap 9 (
    inoremap 0 )
    inoremap - _
    " and then the opposite
    inoremap ! 1
    inoremap @ 2
    inoremap # 3
    inoremap $ 4
    inoremap % 5
    inoremap ^ 6
    inoremap & 7
    inoremap * 8
    inoremap ( 9
    inoremap ) 0
    inoremap _ -
endfu


func! NumberLineRevert()
    "map each number to its shift-key character
    inoremap ! !
    inoremap @ @
    inoremap # #
    inoremap $ $
    inoremap % %
    inoremap ^ ^
    inoremap & &
    inoremap * *
    inoremap ( (
    inoremap ) )
    inoremap _ _
    " and then the opposite
    inoremap 1 1
    inoremap 2 2
    inoremap 3 3
    inoremap 4 4
    inoremap 5 5
    inoremap 6 6
    inoremap 7 7
    inoremap 8 8
    inoremap 9 9
    inoremap 0 0
    inoremap - -
endfu


func! ToggleNumberLineInvert()
    if !exists("g:toginvnum") 
        let g:toginvnum=1
    endif
    let g:toginvnum = 1 - g:toginvnum 
    if (g:toginvnum)
        call NumberLineInvert()
    else
        call NumberLineRevert()
    endif
endfu
