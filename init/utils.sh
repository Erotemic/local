__heredoc__(){
    # simple function that does nothing so we can write simple heredocs
    # we cant use it here though, otherwise it would infinite recurse!
    # Use it like this (sans leading comment symbols):
    # __heredoc__ '''
    # this is where your text goes. It can be multiline and indented, just dont
    # include the single quote character.  also note the surrounding triple
    # quotes just happen to be synatically correct and are not necessary,
    # although I do recomend them.
    # '''
    if [ "$noop" == "defined for some reason" ]
    then
        echo Why did you define noop to that particular value? Were you looking to see this message?
        echo I really wish other languages would add python triple quotes. they are exceptionally convenient.
    fi
}


unlink_or_backup()
{
    __heredoc__ '''
    Get a file or directory out of the way without removing it.

    If TARGET exists, it is removed if it is a link, otherwise if it is a file or
    directory it renames it based on a the current time. If it doesnt exist
    nothing happens.

    TODO:
        move to a bash utils file

    Args:
        TARGET (str): a path to a directory, link, or file
    ''' 

    TARGET=$1
    if [ -L $TARGET ]; then
        # remove any previouly existing link
        unlink $TARGET
    elif [ -f $TARGET ] || [ -d $TARGET ] ; then
        # backup any existing file or directory
        mv $TARGET $TARGET."$(date +"%T")".old
    fi
}


have_sudo(){
    __heredoc__ '''
    Tests if we have the ability to use sudo.
    Returns the string "True" if we do.

    TODO:
        move to a bash utils file

    Example:
        HAVE_SUDO=$(have_sudo)
        if [ "$HAVE_SUDO" == "True" ]; then
            sudo do stuff
        else
            we dont have sudo
        fi
    '''

    python -c "$(codeblock "
        import grp, pwd 
        user = '$(whoami)'
        groups = [g.gr_name for g in grp.getgrall() if user in g.gr_mem]
        gid = pwd.getpwnam(user).pw_gid
        groups.append(grp.getgrgid(gid).gr_name)
        print('sudo' in groups)
    ")"
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
        #python -c "from textwrap import dedent; print(dedent('''$1''').strip('\n'))"
        echo "$1" | python -c "import sys; from textwrap import dedent; print(dedent(sys.stdin.read()).strip('\n'))"
    fi
}



writeto()
{
    fpath=$1
    text=$2
    fixed_text=$(codeblock "$text")
    sh -c "echo \"$fixed_text\" > $fpath"
}


sudo_writeto()
{
    fpath=$1
    text=$2
    fixed_text=$(codeblock "$text")
    # IS THERE A BETTER WAY TO FORWARD AN ENV TO SUDO SO sudo writeto works
    sudo sh -c "echo \"$fixed_text\" > $fpath"
}

sudo_appendto()
{
    fpath=$1
    text=$2
    fixed_text=$(codeblock "$text")
    # IS THERE A BETTER WAY TO FORWARD AN ENV TO SUDO SO sudo writeto works
    sudo sh -c "echo \"$fixed_text\" >> $fpath"
}

# Can we wrap sudo such we can allow utils to be used?
#util_sudo(){
#    echo "$@"
#    #sudo bash -c "source $HOME/local/init/utils.sh; $@"
#}
