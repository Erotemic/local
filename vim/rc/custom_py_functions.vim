

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
