if has('python')
    command! -nargs=1 Python2or3 python <args>
elseif has('python3')
    command! -nargs=1 Python2or3 python3 <args>
else
    echo "Error: Requires Vim compiled with +python or +python3"
    finish
endif

function! LoadVirtualEnv(path)
" References: 
" http://stackoverflow.com/questions/3881534/set-python-virtualenv-in-vim
" Function to activate a virtualenv in the embedded interpreter for
" omnicomplete and other things like that.
let activate_this = a:path . '/bin/activate_this.py'
if getftype(a:path) == "dir" && filereadable(activate_this)
Python2or3 << EOF
import vim
activate_this = vim.eval('l:activate_this')
exec(open(activate_this).read(), dict(__file__=activate_this))
#execfile(activate_this, dict(__file__=activate_this))
EOF
    endif
endfunction

" Load up personal virtual env
"let defaultvirtualenv = $HOME . "/venv3"
let defaultvirtualenv = $VIRTUAL_ENV

" Only attempt to load this virtualenv if the defaultvirtualenv
" actually exists, and we aren't running with a virtualenv active.
if has("python") || has('python3')
    "if empty($VIRTUAL_ENV) && getftype(defaultvirtualenv) == "dir"
    if getftype(defaultvirtualenv) == "dir"
        call LoadVirtualEnv(defaultvirtualenv)
    endif
endif

