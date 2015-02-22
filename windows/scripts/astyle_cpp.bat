    "
    --pad-oper, -p
          Insert  space  padding  around  operators.  Any end of line comments will remain in the
          original column, if possible. Note that there is no option to unpad. Once padded,  they
          stay padded.
       --add-brackets, -j
              Add brackets  to  unbracketed  one  line  conditional  statements  (e.g.  "if",  "for",
              "while"...).  The  statement  must  be  on  a  single line.  The brackets will be added
              according to the currently requested predefined style or bracket type. If no  style  or
              bracket  type is requested the brackets will be attached. If --add-one-line-brackets is
              also used the result will be one line brackets.
         
       --convert-tabs, -c
              Convert tabs to spaces in the non-indentation part of the line. The  number  of  spaces
              inserted  will  maintain the spacing of the tab. The current setting for spaces per tab
              is used. It may not produce the expected results if --convert-tabs is used when  chang‐
              ing spaces per tab. Tabs are not replaced in quotes.
              
       --max-code-length=#, -xC#
       --break-after-logical, -xL
              The  option  --max\[u2011]code\[u2011]length  will  break  a line if the code exceeds #
              characters. The valid values are 50 thru 200. Lines without logical  conditionals  will
              break on a logical conditional (||, &&, ...), comma, paren, semicolon, or space.
       --delete-empty-lines, -xe
              Delete  empty  lines  within  a function or method. Empty lines outside of functions or
              methods are NOT deleted. If used with  --break-blocks  or  --break-blocks=all  it  will
              delete all lines except the lines added by the --break-blocks options.
    "
    
    export ASTYLE_OPTIONS "--style=ansi --indent=spaces --attach-inlines --attach-extern-c --indent-classes  --indent-switches --indent-preproc-cond --indent-col1-comments --pad-oper --unpad-paren --delete-empty-lines --add-brackets"
    "
    {
    "--style=ansi": "-A1",
    "--indent=spaces": "-s"
    "--attach-inlines": "-x1"
    "--attach-extern-c": "-xk",
    "--indent-classes": "-C",
    "--indent-modifiers": "-xG",
    "--indent-switches": "-S",
    "--indent-preproc-cond ": "-xw",
    "--indent-col1-comments": "-Y",
    "--pad-oper": "-p", 
    "--unpad-paren": "-U",
    "-delete-empty-lines": "-xe",
    "--add-brackets": "-j",