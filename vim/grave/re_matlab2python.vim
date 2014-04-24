"matlab to python function

func! Matlab2Python() 
    %s/%/#/g
    %s/n2s/str/g
    %s/&&/and/g
    %s/&/and/g
    %s/||/or/g
    %s/|/or/g
    %s/classdef/class/g
    %s/^\( *\)function\(.*\) =/\1#return \2\r\1def /g
    %s/^\( *\)function /\1#return None\r\1def /g
    %s/^\(.*\<def\>.*)\)/\1:/g
    %s/^\(.*\<class\>.*)\)/\1:/g
    %s/^\(.*\<if\>.*)\)/\1:/g
    %s/^\(.*\<while\>.*)\)/\1:/g
    %s/^\( *\<for\>.*)\)/\1:/g
    %s/true/True/g
    %s/false/False/g
    %s/'/"/g
    %s/\<end\>//g
    %s/;\( *#\)/\1/g
    %s/; *$//g
    %s/if  *\~/if not /g
    %s/else:*/else:/g
    %s/\(logmsg.*\)])/\1)/g
    %s/\(logwarn.*\)])/\1)/g
    %s/cols/len/g
    %s/iid/cid/g
    %s/IID/CID/g
    %s/instance/chip/g
    %s/Instance/Chip/g
    %s/inst/chip/g
    %s/\<ix/cx/g
    %s/ix\>/cx/g
    %s/\<im\>/cm/g
    %s/setdiff/listDiff/g
    %s/\([ncigra]id2_[ncigra]x\)(\([^(,)]*\))/\1[\2]/g
    %s/\([ncigra]x2_[ncigra]id\)(\([^(,)]*\))/\1[\2]/g
    %s/\([ncigra]x2_[ncigra]name\)(\([^(,)]*\))/\1[\2]/g
    %s/\(cx2_[ncigra]name\)(\([^(,)]*\))/\1[\2]/g
    %s/uint32(\[\])/np.array([], dtype=np.uint32)/g
    %s/num2str/str/g
    %s/\.\.\./\\/g
    %s/ *< *handle *$/:/g
    %s/^\( *\)properties.*/\1def __init__(SELFOBJ):/
    %s/^\( *\)if\([^:]*\)$/\1if\2:/
    %s/"/'/g
    %s/cmg/img/g
    %s/\<num_i\>/num_c/g
    %s/numel/len/g
    %s/NEWLINE()/'\\n'/g
    %s/@(\([^)]*\))/lambda \1:/g
    %s/^\( *\)methods.*//
    %s/{\(.\{-,}\)}/[\1]/gc
endfu 
         " %s/\[\(.*\) \(.*\]\)/[\1+\2/gc
         "%s/\[\("[^"]\{-1,}"\)  *\(.\{-1,}]\)/\1+\2/gc
         "%s/len(\([gin]id.[gin]x2_[gin]id\))/\1.size/gc
         "%s/len(\([gin]id.[gin]x2_[gin]id\))/\1.size/gc
         "%s/\[\("[^"]\{-1,}"\)  *\(.\{-1,}]\)/\1+\2/gc
         "REGEX to replace () with []
         " %s/(\(.\{-,}\))/[\1]/gc
         " %s/1:\(.*\>\)/range(0,\1)/gc
command! M2P :call Matlab2Python()
