# simple function that does nothing so we can write simple heredocs
# we cant use it here though, otherwise it would infinite recurse!
# Use it like this (sans leading comment symbols):
__doc__='
this is where your text goes. It can be multiline and indented, just dont
include the single quote character.  also note the surrounding triple
quotes just happen to be synatically correct and are not necessary,
although I do recomend them.

Usage:
    source $HOME/local/init/utils.sh

'
if [ "$__SOURCED_EROTEMIC_UTILS__" = "1" ]; then
   return
fi
__SOURCED_EROTEMIC_UTILS__=1


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

    Example:
        HAVE_SUDO=$(have_sudo)
        if [ "$HAVE_SUDO" == "True" ]; then
            sudo do stuff
        else
            we dont have sudo
        fi
    '
    _PYEXE=$(system_python)
    $_PYEXE -c "$(codeblock "
        import grp, pwd 
        user = '$(whoami)'
        groups = [g.gr_name for g in grp.getgrall() if user in g.gr_mem]
        gid = pwd.getpwnam(user).pw_gid
        groups.append(grp.getgrgid(gid).gr_name)
        print('sudo' in groups)
    ")"
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
    #$PYEXE -c "$(codeblock "
    #    try:
    #        import $PYMOD
    #        print(True)
    #    except ImportError:
    #        print(False)
    #")"
}

pyblock(){
    __doc__='
    Executes python code and handles nice indentation.  Need to be slightly
    careful about the type of quotes used.  Typically stick to doublequotes
    around the code and singlequotes inside python code. Sometimes it will be
    necessary to escape some characters.

    Usage:
       pyblock [PYEXE] TEXT [ARGS...]

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

        OUTPUT = /home/joncrall/venv3.6/bin/python

        OUTPUT=$(pyblock pypy "
            import sys
            print(sys.executable)
        ")
        echo "OUTPUT = $OUTPUT"

        OUTPUT = /usr/bin/pypy
    '
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

    $PYEXE -c "$(codeblock "$TEXT")" $@
}


codeblock()
{
    if [ "-h" == "$1" ] || [ "--help" == "$1" ]; then 
        # Use codeblock to show the usage of codeblock, so you can use
        # codeblock while you codeblock.
        echo "$(codeblock '
            Unindents code before its executed so you can maintain a pretty
            indentation in your code file. Multiline strings simply begin  
            with 
                "$(codeblock "
            and end with 
                ")"

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
        ')"
    else
        # Prevents python indentation errors in bash
        #python -c "from textwrap import dedent; print(dedent('$1').strip('\n'))"
        PYEXE=$(system_python)
        echo "$1" | $PYEXE -c "import sys; from textwrap import dedent; print(dedent(sys.stdin.read()).strip('\n'))"
    fi
}


writeto()
{
    __doc__="
    Usage:
        writeto <fpath> <text>

    Example:
        writeto some-file.txt '
            # Text in this command is automatically dedented via codeblock
            option=True
            variable=False
            '
    "
    fpath=$1
    text=$2
    fixed_text=$(codeblock "$text")
    sh -c "echo \"$fixed_text\" > $fpath"
}


sudo_writeto()
{
    __doc__="

    Usage:
        sudo_writeto <fpath> <text>

    Example:
        sudo_writeto /root-file '
            # Text in this command is automatically dedented via codeblock
            option=True
            variable=False
            '
    "

    # NOTE: FAILS WITH QUOTES IN BODY
    fpath=$1
    text=$2
    fixed_text=$(codeblock "$text")
    # IS THERE A BETTER WAY TO FORWARD AN ENV TO SUDO SO sudo writeto works
    sudo sh -c "echo \"$fixed_text\" > $fpath"
#    # Maybe this?
#    sudo sh -c "cat > ${fpath} << EOF
#${fixed_text}
#"
}

sudo_appendto()
{
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
    fpath=$1
    text=$2
    fixed_text=$(codeblock "$text")
    # Apppend the text only if it doesn't exist
    found="$(grep -F "$fixed_text" "$fpath")"
    if [ "$found" == "" ]; then
        sh -c "echo \"$fixed_text\" >> $fpath"
    fi
}

# Can we wrap sudo such we can allow utils to be used?
#util_sudo(){
#    echo "$@"
#    #sudo bash -c "source $HOME/local/init/utils.sh; $@"
#}


safe_symlink(){
    __doc__="
    Args:
        real_path
        link_path
    "
    real_path=$1
    link_path=$2
    echo "Safe symlink $real_path -> $link_path"
    unlink_or_backup ${link_path}
    ln -s "${real_path}" "${link_path}"
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

    TARGET=$1
    if [ -L $TARGET ]; then
        # remove any previouly existing link
        unlink $TARGET
    elif [ -f $TARGET ] || [ -d $TARGET ] ; then
        # backup any existing file or directory
        mv $TARGET $TARGET."$(date +"%T")".old
    fi
}


apt_ensure(){
    __doc__="
    Checks to see if the pacakges are installed and installs them if needed.

    The main reason to use this over normal apt install is that it avoids sudo
    if we already have all requested packages.

    Args:
        *ARGS : one or more requested packages 

    Example:
        apt_ensure git curl htop 

    Ignore:
        REQUESTED_PKGS=(git curl htop) 
    "
    # Note the $@ is not actually an array, but we can convert it to one
    # https://linuxize.com/post/bash-functions/#passing-arguments-to-bash-functions
    ARGS=("$@")
    MISS_PKGS=()
    HIT_PKGS=()
    for PKG_NAME in ${ARGS[@]}
    do
        #apt_ensure_single $EXE_NAME
        RESULT=$(dpkg -l "$PKG_NAME" | grep "^ii *$PKG_NAME")
        if [ "$RESULT" == "" ]; then 
            echo "Do not have PKG_NAME='$PKG_NAME'"
            MISS_PKGS=(${MISS_PKGS[@]} "$PKG_NAME")
        else
            echo "Already have PKG_NAME='$PKG_NAME'"
            HIT_PKGS=(${HIT_PKGS[@]} "$PKG_NAME")
        fi
    done

    if [ "${#MISS_PKGS}" -gt 0 ]; then
        sudo apt install -y "${MISS_PKGS[@]}"
    else
        echo "No missing packages"
    fi
}

compress_path(){
    __doc__="
    Replace explicit home dir with tilde

    References:
        https://stackoverflow.com/questions/10036255/is-there-a-good-way-to-replace-home-directory-with-tilde-in-bash

    Example:
        compress_path $HOME/hello
        compress_path /hello
    "
    local name=$1
    if [[ "$name" =~ ^"$HOME"(/|$) ]]; then
        name="~${name#$HOME}"
        echo $name
    fi
    echo $name
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
        __SOURCED_EROTEMIC_UTILS__=0
        source $HOME/local/init/utils.sh
        exthist /bin /etc -r
        exthist $HOME
    "
    local RECURSIVE=""
    local DPATH_LIST=()
    local DPATH=""
    local SUB_DPATH=""
    while [[ $# -gt 0 ]]
    do
        local key="$1"
        case $key in
            -r|--recursive)
            RECURSIVE=True
            shift # past argument
            ;;
            *)    # unknown option
            echo $1
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

    for DPATH in "${DPATH_LIST[@]}"; do
        if [ "$RECURSIVE" == "True" ]; then
            # TODO: could pass more arguments to find to restrict recursion
            local FIND_RESULT=$(find $DPATH -type d)
            for SUB_DPATH in $FIND_RESULT; do
                echo "SUB_DPATH=$SUB_DPATH"
                find $SUB_DPATH -maxdepth 1 -xtype f  | rev | cut -d. -f1 | cut -d/ -f1 | rev  | tr '[:upper:]' '[:lower:]' | sort | uniq --count | sort -rn
            done
        else
            echo "DPATH=$DPATH"
            # Logic is
            # reverse the string, 
            # remove everything after the "first" . and / 
            # reverse again (aka we got everything after the last . or /)
            # convert to lowercase
            # sort, unique, and count
            find $DPATH -maxdepth 1 -xtype f  | rev | cut -d. -f1 | cut -d/ -f1 | rev  | tr '[:upper:]' '[:lower:]' | sort | uniq --count | sort -rn
        fi
    done 
}


bash_array_repr(){
    __doc__='
    Given a bash array, this should print a literal copy-pastable
    representation

    Example:
        ARR=(1 "2 3" 4)
        bash_array_repr "${ARR[@]}"
    '
    ARGS=("$@")
    if [ "${#ARGS}" -gt 0 ]; then
        # Not sure if the double or single quotes is better here
        echo "($(printf "'%s' " "${ARGS[@]}"))"
        #echo "($(printf "\'%s\' " "${ARGS[@]}"))"
    else
        echo "()"
    fi
}


#recursive_ext_hist(){
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
