# simple function that does nothing so we can write simple heredocs
# we cant use it here though, otherwise it would infinitely recurse!
# Use it like this (sans leading comment symbols):
__doc__='
this is where your text goes. It can be multiline and indented, just dont
include the single quote character.  Also note the surrounding triple
quotes just happen to be syntactically correct and are not necessary,
although I do recommend them.

TODO:
    - [ ] Refeactor into a standalone bash library
    - [ ] Provide an easy and secure installation mechanism
    - [ ] Provide an easy and secure update mechanism
    - [ ] Write high-level documentation

Usage:
    source $HOME/local/init/utils.sh
'

# set to 0 to prevent this script from running more than once
# set to 1 for editable "development" mode
__EROTEMIC_ALWAYS_RELOAD__="${__EROTEMIC_ALWAYS_RELOAD__:=0}"
__EROTEMIC_UTILS_VERSION__="0.1.2"

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

        _handle_help $@ || return 
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
    _handle_help $@ || return 0
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


_simple_codeblock()
{
    __doc__='
    copy-pastable implementation
    Prevents indentation errors in bash
    '
    PYEXE=python
    echo "$1" | $PYEXE -c "import sys; from textwrap import dedent; print(dedent(sys.stdin.read()).strip('\n'))"
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
    _handle_help $@ || return 0
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
    _handle_help $@ || return 0

    # NOTE: FAILS WITH QUOTES IN BODY
    fpath=$1
    text=$2
    fixed_text=$(codeblock "$text")
    echo "fpath = $fpath"
    echo "text = $text"
    echo "fixed_text = $fixed_text"
    # IS THERE A BETTER WAY TO FORWARD AN ENV TO SUDO SO sudo writeto works
    sudo sh -c "echo \"$fixed_text\" > $fpath"
#    # Maybe this?
#    sudo sh -c "cat > ${fpath} << EOF
#${fixed_text}
#"
}

sudo_appendto()
{
    _handle_help $@ || return 0
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
    _handle_help $@ || return 0
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
    _handle_help $@ || return 0
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
        safe_symlink real_file link_file
        safe_symlink real_dir link_dir
        ls -al
    "
    _handle_help $@ || return 0
    real_path=$1
    link_path=$2
    echo "Safe symlink $link_path -> $real_path"
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
    _handle_help $@ || return 0

    TARGET=$1
    if [ -L $TARGET ]; then
        # remove any previouly existing link
        unlink $TARGET
    elif [ -f $TARGET ] || [ -d $TARGET ] ; then
        # backup any existing file or directory
        mv $TARGET $TARGET."$(date --iso-8601=seconds)".old
    fi
}


apt_ensure(){
    __doc__="
    Checks to see if the packages are installed and installs them if needed.

    The main reason to use this over normal apt install is that it avoids sudo
    if we already have all requested packages.

    Args:
        *ARGS : one or more requested packages 

    Example:
        apt_ensure git curl htop 

    Ignore:
        REQUESTED_PKGS=(git curl htop) 
    "
    _handle_help $@ || return 0
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
    RED_CODE="$?"
    if [[ $RET_CODE -eq 0 ]]; then
        echo "replacing: $FILEPATH"
        sed "s|${SEARCH}|${REPLACE}|gp" $FILEPATH > $FILEPATH.sedr.tmp
        diff -u $FILEPATH.sedr.tmp $FILEPATH | colordiff
        rm $FILEPATH.sedr.tmp
    fi
}
# Needs to be global for find
export -f sedfile


sedr(){
    __doc__="""
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
        
    """
    _handle_help $@ || return 0

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
    _handle_help $@ || return 0

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

    #echo "
    #* RECURSIVE = $RECURSIVE
    #* DPATH_LIST = $DPATH_LIST
    #* IGNORE_HIDDEN = $IGNORE_HIDDEN
    #"

    local DPATH=""
    local SUB_DPATH=""
    #DPATH=""
    #SUB_DPATH=""
    for DPATH in "${DPATH_LIST[@]}"; do
        if [ "$RECURSIVE" == "True" ]; then
            # TODO: could pass more arguments to find to restrict recursion
            if [ "$IGNORE_HIDDEN" == "1" ]; then
                # trouble with bash, reading find into arrays. Is there a better way?
                ALL_SUBDIRS=()
                while IFS=  read -r -d $'\0'; do
                    ALL_SUBDIRS+=("$REPLY")
                done < <(find $DPATH -xtype d -not -path '*/\.*' -print0)

            else
                #ALL_SUBDIRS="$(find $DPATH)"
                ALL_SUBDIRS=()
                while IFS=  read -r -d $'\0'; do
                    ALL_SUBDIRS+=("$REPLY")
                done < <(find $DPATH -xtype d -print0 )
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
            find $DPATH -maxdepth 1 -xtype f | rev | cut -d. -f1 | cut -d/ -f1 | rev  | tr '[:upper:]' '[:lower:]' | sort | uniq --count | sort -rn
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

    TODO:
        - [ ] Add to erotemic.utils

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
    _handle_help $@ || return 0

    ARGS=("$@")
    if [ "${#ARGS}" -gt 0 ]; then
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
        URL="https://golang.org/dl/go1.17.linux-amd64.tar.gz"
        BASENAME=$(basename $URL)
        curl_verify_hash $URL $BASENAME "6bf89fc4f5ad763871cf7eac80a2d594492de7a818303283f1366a7f6a30372d" "sha256sum" " -L"
        
    '
    _handle_help $@ || return 0

    local URL=${1:-${URL:-""}}
    local DEFAULT_DST=$(basename $URL)
    local DST=${2:-${DST:-$DEFAULT_DST}}
    local EXPECTED_HASH=${3:-${EXPECTED_HASH:-'*'}}
    local HASHER=${4:-sha256sum}
    local CURL_OPTS=${5:-"${CURL_OPTS}"}
    local VERBOSE=${6:-${VERBOSE:-"3"}}

    python -c "import sys; sys.exit(0 if ('$HASHER' in {'sha256sum', 'sha512sum'}) else 1)"

    if [ $? -ne 0 ]; then
        echo "HASHER = $HASHER is not in the known list"
        return 1
    fi

    if [ $VERBOSE -ge 3 ]; then
        codeblock "
            curl_verify_hash
                * URL='$URL'
                * DST='$DST'
                * CURL_OPTS='$CURL_OPTS'
            "
    fi

    # Download the file
    curl $CURL_OPTS "$URL" --output "$DST"

    # Verify the hash
    verify_hash $DST $EXPECTED_HASH $HASHER $VERBOSE
    return $?
}

verify_hash(){
    __doc__='
    Verifies the hash of a file

    Example:
        FPATH="$(which ls)"
        EXPECTED_HASH=4ef89baf437effd684a125da35674dc6147ef2e34b76d11ea0837b543b60352f
        __EROTEMIC_ALWAYS_RELOAD__=1
        source $HOME/local/init/utils.sh
        verify_hash $FPATH $EXPECTED_HASH
    '
    _handle_help $@ || return 0

    local FPATH=${1:-${FPATH:-"Unspecified"}}
    local EXPECTED_HASH=${2:-${EXPECTED_HASH:-'*'}}
    local HASHER=${3:-sha256sum}
    local VERBOSE=${4:-${VERBOSE:-"3"}}

    python -c "import sys; sys.exit(0 if ('$HASHER' in {'sha256sum', 'sha512sum'}) else 1)"

    if [ $? -ne 0 ]; then
        echo "HASHER = $HASHER is not in the known list"
        return 1
    fi

    # Get the hash
    local GOT_HASH=$($HASHER $FPATH | cut -d' ' -f1)
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
        if [ $VERBOSE -ge 1 ]; then
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


escape_bash_string(){
    __doc__='
    Escapes the input string so the program that it is passed to sees exactly
    the given input string.

    Args:
        The string to escape

    Returns:
        The escaped string

    Example:
        __EROTEMIC_ALWAYS_RELOAD__=1
        source $HOME/local/init/utils.sh
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
