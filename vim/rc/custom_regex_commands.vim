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
