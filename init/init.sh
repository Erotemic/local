#!/bin/bash
__heredoc__="""

Idenpotent script for initializing an ubuntu system

Dont put something in here that can't run twice efficiently.

CommandLine:
    sudo apt install git -y
    cd ~
    git clone https://github.com/Erotemic/local.git
    source ~/local/init/init.sh

"""
source $HOME/local/init/freshstart_ubuntu.sh
source $HOME/local/init/utils.sh

HAVE_SUDO=$(have_sudo)
IS_HEADLESS=$(is_headless)
echo "IS_HEADLESS = $IS_HEADLESS"
echo "HAVE_SUDO = $HAVE_SUDO"


if [ "$HAVE_SUDO" == "True" ]; then

    if [[ `which git` == "" ]]; then
        sudo apt install git -y
    fi

    if [[ `which gcc` == "" ]]; then
        sudo apt install gcc g++ gfortran build-essential -y
    fi

    if [[ `which curl` == "" ]]; then
        sudo apt install curl -y
    fi

    if [[ `which htop` == "" ]]; then
        sudo apt install htop tmux tree -y
    fi

    if [[ `which sshfs` == "" ]]; then
        sudo apt install sshfs -y
    fi

    if [[ `which astyle` == "" ]]; then
        sudo apt install astyle p7zip-full pgpgpg lm-sensors -y
    fi
else
    echo "We dont have sudo. Hopefully we wont need it"
fi


_GITUSER=$(git config --global user.name)
if [ "$_GITUSER" == "" ]; then
  echo "ENSURE GIT CONFIG"
  set_global_git_config
  mkdir -p ~/tmp
  mkdir -p ~/code
fi

if [ "$IS_HEADLESS" == "False" ]; then

    if [ $(which terminator) = "" ]; then
        echo "ENSURE TERMINATOR"
            # Dont use buggy gtk2 version 
            # https://bugs.launchpad.net/ubuntu/+source/terminator/+bug/1568132
            sudo add-apt-repository ppa:gnome-terminator/nightly-gtk3
            sudo apt update
            sudo apt install terminator -y
    fi

    if [ ! -e ~/.config/terminator ]; then
        echo "ENSURE SYMLINKS"
        source ~/local/init/ensure_symlinks.sh 
        ensure_config_symlinks
        # TODO: terminator doesnt configure to automatically use the joncrall profile in 
        # the terminator config. Why?
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
fi

if [ ! -d ~/.local/conda ]; then
    echo "SETUP CONDA ENV"
    setup_conda_env
    pip install six ubelt xdoctest xinspect xdev
    pip install pyperclip psutil pep8 autopep8 flake8 pylint pytest
fi

source ~/.bashrc


#vim-gnome  
if [ ! -d ~/.local/share/vim ]; then
    if [ $(which ctags) = "" ]; then
        sudo apt install -y exuberant-ctags 
        sudo apt install libgtk-3-dev gnome-devel ncurses-dev build-essential libtinfo-dev -y 
    fi

    # sudo apt install -y vim-gnome
    deactivate_venv
    source ~/local/build_scripts/init_vim.sh
    do_vim_build

    source ~/local/vim/init_vim.sh
    python ~/local/init/ensure_vim_plugins.py 
fi


python ~/local/init/init_ipython_config.py


if [ "$IS_HEADLESS" == "False" ]; then
    if [[ `which google-chrome` == "" ]]; then
        install_chrome

        install_basic_extras

        sh ~/local/build_scripts/install_zotero.sh

        sudo apt install -y vlc redshift sshfs wmctrl xdotool xclip 

        sudo snap install spotify
    fi
fi


# TODO: setup ssh keys

# Clone all of my repos
# gg-clone
# developer setup my repos

# TODO: setup nvidia drivers on appropriate systems: see init_cuda 

# TODO: setup secrets and internal state
