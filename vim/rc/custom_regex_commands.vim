" ATOMS
"

" VAR
\(\<[A-Za-z_][0-9A-Za-z_]*\>\)


" DELIM
\([,() ]\)

" ENTIRE_LINE
^\(.*\) *$


"func! ChangeWords(...)
func :%s/\<\(\)\>//gc

" Variable Name word on a line
s/\<\([A-Za-z_][A-Z0-9a-z_]*\)\>//gc


" Remove Blank Lines
s/^ *$\n//gc

" Fix Tabs
s/\t/    /gc

" APPEND (s)
regex=ENTIRE_LINE
regex=^\(.*\) *$
repl=\1, (
repl=\1,
s/regex/repl/gc
s/^\(.*\) *$/repl/gc
s/^\(.*\) *$/\1, (/gc
" APPEND COMMAS
s/^\(.*\) *$/\1,/gc


"'s/\(.*\) *$/\1'.repl.'/gc'
s/\(.*\) *$/\1,(/gc
s/\(.*\) *$/\1),/gc




" PREPEND
s/\(^ *\) */\1(/gc

" Stringify
regex = DELIM.VAR.DELIM
repl  = \1'\2'\3
s/regex/repl/gc
regex = \([,() ]\)\(\<[A-Za-z_][0-9A-Za-z_]*\>\)\([,() ]\)
repl  = \1'\2'\3


s/\([,() ]\)\(\<[A-Za-z_][0-9A-Za-z_]*\>\)\([,() ]\)/\1'\2'\3/gc


" APPEND COMMA
"
"
SPACES=  *
NOTSPACES=[^ ][^ ]*
SECOND_SPACES=\(SPACES.NOSPACES\)SPACES,
s/SECOND_SPACES/\1 /gc
" REMOVE SECOND SPACE
s/\(  *[^ ][^ ]*\)  */\1 /gc
" REMOVE THIRD SPACE
s/\(  *[^ ][^ ]*  *[^ ][^ ]*\)  */\1 /gc
" FIX PREWHITESPACE COMMAS
s/\(  *[^ ][^ ]*\)  *,/\1, /gc
" FIX PREWHITESPACE COMMAS (MAINTAIN ALIGN)
s/\(  *[^ ][^ ]*\)\(  *\),/\1,\2/gc



" Replace hs with ibs
s/\<hs\>/ibs/gc
s/\<qcxs\>/qrids/gc
s/\<qcx\>/qrid/gc
s/\<qcx_list\>/qrid_list/gc
s/\<cx_list\>/rid_list/gc
s/\<cx\>/rid/gc
s/\<cxs\>/rids/gc
s/\<res\>/qres/gc
s/\<qcx2_res\>/qrid2_qres/gc
s/\<res2_/qres2_/gc
s/_cxs\>/_rids/gc
s/_cx\>/_rid/gc
s/\<cx2_/rid2_/gc


" TABLES = tables.XXX
" INDEX  = \[\([^\]]*\)\]
"
s/tables.cx2_nx\[\([^\]]*\)\]/get_roi_nids(\1)/gc
s/tables.cx2_cid\[\([^\]]*\)\]/get_roi_nids(\1)/gc

s/cx2_desc\[\([^\]]*\)\]/ibs.get_roi_desc(\1)/gc


" CLASS TO DICT
"
classname = allorg

classname.varSPACES=SPACESVAR

s/
\<allorg\>\.\(\<[A-Za-z_][0-9A-Za-z_]*\>\)\(  *\)=\( *\<[A-Za-z_][0-9A-Za-z_]*\>\)
/
'\1'\2:\3,
/gc

%s/\<allorg\>\.\(\<[A-Za-z_][0-9A-Za-z_]*\>\)\(  *\)=\( *\<[A-Za-z_][0-9A-Za-z_]*\>\)/'\1'\2:\3,/gc
