__doc__="
SeeAlso:
    ~/local/homelinks/helpers/alias_helpers.sh
"
pathvar_remove()
{
local _VAR=$1
local _VAL=$2
local _PYEXE=$(system_python)
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



remove_ld_library_path_entry()
{
# http://stackoverflow.com/questions/370047/what-is-the-most-elegant-way-to-remove-a-path-from-the-path-variable-in-bash
export LD_LIBRARY_PATH=$(pathvar_remove LD_LIBRARY_PATH $1)
}


remove_ld_library_path_entry()
{
# http://stackoverflow.com/questions/370047/what-is-the-most-elegant-way-to-remove-a-path-from-the-path-variable-in-bash
export LD_LIBRARY_PATH=$(pathvar_remove LD_LIBRARY_PATH $1)
}

remove_path_entry()
{
# http://stackoverflow.com/questions/370047/what-is-the-most-elegant-way-to-remove-a-path-from-the-path-variable-in-bash
export PATH=$(pathvar_remove PATH $1)
}

remove_cpath_entry()
{
export CPATH=$(pathvar_remove CPATH $1)
}


debug_paths(){
    _PYEXE=$(system_python)
    $_PYEXE -c "import os; path = os.environ['LD_LIBRARY_PATH'].split(os.pathsep); print('\n'.join(path))"
    $_PYEXE -c "import os; path = os.environ['PATH'].split(os.pathsep); print('\n'.join(path))"

    $_PYEXE -c "import os; path = os.environ['LD_LIBRARY_PATH'].split(os.pathsep); print(os.pathsep.join(path))"
}


deactivate_venv()
{

    # https://stackoverflow.com/questions/85880/determine-if-a-function-exists-in-bash
    if [ -n "$(type -t conda)" ] && [ "$(type -t conda)" = function ]; then
        conda deactivate
    fi

    OLD_VENV=$VIRTUAL_ENV
    echo "deactivate_venv OLD_VENV=$OLD_VENV"
    if [ "$OLD_VENV" != "" ]; then
        #if [ -n "$(type -t rvm)" ] && [ "$(type -t rvm)" = function ]; then
        #    echo rvm is a function; 
        #else
        #    echo rvm is NOT a function;
        #fi
        if [ -n "$(type -t deactivate)" ] && [ "$(type -t deactivate)" = function ]; then
            # deactivate bash function exists
            deactivate
            # reset LD_LIBRARY_PATH 
            remove_ld_library_path_entry $OLD_VENV/local/lib
            remove_ld_library_path_entry $OLD_VENV/lib
            remove_path_entry $OLD_VENV/bin
            remove_cpath_entry $OLD_VENV/include
        fi
    fi
    # Hack for personal symlinks.  I'm not sure why these are populated
    #remove_ld_library_path_entry ~/venv3/local/lib
    #remove_ld_library_path_entry ~/venv3/lib
    #remove_path_entry ~/venv3/bin
    #remove_cpath_entry ~/venv3/include
}

workon_py()
{
    __doc__="
    Switch virtual environments
    "
    local NEW_VENV=$1
    echo "workon_py: NEW_VENV = $NEW_VENV"

    if [ ! -f $NEW_VENV/bin/activate ]; then
        # Check if it is the name of a conda or virtual env
        # First try conda, then virtualenv
        local TEMP_PATH=$_CONDA_ROOT/envs/$NEW_VENV
        #echo "TEMP_PATH = $TEMP_PATH"
        if [ -d $TEMP_PATH ]; then
            NEW_VENV=$TEMP_PATH
        else
            local TEMP_PATH=$HOME/$NEW_VENV
            if [ -d $TEMP_PATH ]; then
                local NEW_VENV=$TEMP_PATH
            fi
        fi
    fi
    #echo "WEVN2: NEW_VENV = $NEW_VENV"
    #echo "TRY NEW VENV"

    # Try to find the environment the user requested
    #VENV_NAME_CAND1=pyenv$NEW_VENV
    #PYENV_ACTIVATE_CAND1=$(pyenv root)/versions/$NEW_VENV/envs/$VENV_NAME_CAND1/bin/activate
    PYENV_ACTIVATE_CAND1=$(echo $(pyenv root)/versions/*/envs/$NEW_VENV/bin/activate)

    if [ -f "$PYENV_ACTIVATE_CAND1" ]; then
        deactivate_venv
        source $PYENV_ACTIVATE_CAND1
    elif [ -d $NEW_VENV/conda-meta ]; then
        #echo "NEW CONDA VENV"
        deactivate_venv
        # Use a conda environment
        conda activate $NEW_VENV
        export LD_LIBRARY_PATH=$NEW_VENV/lib:$LD_LIBRARY_PATH
        export CPATH=$NEW_VENV/include:$CPATH
    elif [ -d $NEW_VENV ]; then
        #echo "NEW VENV"
        # Ensure the old env is deactivated
        deactivate_venv
        # Use a virtualenv environment
        # Activate the new venv
        export LD_LIBRARY_PATH=$NEW_VENV/local/lib:$LD_LIBRARY_PATH
        export LD_LIBRARY_PATH=$NEW_VENV/lib:$LD_LIBRARY_PATH
        source $NEW_VENV/bin/activate
    fi
    # echo "new venv doesn't exist"
}

we(){
    workon_py $@
}


refresh_workon_autocomplete(){
    if [ -d "$_CONDA_ROOT" ]; then
        local KNOWN_CONDA_ENVS="$(/bin/ls -1 $_CONDA_ROOT/envs | sort)"
    else
        local KNOWN_CONDA_ENVS=""
    fi 
    local KNOWN_VIRTUAL_ENVS="$(/bin/ls -1 $HOME | grep venv | sort)"
    
    if [[ "$(which pyenv)" ]]; then
        local KNOWN_PYENV_ENVS=$(find $(pyenv root)/versions/*/envs/* -maxdepth 0 -type d -printf "%f\n")
    fi
    #readarray -d '' KNOWN_PYENV_ENVS < <(find $(pyenv root)/versions/*/envs/* -maxdepth 0 -type d -printf "%f\n")

    #echo "KNOWN_VIRTUAL_ENVS = $KNOWN_VIRTUAL_ENVS"
    #echo "KNOWN_CONDA_ENVS = $KNOWN_CONDA_ENVS"
    #echo "KNOWN_PYENV_ENVS = $KNOWN_PYENV_ENVS"

    # Remove newlines
    local KNOWN_ENVS=$(echo "$KNOWN_CONDA_ENVS $KNOWN_VIRTUAL_ENVS $KNOWN_PYENV_ENVS" | tr '\n' ' ')
    complete -W "$KNOWN_ENVS" "workon_py"
    complete -W "$KNOWN_ENVS" "we"
}
refresh_workon_autocomplete


install_pyenv(){
    __doc__='
    export PATH="$PYENV_ROOT/bin:$PATH"
    eval "$($PYENV_ROOT/bin/pyenv init -)"
    eval "$($PYENV_ROOT/bin/pyenv init -)"
    '
    # Install requirements for building Python
    sudo apt-get install -y \
        make build-essential libssl-dev zlib1g-dev \
        libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm libncurses5-dev \
        libncursesw5-dev xz-utils tk-dev libffi-dev liblzma-dev python-openssl python3-openssl

    # Download pyenv
    export PYENV_ROOT="$HOME/.pyenv"
    if [[ ! -d "$PYENV_ROOT" ]]; then
        git clone https://github.com/pyenv/pyenv.git $PYENV_ROOT
        (cd $PYENV_ROOT && src/configure && make -C src)
    fi

}


_strip_double_whitespace(){
    echo "$@" | sed -zE 's/[ \n]+/ /g'
}



pyenv_create_virtualenv(){
    __doc__="
    The conda variant is: 
        conda create -y -n <venv-name> python=<target-pyversion>

    This command will seek to do something similar

    Args:
        PYTHON_VERSION (str) 
        OPTIMIZE_PRESET (str, default=most): can be off, most, or full

    Example:
        source ~/local/tools/pyenv_ext/pyenv_ext_commands.sh
        pyenv_create_virtualenv 3.6.13

        PYTHON_VERSION=3.8.5
        CHOSEN_PYTHON_VERSION=3.8.5

        PYTHON_VERSION=3.8.8
        CHOSEN_PYTHON_VERSION=3.8.8

        # See Available versions
        pyenv install --list

        source ~/local/tools/pyenv_ext/pyenv_ext_commands.sh
        pyenv_create_virtualenv 3.8.6 most

        source ~/local/tools/pyenv_ext/pyenv_ext_commands.sh
        pyenv_create_virtualenv 3.7.10 off

        source ~/local/tools/pyenv_ext/pyenv_ext_commands.sh
        pyenv_create_virtualenv 3.7.9 off
    "
    _handle_help $@ || return 0

    local PYTHON_VERSION=$1
    local OPTIMIZE_PRESET=${2:="most"}

    local CHOSEN_PYTHON_VERSION=$PYTHON_VERSION
    local BEST_MATCH=$(_pyenv_best_version_match $PYTHON_VERSION)
    echo "BEST_MATCH = $BEST_MATCH"
    if [[ $BEST_MATCH == "None" ]]; then
        echo "failed to find match"
        return 1
    fi
    CHOSEN_PYTHON_VERSION=$BEST_MATCH

    #PYTHON_CFLAGS="
    #    -march=x86-64
    #    -march=rocketlake
    #    -march=native
    #    -O2
    #    -O3
    #"

    # About Optimizations
    # https://github.com/docker-library/python/issues/160#issuecomment-509426916
    # https://gist.github.com/nszceta/ec6efc9b5e54df70deeec7bceead0a1d
    # https://clearlinux.org/news-blogs/boosting-python-profile-guided-platform-specific-optimizations
    if [[ "$OPTIMIZE_PRESET" == "full" ]]; then
        PROFILE_TASK=$(_strip_double_whitespace "-m test.regrtest --pgo
            test_array
            test_base64 
            test_binascii 
            test_binop 
            test_bisect 
            test_bytes 
            test_bz2 
            test_cmath 
            test_codecs 
            test_collections 
            test_complex 
            test_dataclasses 
            test_datetime 
            test_decimal 
            test_difflib 
            test_embed 
            test_float 
            test_fstring 
            test_functools 
            test_generators 
            test_hashlib 
            test_heapq 
            test_int 
            test_itertools 
            test_json 
            test_long 
            test_lzma 
            test_math 
            test_memoryview 
            test_operator 
            test_ordered_dict 
            test_pickle 
            test_pprint 
            test_re 
            test_set 
            test_sqlite 
            test_statistics 
            test_struct 
            test_tabnanny 
            test_time 
            test_unicode 
            test_xml_etree 
            test_xml_etree_c 
        ")

        PYTHON_CONFIGURE_OPTS=$(_strip_double_whitespace "
            --enable-shared 
            --enable-optimizations 
            --with-computed-gotos
            --with-lto")

        PYTHON_CFLAGS="-march=native -O2 -pipe" 
    elif [[ "$OPTIMIZE_PRESET" == "most" ]]; then
        # FIXME: most and full are the same, what is the real breakdown?
        PROFILE_TASK=$(_strip_double_whitespace "-m test.regrtest 
            --pgo test_array test_base64 test_binascii test_binhex test_binop
            test_c_locale_coercion test_csv test_json test_hashlib test_unicode
            test_codecs test_traceback test_decimal test_math test_compile
            test_threading test_time test_fstring test_re test_float test_class
            test_cmath test_complex test_iter test_struct test_slice test_set
            test_dict test_long test_bytes test_memoryview test_io test_pickle")

        PYTHON_CONFIGURE_OPTS=$(_strip_double_whitespace "
            --enable-shared 
            --enable-optimizations 
            --with-computed-gotos
            --with-lto")

        # -march option: https://gcc.gnu.org/onlinedocs/gcc/x86-Options.html
        # -pipe option: https://gcc.gnu.org/onlinedocs/gcc-4.1.2/gcc/Overall-Options.html
        # TODO: maybe use --mtune=intel?
        PYTHON_CFLAGS="-march=native -O2 -pipe" 
        MAKE_OPTS=""
    elif [[ "$OPTIMIZE_PRESET" == "off" ]]; then
        PROFILE_TASK=""
        PYTHON_CONFIGURE_OPTS="--enable-shared"
        PYTHON_CFLAGS="-march=native -O2 -pipe" 
    else
        echo "UNKNOWN OPT PRESET"
        return 1
    fi

    MAKE_OPTS=""
    MAKE_OPTS="-j$(nproc)"

    MAKE_OPTS="$MAKE_OPTS" \
    PROFILE_TASK="$PROFILE_TASK" \
    PYTHON_CFLAGS="$PYTHON_CFLAGS" \
    PYTHON_CONFIGURE_OPTS="$PYTHON_CONFIGURE_OPTS" \
        pyenv install $CHOSEN_PYTHON_VERSION --verbose

    #pyenv shell $CHOSEN_PYTHON_VERSION
    #pyenv global $CHOSEN_PYTHON_VERSION

    VERSION_PREFIX=$(pyenv prefix $CHOSEN_PYTHON_VERSION)
    CHOSEN_PYEXE=$VERSION_PREFIX/bin/python

    $CHOSEN_PYEXE --version

    VENV_NAME=pyenv$CHOSEN_PYTHON_VERSION
    VENV_PATH=$VERSION_PREFIX/envs/$VENV_NAME

    if [[ $CHOSEN_PYTHON_VERSION == 2.7.* ]]; then
        echo "2.7"
        $CHOSEN_PYEXE -m pip install virtualenv
        $CHOSEN_PYEXE -m virtualenv $VENV_PATH
    else
        echo "3.x"
        # Create the virtual environment
        $CHOSEN_PYEXE -m venv $VENV_PATH
    fi
}


_pyenv_best_version_match(){
    __doc__="
    Finds a valid pyenv version that matches a user request
    "
    PYTHON_VERSION=$1
    #VENV_NAME=$2

    AVAILALBE_VERSION=$(pyenv install --list)
    # vim hates this syntax highlight apparently
    readarray -t arr <<< "$AVAILALBE_VERSION"
    BEST_MATCH=None
    for arg in "${arr[@]}"; do 
        arg=$(echo "$arg" | xargs echo -n)
        if [[ $arg == $PYTHON_VERSION* ]]; then
            BEST_MATCH=$arg
        fi
    done
    echo "$BEST_MATCH"
}
