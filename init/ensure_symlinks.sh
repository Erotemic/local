
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


ensure_config_symlinks()
{
    __heredoc__ '''
    CommandLine:
        source ~/local/init/ensure_symlinks.sh && ensure_config_symlinks
    '''

    HAVE_SUDO=$(have_sudo)

    if [ "$(which symlinks)" == "" ]; then
        # Program to remove dead symlinks
        if [ "$HAVE_SUDO" == "True" ]; then 
            sudo apt-get install symlinks -y
        fi
        if [ "$(which symlinks)" == "" ]; then
            # bypass symlinks
            alias symlinks=echo "bypass symlinks not installed"
        fi
    fi

    # TODO: make symbolic links relative to the home directory

    echo "==============================="
    echo "STARTING ensure_config_symlinks"
    echo "==============================="


    # Try to link relative to home
    cd $HOME
    #RELHOME="~"

    # If that doesnt work use absolute home link
    RELHOME="$HOME"
    
    HOMELINKS=$RELHOME/local/homelinks

    # Symlink all homelinks dotfiles 
    #================
    BASEDIR="dotfiles"
    # NOTE: these path names are files
    PNAMES=$(/bin/ls -Ap $HOMELINKS/$BASEDIR | grep -v /)
    echo "* SYMLINK BASEDIR=$BASEDIR"
    #echo "* PNAMES=$PNAMES"
    echo "* --- BEGIN ---"
    echo "* cleanup"
    symlinks -d $RELHOME
    echo "* symlink"
    for p in $PNAMES; do 
        SOURCE=$HOMELINKS/$BASEDIR/$p
        TARGET=$RELHOME/.$p
        unlink_or_backup $TARGET
        ln -vs $SOURCE $TARGET;
    done
    echo "* Convert to relative symlinks"
    symlinks -c $RELHOME/.$BASEDIR
    echo "* --- END ---"
    #================

    # Symlink nautlius scripts
    #================
    BASEDIR="gnome2/nautilus-scripts"
    # NOTE: these path names are files
    PNAMES=$(/bin/ls -Ap $HOMELINKS/$BASEDIR | grep -v /)
    echo "* SYMLINK BASEDIR=$BASEDIR"
    #echo "* PNAMES=$PNAMES"
    echo "* --- BEGIN ---"
    echo "* mkdir"
    mkdir -pv $RELHOME/.$BASEDIR
    echo "* cleanup"
    symlinks -d $RELHOME/.$BASEDIR
    echo "* symlink"
    for p in $PNAMES; do 
        SOURCE=$HOMELINKS/$BASEDIR/$p
        TARGET=$RELHOME/.$BASEDIR/$p
        unlink_or_backup $TARGET
        ln -vs $SOURCE $TARGET;
    done
    echo "* Convert to relative symlinks"
    symlinks -c $RELHOME/.$BASEDIR
    echo "* --- END ---"
    #================

    # Symlink config subdirs (note these are directories)
    #================
    BASEDIR="config"
    # NOTE: these path names are directories
    PNAMES=$(/bin/ls -A $HOMELINKS/$BASEDIR)
    echo "* SYMLINK BASEDIR=$BASEDIR"
    #echo "* PNAMES=$PNAMES"
    echo "* --- BEGIN ---"
    echo "* mkdir"
    mkdir -pv $RELHOME/.$BASEDIR
    echo "* cleanup"
    symlinks -d $RELHOME/.$BASEDIR
    echo "* symlink"
    for p in $PNAMES; do 
        SOURCE=$HOMELINKS/$BASEDIR/$p
        TARGET=$RELHOME/.$BASEDIR/$p
        unlink_or_backup $TARGET
        ln -vs $SOURCE $TARGET;
    done
    echo "* Convert to relative symlinks"
    symlinks -c $RELHOME/.$BASEDIR
    echo "* --- END ---"
    #================

    # Extras

    if [ ! -L ~/.vim ]; then
        ln -s ~/local/vim/vimfiles ~/.vim
        symlinks -c ~
        symlinks -d ~/.vim/
        mkdir -p ~/local/vim/vimfiles/files/info
    fi
    if [ -d ~/scripts ]; then
        unlink ~/scripts
    fi
    ln -s ~/local/scripts ~/scripts
    

    echo "==============================="
    echo "FINISHED ensure_config_symlinks"
    echo "==============================="
}

