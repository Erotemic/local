#!/usr/bin/env bash
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
    source ~/local/init/utils.sh
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

    #pyenv_create_virtualenv 3.8.13 most
    pyenv_create_virtualenv 3.11.2 most
    #pyenv_create_virtualenv pypy3.7-7.3.9 most
    #
    pyenv_create_virtualenv 3.11.9 off
    pyenv_create_virtualenv 3.12.3 off
    pyenv_create_virtualenv 3.6.15 off
    pyenv_create_virtualenv 3.7 off
    pyenv_create_virtualenv 3.8 off
    pyenv_create_virtualenv 3.10 off
    pyenv_create_virtualenv 3.10.4 off
    pyenv_create_virtualenv 3.12 full
    pyenv_create_virtualenv 3.13.2 full
    pyenv_create_virtualenv 3.14.0rc2 off

    pyenv_create_virtualenv 3.11.9 off
    pyenv_create_virtualenv 3.11 most neovim

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
        libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm  \
        xz-utils tk-dev libffi-dev liblzma-dev libgdbm-dev libc6-dev


    # TODO: conditional
    if lsb_release -a | grep "24.04" &> /dev/null; then
        # For 24.04
        apt_ensure libncurses-dev
    else
        # For 22.04
        apt_ensure libncurses5-dev libncursesw5-dev
    fi

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
    Create a virtual environment for a specific version of Python with specific
    optimizations enabled.

    If the specific version of Python is not available it will be compiled.

    Args:
        PYTHON_VERSION (str):
            The requested version of Python to install.
            Must match an entry in 'pyenv install --list'.

        OPTIMIZE_PRESET (str | None):
            controls the level of profile-guided optimization.
            defaults to 'most', can be off, most, or full

        VENV_NAME (str | None):
            Name of the new environment. In unspecified, it chooses a default.

    Notes:
        This command does something similar to the conda command

        conda create -y -n <venv-name> python=<target-pyversion>

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
        pyenv_create_virtualenv 3.11 full geowatch-3.11-bleeding
    "
    _handle_help "$@" || return 0

    local PYTHON_VERSION=$1
    local OPTIMIZE_PRESET=${2:-"most"}
    local VENV_NAME=${3:-"auto"}

    local CHOSEN_PYTHON_VERSION=$PYTHON_VERSION
    # shellcheck disable=SC2155
    local BEST_MATCH=$(_pyenv_best_version_match "$PYTHON_VERSION")
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
    # https://github.com/pyenv/pyenv/blob/1cabb6e02b14/plugins/python-build/README.md#building-for-maximum-performance

    # Fixme: for 3.13+ use:
    TEST_SQLITE_NAME="test_sqlite3"
    TEST_UNICODE_NAME="test_str"
    # Before use:
    #TEST_SQLITE_NAME="test_sqlite"
    #TEST_UNICODE_NAME="test_unicode"

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
            $TEST_SQLITE_NAME
            test_statistics
            test_struct
            test_tabnanny
            test_time
            $TEST_UNICODE_NAME
            test_xml_etree
            test_xml_etree_c
        ")

        PYTHON_CONFIGURE_OPTS=$(_strip_double_whitespace "
            --enable-shared
            --enable-optimizations
            --with-computed-gotos
            --with-lto")

        if lscpu | grep Intel &> /dev/null ; then
            PYTHON_CFLAGS="-march=native -mtune=intel -O3 -pipe"
        else
            PYTHON_CFLAGS="-march=native -O3 -pipe"
        fi
    elif [[ "$OPTIMIZE_PRESET" == "most" ]]; then
        # FIXME: most and full are the same, what is the real breakdown?
        PROFILE_TASK=$(_strip_double_whitespace "-m test.regrtest
            --pgo test_array test_base64 test_binascii test_binhex test_binop
            test_c_locale_coercion test_csv test_json test_hashlib $TEST_UNICODE_NAME
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

    echo "Preparing to compile Python if needed"

    MAKE_OPTS="$MAKE_OPTS" \
    PROFILE_TASK="$PROFILE_TASK" \
    PYTHON_CFLAGS="$PYTHON_CFLAGS" \
    PYTHON_CONFIGURE_OPTS="$PYTHON_CONFIGURE_OPTS" \
        pyenv install "$CHOSEN_PYTHON_VERSION" -s --verbose

    #pyenv shell $CHOSEN_PYTHON_VERSION
    #pyenv global $CHOSEN_PYTHON_VERSION

    VERSION_PREFIX=$(pyenv prefix "$CHOSEN_PYTHON_VERSION")
    CHOSEN_PYEXE=$VERSION_PREFIX/bin/python

    $CHOSEN_PYEXE --version

    if [[ "$VENV_NAME" == "auto" ]]; then
        VENV_NAME=pyenv$CHOSEN_PYTHON_VERSION
    fi
    VENV_PATH=$VERSION_PREFIX/envs/$VENV_NAME

    if [[ $CHOSEN_PYTHON_VERSION == 2.7.* ]]; then
        echo "Creating a 2.7 environment in $VENV_PATH"
        $CHOSEN_PYEXE -m pip install virtualenv
        $CHOSEN_PYEXE -m virtualenv "$VENV_PATH"
    else
        echo "Creating a 3.x environment in $VENV_PATH"
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
    #echo "deactivate_venv OLD_VENV=$OLD_VENV"
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

__list_venvs_fd() {
    # Maybe a faster way to list the envs?
    # TODO: consolidate with __list_static_python_venvs and __list_dynamic_python_envs
    echo "Available environments (via fd):"
    echo

    echo "[conda]"
    if [ -d "$_CONDA_ROOT/envs" ]; then
        fd -u --type d --max-depth 2 bin "$_CONDA_ROOT/envs" \
            | while read -r bin_dir; do
                if [ -f "$bin_dir/activate" ]; then
                    echo "  $(basename "$(dirname "$bin_dir")")"
                fi
            done
        echo
    fi

    echo "[virtualenvs in \$HOME]"
    fd -u --type d --max-depth 2 bin "$HOME" \
        | while read -r bin_dir; do
            if [ -f "$bin_dir/activate" ] && [[ "$bin_dir" == *venv* ]]; then
                echo "  $(basename "$(dirname "$bin_dir")")"
            fi
        done
    echo

    if command -v pyenv >/dev/null 2>&1; then
        echo "[pyenv]"
        pyenv_root=$(pyenv root)
        fd -u --type f --max-depth 1 "activate$" "$pyenv_root"/versions/*/envs/*/bin 2>/dev/null \
            | sed -E "s|.*/envs/||" | sed -E 's|/bin/activate$||' | sort -u \
            | sed 's|^|  |'
        echo
    fi

    echo "[local virtualenvs in $PWD]"
    fd -u --type f --max-depth 1 "activate$" "$PWD"/*/bin 2>/dev/null \
        | sed -E "s|$PWD/||" | sed -E 's|/bin/activate$||' | sort -u \
        | sed 's|^|  |'
}


__list_venvs_find() {
    # TODO: consolidate with __list_static_python_venvs and __list_dynamic_python_envs
    echo "Available environments:"
    echo

    if [ -d "$_CONDA_ROOT/envs" ]; then
        echo "[conda]"
        find "$_CONDA_ROOT/envs" -mindepth 1 -maxdepth 1 -type d -printf "  %f\n"
        echo
    fi

    echo "[virtualenvs in \$HOME]"
    find "$HOME" -mindepth 1 -maxdepth 1 -type d -name "*venv*" -printf "  %f\n"
    echo

    if command -v pyenv >/dev/null 2>&1; then
        echo "[pyenv]"
        # TODO?
        #find "$(pyenv root)"/versions/*/envs -mindepth 3 -maxdepth 3 -type f -path "*/bin/activate"  -exec echo {} \; | sed "s|.*/envs/||" | sed "s|/bin/activate||"
        find "$(pyenv root)/versions" -type f -path "*/envs/*/bin/activate" \
            -exec dirname {} \; | sed 's|.*/envs/|  |'  | sed "s|/bin||"
        echo
    fi

    echo "[local virtualenvs in $PWD]"
    find "$PWD" -type f -path "*/bin/activate" \
        -exec dirname {} \; | sed "s|$PWD/|  |" | sed "s|/bin||"
    echo
}


list_venvs(){
    if command -v fd >/dev/null 2>&1; then
        __list_venvs_fd
    else
        __list_venvs_find
    fi
}

workon_py()
{
    __doc__="
    Switch virtual environments
    "
    if [[ "$1" == "list" ]]; then
        list_venvs
        return 0
    fi

    local NEW_VENV=$1
    #echo "workon_py: NEW_VENV = $NEW_VENV"

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


function with_shopt_option() {
    __doc__='
    Modified from a Gemini response.
    This doesnt seem to work great yet. The example without dependencies can be
    slotted in, but it would be nice to make this function work generally.

    SeeAlso: the ls_array function

    Demo Setup:
        mkdir -p $HOME/tmp/test/test_shopt_context
        cd $HOME/tmp/test/test_shopt_context
        mkdir -p dpath1
        mkdir -p dpath1/dpath2
        touch dpath1/fpath1
        touch dpath1/fpath2
        touch dpath1/dpath2/fpath3
        touch dpath1/dpath2/fpath4

    Usage Without Dependencies:

        # ENTER CONTEXT
        _option="nullglob"
        _original_value=$(shopt -p "$_option")
        shopt -s "$_option"

        # YOUR COMMANDS HERE
        cd $HOME/tmp/test/test_shopt_context
        VENV_DPATH_ARR1=(*/fpath*)
        VENV_DPATH_ARR2=(*/lpath*)

        # EXIT CONTEXT
        eval "$_original_value"

        # Inspect
        echo "${VENV_DPATH_ARR1[@]}"
        echo "${VENV_DPATH_ARR2[@]}"

    Ignore
        shopt -p nullglob
        shopt -s nullglob
        shopt -u nullglob

    Usage:
        cd $HOME/tmp/test/test_shopt_context
        VENV_DPATH_ARR1=(*/fpath*)
        VENV_DPATH_ARR2=(*/lpath*)
        echo "${VENV_DPATH_ARR1[@]}"
        echo "${VENV_DPATH_ARR2[@]}"

        # The problem is that things get expanded before they are passed into
        # the context.
        source ~/local/tools/pyenv_ext/pyenv_ext_commands.sh
        with_shopt_option "nullglob" echo */foo

    '
    local option="$1"
    # Save the original value of the option
    local original_value=$(shopt -p "$option")
    # Set the option to the desired value (note: should ideally be "-s" or "-u")
    shopt -s "$option"

    shift
    # Execute the code within the context
    "$@"

    # Restore the original value of the option
    eval "$original_value"
}


__list_static_python_venvs(){
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
        #PYENV_VERSION_DPATH=$(pyenv root)/versions
        KNOWN_PYENV_ENVS=$(find "$(pyenv root)"/versions/*/envs -mindepth 3 -maxdepth 3 -type f -path "*/bin/activate"  -exec echo {} \; | sed "s|.*/envs/||" | sed "s|/bin/activate||")
        #ls_array VENV_DPATH_ARR "$PYENV_VERSION_DPATH/*/envs/*"
        #if [ "${#VENV_DPATH_ARR[@]}" -gt 0 ]; then
        #    KNOWN_PYENV_ENVS=$(find "${VENV_DPATH_ARR[@]}" -maxdepth 0 -type d -printf "%f\n")
        #fi
    fi
    # Remove newlines
    echo "$KNOWN_CONDA_ENVS $KNOWN_VIRTUAL_ENVS $KNOWN_PYENV_ENVS" | tr '\n' ' '
}

__list_dynamic_python_envs(){
    # Local project virtualenvs (search from cwd)
    find "$PWD" -mindepth 3 -maxdepth 3 -type f -path "*/bin/activate"  -exec echo {} \; | sed "s|$PWD/||" | sed "s|/bin/activate||"
}


refresh_static_workon_autocomplete(){
    local KNOWN_ENVS
    KNOWN_ENVS=$(__list_static_python_venvs)
    complete -W "$KNOWN_ENVS" "workon_py"
    complete -W "$KNOWN_ENVS" "we"
}


_dynamic_workon_autocomplete() {
    # Function that will run every time we press "tab" to autocomplete on workon_py
    local curr_arg
    local all_envs

    curr_arg="${COMP_WORDS[COMP_CWORD]}"

    # Virtualenvs in $HOME that match pattern
    static_virtualenvs=$(__list_static_python_venvs)

    # Local project virtualenvs (search from cwd)
    local_envs=$(__list_dynamic_python_envs)

    # Combine and deduplicate
    all_envs=$(echo -e "$static_virtualenvs\n$local_envs" | sort -u)

    # COMPREPLY=($(compgen -W "$all_envs" -- "$curr_arg"))
    mapfile -t COMPREPLY < <(compgen -W "$all_envs" -- "$curr_arg")
}

execute_pyenv_ext_complete_script(){
    complete -W "PATH LD_LIBRARY_PATH CPATH CMAKE_PREFIX_PATH" "pathvar_remove"

    complete -F _dynamic_workon_autocomplete "workon_py"
    complete -F _dynamic_workon_autocomplete "we"
    #refresh_static_workon_autocomplete
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
    #apt_ensure build-essential libtinfo-dev libncurses-dev gnome-devel libgtk-3-dev libxt-dev
    # note: libtinfo-dev did not install because "selecting 'libncurses-dev' instead of 'libtinfo-dev'"
    apt_ensure build-essential libncurses-dev gnome-devel libgtk-3-dev libxt-dev

    #./configure --help
    #./configure --help | grep python
    # shellcheck disable=SC2164
    cd "$HOME/code/vim"

    # https://github.com/vim/vim/issues/6457
    #git checkout v8.1.2424
    #git checkout v8.2.4030
    #git checkout v9.0.0824
    git checkout v9.1.1169

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

    Args:
       PYTHON_VERSION: the semantic version string

    Example:
        source ~/local/tools/pyenv_ext/pyenv_ext_commands.sh
        _pyenv_best_version_match '3.13'
        _pyenv_best_version_match '3.11'
        _pyenv_best_version_match '3.11.2'
        _pyenv_best_version_match '3'
    "
    PYTHON_VERSION=$1

    # List available python versions and read them into a bash array
    # This relies on the fact that higher versions are stored last
    AVAILALBE_VERSION=$(pyenv install --list)
    readarray -t arr <<< "$AVAILALBE_VERSION"
    BEST_MATCH=None

    # Loop over all possible versions and find one that has the chosen prefix.
    # Avoid dev and release candidates if not explicitly requested.
    for arg in "${arr[@]}"; do
        arg=$(echo "$arg" | xargs echo -n)
        if [[ "$arg" == "$PYTHON_VERSION" ]]; then
            # Always choose an exact match
            BEST_MATCH=$arg
            break
        elif [[ $arg == $PYTHON_VERSION* ]] && [[ "$arg" != *"-dev" ]] && [[ "$arg" != *"t" ]] && [[ "$arg" != *"a"* ]]; then
            # Otherwise choose a matching prefix, as long as it is not a dev or prerelease version
            BEST_MATCH=$arg
        fi
    done

    # Print out the result
    echo "$BEST_MATCH"
}

install_conda(){
    __doc__="
    In some cases conda is a better choice than pyenv. While pyenv can install
    conda, if you need the conda manager, installing conda in a standalone way
    is a better idea.

    To update to a newer version see: [CondaHashes]_ and [CondaInstallers]_.

    References:
        #.. [CondaHashes] https://docs.conda.io/en/latest/miniconda_hashes.html
        .. [CondaHashes] https://docs.conda.io/projects/miniconda/en/latest/miniconda-hashes.html
        .. [CondaInstallers] https://docs.conda.io/en/latest/miniconda.html#linux-installers
    "
    mkdir -p ~/tmp/setup-conda
    cd ~/tmp/setup-conda
    #https://repo.anaconda.com/miniconda/Miniconda3-py311_23.5.2-0-Windows-x86_64.exe
    #https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh

    #CONDA_VERSION=4.10.3
    #CONDA_PY_VERSION=py38
    CONDA_VERSION=23.10.0-1
    CONDA_PY_VERSION=py311
    #ARCH="$(dpkg --print-architecture)"  # different convention
    ARCH="$(arch)"  # e.g. x86_64
    OS=Linux
    CONDA_KEY="Miniconda3-${CONDA_PY_VERSION}_${CONDA_VERSION}-${OS}-${ARCH}"
    echo "CONDA_KEY = $CONDA_KEY"
    CONDA_INSTALL_SCRIPT_FNAME="${CONDA_KEY}.sh"
    CONDA_URL="https://repo.anaconda.com/miniconda/${CONDA_INSTALL_SCRIPT_FNAME}"

    declare -A CONDA_KNOWN_SHA256=(
        ["Miniconda3-py311_23.10.0-1-Linux-x86_64"]="d0643508fa49105552c94a523529f4474f91730d3e0d1f168f1700c43ae67595"
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


bootstrap_dependencies(){
    __doc__="
    https://github.com/openssl/openssl/blob/master/INSTALL.md
    "
    # See: ~/local/tools/pyenv_ext/bootstrap_dependencies.sh
    echo 'local/tools/pyenv_ext/bootstrap_dependencies.sh'
}



install_python_from_uv(){
    # Test to try working with uv as the main tool
    # https://docs.astral.sh/uv/getting-started/installation/#github-releases
    curl -LsSf https://astral.sh/uv/install.sh | sh
    #mkdir -p "$UV_ENV_DPATH"
    #uv python install 3.13
    #uv venv --pyhthon=3.13 --seed --no-project $
    #source .venv/bin/activate

    UV_ENV_DPATH=$HOME/.local/uv/envs
    CHOSEN_PYTHON_VERSION=3.13.2
    VENV_NAME=uvpy$CHOSEN_PYTHON_VERSION
    VENV_PATH=$UV_ENV_DPATH/$VENV_NAME
    mkdir -p "$VENV_PATH"
    uv venv --python=$CHOSEN_PYTHON_VERSION --seed --no-project "$VENV_PATH"
    source "$VENV_PATH/bin/activate"

}


ensure_local_venv(){
    # Name of the venv directory
    VENV_DIR=".venv"

    # Check if the venv already exists
    if [ ! -d "$VENV_DIR" ]; then
        echo "No virtual environment found. Creating one in $PWD/$VENV_DIR ..."
        uv venv "$VENV_DIR" || { echo "Failed to create venv with uv"; return 1; }
    fi

    # Activate the environment
    # shellcheck disable=SC1091
    if [ -f "$VENV_DIR/bin/activate" ]; then
        # Use '.' instead of 'source' for portability
        . "$VENV_DIR/bin/activate"
        echo "Activated virtual environment: $VENV_DIR"
    else
        echo "Error: Could not find activate script in $VENV_DIR/bin/activate"
        return 1
    fi
}
