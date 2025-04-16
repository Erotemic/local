#!/usr/bin/env bash
source "$HOME"/local/init/utils.sh

if [[ ${BASH_SOURCE[0]} == "$0" ]]; then
	# Running as a script
	set -eo pipefail
fi

ensure_config_symlinks()
{
    _doc__='
    CommandLine:
        ~/local/init/ensure_symlinks.sh
        ~/local/init/ensure_symlinks.sh --nosudo
    '

    HAVE_SUDO=${HAVE_SUDO:=$(have_sudo)}
    echo "HAVE_SUDO = $HAVE_SUDO"
    NOSUDO=$1

    if [ "$(which symlinks)" == "" ] && [ "$NOSUDO" != "--nosudo" ]; then
        # Program to remove dead symlinks
        if [ "$HAVE_SUDO" == "True" ]; then
            sudo apt-get install symlinks -y
        fi
        if [ "$(which symlinks)" == "" ]; then
            # bypass symlinks
            symlinks(){
                echo "bypass symlinks not installed"
            }
        fi
    fi

    # TODO: make symbolic links relative to the home directory

    echo "==============================="
    echo "STARTING ensure_config_symlinks"
    echo "==============================="


    # Try to link relative to home
    #cd "$HOME"
    #RELHOME="~"

    # If that doesnt work use absolute home link
    RELHOME="$HOME"
    HOMELINKS_DPATH=$RELHOME/local/homelinks

    echo "* cleanup"
    symlinks -d "$RELHOME"

    symlink_root_hidden_files "$HOMELINKS_DPATH" "$RELHOME"

    # Symlink config subdirs (note these are directories)
    BASEDIR="config"
    symlink_inside_hidden_homedir $BASEDIR "$HOMELINKS_DPATH" "$RELHOME"

    # Symlink nautlius scripts
    BASEDIR="gnome2/nautilus-scripts"
    symlink_inside_hidden_homedir $BASEDIR "$HOMELINKS_DPATH" "$RELHOME"

    # Extras
    echo "* --- START EXTRAS ---*"

    mkdir -p ~/local/vim/vimfiles/files/info
    safe_symlink ~/local/scripts ~/scripts
    safe_symlink ~/local/vim/vimfiles ~/.vim
    safe_symlink ~/local/vim/portable_vimrc ~/.vimrc
    safe_symlink ~/local/homelinks/ipython ~/.ipython
    #safe_symlink ~/code/vimtk ~/local/vim/vimfiles/bundle/vimtk


    #### DO EXTRA SYMLINK FIXES
    #echo "* --- START FIXES ---*"
    #symlinks -c $HOME
    #symlinks -cr $HOME/.local
    #symlinks -cr $HOME/code
    #symlinks -cr $HOME/local

    #symlinks -crt $HOME | grep -v work | grep -v venv3.6 | grep -v .config
    #ls -lR $HOME | grep ^l

    echo "==============================="
    echo "FINISHED ensure_config_symlinks"
    echo "==============================="
}


symlink_inside_hidden_homedir(){
    __doc__='
    This will symlink FILES inside a homelinks folder (e.g.  homelinks/<name>)
    into the corersponding hidden directory (e.g. ~/.<name>) in your home
    folder.

    This is used to link FILES between directories

        homelinks/config/* -> ~/.config/*
        homelinks/foobar/* -> ~/.foobar/*

    Args:
        BASEDIR (str): the homelink folder to symlink files from
    '

    # Symlink config subdirs (note these are directories)
    #================
    BASEDIR=$1
    HOMELINKS_DPATH=$2
    RELHOME=$3
    #"config"

    # NOTE: these path names are directories
    PNAMES=$(/bin/ls -A "$HOMELINKS_DPATH"/"$BASEDIR")
    echo "* SYMLINK BASEDIR=$BASEDIR"
    #echo "* PNAMES=$PNAMES"
    echo "* --- BEGIN ---"
    echo "* mkdir"
    mkdir -pv "$RELHOME"/."$BASEDIR"
    #echo "* cleanup"
    #symlinks -d "$RELHOME"/."$BASEDIR"
    echo "* symlink"
    for p in $PNAMES; do
        SOURCE=$HOMELINKS_DPATH/$BASEDIR/$p
        TARGET=$RELHOME/.$BASEDIR/$p
        unlink_or_backup "$TARGET"
        ln -vs "$SOURCE" "$TARGET";
    done
    echo "* Convert to relative symlinks"
    for p in $PNAMES; do
        TARGET=$RELHOME/.$BASEDIR/$p
        symlinks -c "$TARGET"
    done
    echo "* --- END ---"
    #================
}


symlink_root_hidden_files(){
    __doc__="
    Symlink files in homelinks/dotfiles/<name> directly to ~/.<name>
    "
    HOMELINKS_DPATH=$1
    RELHOME=$2

    # Symlink all homelinks dotfiles
    #================
    BASEDIR="dotfiles"
    # NOTE: these path names are files
    PNAMES=$(/bin/ls -Ap "$HOMELINKS_DPATH"/$BASEDIR | grep -v /)
    echo "* SYMLINK BASEDIR=$BASEDIR"
    echo "* PNAMES=$PNAMES"
    echo "* --- BEGIN ---"
    #echo "* cleanup"
    #symlinks -d "$RELHOME"
    echo "* symlink"
    for p in $PNAMES; do
        SOURCE=$HOMELINKS_DPATH/$BASEDIR/$p
        TARGET=$RELHOME/.$p
        unlink_or_backup "$TARGET"
        ln -vs "$SOURCE" "$TARGET";
    done

    echo "* Convert to relative symlinks"
    symlinks -c "$RELHOME"/.$BASEDIR
    echo "* --- END ---"
    #================
}

# bpkg convention
# https://github.com/bpkg/bpkg
if [[ ${BASH_SOURCE[0]} != "$0" ]]; then
    # We are sourcing the library
    #echo "Sourcing prepare_system as a library and environment"
    :  # noop
else
    for var in "$@"
    do
        if [[ "$var" == "--help" ]]; then
            echo "No help docs yet"
            echo "...exiting"
            exit 1
        fi
    done
    ensure_config_symlinks "${@}"
    exit $?
fi
