#!/bin/bash
__heredoc__="""

Idenpotent script for initializing an ubuntu system

Dont put something in here that can't run twice efficiently.

CommandLine:
    sudo apt install git -y
    cd ~
    git clone https://github.com/Erotemic/local.git

    bash ~/local/init.sh

    or

    # Customize settings (if unset they will choose sensible defaults)
    HAVE_SUDO=False
    IS_HEADLESS=True
    WITH_SSH_KEYS=False

    HAVE_SUDO=True
    IS_HEADLESS=False

    source ~/local/init.sh
"""

if [[ "$(type -P python)" == "" ]]; then
    if [[ "$(type -P python3)" != "" ]]; then
        alias python=python3
    fi
fi

source $HOME/local/init/freshstart_ubuntu.sh
source $HOME/local/init/utils.sh

if [ "$HAVE_SUDO" == "" ]; then
    HAVE_SUDO=$(have_sudo)
fi
if [ "$IS_HEADLESS" == "" ]; then
    IS_HEADLESS=$(is_headless)
fi
if [ "$WITH_SSH_KEYS" == "" ]; then
    WITH_SSH_KEYS="True"  # doesnt do anything atm
fi

echo "IS_HEADLESS = $IS_HEADLESS"
echo "HAVE_SUDO = $HAVE_SUDO"


if [ "$HAVE_SUDO" == "True" ]; then
    apt_ensure git 
    apt_ensure gcc g++ build-essential 
    apt_ensure gfortran 
    apt_ensure curl 
    apt_ensure htop tmux tree 
    apt_ensure sshfs 
    apt_ensure astyle p7zip-full pgpgpg lm-sensors
else
    echo "We dont have sudo. Hopefully we wont need it"
fi


_GITUSER="$(git config --global user.name)"
if [ "$_GITUSER" == "" ]; then
  echo "ENSURE GIT CONFIG"
  # TODO: need to determine the right user.email depending on the system being set up
  set_global_git_config
  mkdir -p ~/tmp
  mkdir -p ~/code
fi

echo "ENSURE SYMLINKS"
# TODO: terminator doesnt configure to automatically use the joncrall profile
# in the terminator config. Why?
source ~/local/init/ensure_symlinks.sh 
ensure_config_symlinks

if [ "$IS_HEADLESS" == "False" ]; then
    if [ "$(type -P terminator)" == "" ]; then
        echo "ENSURE TERMINATOR"
            # Dont use buggy gtk2 version 
            # https://bugs.launchpad.net/ubuntu/+source/terminator/+bug/1568132
            sudo add-apt-repository ppa:gnome-terminator/nightly-gtk3 -y
            sudo apt update
            sudo apt install terminator -y
    fi
fi

if [ ! -d ~/.ssh ]; then
    echo "ENSURE SSH"
    mkdir -p ~/.ssh 
    chmod 700 ~/.ssh

    if [ ! -f ~/.ssh/authorized_keys ]; then
        touch ~/.ssh/authorized_keys
        chmod 640 ~/.ssh/authorized_keys
    fi 
    echo "TODO: YOU MUST MANUALLY SET UP YOUR KEYS"
fi

if [ ! -d ~/.local/conda ]; then
    echo "SETUP CONDA ENV"
    setup_conda_env

    pip install six ubelt xdoctest xinspect xdev
    pip install pyperclip psutil pep8 autopep8 flake8 pylint pytest
fi

# Unset the python alias we set earlier because now we should be in a conda env
if [ "$(alias | grep 'alias python=')" != "" ]; then
    unalias python
fi

source ~/.bashrc
deactivate_venv

PY_EXE="$(system_python)"


if [ "$HAVE_SUDO" == "True" ]; then
    apt_ensure python3-pip
    apt_ensure vim-gnome
    if [ ! -d ~/.local/share/vim ]; then
        if [ "$(type -P ctags)" = "" ]; then
            apt_ensure exuberant-ctags 
            apt_ensure libgtk-3-dev gnome-devel ncurses-dev build-essential libtinfo-dev
        fi
    fi

    # If you need to build from scratch
    #source ~/local/build_scripts/init_vim.sh
    #do_vim_build

    # Old code, no longer needed I think
    #python ~/local/init/ensure_vim_plugins.py 
fi


# 
source ~/local/vim/init_vim.sh
if [ ! -d ~/.vim/autoload/plug.vim ]; then
    curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
fi


#if [ "$HAVE_SUDO" == "True" ]; then
#    sudo apt install python3-pip
#    $PY_EXE -m pip install ubelt xdoctest xdev
#fi




if [[ "$IS_HEADLESS" == "False" ]]; then
    #apt_ensure redshift  # ubuntu has nightlight now
    apt_ensure caffeine vlc
    apt_ensure sshfs wmctrl xdotool xclip git astyle
    apt_ensure git curl htop tmux tree 
    apt_ensure gcc gcc g++ gfortran build-essential
    apt_ensure 7z p7zip-full
    apt_ensure gpg pgpgpg
    apt_ensure net-tools nmap
    apt_ensure sensors lm-sensors

    if [[ "$(type -P google-chrome)" == "" ]]; then
        install_chrome

        sudo apt-get install chrome-gnome-shell # for gnome shell extension integration
    fi
    if [ ! -e /snap/bin/spotify ]; then
        sudo snap install spotify
    fi
    if [[ "$(type -P veracrypt)" == "" ]]; then
        sudo add-apt-repository ppa:unit193/encryption -y
        sudo apt update
        sudo apt install veracrypt -y
    fi
    #if [[ "$(type -P zotero)" == "" ]]; then
    #    sh ~/local/build_scripts/install_zotero.sh
    #fi
fi


# TODO: setup ssh keys

# Clone all of my repos
# gg-clone
# developer setup my repos

# TODO: setup nvidia drivers on appropriate systems: see init_cuda 

# TODO: setup secrets and internal state

source ~/.bashrc


source $HOME/local/init/freshstart_ubuntu.sh
if [[ "" == "" ]]; then
    # 
    setup_single_use_ssh_keys

    # Or copy data from another machine
    # See setup_remote_ssh_keys
fi


if [[ "$IS_HEADLESS" == "False" ]]; then
    #install_transcrypt
    git clone https://github.com/Erotemic/transcrypt.git $HOME/code/transcrypt

    source $HOME/local/init/utils.sh
    mkdir -p $HOME/.local/bin
    safe_symlink $HOME/code/transcrypt/transcrypt $HOME/.local/bin/transcrypt

    echo "YOU WILL NEED TO INPUT PASSWORDS"
    # NOTE: if you have valid gitlab ssh keys, you can change to a git@ url
    git clone https://gitlab.com/Erotemic/erotemic.git $HOME/code/erotemic
    # Input username
    # Input password
    cd $HOME/code/erotemic

    # The user must supply a password here
    transcrypt -c aes-256-cbc 
    # Reply no to using a random password
    # Input password
fi

## 
## TODO: get the netharn supersetup working with my "repos"
## Do this after the encrypted repo is setup
## Then do it once more, as we may pull more secret repos
# $(system_python) ~/local/init/util_git1.py 'clone_repos'
# $(system_python) ~/local/init/util_git1.py 'clone_repos'
