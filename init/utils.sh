#!/usr/bin/env bash
__doc__='
Erotemics Bash Utilities
========================

These are reasonably simple and standalone bash utilities that help automate
common bash tasks.

These utilties were written by a Python programer, and thus, while many of the
functions are pure-bash, but some do rely on python, and many of them have the
goal of making it easier to work with python in a bash shell.

An overview and example usage of some of the selected utilities are as follows:


* have_sudo - prints True if current user is a sudoer

* codeblock <TEXT> - removes leading indentation from a multiline bash string

* pyblock [PYEXE] <TEXT> [ARGS...] - uses codeblock to remove leading indentation and executes the code in Python

* writeto <fpath> <text> - Unindents text and writes it to a file

* sudo_writeto <fpath> <text> - Unindents text and writes it to a file with sudo privledges

* curl_verify_hash <URL> <DST> <EXPECTED_HASH> [HASHER] [CURL_OPTS] [VERBOSE] - downloads a file with curl and also checks its hash.

* joinby <SEP> [ARGS...] - joins all the arguments into a string separated by the separator


Example:
    source $HOME/local/init/utils.sh

    # have_sudo - prints True if your user hs the ability to run commands with sudo
    have_sudo

TODO:
    - [ ] Refeactor into a standalone bash library
    - [ ] Provide an easy and secure installation mechanism
    - [ ] Provide an easy and secure update mechanism
    - [ ] Write high-level documentation


Standalone Install Instructions:
    todo

    # Not the best way, but a way.
    curl https://raw.githubusercontent.com/Erotemic/local/main/init/utils.sh > erotemic_utils.sh
'

# set to 0 to prevent this script from running more than once
# set to 1 for editable "development" mode
__EROTEMIC_ALWAYS_RELOAD__=1
__EROTEMIC_ALWAYS_RELOAD__="${__EROTEMIC_ALWAYS_RELOAD__:=0}"
__EROTEMIC_UTILS_VERSION__="0.3.0"

if [ "$__EROTEMIC_ALWAYS_RELOAD__" = "0" ]; then
    if [ "$__SOURCED_EROTEMIC_UTILS__" = "$__EROTEMIC_UTILS_VERSION__" ]; then
       # Prevent reloading if the version hasnt changed
       return
    fi
fi
__SOURCED_EROTEMIC_UTILS__="$__EROTEMIC_UTILS_VERSION__"


_handle_help(){
    __internal_doc__='
    Internal helper used to add --help support to commands in this file.
    The commands must define a __doc__ variable then they must call
    this function as such:

        _handle_help "$@" || return

        or if using in a top-level script

        _handle_help "$@" || exit 0
    '
    for var in "$@"
    do
        if [[ "$var" == "--help" || "$var" == "-h" ]]; then
            echo "$__doc__"
            return 1
        fi
    done
    return 0
}


system_python(){
    __doc__="
    Return name of system python
    "
    if [ "$(type -P python)" != "" ]; then
        echo "python"
    elif [ "$(type -P python3)" != "" ]; then
        echo "python3"
    else
        echo "python"
    fi
}


have_sudo(){
    __doc__='
    Tests if we have the ability to use sudo.
    Returns the string "True" if we do.

    References:
        https://stackoverflow.com/questions/18431285/check-if-a-user-is-in-a-group

    Example:
        HAVE_SUDO=$(have_sudo)
        if [ "$HAVE_SUDO" == "True" ]; then
            sudo do stuff
        else
            we dont have sudo
        fi
    '
    # New pure-bash implementation
    local USER_GROUPS
    USER_GROUPS=$(id -Gn "$(whoami)")
    if [[ " $USER_GROUPS " == *" sudo "* ]]; then
        echo "True"
    else
        echo "False"
    fi
    # Old python-based implementation
    #_PYEXE=$(system_python)
    #$_PYEXE -c "$(codeblock "
    #    import grp, pwd
    #    user = '$(whoami)'
    #    groups = [g.gr_name for g in grp.getgrall() if user in g.gr_mem]
    #    gid = pwd.getpwnam(user).pw_gid
    #    groups.append(grp.getgrgid(gid).gr_name)
    #    print('sudo' in groups)
    #")"
}


is_headless(){
    __doc__='
    Tests if we have a local display variable (i.e. not x11 forwarding)
    if we dont then we are probably on a headless server

    Example:
        source $HOME/local/init/utils.sh
        IS_HEADLESS=$(is_headless)
        echo "IS_HEADLESS = $IS_HEADLESS"
    '
    if [ "$DISPLAY" == "" ]; then
        echo "True"
    else
        # TODO: how do we test for headless in bash
        _PYEXE=$(system_python)
        _VAR=$($_PYEXE -c "print('True' * '$DISPLAY'.startswith(':'))")
        if [ "$_VAR" == "True" ]; then
            echo "False"
        else
            echo "True"
        fi
    fi
}


has_pymodule(){
    __doc__='
    Check if a python module is installed. Echos "True" or "False" to the
    command line depending on the result.

    Example:
        source $HOME/local/init/utils.sh
        has_pymodule sys
        has_pymodule fake_module
    '

    if [ "$2" ]; then
        PYEXE="$1"
        PYMOD="$2"
    else
        PYEXE=$(system_python)
        PYMOD="$1"
    fi
    pyblock "$PYEXE" "
        try:
            import $PYMOD
            print(True)
        except ImportError:
            print(False)
    "
}

pyblock(){
    __doc__='
    Executes python code and handles nice indentation.  Need to be slightly
    careful about the type of quotes used.  Typically stick to doublequotes
    around the code and singlequotes inside python code. Sometimes it will be
    necessary to escape some characters.

    Usage:
       pyblock [PYEXE] <TEXT> [ARGS...]

    Args:
       PYEXE : positional arg to specify the python executable.
           if not specified, it defaults to "python"

       TEXT : arbitrary python code to execute

       ARGS : sys.argv passed to the python program

    Notes:
        Capture results from stdout either using using
            (1) dollar-parens: $()
            (2) backticks: ``

    Example:
        source $HOME/local/init/utils.sh
        OUTPUT=$(pyblock "
            import sys
            print(sys.executable)
        ")
        echo "OUTPUT = $OUTPUT"

        OUTPUT=$(pyblock python3 "
            import sys
            print(sys.executable)
        ")
        echo "OUTPUT = $OUTPUT"

        OUTPUT=$(pyblock python3 "
            import sys
            print(sys.argv)
        " "arg1" "arg2 and still arg2" arg3)
        echo "OUTPUT = $OUTPUT"
    '
    _handle_help "$@" || return 0
    if [[ $# -eq 0 ]]; then
        echo "MUST SUPPLY AN ARGUMENT: USAGE IS: pyblock [PYEXE] TEXT [ARGS...]"
    fi

    # Default values
    PYEXE=$(system_python)
    TEXT=""
    if [ $# -gt 1 ] && [[ $(type -P "$1") != "" ]] ; then
        # If the first arg executable, then assume it is a python executable
        PYEXE=$1
        # In this case the second arg must be text
        TEXT=$2
        # pop off these first two processed arguments, so the rest can be
        # passed to the python program
        shift
        shift
    else
        # Usually the first argument is text
        TEXT=$1
        # pop off this processed arguments, so the rest can be passed down
        shift
    fi
    $PYEXE -c "$(codeblock "$TEXT")" "$@"
}


codeblock()
{
    if [ "-h" == "$1" ] || [ "--help" == "$1" ]; then
        # Use codeblock to show the usage of codeblock, so you can use
        # codeblock while you codeblock.
        codeblock '
            Unindents code before its executed so you can maintain a pretty
            indentation in your code file. Multiline strings simply begin
            with
                "$(codeblock "
            and end with
                ")"

            Usage:
               codeblock <TEXT>

            Args:
               TEXT : text to remove leading indentation of

            Example:
               echo "$(codeblock "
                    a long
                    multiline string.
                    this is the last line that will be considered.
                    ")"

               # No indentation errors
               python -c "$(codeblock "
                   import math
                   for i in range(10):
                       print(math.factorial(i))
                   ")"
        '
    else
        # Prevents python indentation errors in bash
        #python -c "from textwrap import dedent; print(dedent('$1').strip('\n'))"
        local PYEXE
        PYEXE=$(system_python)
        echo "$1" | $PYEXE -c "import sys; from textwrap import dedent; print(dedent(sys.stdin.read()).strip('\n'))"
    fi
}


_simple_codeblock()
{
    __doc__='
    copy-pastable implementation
    Prevents indentation errors in bash
    '
    echo "$1" | python -c "import sys; from textwrap import dedent; print(dedent(sys.stdin.read()).strip('\n'))"
}


writeto()
{
    __doc__="
    Unindents text and writes it to a file

    Usage:
        writeto <fpath> <text>

    Args:
        fpath : path to write to
        text : text to unindent and write

    Example:
        writeto some-file.txt '
            # Text in this command is automatically dedented via codeblock
            option=True
            variable=False
            '
    "
    _handle_help "$@" || return 0
    fpath=$1
    text=$2
    fixed_text=$(codeblock "$text")
    sh -c "echo \"$fixed_text\" > $fpath"
}


sudo_writeto()
{
    __doc__="
    Unindents text and writes it to a file with sudo privledges

    Usage:
        sudo_writeto <fpath> <text>

    Args:
        fpath : path to write to
        text : text to unindent and write

    Example:
        sudo_writeto /root-file '
            # Text in this command is automatically dedented via codeblock
            option=True
            variable=False
        '
        cat /root-file
    "
    _handle_help "$@" || return 0

    # NOTE: FAILS WITH QUOTES IN BODY
    fpath=$1
    text=$2
    fixed_text=$(codeblock "$text")
    echo "
    fpath = '$fpath'
    text = '$text'
    fixed_text = '$fixed_text'
    "
    # IS THERE A BETTER WAY TO FORWARD AN ENV TO SUDO SO sudo writeto works
    sudo sh -c "echo \"$fixed_text\" > $fpath"
#    # Maybe this?
#    sudo sh -c "cat > ${fpath} << EOF
#${fixed_text}
#"
}

sudo_appendto()
{
    __doc__="
    Unindents text and appends it to a file with sudo privledges

    Usage:
        sudo_appendto <fpath> <text>

    Args:
        fpath : path to write to
        text : text to unindent and write

    Example:
        sudo_appendto /root-file '
            # Text in this command is automatically dedented via codeblock
            option=True
            variable=False
        '
        cat /root-file
    "
    _handle_help "$@" || return 0
    # NOTE: FAILS WITH QUOTES IN BODY
    fpath=$1
    text=$2
    fixed_text=$(codeblock "$text")
    # IS THERE A BETTER WAY TO FORWARD AN ENV TO SUDO SO sudo writeto works
    sudo sh -c "echo \"$fixed_text\" >> $fpath"

#    # Maybe this?
#    sudo sh -c "cat >> ${fpath} << EOF
#${fixed_text}
#"
}


append_if_missing()
{
    __doc__='
    Appends a line to the end of a file only if that line does not exist.

    Args:
        fpath: the file path
        text: the line to append. Leading indentation is removed.

    Example:
        source $HOME/local/init/utils.sh

        fpath="/tmp/foo.txt"
        text="my config option"

        # Initialize an empty file
        echo "" > /tmp/foo.txt
        cat /tmp/foo.txt

        # This should append the text to the end
        append_if_missing "/tmp/foo.txt" "my config option"
        cat /tmp/foo.txt

        # This should not append the text to the end because it already exists
        append_if_missing "/tmp/foo.txt" "my config option"
        cat /tmp/foo.txt
    '
    _handle_help "$@" || return 0
    fpath=$1
    text=$2
    fixed_text=$(codeblock "$text")
    # Apppend the text only if it doesn't exist
    found="$(grep -F "$fixed_text" "$fpath")"
    if [ "$found" == "" ]; then
        sh -c "echo \"$fixed_text\" >> $fpath"
    fi
}

exists(){
    __doc__='
    Bash version of os.path.exists from Python

    Returns 0 if the path exists, otherwise returns 1

    Args:
        FS_PATH : path to check

    Equivalent to [ -e $FS_PATH ]

    Example:
        __EROTEMIC_ALWAYS_RELOAD__=1
        source ~/local/init/utils.sh

        # This path does not exist
        FS_PATH=$HOME/does-not-exist
        exists $FS_PATH
        echo $?
        [ -e $FS_PATH ]
        echo $?
        if exists "$FS_PATH"; then
            echo "FS_PATH=$FS_PATH exists"
        else
            echo "FS_PATH=$FS_PATH does not exist"
        fi

        # This path does exist
        FS_PATH=$HOME
        exists $FS_PATH
        echo $?
        [ -e $FS_PATH ]
        echo $?
        if exists "$FS_PATH"; then
            echo "FS_PATH=$FS_PATH exists"
        else
            echo "FS_PATH=$FS_PATH does not exist"
        fi
    '
    _handle_help "$@" || return 0
    [ -e "$1" ]
    return $?
}

# Can we wrap sudo such we can allow utils to be used?
#util_sudo(){
#    echo "$@"
#    #sudo bash -c "source $HOME/local/init/utils.sh; $@"
#}


safe_symlink(){
    __doc__="
    REAL PATH FIRST, LINK PATH SECOND

    Args:
        real_path (the real file you want to point to)
        link_path (the location that you want to point to the real file)

    Example:
        __EROTEMIC_ALWAYS_RELOAD__=1
        source ~/local/init/utils.sh

        mkdir -p ~/tmp/test_safe_symlink
        rm -rf ~/tmp/test_safe_symlink
        mkdir -p ~/tmp/test_safe_symlink
        cd ~/tmp/test_safe_symlink
        touch real_file
        mkdir -p real_dir
        touch conflict_file
        mkdir -p conflict_dir
        safe_symlink real_file link_file
        safe_symlink real_dir link_dir
        safe_symlink real_file link_file
        safe_symlink real_dir link_dir
        safe_symlink real_file conflict_file
        safe_symlink real_dir conflict_dir
        ls -al
    "
    _handle_help "$@" || return 0
    real_path=$1
    link_path=$2
    echo "Safe symlink $real_path <- $link_path"
    unlink_or_backup "${link_path}"
    ln -s "${real_path}" "${link_path}"
}


safe_copy(){
    __doc__="
    Copy a file to target destination and backup anything that it would clobber

    Args:
        src: file to copy
        dst: destination path

    Example:
        __EROTEMIC_ALWAYS_RELOAD__=1
        source ~/local/init/utils.sh

        mkdir -p ~/tmp/safe_copy
        rm -rf ~/tmp/safe_copy
        mkdir -p ~/tmp/safe_copy
        cd ~/tmp/safe_copy
        touch orig_file
        mkdir -p orig_dir
        touch conflict_file
        mkdir -p conflict_dir
        safe_copy orig_file copy_file
        safe_copy orig_dir copy_dir
        safe_copy orig_file copy_file
        safe_copy orig_dir copy_dir
        safe_copy orig_file conflict_file
        safe_copy orig_dir conflict_dir
        ls -al
    "
    _handle_help "$@" || return 0
    src_path=$1
    dst_path=$2
    echo "Safe copy $src_path to $dst_path"
    unlink_or_backup "${dst_path}"
    cp -r "${src_path}" "${dst_path}"
}


unlink_or_backup()
{
    __doc__='
    Get a file or directory out of the way without removing it.

    If TARGET exists, it is removed if it is a link, otherwise if it is a file or
    directory it renames it based on a the current time. If it doesnt exist
    nothing happens.

    TODO:
        move to a bash utils file

    Args:
        TARGET (str): a path to a directory, link, or file
    '
    _handle_help "$@" || return 0

    TARGET=$1
    if [ -L "$TARGET" ]; then
        # remove any previouly existing link
        unlink "$TARGET"
    elif [ -f "$TARGET" ] || [ -d "$TARGET" ] ; then
        # backup any existing file or directory
        mv "$TARGET" "$TARGET"."$(date --iso-8601=seconds)".old
    fi
}



apt_ensure(){
    __doc__="
    Checks to see if the packages are installed and installs them if needed.

    The main reason to use this over normal apt install is that it avoids sudo
    if we already have all requested packages.

    Args:
        *ARGS : one or more requested packages

    Environment:
        UPDATE : if this is populated also runs and apt update

    Example:
        apt_ensure git curl htop
    "
    _handle_help "$@" || return 0
    # Note the $@ is not actually an array, but we can convert it to one
    # https://linuxize.com/post/bash-functions/#passing-arguments-to-bash-functions
    ARGS=("$@")
    MISS_PKGS=()
    HIT_PKGS=()
    _SUDO=""
    if [ "$(whoami)" != "root" ]; then
        # Only use the sudo command if we need it (i.e. we are not root)
        _SUDO="sudo "
    fi
    for PKG_NAME in "${ARGS[@]}"
    do
        # Check if the package is already installed or not
        if dpkg-query -W -f='${Status}' "$PKG_NAME" 2>/dev/null | grep -q "install ok installed"; then
            echo "Already have PKG_NAME='$PKG_NAME'"
            HIT_PKGS+=("$PKG_NAME")
        else
            echo "Do not have PKG_NAME='$PKG_NAME'"
            MISS_PKGS+=("$PKG_NAME")
        fi
    done

    # Install the packages if any are missing
    if [ "${#MISS_PKGS[@]}" -gt 0 ]; then
        if [ "${UPDATE}" != "" ]; then
            $_SUDO apt update -y
        fi
        DEBIAN_FRONTEND=noninteractive $_SUDO apt install -y "${MISS_PKGS[@]}"
    else
        echo "No missing packages"
    fi
}



compress_path(){
    __doc__="
    Replace explicit home dir with tilde

    Args:
        path : path to shrink

    References:
        https://stackoverflow.com/questions/10036255/is-there-a-good-way-to-replace-home-directory-with-tilde-in-bash

    Example:
        ~/local/init/utils.sh
        compress_path $HOME/hello
        compress_path /hello
    "
    _handle_help "$@" || return 0
    local path=$1
    if [[ "$path" =~ ^"$HOME"(/|$) ]]; then
        path="~${path#"$HOME"}"
        echo "$path"
    fi
    echo "$path"
}


sedfile(){
    local FILEPATH=$1
    local SEARCH=$2
    local REPLACE=$3
    local INPLACE=$4

    echo "search: $FILEPATH"
    #echo "FILEPATH='$FILEPATH'"
    #echo "SEARCH='$SEARCH'"
    #echo "REPLACE='$REPLACE'"
    #echo "INPLACE='$INPLACE'"
    # Do replace into a temp file
    # https://stackoverflow.com/questions/15965073/return-value-of-sed-for-no-match/15966279
    grep -q -m 1 "${SEARCH}" "${FILEPATH}"
    RET_CODE="$?"
    if [[ $RET_CODE -eq 0 ]]; then
        echo "replacing: $FILEPATH"
        sed "s|${SEARCH}|${REPLACE}|gp" "$FILEPATH" > "$FILEPATH.sedr.tmp"
        diff -u "${FILEPATH}.sedr.tmp" "$FILEPATH" | colordiff
        rm "$FILEPATH.sedr.tmp"
    fi
}
# Needs to be global for find
export -f sedfile


sedr(){
    __doc__="
    Recursive sed

    Args:
        search
        replace
        pattern (passed as -iname to find defaults to *.py)
        live_run

    Example:
        __EROTEMIC_ALWAYS_RELOAD__=1
        cd $HOME/code/ubelt/ubelt
        source $HOME/local/init/utils.sh && PATTERN='*.py' sedr not-a-thing daft
        source $HOME/local/init/utils.sh && PATTERN='*.py' sedr def daft
        source $HOME/local/init/utils.sh && PATTERN='*.py' sedr util_io fds

    SeeAlso:
       xdev sed
    "
    _handle_help "$@" || return 0

    local SEARCH=${1:-${SEARCH:-""}}
    local REPLACE=${2:-${REPLACE:-""}}
    local PATTERN=${3:-${PATTERN:-'*'}}
    local INPLACE=${4:-${INPLACE:-"False"}}

    echo "
    === sedr ===
    argv[1] = SEARCH = '$SEARCH' - text to search
    argv[2] = REPLACE = '$REPLACE' - text to replace
    argv[3] = PATTERN = '$PATTERN' - filename patterns to match
    argv[4] = INPLACE = '$INPLACE' - set to 'True' modify the files inplace
    "

    #find . -type f -iname "${PATTERN}" -print
    if [[ "$INPLACE" == "True" ]]; then
        # Live RUN
        find . -type f -iname "${PATTERN}" -exec sed -i "s|${SEARCH}|${REPLACE}|g" {} +
    else
        # https://unix.stackexchange.com/questions/97297/how-to-report-sed-in-place-changes
        #find . -type f -iname "${PATTERN}" -exec sed "s|${SEARCH}|${REPLACE}|g" {} + | grep "${REPLACE}"
        #find . -type f -iname "${PATTERN}" -exec sed --quiet "s|${SEARCH}|${REPLACE}|gp" {} + | grep "${REPLACE}" -C 100
        find . -type f -iname "${PATTERN}" -exec /bin/bash -c "sedfile \"\$1\" \"$SEARCH\" \"$REPLACE\" \"$INPLACE\" " bash {} \;
    fi
}



exthist(){
    __doc__="
    Create a histogram of unique extensions in a directory.

    Usage:
       exthist [-r] [dpath...]

    Args:
        dpath
            One or more directories to perform this action on. If unspecified
            uses the cwd.

        -r, --recursive
            if specified do this recursively

    References:
        https://stackoverflow.com/questions/1842254/distinct-extensions-in-a-folder

    Example:
        __EROTEMIC_ALWAYS_RELOAD__=1
        source $HOME/local/init/utils.sh && exthist $HOME/code/ubelt -a -r
        source $HOME/local/init/utils.sh && exthist $HOME/local -r
        source $HOME/local/init/utils.sh && exthist $HOME/local
        exthist $HOME/local -r
        exthist $HOME/local

        exthist --help
        exthist /bin /etc -r
        exthist $HOME/local/init -r
        exthist -r
    "
    _handle_help "$@" || return 0

    local RECURSIVE="0"
    DPATH_LIST=()
    local IGNORE_HIDDEN="1"

    while [[ $# -gt 0 ]]
    do
        local key="$1"
        case $key in
            -r|--recursive)
            RECURSIVE=True
            shift # past argument
            ;;
            -a|--all)
            IGNORE_HIDDEN="0"
            shift # past argument
            ;;
            *)    # unknown option
            echo "$1"
            # all other positional args specify directories
            DPATH_LIST+=("$1")
            shift # past argument
            ;;
        esac
    done
    if [[ ${#DPATH_LIST[@]} -eq 0 ]]; then
        # Default to cwd
        DPATH_LIST=(.)
    fi

    #echo "
    #* RECURSIVE = $RECURSIVE
    #* DPATH_LIST = $DPATH_LIST
    #* IGNORE_HIDDEN = $IGNORE_HIDDEN
    #"

    local DPATH=""
    for DPATH in "${DPATH_LIST[@]}"; do
        if [ "$RECURSIVE" == "True" ]; then
            # TODO: could pass more arguments to find to restrict recursion
            if [ "$IGNORE_HIDDEN" == "1" ]; then
                # trouble with bash, reading find into arrays. Is there a better way?
                ALL_SUBDIRS=()
                while IFS=  read -r -d $'\0'; do
                    ALL_SUBDIRS+=("$REPLY")
                done < <(find "$DPATH" -xtype d -not -path '*/\.*' -print0)

            else
                #ALL_SUBDIRS="$(find $DPATH)"
                ALL_SUBDIRS=()
                while IFS=  read -r -d $'\0'; do
                    ALL_SUBDIRS+=("$REPLY")
                done < <(find "$DPATH" -xtype d -print0 )
            fi

            #echo "ALL_SUBDIRS = $(bash_array_repr "${ALL_SUBDIRS[@]}")"
            #echo "n=${#ALL_SUBDIRS[@]}"
            #find "${ALL_SUBDIRS[@]}" -maxdepth 1 -xtype f -path '*/*.*'

            # TODO: breakup dirs option
            # TODO:
            find "${ALL_SUBDIRS[@]}" -maxdepth 1 -xtype f -path '*/*.*' | rev | cut -d. -f1 | cut -d/ -f1 | rev  | tr '[:upper:]' '[:lower:]' | sort | uniq --count | sort -rn

        else
            # Logic is
            # reverse the string,
            # remove everything after the "first" . and /
            # reverse again (aka we got everything after the last . or /)
            # convert to lowercase
            # sort, unique, and count
            find "$DPATH" -maxdepth 1 -xtype f | rev | cut -d. -f1 | cut -d/ -f1 | rev  | tr '[:upper:]' '[:lower:]' | sort | uniq --count | sort -rn
        fi
    done

    #echo "
    #* RECURSIVE = $RECURSIVE
    #* DPATH_LIST = $DPATH_LIST
    #* IGNORE_HIDDEN = $IGNORE_HIDDEN
    #"
}

escape_bash_string(){
    __doc__='
    Escapes the input string so the program that it is passed to sees exactly
    the given input string.

    Args:
        The string to escape

    Returns:
        The escaped string

    Example:
        escape_bash_string "one-word" && echo ""
        escape_bash_string "two words" && echo ""
        escape_bash_string "\"a quoted phrase\"" && echo ""
        escape_bash_string "\"a literal \" quoted phrase\"" && echo ""
        escape_bash_string "oh \" no \" so \" my \" ba \" \"\" \\ hm" && echo ""
        escape_bash_string "backslashes \\\\\\\\" && echo ""
        escape_bash_string "three words" && echo ""
        escape_bash_string "path\"o\"log ic" && echo ""
    '
    printf "%q" "$1"
}

_extlist_group(){
    __doc__="
    helper that lists all the extensions
    "
    FIND_FILE_OPTS=${FIND_FILE_OPTS:=""}
    #echo "+!!FIND_FILE_OPTS = $FIND_FILE_OPTS"
    #local _DPATH
    for _DPATH in "$@"; do
        #find $_DPATH -maxdepth 1 -xtype f "$FIND_FILE_OPTS" | rev | cut -d. -f1 | cut -d/ -f1 | rev  | tr '[:upper:]' '[:lower:]'
        find "$_DPATH" -maxdepth 1 -xtype f | rev | cut -d. -f1 | cut -d/ -f1 | rev  | tr '[:upper:]' '[:lower:]'
        #echo "-!! _DPATH = $_DPATH"
    done
    #echo "!!FIND_FILE_OPTS = $FIND_FILE_OPTS"
}


bash_array_repr(){
    __doc__='
    Given a bash array, this should print a literal copy-pastable
    representation

    Example:
        ARR=(1 "2 3" 4)
        bash_array_repr "${ARR[@]}"
    '
    _handle_help "$@" || return 0

    local ARGS=("$@")
    if [ "${#ARGS[@]}" -gt 0 ]; then
        # Not sure if the double or single quotes is better here
        echo "($(printf "'%s' " "${ARGS[@]}"))"
        #echo "($(printf "\'%s\' " "${ARGS[@]}"))"
    else
        echo "()"
    fi
}


#recursive_exthist(){
#    ROOT=$1
#    FIND_RESULT=$(find $ROOT -type d)
#    for dpath in $FIND_RESULT; do
#        ext_hist $dpath
#    done
#}

#__parse_args(){
#    __doc__="
#    TODO: Can we develop a simple version of something like argparse for bash
#    "
#    if [[ $# -gt 0 ]]; then
#        POSITIONAL=()
#        while [[ $# -gt 0 ]]
#        do
#            key="$1"

#            case $key in
#                -u|--unmount)
#                UNMOUNT=YES
#                shift # past argument
#                ;;
#                -f|--force)
#                FORCE=YES
#                shift # past argument
#                ;;
#                *)    # unknown option
#                POSITIONAL+=("$1") # save it in an array for later
#                shift # past argument
#                ;;
#            esac
#        done
#        set -- "${POSITIONAL[@]}" # restore positional parameters

#        if [[ ${#POSITIONAL[@]} -gt 0 ]]; then
#            # User specified a specific set of remotes
#            # Always force when user specifies the remotes
#            FORCE=YES
#            for REMOTE in "${POSITIONAL[@]}"
#            do :
#                echo "REMOTE = $REMOTE"
#                if [ "$UNMOUNT" == "YES" ]; then
#                    echo "FORCE = $FORCE"
#                    echo "REMOTE = $REMOTE"
#                    unmount_if_mounted $REMOTE $FORCE
#                else
#                    mount_remote_if_available $REMOTE $FORCE
#                fi
#            done
#        else
#            echo "ERROR NEED TO SPECIFY REMOTE"
#        fi
#    fi

#}


curl_verify_hash(){
    __doc__='
    A thin wrapper around curl that adds the feature where it will return a
    failure integer code if the hash of the downloaded file does not match an
    expected version.

    Usage:
        curl_verify_hash <URL> <DST> <EXPECTED_HASH> [HASHER] [CURL_OPTS] [VERBOSE]

    Args:
        URL : the url to download
        DST : the destination for the file
        EXPECTED_HASH : the prefix of the expected hash
        HASHER : the hasher to use use (defaults to sha256sum)
        CURL_OPTS : any additional options to CURL
        VERBOSE : for debugging

    References:
        https://github.com/curl/curl/issues/1399

    Example:
        URL=https://file-examples-com.github.io/uploads/2017/02/file_example_JSON_1kb.json
        DST=file_example_JSON_1kb.json
        EXPECTED_HASH="fdsfsd"

        __EROTEMIC_ALWAYS_RELOAD__=1
        source $HOME/local/init/utils.sh

        URL=https://file-examples-com.github.io/uploads/2017/02/file_example_JSON_1kb.json \
        VERBOSE=0 \
        EXPECTED_HASH="aa20e971f6a0a7c482f3ed70cc6edc" \
            curl_verify_hash

        URL=https://file-examples-com.github.io/uploads/2017/02/file_example_JSON_1kb.json \
        EXPECTED_HASH="aaf20" \
            curl_verify_hash

        __EROTEMIC_ALWAYS_RELOAD__=1
        source $HOME/local/init/utils.sh
        GO_KEY=go1.17.5.linux-amd64
        URL="https://go.dev/dl/${GO_KEY}.tar.gz"
        declare -A GO_KNOWN_HASHES=(
            ["go1.17.5.linux-amd64-sha256"]="bd78114b0d441b029c8fe0341f4910370925a4d270a6a590668840675b0c653e"
            ["go1.17.5.linux-arm64-sha256"]="6f95ce3da40d9ce1355e48f31f4eb6508382415ca4d7413b1e7a3314e6430e7e"
        )
        EXPECTED_HASH="${GO_KNOWN_HASHES[${GO_KEY}-sha256]}"
        BASENAME=$(basename "$URL")
        curl_verify_hash "$URL" "$BASENAME" "$EXPECTED_HASH" sha256sum "-L"

    A no-dependency snippet that can be used in place of this looks like

    .. code::

        URL=https://file-examples-com.github.io/uploads/2017/02/file_example_JSON_1kb.json
        DST=file_example_JSON_1kb.json
        EXPECTED_SHA256="70d613e3acfba24fd2876fcbacaf639e1e111ef4d54baf70761c47673f37d6a3"
        curl "$URL" -o "$DST"
        if echo "${EXPECTED_SHA256} $DST" | sha256sum --status -c ; then
            echo "checksum is ok"
        else
            echo "ERROR checksum is NOT the same"
        fi

    Notes:
       To verify a hash without this special command you can use the following pattern, first we setup demodata,
       to illustrate this.

       # Write a file,
       echo "demodata" > demo.txt
       # Given environment variables with a filepath and its expected hash, check if via
       FPATH=demo.txt
       EXPECTED_HASH=63dd7b5024e7859775e6f2afac439664ed2841e993ac5d171ab430f776b0f2cc

       # This command has exit code 0 for success
       echo "$EXPECTED_HASH $FPATH" | sha256sum -c
       echo $?

       # This command has exit code 1 for failure
       echo "badbeafbadbeafbadbeafbadbeafbadbeafbadbeafbadbeafbadbeafbadbeafb $FPATH" | sha256sum -c
       echo $?

    '
    _handle_help "$@" || return 0

    local URL=${1:-${URL:-""}}
    local DEFAULT_DST
    DEFAULT_DST=$(basename "$URL")
    local DST=${2:-${DST:-$DEFAULT_DST}}
    local EXPECTED_HASH=${3:-${EXPECTED_HASH:-'*'}}
    local HASHER=${4:-sha256sum}
    local CURL_OPTS=${5:-"${CURL_OPTS}"}
    local VERBOSE=${6:-${VERBOSE:-"2"}}

    $(system_python) -c "import sys; sys.exit(0 if ('$HASHER' in {'sha256sum', 'sha512sum'}) else 1)"

    if [ $? -ne 0 ]; then
        echo "HASHER = $HASHER is not in the known list"
        return 1
    fi

    if [ "$VERBOSE" -ge 2 ]; then
        codeblock "
            curl_verify_hash
                * URL='$URL'
                * DST='$DST'
                * CURL_OPTS='$CURL_OPTS'
            "
    fi

    # Download the file
    # shellcheck disable=SC2086
    curl $CURL_OPTS "$URL" --output "$DST"

    # Verify the hash
    verify_hash "$DST" "$EXPECTED_HASH" "$HASHER" "$VERBOSE"
    return $?
}

verify_hash(){
    __doc__='
    Verifies the hash *prefix* of a file

    Example:
        FPATH="$(which ls)"
        EXPECTED_HASH=4ef89baf437effd684a125da35674dc6147ef2e34b76d11ea0837b543b60352f
        __EROTEMIC_ALWAYS_RELOAD__=1
        source $HOME/local/init/utils.sh
        verify_hash $FPATH $EXPECTED_HASH
    '
    _handle_help "$@" || return 0

    local FPATH=${1:-${FPATH:-"Unspecified"}}
    local EXPECTED_HASH=${2:-${EXPECTED_HASH:-'*'}}
    local HASHER=${3:-sha256sum}
    local VERBOSE=${4:-${VERBOSE:-"2"}}

    $(system_python) -c "import sys; sys.exit(0 if ('$HASHER' in {'sha256sum', 'sha512sum'}) else 1)"

    if [ $? -ne 0 ]; then
        echo "HASHER = $HASHER is not in the known list"
        return 1
    fi

    # Get the hash
    local GOT_HASH
    GOT_HASH=$($HASHER "$FPATH" | cut -d' ' -f1)
    echo "FPATH = $FPATH"
    echo "GOT_HASH = $GOT_HASH"

    # Verify the hash
    if [[ "$GOT_HASH" != $EXPECTED_HASH* ]]; then
        codeblock "
            Checking hash
                * GOT_HASH      = '$GOT_HASH'
                * EXPECTED_HASH = '$EXPECTED_HASH'
            Downloaded file does not match hash!
            DO NOT CONTINUE WITHOUT VALIDATING NEW VERSION AND UPDATING THE HASH!
        "
        return 1
    else
        if [ "$VERBOSE" -ge 1 ]; then
            codeblock "
                Checking hash
                    * GOT_HASH      = '$GOT_HASH'
                    * EXPECTED_HASH = '$EXPECTED_HASH'
                Hash prefixes match
                "
        fi
        return 0
    fi
}


curl_grabdata(){
    __doc__='
    Similar to curl_verify_hash.

    Implements "grabdata" capabilities to prevent redownloading files that already exist.

    Also uses more concise bash commands and less Python.

    Example:
        URL=https://file-examples-com.github.io/uploads/2017/02/file_example_JSON_1kb.json
        DST=file_example_JSON_1kb.json
        EXPECTED_HASH="21b4d800cc282ca452f7394e95d5382340ac3481a002c21da681005a44f18ea6cf43959990cd715b4657f180e0e96d6087fe724f3200e909f9fd70ebcd5511bd"

        __EROTEMIC_ALWAYS_RELOAD__=1
        source $HOME/local/init/utils.sh

        URL=$URL \
        EXPECTED_HASH="$EXPECTED_HASH" \
        VERBOSE=1 \
            curl_grabdata

    A no-dependency snippet that can be used in place of this looks like

    .. code::

        URL=https://file-examples-com.github.io/uploads/2017/02/file_example_JSON_1kb.json
        DST=file_example_JSON_1kb.json
        EXPECTED_SHA256="70d613e3acfba24fd2876fcbacaf639e1e111ef4d54baf70761c47673f37d6a3"
        curl "$URL" -o "$DST"
        if echo "${EXPECTED_SHA256} $DST" | sha256sum --status -c ; then
            echo "checksum is ok"
        else
            echo "ERROR checksum is NOT the same"
        fi
    '
    _handle_help "$@" || return 0

    # -- <ARGUMENT PARSING> ---
    local URL=${1:-${URL:-""}}
    local DEFAULT_DST
    #local DEFAULT_DPATH
    DEFAULT_DST=$(basename "$URL")
    local DST=${2:-${DST:-$DEFAULT_DST}}
    local EXPECTED_HASH=${3:-${EXPECTED_HASH:-''}}
    local HASHER=${4:-sha512sum}
    local CURL_OPTS=${5:-"${CURL_OPTS}"}
    local VERBOSE=${4:-${VERBOSE:-"2"}}
    # -- </ARGUMENT PARSING> ---

    # -- <ARGUMENT VALIDATION> ---
    $(system_python) -c "import sys; sys.exit(0 if ('$HASHER' in {'sha256sum', 'sha512sum'}) else 1)"
    if [ $? -ne 0 ]; then
        echo "HASHER = $HASHER is not in the known list"
        return 1
    fi
    if [ "$VERBOSE" -ge 2 ]; then
        codeblock "
            _curl_grabdata
                * URL='$URL'
                * DST='$DST'
                * HASHER='$HASHER'
                * EXPECTED_HASH='$EXPECTED_HASH'
                * CURL_OPTS='$CURL_OPTS'
            "
    fi
    if test -d "$DST" ; then
        echo "ERROR DST cannot be a directory"
        return 1
    fi
    # -- </ARGUMENT VALIDATION> ---

    # -- <BODY> ---
    # This snippet should be copy/pastable into standalone scripts
    #
    # Expects Variables:
    #   URL=
    #   EXPECTED_HASH=
    #   DST=
    #   HASHER=
    #   CURL_OPTS=
    echo "${EXPECTED_HASH}  $DST" > "$DST.$HASHER"

    if ! test -f "$DST" ; then
        echo "Downloading $URL to $DST"
        # shellcheck disable=SC2086
        curl $CURL_OPTS "$URL" -o "$DST"
    else
        echo "Already downloaded $DST"
        if $HASHER --status -c "$DST.$HASHER"; then
            echo "Hash is valid"
            return 0
        else
            echo "WARNING: Data exists, but hash is INVALID! Redownloading"
            # shellcheck disable=SC2086
            curl $CURL_OPTS "$URL" -o "$DST"
        fi
    fi

    if $HASHER --status -c "$DST.$HASHER"; then
        echo "Hash is valid"
    else
        echo "ERROR: Hash is INVALID!"
        echo "GOT hash:"
        $HASHER "$DST"
        echo "Wanted hash:"
        cat "$DST.$HASHER"
        return 1
    fi
    # -- </BODY> ---
}


_harden_one_symlink(){
    __doc__="
    Replaces a symlink with a real file
    "
    LINK_FPATH=$1
    [ -L "${LINK_FPATH}" ] && [ -e "${LINK_FPATH}" ] && cp -L "${LINK_FPATH}" "${LINK_FPATH}".tmp && mv "${LINK_FPATH}".tmp "${LINK_FPATH}"

}

harden_symlink(){
    __doc__="
    Replaces symlinks with a real file

    harden_symlink *.pt
    "
    for var in "$@"
    do
        _harden_one_symlink "$var"
    done
}


joinby(){
    __doc__='
    A function that works similar to a Python join

    Args:
        SEP: the separator
        *ARR: elements of the strings to join

    Usage:
        source $HOME/local/init/utils.sh
        ARR=("foo" "bar" "baz")
        RESULT=$(joinby / "${ARR[@]}")
        echo "RESULT = $RESULT"

        RESULT = foo/bar/baz

    References:
        https://stackoverflow.com/questions/1527049/how-can-i-join-elements-of-an-array-in-bash
    '
    _handle_help "$@" || return 0
    local d=${1-} f=${2-}
    if shift 2; then
        printf %s "$f" "${@/#/$d}"
    fi
}


tmux_spawn(){
    __doc__='''
    Run a command in a new tmux session as a background process

    Example:
        source ~/local/init/utils.sh
        tmux_spawn echo "hi"

    References:
        https://serverfault.com/questions/103359/how-to-create-a-uuid-in-bash
    '''
    _handle_help "$@" || return 0
    UUID=$(cat /proc/sys/kernel/random/uuid)
    SESSION_ID=$UUID
    COMMAND=$(joinby " " "$@")
    tmux new-session -d -s "$SESSION_ID" "bash"
    tmux send -t "$SESSION_ID" "$COMMAND" Enter
    echo "SESSION_ID = $SESSION_ID"
}


is_probably_decrypted(){
    __doc__='
    Check if the file exists and is probably decrypted

    Example:
        FPATH=$HOME/local/init/utils.sh
        is_probably_decrypted $FPATH
        echo $?
        is_probably_decrypted does-not-exist
        echo $?
    '
    FPATH=$1
	if [[ ! -e $FPATH ]]; then
		echo "False"
        return 2
    else
        # check if the first line contains "Salted" in base64
        # (indicative of openssl encryption)
        firstbytes=$(head -c8 "$FPATH" | LC_ALL=C tr -d '\0')
        if [[ $firstbytes == "U2FsdGVk" ]]; then
            echo "False"
            return 1
        else
            echo "True"
            return 0
        fi
    fi
}

ls_array(){
    __doc__='
    Read the results of a glob pattern into an array

    Args:
        arr_name : an out variable, an array with this name will be defined
        glob_pattern : a quoted glob pattern (to prevent immediate expansion)

    Example:
        arr_name="my_array"
        glob_pattern="*"
        pass
        bash_array_repr "${array[@]}"
        mkdir -p $HOME/tmp/tests/test_ls_arr
        cd $HOME/tmp/tests/test_ls_arr
        touch "$HOME/tmp/tests/test_ls_arr/path ological files"
        touch "$HOME/tmp/tests/test_ls_arr/are so fun"
        touch "$HOME/tmp/tests/test_ls_arr/foo"
        touch "$HOME/tmp/tests/test_ls_arr/bar"
        touch "$HOME/tmp/tests/test_ls_arr/baz"
        touch "$HOME/tmp/tests/test_ls_arr/biz"
        touch "$HOME/tmp/tests/test_ls_arr/fake_newline\n in fils? YES!"
        python -c "import ubelt; ubelt.Path(\"$HOME/tmp/tests/test_ls_arr/Real newline \n in fname\").expand().touch()"
        python -c "import ubelt; ubelt.Path(\"$HOME/tmp/tests/test_ls_arr/Realnewline\ninfname\").expand().touch()"

        arr_name="my_array"
        glob_pattern="*"
        ls_array "$arr_name" "$glob_pattern"
        echo "arr size: ${#my_array[@]}"
        bash_array_repr "${my_array[@]}"

        arr_name="my_empty_array"
        glob_pattern="*doesnotmatch"
        ls_array "$arr_name" "$glob_pattern"
        echo "arr size: ${#my_empty_array[@]}"
        bash_array_repr "${my_empty_array[@]}"

    Dependency Free Usage:

        # This function is not super easy to use without dependencies, but it
        # can be done. We force setting of the values here which is a bit more
        # work but also more concise.

        # ENTER CONTEXT (ensure nullglob is off and nullglob is on)
        _restore_nullglob=$(shopt -p "nullglob")
        _restore_noglob=$(test -o noglob && echo "set -o noglob")
        set +o noglob
        shopt -s "nullglob"

        # YOUR COMMANDS HERE
        my_array=(*)

        # EXIT CONTEXT (restore settings)
        eval "$_restore_nullglob"
        eval "$_restore_noglob"

        # Rest of your code
        echo "array size: ${#my_array[@]}"
        for item in "${my_array[@]}"
        do
            echo "item = $item"
        done

    Alternatives:
        my_array=()
        while IFS= read -r item; do
            my_array+=("$item")
            echo "item = $item"
        done < <(find . -maxdepth 1 -mindepth 1)
        bash_array_repr "${my_array[@]}"

    References:
        .. [1] https://stackoverflow.com/a/18887210/887074
        .. [2] https://stackoverflow.com/questions/14564746/in-bash-how-to-get-the-current-status-of-set-x
        .. [ShoptGist] https://gist.github.com/detain/dfa0e4d75647b424c5aea45a34af0713

    TODO:
        get the echo of shopt off
    '
    _handle_help "$@" || return 0
    local arr_name="$1"
    local glob_pattern="$2"

    local toggle_noglob=""
    local toggle_nullglob=""
    # Can check the "$-" variable to see what current settings are i.e. set -x, set -e
    # Can check "set -o" to get currentenabled options
    # Can check "shopt" to get current enabled options

    if shopt nullglob > /dev/null; then
        # Check if null glob is enabled, if it is, this will be true
        toggle_nullglob=0
    else
        toggle_nullglob=1
    fi
    # Check for -f to see if noglob is enabled
    # The "$-" variable contains characters indicating options.
    # The f corresponds to if noglob was set.
    if [[ -n "${-//[^f]/}" ]]; then
        # Could also do
        #set +o noglob  # enable noglob
        #test -o noglob; echo $?
        #set -o noglob  # enable noglob
        #test -o noglob; echo $?
        toggle_noglob=1
    else
        toggle_noglob=0
    fi

    if [[ "$toggle_noglob" == "1" ]]; then
        # If noglob was on, turn it off to enable glob expansion.
        set +o noglob  # disable noglob
    fi
    if [[ "$toggle_nullglob" == "1" ]]; then
        # If nullglob was off, turn it on, so no matches return empty
        shopt -s nullglob  # enable nullglob
    fi

    # We have ensure nullglob and noglob are enabled
    # shellcheck disable=SC2206
    array=($glob_pattern)

    # Restore state
    if [[ "$toggle_noglob" == "1" ]]; then
        # If we enabled noglob, then we need to turn it off again
        # (typically it is already on)
        set -o noglob  # re-enable noglob
    fi
    if [[ "$toggle_nullglob" == "1" ]]; then
        # If we enabled nullglob, then we should disable it again
        # typically this does happen because nullglob is off by default
        shopt -u nullglob  # disable nullglob
    fi

    if [ "${#array[@]}" -gt 1 ]; then
        # If there are matches, copy the array into the dynamically named
        # variable
        readarray -t "$arr_name" < <(printf '%s\n' "${array[@]}")
    else
        # Otherwise, the above code doesnt handle empty arrays well so just
        # explicitly define the empty array.
        declare -a "$arr_name"='()'
    fi
}


string_contains() {
    __doc__='
    Check the string in argument 1 contains the string in argument 2.

    Args:
        string : the string to search
        *args : test if the string contains any of these

    Returns:
        0 if any of the args are contained in the string, otherwise 1

    Example:
        string_contains "abcd" "ab"
        echo $?
        string_contains "abcd" "baz"
        echo $?
        string_contains "abcd" "baz"  "biz" "a"
        echo $?
    '
    _handle_help "$@" || return 0
	string=$1
    shift
    args=("$@")
    for arg in "${args[@]}"
    do
        (echo "$string" | grep -qF "$arg") && return 0
    done
    return 1
}

rich_confirm() {
    __doc__='
    Use the rich library to get a nice looking prompt

    Args:
        MESSAGE: the confirm message

    Returns:
        0 on yes and 1 on no

    Example:
        source ~/local/init/utils.sh
        rich_confirm "do a thing?"
        echo "$?"
    '
    MESSAGE=$1
    _PYEXE=$(system_python)
    $_PYEXE -c "import sys, rich.prompt; sys.exit(0 if rich.prompt.Confirm.ask('$MESSAGE') else 1)"
    return $?
}

rich_link(){
    __doc__='
    Use the rich library to make a clickable link

    Example:
        source ~/local/init/utils.sh
        DESC=Link
        PATH=$HOME
        rich_link $HOME
        rich_link $HOME Home
    '
    local _PATH=$1
    local _DESC=${2:-Link}
    python -c "if 1:
        import rich
        path='$_PATH'
        desc='$_DESC'
        rich.print(f'{desc}: [link={path}]{path}[/link]')
    "
}


#Ignore:
#python -c "import rich; rich.print('[link=/home]/home[/link]')"


remove_empty_dirs(){
    __doc__='
    Remove empty directories recursively

    ARGS:
        DPATH : defaults to .

    References:
        https://www.cyberciti.biz/faq/howto-find-delete-empty-directories-files-in-unix-linux/
    '
    _handle_help "$@" || return 0
    local DPATH="${1:-.}"
    find "$DPATH" -empty -type d -delete
}


is_reboot_required(){
    __doc__="
    Check to see if a reboot is needed.
    Prints a message to the screen.

    Returns:
        0 if yes else 1

    References:
        https://www.cyberciti.biz/faq/how-to-find-out-if-my-ubuntudebian-linux-server-needs-a-reboot/
        https://askubuntu.com/questions/1337713/what-creates-the-file-var-run-reboot-required
    "
    if test -f /var/run/reboot-required; then
        cat /var/run/reboot-required
        return 0
    else
        echo "** OK: No reboot needed **"
        return 1
    fi
}
