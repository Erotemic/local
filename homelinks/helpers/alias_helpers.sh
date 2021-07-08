# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

# Unix aliases
#source $HOME/local/init/utils.sh

alias pytree='tree -P "*.py" --dirsfirst'
#alias ls='ls --color --human-readable --group-directories-first --hide="*.pyc" --hide="*.pyo"'
alias ls='ls --color --human-readable --group-directories-first'
#--hide="*.pyc" --hide="*.pyo"'
alias pygrep='grep -r --include "*.py"'
alias clean_python='find . -regex ".*\(__pycache__\|\.py[co]\)" -delete || find . -iname *.pyc -delete || find . -iname *.pyo -delete'

# watch with a higher frequency
alias watch='watch -n .5'

# Ignore snaps and tmpfs when running df
alias df='df -x"squashfs" -x"tmpfs"'

#alias cgrep='grep -I --exclude-dir "*build*" --exclude-dir .git -ER'
alias cgrep='grep -I -ER \
    --exclude-dir "build" \
    --exclude-dir "cmake-build" \
    --exclude-dir "build-*" \
    --exclude-dir "build_*" \
    --exclude-dir "node_modules" \
    --exclude-dir "static" \
    --exclude-dir .git \
    --exclude-dir .pytest_cache \
    --exclude-dir htmlcov \
    --exclude-dir "volumes" \
    --exclude-dir "*.egg-info" \
    --exclude "searchindex.js" \
    --exclude "*.dot*" \
    --exclude "*.rst*" \
    --exclude "profile_output.*" \
    --exclude "*.pipe*" \
    --exclude "*.zip*" \
    --exclude "*.pkl*" \
    --exclude "*.pyc*" \
    --exclude "*.so*" \
    --exclude "*.o*" \
    --exclude "*.coverage*" \
    --exclude "tags"'

    #--exclude "*.js" \
    #--exclude "*.html*" \
    #--exclude "*.css*" \


alias ipy='ipython'

# General navigation
alias home='cd ~'
alias data='cd ~/data'
alias loc='cd ~/local'
alias lc='cd ~/local'
alias mi='cd ~/misc'

#alias vf='cd ~/local/vim/vimfiles'
#alias vfb='cd ~/local/vim/vimfiles/bundle'
#alias lb='cd ~/latex/crall-lab-notebook/'

alias lt='cd ~/latex/'

#alias ca='cd ~/latex/crall-thesis-2017/'
#alias ic='cd ~/latex/crall-iccvw-2017/'

alias scr='cd ~/scripts'
# Special navigation
alias code='cd $CODE_DIR'
alias co='cd $CODE_DIR'

alias remote='cd ~/remote'

alias nh='cd $CODE_DIR/netharn'
alias nd='cd $HOME/code/ndsampler'
alias kwc='cd $HOME/code/kwcoco'
alias sc='cd $HOME/code/scriptconfig'
alias kwa='cd $HOME/code/kwarray'
alias kwn='cd $HOME/code/kwannot'
alias kwi='cd $HOME/code/kwimage'
alias kwp='cd $HOME/code/kwplot'

alias cv='cd $CODE_DIR/opencv'
#alias fl='cd $CODE_DIR/fletch/'
alias kw='cd $CODE_DIR/kwiver/'
alias vi='cd $CODE_DIR/VIAME/'
alias nx='cd $CODE_DIR/networkx'
alias gr='cd $CODE_DIR/graphid'
#alias hs='cd $CODE_DIR/ibeis/ibeis/algo/hots'
#alias smk='cd $CODE_DIR/ibeis/ibeis/algo/smk'
alias ib='cd $CODE_DIR/ibeis/'
#alias sk='cd $CODE_DIR/scikit-learn/'
alias db='cd ~/Dropbox/'
alias desk='cd ~/Desktop/'
alias dl='cd ~/Downloads/'
#alias rf='cd $CODE_DIR/pyrf/'
#alias mtg='cd $CODE_DIR/mtgmonte/'

alias pysite='cd $(python -c "import distutils.sysconfig; print(distutils.sysconfig.get_python_lib())")'

alias ub='cd $CODE_DIR/ubelt'
alias xo='cd $CODE_DIR/xdoctest'
alias ut='cd $CODE_DIR/utool'
alias fl='cd $CODE_DIR/flann/'
alias li='cd $CODE_DIR/line_profiler'
alias vt='cd $CODE_DIR/vtool_ibeis'
alias dt='cd $CODE_DIR/dtool_ibeis'
alias gt='cd $CODE_DIR/guitool_ibeis'
alias pt='cd $CODE_DIR/plottool_ibeis'
alias uu='cd $CODE_DIR/supersetup'
#alias fk='cd $CODE_DIR/ibeis-flukematch-module/'
alias mk='cd $CODE_DIR/mkinit'
alias hes='cd $CODE_DIR/hesaff'
alias work='cd ~/work'

alias vid='cd ~/data/dvc-repos/viame_dvc'


alias vdd='vd ~/work'
alias ebrc='gvim ~/.bashrc'
alias ea='gvim ~/local/homelinks/helpers/alias_helpers.sh'

alias drl='docker run -it $(docker image ls -a --format={{.ID}} | head -1) bash'

alias dmsg=dmesg


clean_latex()
{
    rm *.aux
    rm *.bbl
    rm *.brf 
    rm *.log 
    rm *.bak 
    rm *.blg 
    rm *.tips 
    rm *.synctex
    rm main.pdf
    rm main.dvi

    rm *.fdb_latexmk
    rm *.fls
    rm *.lof
    rm *.toc

    latexmk -c
}

clean_emptydirs()
{
    # https://unix.stackexchange.com/questions/46322/how-can-i-recursively-delete-empty-directories-in-my-home-directory
    find . -type d -empty -print
    find . -type d -empty -delete
}


# Edit Project
ep()
{
    #gvim
    wmctrl -a GVIM
    wmctrl -r GVIM -b "remove,maximized_vert,maximized_horz,fullscreen"
    wmctrl -r GVIM -e 0,1921,1,1220,1920
    wmctrl -r GVIM -b "add,maximized_vert,maximized_horz"
    #wmctrl -r ":ACTIVE:" -e 0,1920,0,100,100
    #wmctrl -r ":ACTIVE:" -b "remove,maximized_vert"
    #wmctrl -r ":ACTIVE:" -t 1  # move to desktop 1
}

# Reload profile
# FIXME if I work on a mac
#alias rrr='source ~/.profile'
alias rrr='source ~/.bashrc'


cls()
{
    __heredoc__="""
    Clears the terminal screen

    References:
        https://askubuntu.com/questions/25077/how-to-really-clear-the-terminal
    """
    tput reset
}


read_clip()
{
    xsel --clipboard < ~/clipboard.txt
}

astyle_cpp()
{

    #'
    #--pad-oper, -p
    #      Insert  space  padding  around  operators.  Any end of line comments will remain in the
    #      original column, if possible. Note that there is no option to unpad. Once padded,  they
    #      stay padded.


    #   --add-brackets, -j
    #          Add brackets  to  unbracketed  one  line  conditional  statements  (e.g.  'if',  'for',
    #          'while'...).  The  statement  must  be  on  a  single line.  The brackets will be added
    #          according to the currently requested predefined style or bracket type. If no  style  or
    #          bracket  type is requested the brackets will be attached. If --add-one-line-brackets is
    #          also used the result will be one line brackets.
         
    #   --convert-tabs, -c
    #          Convert tabs to spaces in the non-indentation part of the line. The  number  of  spaces
    #          inserted  will  maintain the spacing of the tab. The current setting for spaces per tab
    #          is used. It may not produce the expected results if --convert-tabs is used when  chang‐
    #          ing spaces per tab. Tabs are not replaced in quotes.
              
    #   --max-code-length=#, -xC#
    #   --break-after-logical, -xL
    #          The  option  --max\[u2011]code\[u2011]length  will  break  a line if the code exceeds #
    #          characters. The valid values are 50 thru 200. Lines without logical  conditionals  will
    #          break on a logical conditional (||, &&, ...), comma, paren, semicolon, or space.

    #   --delete-empty-lines, -xe
    #          Delete  empty  lines  within  a function or method. Empty lines outside of functions or
    #          methods are NOT deleted. If used with  --break-blocks  or  --break-blocks=all  it  will
    #          delete all lines except the lines added by the --break-blocks options.

    #'
    #export ASTYLE_OPTIONS="--style=allman --indent=spaces --indent-preproc-cond --convert-tabs --indent-namespaces --indent-labels --indent-col1-comments --pad-oper --pad-header --unpad-paren --delete-empty-lines --add-brackets "
    
    #--attach-inlines 
    #--attach-extern-c
    #--indent-preproc-cond
    export ASTYLE_OPTIONS="--style=ansi --indent=spaces  --indent-classes  --indent-switches  --indent-col1-comments --pad-oper --unpad-paren --delete-empty-lines --add-brackets"
    astyle $ASTYLE_OPTIONS $@


    #"
    #{
    #'--style=ansi': '-A1',
    #'--indent=spaces': '-s'
    #'--attach-inlines': '-x1'
    #'--attach-extern-c': '-xk',
    #'--indent-classes': '-C',
    #'--indent-modifiers': '-xG',
    #'--indent-switches': '-S',
    #'--indent-preproc-cond ': '-xw',
    #'--indent-col1-comments': '-Y',
    #'--pad-oper': '-p', 
    #'--unpad-paren': '-U',
    #'-delete-empty-lines': '-xe',
    #'--add-brackets': '-j',
    #}
    #"
    ##-A1 -s -x1 -xw -xk -c -N -L -Y
    #--indent-cases

}


# Start TMUX session
# References: 
#     http://lukaszwrobel.pl/blog/tmux-tutorial-split-terminal-windows-easily
#     https://gist.github.com/MohamedAlaa/2961058
#change_terminal_title()
#    {
#    echo -en "\033]0;$@\a"
#    }

#tmuxnew(){
#    change_terminal_title "TMUX $HOSTNAME NEW"
#    tmux new -s default_session
#}
#tmuxattach(){
#    change_terminal_title "TMUX $HOSTNAME ATTACHED"
#    tmux attach -t default_session
#}


print_all_pathvars()
{
    _PYEXE=$(system_python)
    $_PYEXE -c "$(codeblock "
    import os
    vars = ['PATH', 'LD_LIBRARY_PATH', 'CPATH', 'CMAKE_PREFIX_PATH']
    for v in vars:
        print('------')
        print(v)
        # FIXME: dont use environ
        value = os.environ.get(v, '')
        plist = [p for p in value.split(os.pathsep) if p]
        print('    ' + (os.linesep + '    ').join(plist))
        print('------')
    ")"
}

pathvar_print(){
# pathvar_print LD_LIBRARY_PATH
# pathvar_print PATH
_VAR=$1
_PYEXE=$(system_python)
$_PYEXE -c "
if __name__ == '__main__':
    import os
    oldval = '${!_VAR}'
    pathvar = [p for p in oldval.split(os.pathsep) if p]
    print('\n'.join(pathvar))
"
}
complete -W "PATH LD_LIBRARY_PATH CPATH CMAKE_PREFIX_PATH" "pathvar_print"


pathvar_clean()
{
# pathvar_clean LD_LIBRARY_PATH
# pathvar_clean PATH
_VAR=$1
_PYEXE=$(system_python)
$_PYEXE -c "
if __name__ == '__main__':
    import os
    # Note: dont use environ because it is modified when python is called
    oldval = '${!_VAR}'
    parts = oldval.split(os.pathsep)
    seen = set([])
    fixed = []
    for p in parts:
        if p and p not in seen:
            p = p.replace('//', '/')
            seen.add(p)
            fixed.append(p)
    print(os.pathsep.join(fixed))
"
}
complete -W "PATH LD_LIBRARY_PATH CPATH CMAKE_PREFIX_PATH" "pathvar_clean"

pathvar_remove()
{
# pathvar_clean LD_LIBRARY_PATH
# pathvar_clean PATH
_VAR=$1
_VAL=$2
_PYEXE=$(system_python)
$_PYEXE -c "
if __name__ == '__main__':
    import os
    from os.path import expanduser, abspath
    val = abspath(expanduser('$_VAL'))
    oldpathvar = '${!_VAR}'.split(os.pathsep)
    newpathvar = [p for p in oldpathvar if p and abspath(p) != val]
    print(os.pathsep.join(newpathvar))
"
}
complete -W "PATH LD_LIBRARY_PATH CPATH CMAKE_PREFIX_PATH" "pathvar_remove"




#remove_ld_library_path_entry()
#{
## http://stackoverflow.com/questions/370047/what-is-the-most-elegant-way-to-remove-a-path-from-the-path-variable-in-bash
#export LD_LIBRARY_PATH=$(pathvar_remove LD_LIBRARY_PATH $1)
#}

#remove_path_entry()
#{
## http://stackoverflow.com/questions/370047/what-is-the-most-elegant-way-to-remove-a-path-from-the-path-variable-in-bash
#export PATH=$(pathvar_remove PATH $1)
#}

#remove_cpath_entry()
#{
#export CPATH=$(pathvar_remove CPATH $1)
#}


#debug_paths(){
#    _PYEXE=$(system_python)
#    $_PYEXE -c "import os; path = os.environ['LD_LIBRARY_PATH'].split(os.pathsep); print('\n'.join(path))"
#    $_PYEXE -c "import os; path = os.environ['PATH'].split(os.pathsep); print('\n'.join(path))"

#    $_PYEXE -c "import os; path = os.environ['LD_LIBRARY_PATH'].split(os.pathsep); print(os.pathsep.join(path))"
#}


#deactivate_venv()
#{

#    # https://stackoverflow.com/questions/85880/determine-if-a-function-exists-in-bash
#    if [ -n "$(type -t conda)" ] && [ "$(type -t conda)" = function ]; then
#        conda deactivate
#    fi

#    OLD_VENV=$VIRTUAL_ENV
#    # echo "deactivate_venv OLD_VENV=$OLD_VENV"
#    if [ "$OLD_VENV" != "" ]; then
#        #if [ -n "$(type -t rvm)" ] && [ "$(type -t rvm)" = function ]; then
#        #    echo rvm is a function; 
#        #else
#        #    echo rvm is NOT a function;
#        #fi
#        if [ -n "$(type -t deactivate)" ] && [ "$(type -t deactivate)" = function ]; then
#            # deactivate bash function exists
#            deactivate
#            # reset LD_LIBRARY_PATH 
#            remove_ld_library_path_entry $OLD_VENV/local/lib
#            remove_ld_library_path_entry $OLD_VENV/lib
#            remove_path_entry $OLD_VENV/bin
#            remove_cpath_entry $OLD_VENV/include
#        fi
#    fi
#    # Hack for personal symlinks.  I'm not sure why these are populated
#    remove_ld_library_path_entry ~/venv3/local/lib
#    remove_ld_library_path_entry ~/venv3/lib
#    remove_path_entry ~/venv3/bin
#    remove_cpath_entry ~/venv3/include
#}

#workon_py()
#{
#    NEW_VENV=$1
#    #echo "WEVN1: NEW_VENV = $NEW_VENV"

#    if [ ! -f $NEW_VENV/bin/activate ]; then
#        # Check if it is the name of a conda or virtual env
#        # First try conda, then virtualenv
#        TEMP_PATH=$_CONDA_ROOT/envs/$NEW_VENV
#        #echo "TEMP_PATH = $TEMP_PATH"
#        if [ -d $TEMP_PATH ]; then
#            NEW_VENV=$TEMP_PATH
#        else
#            TEMP_PATH=$HOME/$NEW_VENV
#            if [ -d $TEMP_PATH ]; then
#                NEW_VENV=$TEMP_PATH
#            fi
#        fi
#    fi
#    #echo "WEVN2: NEW_VENV = $NEW_VENV"
#    #echo "TRY NEW VENV"

#    if [ -d $NEW_VENV/conda-meta ]; then
#        #echo "NEW CONDA VENV"
#        deactivate_venv
#        # Use a conda environment
#        conda activate $NEW_VENV
#        export LD_LIBRARY_PATH=$NEW_VENV/lib:$LD_LIBRARY_PATH
#        export CPATH=$NEW_VENV/include:$CPATH
#        #echo "CPATH = $CPATH"
#        #echo "LD_LIBRARY_PATH = $LD_LIBRARY_PATH"
#        #echo "activated conda NEW_VENV=$NEW_VENV"
#    elif [ -d $NEW_VENV ]; then
#        #echo "NEW VENV"
#        # Ensure the old env is deactivated
#        deactivate_venv
#        # Use a virtualenv environment
#        # Activate the new venv
#        export LD_LIBRARY_PATH=$NEW_VENV/local/lib:$LD_LIBRARY_PATH
#        export LD_LIBRARY_PATH=$NEW_VENV/lib:$LD_LIBRARY_PATH
#        source $NEW_VENV/bin/activate
#        #echo "activated virtualenv NEW_VENV=$NEW_VENV"
#        # echo "activated NEW_VENV=$NEW_VENV"
#    fi
#    # echo "new venv doesn't exist"
#}


source $HOME/local/tools/pyenv_ext/pyenv_ext_commands.sh


workon_pysys()
{
    deactivate_venv
}


we-py2()
{
    we "$HOME/venv2"
}
#alias we-py2=workon_py2

#we-py2debug()
#{
#    we "$HOME/code/cpython-27/venvs/venv2-debug"
#}


we-py3()
{
    we "$HOME/venv3"
}
#alias we-py3=workon_py3


#workon_conda()
#{
#    # OLD: DEPRICATE

#    # Wrapper around conda activate that handles deactivating any existing
#    # python virtualenvs
#    NEW_VENV=$1
#    if [ -d $_CONDA_ROOT/envs/$NEW_VENV ]; then
#        # Ensure the old env is deactivated
#        deactivate_venv
#        # Activate the new venv
#        conda activate $NEW_VENV
#    fi
#}
#workon_conda3()
#{
#    __heredoc__ "
#    deactivate_venv
#    conda create -y -n cenv3 python=3
#    we-conda3
#    "
#    workon_conda cenv3
#}
#alias we-conda3=workon_conda3


we-py37()
{
    we py37
}

we-py36()
{
    we py36
}

we-pypy()
{
    we "$HOME/venvpypy"
}




pyedit()
{
    __heredoc__="""
    Open a python module's source code in your favorite editor.

    Args:
        modname (str): module name

    Example:
        source ~/local/homelinks/helpers/alias_helpers.sh
        modname=typing
        pyedit typing
    """
    modname=$1
    cmd="python -c \"import ${modname}, xdev; xdev.editfile(${modname}.__file__)\""
    echo "$cmd"
    bash -c "${cmd}"
}


untilfail()
{
    while $@; do :; done
}

 
permit_erotemic_gitrepo()
{ 
    __heredoc__="""
    change git config from https to ssh
    """
    #permit_gitrepo -i
    sed -E -i 's/https?:\/\/github.com\/Erotemic/git@github.com:Erotemic/' .git/config
    sed -E -i 's/https?:\/\/github.com\/WildbookOrg/git@github.com:WildbookOrg/' .git/config
    sed -E -i 's/https?:\/\/gitlab.com\/Erotemic/git@gitlab.com:Erotemic/' .git/config
    sed -E -i 's/https?:\/\/gitlab.kitware.com\/computer-vision/git@gitlab.kitware.com:computer-vision/' .git/config
    #sed -i 's/https:\/\/github.com\/bluemellophone/git@github.com:bluemellophone/' .git/config
    #sed -i 's/https:\/\/github.com\/zmjjmz/git@github.com:zmjjmz/' .git/config
    #sed -i 's/https:\/\/github.com\//git@github.com:' .git/config
}

normalize_line_endings(){
    __heredoc__ '''
    find . -not -type d -exec file "{}" ";" | grep CRLF
    sudo apt install dos2unix
    '''
    
    for fpath in "$@"
    do
    #echo "fpath = $fpath"
    tr -d '\r' < $fpath > _tempfile.out && mv _tempfile.out $fpath
    done
}

normalize_newline_eof()
{
    for fpath in "$@"
    do
        if [ -z "$(tail -c 1 "$fpath")" ]
        then
            NOOP=
        else
            echo "No newline at end of fpath = $fpath"
            echo "Fixing"
            echo "" >> $fpath
        fi
    done
}

pyversion(){
    __heredoc__="
    Display the version of a Python module
    "
    python -c "import $1; print('$1.__version__ = ' + str($1.__version__))"
}

pywhich(){
    __heredoc__="
    Display the location of a Python module
    "
    python -c "import $1; print('$1.__file__ = ' + str($1.__file__))"
}

pyfile()
{
    echo "python -c \"import $1; print($1.__file__)\""
    python -c "import $1; print($1.__file__.replace(\".pyc\", \".py\"))"
}



gitk(){
    # always spawn gitk in the background 
    GITK_EXE="$(which gitk)"
    $GITK_EXE $@&
}

randpw(){ 
    __heredoc__="""
    Generate a random password

    https://www.howtogeek.com/howto/30184/10-ways-to-generate-a-random-password-from-the-command-line/
    """
    #< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c${1:-16};echo;
    #head -c${1:-2048} /dev/urandom | sha512sum
    #head -c${1:-2048} /dev/urandom | sha512sum
    #head -c${1:-512} /dev/random | sha512sum
    #head -c${1:-128} /dev/random | sha512sum

    #head -c${1:-128} /dev/random | python -c "import ubelt, sys; print(ubelt.hash_data(sys.stdin.read(), base='abc'))"
    #head -c16777216 /dev/random | sha512sum | python -c "import string, ubelt, sys; print(ubelt.hash_data(sys.stdin.read(), base=list(string.ascii_letters + string.digits + '_')))"
    head -c16777216 /dev/urandom | sha512sum | python -c "import string, ubelt, sys; print(ubelt.hash_data(sys.stdin.read(), base='hex')[0:32])"
    #head -c16777216 /dev/urandom | sha512sum | python -c "import string, ubelt, sys; print(ubelt.hash_data(sys.stdin.read(), base='alphanum')[0:64])"
}

randpw_words(){
    # pip install english-words (25487) words
    # pip install diceware
    diceware -n 8
    #pyblock "
    #if 0:
    #    # Word security level 
    #    import math
    #    vocab_size = 25487
    #    vocab_size = 7776
    #    security_levels = {}
    #    security_levels['words-4'] = vocab_size ** 4
    #    security_levels['words-5'] = vocab_size ** 5
    #    security_levels['words-6'] = vocab_size ** 6
    #    security_levels['words-7'] = vocab_size ** 7
    #    security_levels['words-8'] = vocab_size ** 8
    #    security_levels['words-12'] = vocab_size ** 12
    #    security_levels['words-35'] = vocab_size ** 35
    #    security_levels['sha1']   = 16 ** 40
    #    security_levels['sha256'] = 16 ** 64
    #    security_levels['sha512'] = 16 ** 128
    #    security_levels['abc-20'] = 26 ** 20
    #    security_levels['hex-12'] = 16 ** 12
    #    security_levels['hex-20'] = 16 ** 20
    #    security_levels['hex-32'] = 16 ** 32
    #    security_levels['hex-16'] = 16 ** 16


    #    # Type 1 Civ Adversarial Actor
    #    # population = 7.674e9
    #    # num_devices = population * 10

    #    # Type 0 Civ Adversarial Actor
    #    population = 3e8
    #    num_devices = population * 1

    #    # Large Adversarial Actor
    #    num_devices = 1e6

    #    # https://gist.github.com/Chick3nman/e4fcee00cb6d82874dace72106d73fef
    #    device_attempts_per_second = 3934 * 1000  # Based on rtx3090 attacking eth wallet

    #    attempts_per_second = device_attempts_per_second * num_devices
    #    def years_to_crack(x):
    #        return (x / attempts_per_second) / 60 / 60 / 24 / 365
    #    security_bits = ub.map_vals(lambda x: math.log(x) / math.log(2), security_levels)
    #    security_years = ub.map_vals(years_to_crack, security_levels)

    #    print(ub.repr2(ub.sorted_vals(security_bits), align=':', precision=2))
    #    print(ub.repr2(ub.sorted_vals(security_years), align=':', precision=2))

    #    bits_to_years = {
    #        b: years_to_crack((2 ** b)) for b in range(40, 160, 5)
    #    }
    #    print(ub.repr2(ub.sorted_vals(bits_to_years), align=':', precision=6))
    #    # number of words to hit 80 bits of entropy with diceware
    #    vocab_size = 7776
    #    vocab_size ** X == 2 ** 80
    #    math.log(vocab_size ** 8) / math.log(2)
    #    math.log(2 ** 80) / math.log(vocab_size)
    #import english_words
    #import random
    #pool = list(english_words.english_words_set)
    #rng = random.SystemRandom()
    #chosen = rng.choices(pool, k=8)
    #print('_'.join(chosen))
    #"
}


randint(){ 
    head -c128 /dev/random | sha512sum | python -c "import string, ubelt, sys; print(ubelt.hash_data(sys.stdin.read(), base=list(string.digits))[0:32])"
}


git-tarball-hash()
{
    __heredoc__='''
    https://gist.github.com/simonw/a44af92b4b255981161eacc304417368

    '''
    CURRENT_COMMIT=$(git rev-parse HEAD)
    #CURRENT_COMMIT=$(git log -n 1 | head -n 1 | sed -e 's/^commit //')
    CURRENT_COMMIT=0418a4cf84b83a22a4d2aca704543f93677260d6
    echo "CURRENT_COMMIT = $CURRENT_COMMIT"
    git archive --format=tar.gz -o /tmp/temp-repo.tar.gz $(git rev-parse HEAD)
    sha256sum /tmp/temp-repo.tar.gz 

    md5sum /tmp/temp-repo.tar.gz 
    sha1sum /tmp/temp-repo.tar.gz 
    sha512sum /tmp/temp-repo.tar.gz 
}


sedr(){
    __heredoc__="""
    Recursive sed

    Args:
        search 
        replace
        pattern (defaults to *.py)

    Example:
        source ~/local/homelinks/helpers/alias_helpers.sh
        sedr foo bar
    """
    SEARCH=$1
    REPLACE=$2
    PATTERN=$3
    LIVE_RUN=$4

    PATTERN=${PATTERN:="*.py"}

    echo "
    === sedr ===
    argv[1] = SEARCH = '$SEARCH' - text to search
    argv[2] = REPLACE = '$REPLACE' - text to replace
    argv[3] = PATTERN = '$PATTERN' - filename patterns to match
    argv[4] = LIVE_RUN = '$LIVE_RUN' - set to 'True' to do the run for real
    "

    find . -type f -iname "${PATTERN}" 

    if [[ "$LIVE_RUN" == "True" ]]; then
        find . -type f -iname "${PATTERN}" -exec sed -i "s|${SEARCH}|${REPLACE}|g" {} + 
    else
        # https://unix.stackexchange.com/questions/97297/how-to-report-sed-in-place-changes
        #find . -type f -iname "${PATTERN}" -exec sed "s|${SEARCH}|${REPLACE}|g" {} + | grep "${REPLACE}"
        find . -type f -iname "${PATTERN}" -exec sed --quiet "s|${SEARCH}|${REPLACE}|gp" {} + | grep "${REPLACE}" -C 100
    fi
}


search_remotes(){
    __heredoc__="""
    Attempt to massage a path native to a remote to a local path that works
    with the 'Erotemic mounted remote scheme': i.e. where you sshfs mount your
    remote machines onto ~/remote

    Args:
        target_dpath : path to a directory thats on a remote

    Ignore:
        target_dpath = '/home/joncrall/work/sealions'  
    """
    target_dpath=$1

    pyblock """
    import ubelt as ub
    import glob
    from os.path import join

    target_dpath = '$target_dpath'
    remote_dpath = ub.expandpath('~/remote')

    remote_cands = glob.glob(join(remote_dpath, '*'))

    # Need to populate with what my user directory might be called
    # Is there any way to auto-determine this?
    valid_userdirs = [
        '/home/joncrall/',
        '/home/local/KHQ/jon.crall/'
    ]
    valid_suffixes = []
    for cand in valid_userdirs:
        if target_dpath.startswith(cand):
            suffix = target_dpath.replace(cand, '', 1)
            valid_suffixes.append(suffix)

    assert valid_suffixes

    local_candidates = []
    for suffix in valid_suffixes:
        found = ub.find_path(suffix, path=remote_cands)
        local_candidates.extend(list(found))

    if len(local_candidates) == 0:
        print('NOT FOUND')
    if len(local_candidates) == 1:
        print(local_candidates[0])
    else:
        print(local_candidates)
    """
}


clean_empty_dirs(){
    __heredoc__="
    References:
        https://unix.stackexchange.com/questions/24134/remove-empty-directory-trees-removing-as-many-directories-as-possible-but-no-fi
    "
    find . -type d -empty -delete
}


all_dir_sizes(){
    __heredoc__="

    sudo du -sh * | sort -h

    sudo find . -maxdepth 1 -iregex '.*/..*' -exec du -sh {} \; 
    sudo find . -maxdepth 1 -iregex '.*/..*' -exec echo {} \; | sort -h
    sudo find . -maxdepth 1 -iregex '.*/..*' -exec echo {} \; | sort -h

    find . -maxdepth 1 -exec du -sh {} + 
    | sort -h

    "
    find . -maxdepth 1 -type d -iregex ".*/..*" -exec du -sh {} + | sort -h
    sudo find . -maxdepth 1 -iregex ".*/..*" -exec du -sh {} + | sort -h

    du -sh * | sort -h
}


clean_python2(){

    find . -regex ".*\(__pycache__\|\.py[co]\)" -delete || find . -iname *.pyc -delete || find . -iname *.pyo -delete
    find . -type d -empty -delete

    pyblock " 

    import os
    dpath = '.'
    for r, ds, fs in os.walk(dpath):
        if r.endswith('__pycache__'):
            break
        pass

    "

    
}


json_pp2(){
    __doc__="
    Use ubelt to pretty-print a json string
    "
    NL="-1"

    POSITIONAL=()
    while [[ $# -gt 0 ]]
    do
    key="$1"
    case $key in
        -n|--nl|--newlines)
        shift # past argument
        NL="$1"
        shift # past argument
        ;;
        *)    # unknown option
        POSITIONAL+=("$1") # save it in an array for later
        shift # past argument
        ;;
    esac
    done
    echo "NL = $NL"
    python -c "import ubelt, sys, json; print(ubelt.highlight_code(ubelt.repr2(json.loads(sys.stdin.read()), nl=$NL, sort=False)))" $POSITIONAL
}
