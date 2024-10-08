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
" https://stackoverflow.com/questions/72273877/what-does-python-virtual-env-activate-this-py-actually-do
" Function to activate a virtualenv in the embedded interpreter for
" omnicomplete and other things like that.
let activate_this = a:path . '/bin/activate'
if getftype(a:path) == "dir" && filereadable(activate_this)
Python2or3 << EOF
import vim

# THIS DOESNT WORK WITH VENV IT SEEMS

import os
import sys
import site
import pathlib

if 0:
    prev_length = len(sys.path)
    activate_this = pathlib.Path(vim.eval('l:activate_this'))
    bin_dir = activate_this.parent
    path = list((bin_dir / '../lib/').glob('python*/site-packages'))[0].absolute()
    path = os.path.normpath(path)
    path = os.path.realpath(path)
    site.addsitedir(os.fspath(path))
    sys.path[:] = sys.path[prev_length:] + sys.path[0:prev_length]

#activate_this = vim.eval('l:activate_this')
#print('LOAD VIRTUAL ENV = %r' % (activate_this,))
#activate_codeblock = open(activate_this).read()
#temp_locals = dict(__file__=activate_this)

#exec(activate_codeblock, temp_locals)

#import sys
#import utool as ut
#print('sys.path = %s' % (ut.repr4(sys.path),))
# http://stackoverflow.com/questions/42649515/virtualenv-on-ubuntu-symlink-local-lib-lib
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
