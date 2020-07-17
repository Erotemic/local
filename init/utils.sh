# simple function that does nothing so we can write simple heredocs
# we cant use it here though, otherwise it would infinite recurse!
# Use it like this (sans leading comment symbols):
__heredoc__='
this is where your text goes. It can be multiline and indented, just dont
include the single quote character.  also note the surrounding triple
quotes just happen to be synatically correct and are not necessary,
although I do recomend them.

Usage:
    source $HOME/local/init/utils.sh

'
if [ "$__SOURCED_UTILS__" = "1" ]; then
   return
fi
__SOURCED_UTILS__=1


system_python(){
    __heredoc__="
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
    __heredoc__='
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
    __heredoc__='
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
    __heredoc__='
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
    __heredoc__='
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
    __heredoc__="

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
    __heredoc__="

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
    __heredoc__='
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
    __heredoc__="
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
    __heredoc__='
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
