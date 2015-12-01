" References: http://superuser.com/questions/1003231/folding-specific-sections-of-code-in-vim/1006806#1006806
"

function! ExampleFolds(lnum)
  let s:thisline = getline(a:lnum)
  if match(s:thisline, '^\s*Example:$') >= 0
    return '>1'
  elseif match(s:thisline, '^\s*$') >= 0
    return '0'
  else
    return '='
endfunction

setlocal foldmethod=expr
setlocal foldexpr=ExampleFolds(v:lnum)
