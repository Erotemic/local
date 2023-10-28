#!/bin/bash
__doc__="
This script is meant to help with the installation, creation, and management of
pyenv virtual enviornments.

Main user-facing functions:

    install_pyenv -
        Helps install pyenv itself

    pyenv_create_virtualenv -
        Creates a new python environment for a new python version


Currently depends on other scripts inside the github.com/Erotemic/local repo,
namely

    ~/local/init/utils.sh

SeeAlso:
    ~/local/homelinks/helpers/alias_helpers.sh


Example Usage:
    # Assuming the local repo is installed, source required files
    source ~/local/tools/utils.sh
    source ~/local/tools/pyenv_ext/pyenv_ext_commands.sh

    # Install or upgrade pyenv
    UPGRADE=1 install_pyenv

    # Use pyenv to list all available versions that could be installed
    pyenv install --list

    # Install a python version and make a default virtual enviornment for it
    # Setting the second argument to 'full' ensures all compile-time
    # optimizations are enabled. Different versions will have different
    # compile-time requirements, but the script handles these for modern
    # versions of CPython
    source ~/local/tools/pyenv_ext/pyenv_ext_commands.sh

    #pyenv_create_virtualenv 3.8.13 full
    pyenv_create_virtualenv 3.11.2 most
    #pyenv_create_virtualenv pypy3.7-7.3.9 most
    #
    pyenv_create_virtualenv 3.12.0 full

    source ~/local/tools/pyenv_ext/pyenv_ext_commands.sh
    build_vim_for_pyenv
"

install_pyenv(){
    # shellcheck disable=SC2016
    __doc__='
    Perform installation of the pyenv library

    Args:
        UPGRADE (str): if truthy update to the latest

    Example:
        source ~/local/tools/utils.sh
        source ~/local/tools/pyenv_ext/pyenv_ext_commands.sh
        UPGRADE=1 install_pyenv

    Ignore:
        export PATH="$PYENV_ROOT/bin:$PATH"
        eval "$($PYENV_ROOT/bin/pyenv init -)"
        eval "$($PYENV_ROOT/bin/pyenv init -)"

    TODO:
        # https://github.com/pyenv/pyenv-installer
        # no compile?
        # new installer:
        curl https://pyenv.run | bash
        export PYENV_ROOT="$HOME/.pyenv"
        if [ -d "$PYENV_ROOT" ]; then
            export PATH="$PYENV_ROOT/bin:$PATH"
            eval "$("$PYENV_ROOT"/bin/pyenv init -)"
            eval "$("$PYENV_ROOT"/bin/pyenv init --path)"
            source "$PYENV_ROOT/completions/pyenv.bash"
        fi
        pyenv install mambaforge-22.9.0-3
        pyenv global mambaforge-22.9.0-3
    '
    _handle_help "$@" || return 0

    # Install requirements for building Python
    #sudo apt-get install -y \
    apt_ensure \
        make build-essential libssl-dev zlib1g-dev \
        libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm libncurses5-dev \
        libncursesw5-dev xz-utils tk-dev libffi-dev liblzma-dev libgdbm-dev libc6-dev

    #apt_ensure python-openssl python3-openssl  # Is this needed?

    # Download pyenv
    export PYENV_ROOT="$HOME/.pyenv"
    if [[ ! -d "$PYENV_ROOT" ]]; then
        git clone https://github.com/pyenv/pyenv.git "$PYENV_ROOT"
        (cd "$PYENV_ROOT" && src/configure && make -C src)
    fi
    if [[ "$UPGRADE" == "1" ]]; then
        (cd "$PYENV_ROOT" && git pull && src/configure && make -C src)
    fi
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
        # See Available versions
        pyenv install --list | grep 3.9
        pyenv install --list

        source ~/local/tools/pyenv_ext/pyenv_ext_commands.sh
        pyenv_create_virtualenv 3.9.9 full

        PYTHON_VERSION=3.8.5
        CHOSEN_PYTHON_VERSION=3.8.5

        PYTHON_VERSION=3.9.9
        CHOSEN_PYTHON_VERSION=3.9.9

        source ~/local/tools/pyenv_ext/pyenv_ext_commands.sh
        pyenv_create_virtualenv 3.8.5 full

        source ~/local/tools/pyenv_ext/pyenv_ext_commands.sh
        pyenv_create_virtualenv 3.8.6 most

        source ~/local/tools/pyenv_ext/pyenv_ext_commands.sh
        pyenv_create_virtualenv 3.7.10 off

        source ~/local/tools/pyenv_ext/pyenv_ext_commands.sh
        pyenv_create_virtualenv 2.7.18

        source ~/local/tools/pyenv_ext/pyenv_ext_commands.sh
        pyenv_create_virtualenv 2.7.17 off

        source ~/local/tools/pyenv_ext/pyenv_ext_commands.sh
        PYTHON_VERSION=3.4.10
        pyenv_create_virtualenv 3.4.10 off

        source ~/local/tools/pyenv_ext/pyenv_ext_commands.sh
        pyenv_create_virtualenv 3.5.10 off

        source ~/local/tools/pyenv_ext/pyenv_ext_commands.sh
        pyenv_create_virtualenv 3.6.15 off

        source ~/local/tools/pyenv_ext/pyenv_ext_commands.sh
        pyenv_create_virtualenv 3.9.9 full

        source ~/local/tools/pyenv_ext/pyenv_ext_commands.sh
        pyenv_create_virtualenv 3.10.0 full

        source ~/local/tools/pyenv_ext/pyenv_ext_commands.sh
        pyenv_create_virtualenv 3.10.10 full

        source ~/local/tools/pyenv_ext/pyenv_ext_commands.sh
        pyenv_create_virtualenv 3.10.5 full

        source ~/local/tools/pyenv_ext/pyenv_ext_commands.sh
        pyenv_create_virtualenv 3.11.0rc2 none
    "
    _handle_help "$@" || return 0

    local PYTHON_VERSION=$1
    local OPTIMIZE_PRESET=${2:-"most"}

    local CHOSEN_PYTHON_VERSION=$PYTHON_VERSION
    # shellcheck disable=SC2155
    local BEST_MATCH=$(_pyenv_best_version_match "$PYTHON_VERSION")
    echo "BEST_MATCH = $BEST_MATCH"
    if [[ $BEST_MATCH == "None" ]]; then
        echo "failed to find match"
        return 1
    fi
    CHOSEN_PYTHON_VERSION=$BEST_MATCH

    #if [[ "$PYTHON_VERSION" =~ ^3.4..* ]]; then
    #    # https://github.com/pyenv/pyenv/issues/945
    #    # Need to ensure libssl1.0

    #    # Doesnt work
    #    #mkdir -p $HOME/tmp/sslhack/libssl1.0-dev
    #    #cd $HOME/tmp/sslhack/libssl1.0-dev
    #    #wget https://debian.sipwise.com/debian-security/pool/main/o/openssl1.0/libssl1.0-dev_1.0.2l-2+deb9u3_amd64.deb
    #    ##apt-get download libssl1.0-dev
    #    #ar x libssl1.0-dev_1.0.2l-2+deb9u3_amd64.deb data.tar.xz
    #    #tar -xf data.tar.xz --strip-components=2
    #    #rm data.tar.xz

    #    #HACK_INCLUDE1=$HOME/tmp/sslhack/libssl1.0-dev/include
    #    #HACK_INCLUDE2=$HOME/tmp/sslhack/libssl1.0-dev/include/x86_64-linux-gnu
    #    #HACK_LIB1=$HOME/tmp/sslhack/libssl1.0-dev/lib/x86_64-linux-gnu
    #    #echo "HACK_INCLUDE1 = $HACK_INCLUDE1"
    #    #echo "HACK_INCLUDE2 = $HACK_INCLUDE2"

    #    #ln -s /usr/lib/x86_64-linux-gnu/libcrypto.so.1.0.2 $HOME/tmp/sslhack/libssl1.0-dev/lib/x86_64-linux-gnu
    #    #ln -s /usr/lib/x86_64-linux-gnu/libssl.so.1.0.2 $HOME/tmp/sslhack/libssl1.0-dev/lib/x86_64-linux-gnu
    #    #CFLAGS="-I${HACK_INCLUDE1} -I${HACK_INCLUDE2}" LDFLAGS="-L${HACK_LIB1}" pyenv install 3.4.10

    #fi

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

    # List all presets
    # python3 -m test.regrtest --pgo
    if [[ "$OPTIMIZE_PRESET" == "full" ]] || [[ "$OPTIMIZE_PRESET" == "all" ]]; then
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

        if lscpu | grep Intel ; then
            PYTHON_CFLAGS="-march=native -mtune=intel -O3 -pipe"
        else
            PYTHON_CFLAGS="-march=native -O3 -pipe"
        fi
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
        if lscpu | grep Intel ; then
            PYTHON_CFLAGS="-march=native -mtune=intel -O3 -pipe"
        else
            PYTHON_CFLAGS="-march=native -O3 -pipe"
        fi
        MAKE_OPTS=""
    elif [[ "$OPTIMIZE_PRESET" == "off" || "$OPTIMIZE_PRESET" == "none" ]] ; then
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
        pyenv install "$CHOSEN_PYTHON_VERSION" --verbose

    #pyenv shell $CHOSEN_PYTHON_VERSION
    #pyenv global $CHOSEN_PYTHON_VERSION

    VERSION_PREFIX=$(pyenv prefix "$CHOSEN_PYTHON_VERSION")
    CHOSEN_PYEXE=$VERSION_PREFIX/bin/python

    $CHOSEN_PYEXE --version

    VENV_NAME=pyenv$CHOSEN_PYTHON_VERSION
    VENV_PATH=$VERSION_PREFIX/envs/$VENV_NAME

    if [[ $CHOSEN_PYTHON_VERSION == 2.7.* ]]; then
        echo "2.7"
        $CHOSEN_PYEXE -m pip install virtualenv
        $CHOSEN_PYEXE -m virtualenv "$VENV_PATH"
    else
        echo "3.x"
        # Create the virtual environment
        $CHOSEN_PYEXE -m venv "$VENV_PATH"
    fi
}


new_venv(){
    __doc__="
    Create a new venv with the current version of Python and the chosen name.
    "
    VENV_NAME=$1
    CHOSEN_PYTHON_VERSION=$(python -c "import sys; print('.'.join(map(str, sys.version_info[0:3])))")
    VERSION_PREFIX=$(pyenv prefix "$CHOSEN_PYTHON_VERSION")
    VENV_PATH=$VERSION_PREFIX/envs/$VENV_NAME
    CHOSEN_PYEXE=$VERSION_PREFIX/bin/python
    $CHOSEN_PYEXE -m venv "$VENV_PATH"
}

pathvar_remove()
{
    __doc__="
    Removes a variable from a path-style variable
    TODO: could be moved to general utils
    "
    local _VAR=$1
    local _VAL=$2
    # shellcheck disable=SC2155
    local _PYEXE=$(system_python)
    $_PYEXE -c "if 1:
        if __name__ == '__main__':
            import os
            from os.path import expanduser, abspath
            val = abspath(expanduser('$_VAL'))
            oldpathvar = '${!_VAR}'.split(os.pathsep)
            newpathvar = [p for p in oldpathvar if p and abspath(p) != val]
            print(os.pathsep.join(newpathvar))
    "
}



remove_ld_library_path_entry()
{
    # http://stackoverflow.com/questions/370047/what-is-the-most-elegant-way-to-remove-a-path-from-the-path-variable-in-bash
    # shellcheck disable=SC2155
    export LD_LIBRARY_PATH=$(pathvar_remove LD_LIBRARY_PATH "$1")
}


remove_ld_library_path_entry()
{
    # http://stackoverflow.com/questions/370047/what-is-the-most-elegant-way-to-remove-a-path-from-the-path-variable-in-bash
    # shellcheck disable=SC2155
    export LD_LIBRARY_PATH=$(pathvar_remove LD_LIBRARY_PATH "$1")
}

remove_path_entry()
{
    # http://stackoverflow.com/questions/370047/what-is-the-most-elegant-way-to-remove-a-path-from-the-path-variable-in-bash
    # shellcheck disable=SC2155
    export PATH=$(pathvar_remove PATH "$1")
}

remove_cpath_entry()
{
    # shellcheck disable=SC2155
    export CPATH=$(pathvar_remove CPATH "$1")
}


debug_paths(){
    # Print contents of path variables for debugging
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
            remove_ld_library_path_entry "$OLD_VENV/local/lib"
            remove_ld_library_path_entry "$OLD_VENV/lib"
            remove_path_entry "$OLD_VENV/bin"
            remove_cpath_entry "$OLD_VENV/include"
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

    if [ ! -f "$NEW_VENV/bin/activate" ]; then
        # Check if it is the name of a conda or virtual env
        # First try conda, then virtualenv
        local TEMP_PATH=$_CONDA_ROOT/envs/$NEW_VENV
        #echo "TEMP_PATH = $TEMP_PATH"
        if [ -d "$TEMP_PATH" ]; then
            NEW_VENV=$TEMP_PATH
        else
            local TEMP_PATH=$HOME/$NEW_VENV
            if [ -d "$TEMP_PATH" ]; then
                local NEW_VENV=$TEMP_PATH
            fi
        fi
    fi
    #echo "WEVN2: NEW_VENV = $NEW_VENV"
    #echo "TRY NEW VENV"

    # Try to find the environment the user requested
    #VENV_NAME_CAND1=pyenv$NEW_VENV
    #PYENV_ACTIVATE_CAND1=$(pyenv root)/versions/$NEW_VENV/envs/$VENV_NAME_CAND1/bin/activate
    PYENV_ACTIVATE_CAND1=$(echo "$(pyenv root)"/versions/*/envs/"$NEW_VENV"/bin/activate)

    if [ -f "$PYENV_ACTIVATE_CAND1" ]; then
        deactivate_venv
        # shellcheck disable=SC1090
        source "$PYENV_ACTIVATE_CAND1"
    elif [ -d "$NEW_VENV/conda-meta" ]; then
        #echo "NEW CONDA VENV"
        deactivate_venv
        # Use a conda environment
        conda activate "$NEW_VENV"
        export LD_LIBRARY_PATH=$NEW_VENV/lib:$LD_LIBRARY_PATH
        export CPATH=$NEW_VENV/include:$CPATH
    elif [ -d "$NEW_VENV" ]; then
        #echo "NEW VENV"
        # Ensure the old env is deactivated
        deactivate_venv
        # Use a virtualenv environment
        # Activate the new venv
        export LD_LIBRARY_PATH=$NEW_VENV/local/lib:$LD_LIBRARY_PATH
        export LD_LIBRARY_PATH=$NEW_VENV/lib:$LD_LIBRARY_PATH
        # shellcheck disable=SC1091
        source "$NEW_VENV/bin/activate"
    fi
    # echo "new venv doesn't exist"
}

we(){
    # Alias for workon_py
    workon_py "$@"
}


refresh_workon_autocomplete(){
    local KNOWN_CONDA_ENVS
    local KNOWN_VIRTUAL_ENVS
    local KNOWN_PYENV_ENVS
    local KNOWN_ENVS
    if [ -d "$_CONDA_ROOT" ]; then
        KNOWN_CONDA_ENVS="$(/bin/ls -1 "$_CONDA_ROOT/envs" | sort)"
    else
        KNOWN_CONDA_ENVS=""
    fi
    # shellcheck disable=SC2155
    KNOWN_VIRTUAL_ENVS="$(/bin/ls -1 "$HOME" | grep venv | sort)"

    if [[ "$(which pyenv)" ]]; then
        KNOWN_PYENV_ENVS=$(find "$(pyenv root)"/versions/*/envs/* -maxdepth 0 -type d -printf "%f\n")
    fi
    # Remove newlines
    KNOWN_ENVS=$(echo "$KNOWN_CONDA_ENVS $KNOWN_VIRTUAL_ENVS $KNOWN_PYENV_ENVS" | tr '\n' ' ')
    complete -W "$KNOWN_ENVS" "workon_py"
    complete -W "$KNOWN_ENVS" "we"
}

execute_pyenv_ext_complete_script(){
    complete -W "PATH LD_LIBRARY_PATH CPATH CMAKE_PREFIX_PATH" "pathvar_remove"
    refresh_workon_autocomplete
}

rebuild_python(){
    __doc__='
    Rebuild python with with the same config (useful if ubuntu breaks your libs on you)
    '
    #python3 -m sysconfig
    #python3 -m sysconfig  | grep -i '\-j'
    CONFIG_ARGS=$(python -c "import sysconfig; print(sysconfig.get_config_var('CONFIG_ARGS'))")
    PYTHON_CFLAGS=$(python -c "import sysconfig; print(sysconfig.get_config_var('CONFIGURE_CFLAGS'))")
    PROFILE_TASK=$(python -c "import sysconfig; print(sysconfig.get_config_var('PROFILE_TASK'))")
    echo "PROFILE_TASK = $PROFILE_TASK"
    echo "PYTHON_CFLAGS = $PYTHON_CFLAGS"
    echo "CONFIG_ARGS = $CONFIG_ARGS"

    # Fix me for non-cpython
    CHOSEN_PYTHON_VERSION=$(python -c "import sys; print('.'.join(list(map(str, sys.version_info[0:3]))))")
    echo "CHOSEN_PYTHON_VERSION = $CHOSEN_PYTHON_VERSION"

    MAKE_OPTS="$MAKE_OPTS" \
    PROFILE_TASK="$PROFILE_TASK" \
    PYTHON_CFLAGS="$PYTHON_CFLAGS" \
    PYTHON_CONFIGURE_OPTS="$PYTHON_CONFIGURE_OPTS" \
        pyenv install "$CHOSEN_PYTHON_VERSION" --verbose


}


new_pyenv_venv(){
    # shellcheck disable=SC2016
    __doc__='
    Create a new pyenv virtual environment

    # Uninstall everything
    pip uninstall $(echo $(pip freeze | sed -e '"'s/==.*//'"')) -y

    source ~/local/tools/pyenv_ext/pyenv_ext_commands.sh
    new_pyenv_venv new_env$(date --iso-8601=m)
    VENV_NAME=temp_env
    '
    _handle_help "$@" || return 0
    VENV_NAME=$1

    VERSION_PREFIX=$(pyenv prefix "$CHOSEN_PYTHON_VERSION")
    CHOSEN_PYEXE=$VERSION_PREFIX/bin/python

    VENV_PATH=$VERSION_PREFIX/envs/$VENV_NAME
    $CHOSEN_PYEXE -m venv "$VENV_PATH"

    workon_py "$VENV_NAME"
}

update_pyenv(){
    # shellcheck disable=SC2016
    __doc__='
    export PATH="$PYENV_ROOT/bin:$PATH"
    eval "$($PYENV_ROOT/bin/pyenv init -)"
    eval "$($PYENV_ROOT/bin/pyenv init -)"
    '
    # Download pyenv
    export PYENV_ROOT="$HOME/.pyenv"
    (cd "$PYENV_ROOT" && git pull && src/configure && make -C src)
}


_strip_double_whitespace(){
    echo "$@" | sed -zE 's/[ \n]+/ /g'
}


build_vim_for_pyenv(){
    __doc__="
    Helper to install vim/gvim compiled against a specific python virtual environment

    source ~/local/tools/pyenv_ext/pyenv_ext_commands.sh
    build_vim_for_pyenv
    "

    if [[ ! -d "$HOME/code/vim" ]]; then
        git clone https://github.com/vim/vim.git ~/code/vim
    else
        (cd "$HOME/code/vim" && git fetch)
    fi

    # shellcheck disable=SC1091
    source "$HOME/local/init/utils.sh"
    apt_ensure build-essential libtinfo-dev libncurses-dev gnome-devel libgtk-3-dev libxt-dev

    #./configure --help
    #./configure --help | grep python
    # shellcheck disable=SC2164
    cd "$HOME/code/vim"

    # https://github.com/vim/vim/issues/6457
    #git checkout v8.1.2424
    #git checkout v8.2.4030
    git checkout v9.0.0824

    # Build for the global pyenv python outside of venv
    CHOSEN_PYTHON_VERSION=$(python -V | cut -d' ' -f2)
    echo "CHOSEN_PYTHON_VERSION = $CHOSEN_PYTHON_VERSION"
    pyenv shell "$CHOSEN_PYTHON_VERSION"
    pyenv global "$CHOSEN_PYTHON_VERSION"

    # Build in virtualenv?
    # deactivate
    deactivate_venv

    BUILD_IN_VIRTUALENV=0
    if [[ "$BUILD_IN_VIRTUALENV" == "1" ]]; then
        #PREFIX=$VIRTUAL_ENV
        # I Think the config has to point to the actual python install and not
        # the virtualenv
        PREFIX=$(pyenv prefix)
        EXEC_PREFIX=$VIRTUAL_ENV
        CONFIG_DIR=$("$(pyenv prefix)"/bin/python-config --configdir)
        #CONFIG_DIR=$($VIRTUAL_ENV/bin/python-config --configdir)
        PYTHON_CMD=$(which python)
    else
        # Seems like this doesnt always work
        PREFIX=$(pyenv prefix)
        EXEC_PREFIX="$PREFIX"
        CONFIG_DIR=$("$(pyenv prefix)"/bin/python-config --configdir)
        PYTHON_CMD=$(pyenv which python)
    fi

    #PREFIX=${VIRTUAL_ENV:=$HOME/.local}
    #CONFIG_DIR=$(python-config --configdir)

    #https://github.com/ycm-core/YouCompleteMe/issues/3760
    #PREFIX=$(pyenv prefix)
    #CONFIG_DIR=$($(pyenv prefix)/bin/python-config --configdir)
    echo "
        PREFIX='$PREFIX'
        EXEC_PREFIX='$EXEC_PREFIX'
        CONFIG_DIR='$CONFIG_DIR'
    "

    # THIS WORKS!
    export LDFLAGS="-rdynamic"
    make distclean
    ./configure \
        "--prefix=$PREFIX" \
        "--exec-prefix=$EXEC_PREFIX" \
        --enable-pythoninterp=no \
        --enable-python3interp=yes \
        "--with-python3-command=$PYTHON_CMD" \
        "--with-python3-config-dir=$CONFIG_DIR" \
        --enable-gui=gtk3
    cat src/auto/config.mk

    # Ensure the version of python matches (there are cases due to system
    # configs where it might not)
    # shellcheck disable=SC2002
    cat src/auto/config.mk | grep 'PYTHON3\|prefix'

    make -j"$(nproc)"
    #./src/vim -u NONE --cmd "source test.vim"
    make install

    # BROKEN
    pip install ubelt pyperclip shellcheck-py six xinspect psutil pyflakes packaging
    #if [[ -d "$HOME/code/vimtk" ]]; then
    #    unlink_or_backup "$HOME/.vim/bundle/vimtk"
    #    ln -s "$HOME/code/vimtk" "$HOME/.vim/bundle/vimtk"
    #    pip install -r "$HOME/.vim/bundle/vimtk/requirements/runtime.txt"
    #else
    #    pip install ubelt pyperclip shellcheck-py six xinspect psutil pyflakes
    #fi
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

install_conda(){
    __doc__="
    In some cases conda is a better choice than pyenv. While pyenv can install
    conda, if you need the conda manager, installing conda in a standalone way
    is a better idea.

    To update to a newer version see: [CondaHashes]_ and [CondaInstallers]_.

    References:
        .. [CondaHashes] https://docs.conda.io/en/latest/miniconda_hashes.html
        .. [CondaInstallers] https://docs.conda.io/en/latest/miniconda.html#linux-installers
    "
    mkdir -p ~/tmp/setup-conda
    cd ~/tmp/setup-conda
    #https://repo.anaconda.com/miniconda/Miniconda3-py311_23.5.2-0-Windows-x86_64.exe
    #https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh

    #CONDA_VERSION=4.10.3
    #CONDA_PY_VERSION=py38
    CONDA_VERSION=23.5.2-0
    CONDA_PY_VERSION=py311
    #ARCH="$(dpkg --print-architecture)"  # different convention
    ARCH="$(arch)"
    OS=Linux
    CONDA_KEY="Miniconda3-${CONDA_PY_VERSION}_${CONDA_VERSION}-${OS}-${ARCH}"
    echo "CONDA_KEY = $CONDA_KEY"
    CONDA_INSTALL_SCRIPT_FNAME="${CONDA_KEY}.sh"
    CONDA_URL="https://repo.anaconda.com/miniconda/${CONDA_INSTALL_SCRIPT_FNAME}"

    declare -A CONDA_KNOWN_SHA256=(
        ["Miniconda3-py311_23.5.2-0-Linux-x86_64"]="634d76df5e489c44ade4085552b97bebc786d49245ed1a830022b0b406de5817"
        ["Miniconda3-py38_4.10.3-Linux-x86_64"]="935d72deb16e42739d69644977290395561b7a6db059b316958d97939e9bdf3d"
        ["Miniconda3-py38_4.10.3-Linux-aarch64"]="19584b4fb5c0656e0cf9de72aaa0b0a7991fbd6f1254d12e2119048c9a47e5cc"
        ["Miniconda3-py38_4.10.3-Linux-aarch64"]="19584b4fb5c0656e0cf9de72aaa0b0a7991fbd6f1254d12e2119048c9a47e5cc"
    )
    CONDA_EXPECTED_SHA256="${CONDA_KNOWN_SHA256[${CONDA_KEY}]}"
    echo "CONDA_EXPECTED_SHA256 = $CONDA_EXPECTED_SHA256"

    curl "$CONDA_URL" -O "$CONDA_INSTALL_SCRIPT_FNAME"

    # For security, it is important to verify the hash
    if ! echo "${CONDA_EXPECTED_SHA256}  ${CONDA_INSTALL_SCRIPT_FNAME}" | sha256sum --status -c; then
        GOT_HASH=$(sha256sum "$CONDA_INSTALL_SCRIPT_FNAME")
        echo "GOT_HASH      = $GOT_HASH"
        echo "EXPECTED_HASH = $CONDA_EXPECTED_SHA256"
        echo "Downloaded file does not match hash! DO NOT CONTINUE!"
    else
        echo "Hash verified, continue with install"
        echo "CONDA_INSTALL_SCRIPT_FNAME = $CONDA_INSTALL_SCRIPT_FNAME"
        chmod +x "$CONDA_INSTALL_SCRIPT_FNAME"
        # Install miniconda to user local directory
        _CONDA_ROOT=$HOME/.local/conda

        # Update if the root already exist, otherwise fresh install
        if [ -d "$_CONDA_ROOT" ]; then
            sh "$CONDA_INSTALL_SCRIPT_FNAME" -b -p "$_CONDA_ROOT" -u
        else
            sh "$CONDA_INSTALL_SCRIPT_FNAME" -b -p "$_CONDA_ROOT"
        fi

        # Activate the basic conda environment
        _CONDA_ROOT=$HOME/.local/conda
        source "$_CONDA_ROOT/etc/profile.d/conda.sh"
    fi
}
