func! FUNC_Remap(lhs, rhs)
    " Function which remaps keys in all modes
    "
    ":echom 'inoremap '.a:lhs.' '.a:rhs
    "http://vim.wikia.com/wiki/Mapping_keys_in_Vim_-_Tutorial_(Part_1)
    "  CHAR	MODE	~
    " <Space>	Normal, Visual, Select and Operator-pending
	"n	Normal
	"v	Visual and Select
	"s	Select
	"x	Visual
	"o	Operator-pending
	"!	Insert and Command-line
	"i	Insert
	"l	":lmap" mappings for Insert, Command-line and Lang-Arg
	"c	Command-line
    "--------------
    " Normal Mode
    :exec 'noremap '.a:lhs.' '.a:rhs
    " Visual and Select Mode
    :exec 'vnoremap '.a:lhs.' '.a:rhs
    " Display select mode map
    :exec 'snoremap '.a:lhs.' '.a:rhs
    " Display visual mode maps
    :exec 'xnoremap '.a:lhs.' '.a:rhs
    " Operator Pending Mode
    :exec 'onoremap '.a:lhs.' '.a:rhs
    " Insert and Replace Mode
    :exec 'inoremap '.a:lhs.' '.a:rhs
    " Language Mode
    :exec 'lnoremap '.a:lhs.' '.a:rhs
    " Command Line Mode
    :exec 'cnoremap '.a:lhs.' '.a:rhs
    " Make r<lhs> do the right thing
    :exec 'noremap r'.a:lhs.' r'.a:rhs
    :exec 'noremap f'.a:lhs.' r'.a:rhs
endfu
command! -nargs=* CMDREMAP call FUNC_Remap(<f-args>)


func! FUNC_Unmap(lhs, rhs)
    ":CMDREMAP(a:lhs, a:lhs)
    ":CMDREMAP(a:rhs, a:rhs)
    :silent! exec 'nunmap '.a:lhs
    :silent! exec 'vunmap '.a:lhs
    :silent! exec 'sunmap '.a:lhs
    :silent! exec 'xunmap '.a:lhs
    :silent! exec 'ounmap '.a:lhs
    :silent! exec 'iunmap '.a:lhs
    :silent! exec 'lunmap '.a:lhs
    :silent! exec 'cunmap '.a:lhs
    " Make r<lhs> do the right thing
    :silent! exec 'unmap r'.a:lhs
    :silent! exec 'unmap f'.a:lhs
    " unmap other side
    :silent! exec 'nunmap '.a:rhs
    :silent! exec 'vunmap '.a:rhs
    :silent! exec 'sunmap '.a:rhs
    :silent! exec 'xunmap '.a:rhs
    :silent! exec 'ounmap '.a:rhs
    :silent! exec 'iunmap '.a:rhs
    :silent! exec 'lunmap '.a:rhs
    :silent! exec 'cunmap '.a:rhs
    " Make r<rhs> do the right thing
    :silent! exec 'unmap r'.a:rhs
    :silent! exec 'unmap f'.a:rhs
endfu
command! -nargs=* CMDUNMAP call FUNC_Unmap(<f-args>)


func! FUNC_Swap(lhs, rhs)
    :call FUNC_Remap(a:lhs, a:rhs)
    :call FUNC_Remap(a:rhs, a:lhs)
endfu
command! -nargs=* CMDSWAP call FUNC_Swap(<f-args>)


func! FUNC_Unswap(lhs, rhs)
    :call FUNC_Remap(a:lhs, a:lhs)
    :call FUNC_Remap(a:rhs, a:rhs)
endfu
command! -nargs=* CMDUNSWAP call FUNC_Unswap(<f-args>)


func! FUNC_Remap2(lhs, rhs)
    " Function which remaps keys in interactive modes
    ":exec 'noremap '.a:lhs.' '.a:rhs
    :exec 'inoremap '.a:lhs.' '.a:rhs
    ":exec 'vnoremap '.a:lhs.' '.a:rhs
    ":exec 'vnoremap '.a:rhs.' '.a:lhs
    ":exec 'onoremap '.a:lhs.' '.a:rhs
    ":exec 'onoremap '.a:rhs.' '.a:lhs
endfu
command! -nargs=* CMDREMAP2 call FUNC_Remap2(<f-args>)

func! FUNC_Swap2(lhs, rhs)
    :call FUNC_Remap2(a:lhs, a:rhs)
    :call FUNC_Remap2(a:rhs, a:lhs)
endfu
command! -nargs=* CMDSWAP2 call FUNC_Swap2(<f-args>)


func! FUNC_Unswap2(lhs, rhs)
    :call FUNC_Remap2(a:lhs, a:lhs)
    :call FUNC_Remap2(a:rhs, a:rhs)
endfu
command! -nargs=* CMDUNSWAP2 call FUNC_Unswap2(<f-args>)


func! NumberLineInvert()
    "map each number to its shift-key character
    ":CMDSWAP2 : ;
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
    ":CMDUNSWAP2 : ;
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
