
ensure_config_symlinks()
{
    "
    CommandLine:
        source ~/local/init/ensure_symlinks.sh && ensure_config_symlinks
    "

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

    # Symlink all homelinks files 
    #================
    BASEDIR=""
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
        SOURCE=$HOMELINKS/$BASEDIR$p
        TARGET=$RELHOME/.$BASEDIR$p
        if [ -L $TARGET ]; then
            unlink $TARGET
        else
            mv $TARGET $TARGET."$(date +"%T")".old
        fi
        ln -vs $SOURCE $TARGET;
    done
    echo "* Convert to relative symlinks"
    symlinks -c $RELHOME/.$BASEDIR
    echo "* --- END ---"
    #================

    # Symlink nautlius scripts
    #================
    BASEDIR="gnome2/nautilus-scripts/"
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
        SOURCE=$HOMELINKS/$BASEDIR$p
        TARGET=$RELHOME/.$BASEDIR$p
        if [ -L $TARGET ]; then
            unlink $TARGET
        else
            mv $TARGET $TARGET."$(date +"%T")".old
        fi
        ln -vs $SOURCE $TARGET;
    done
    echo "* Convert to relative symlinks"
    symlinks -c $RELHOME/.$BASEDIR
    echo "* --- END ---"
    #================

    # Symlink config subdirs (note these are directories)
    #================
    BASEDIR="config/"
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
        SOURCE=$HOMELINKS/$BASEDIR$p
        TARGET=$RELHOME/.$BASEDIR$p
        if [ -L $TARGET ]; then
            unlink $TARGET
        else
            mv $TARGET $TARGET."$(date +"%T")".old
        fi
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

