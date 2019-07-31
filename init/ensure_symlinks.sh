source $HOME/local/init/utils.sh

ensure_config_symlinks()
{
    __heredoc__ '''
    CommandLine:
        source ~/local/init/ensure_symlinks.sh && ensure_config_symlinks
        source ~/local/init/ensure_symlinks.sh && ensure_config_symlinks --nosudo
    '''

    HAVE_SUDO=$(have_sudo)
    NOSUDO=$1

    if [ "$(which symlinks)" = "" ] && ["$NOSUDO" != "--nosudo"]; then
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
    ln -s ~/local/vim/vimfiles/bundle/vimtk ~/code/vimtk


    #### DO EXTRA SYMLINK FIXES
    symlinks -c $HOME
    symlinks -cr $HOME/.local
    symlinks -cr $HOME/code
    symlinks -cr $HOME/local

    #symlinks -crt $HOME | grep -v work | grep -v venv3.6 | grep -v .config

    ls -lR $HOME | grep ^l

    echo "==============================="
    echo "FINISHED ensure_config_symlinks"
    echo "==============================="
}

