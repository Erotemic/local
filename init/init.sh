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
source ~/local/init/freshstart_ubuntu.sh



_GITUSER=$(git config --global user.name)
if [ "$_GITUSER" == "" ]; then
  echo "ENSURE GIT CONFIG"
  set_global_git_config
  mkdir -p ~/tmp
  mkdir -p ~/code
fi

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

if [ ! -d ~/.ssh ]; then
    echo "ENSURE SSH"
    mkdir -p ~/.ssh 
    chmod 700 ~/.ssh
    if [ ! -f ~/.ssh/authorized_keys ]; then
        touch ~/.ssh/authorized_keys
        chmod 640 ~/.ssh/authorized_keys
    fi 
fi

if [ $(which curl) = "" ]; then
  echo "ENSURE CURL"
  ensure_curl
fi

if [ ! -d ~/.local/conda ]; then
    echo "SETUP CONDA ENV"
    setup_conda_env
    pip install six ubelt xdoctest xdev
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


if [[ `which gfortran` == "" ]]; then
    sudo apt install gcc g++ gfortran build-essential -y
fi


if [[ `which google-chrome` == "" ]]; then
    install_chrome

    install_basic_extras

    sh ~/local/build_scripts/install_zotero.sh

    sudo apt install -y vlc redshift sshfs wmctrl xdotool tmux xclip htop tree astyle p7zip-full pgpgpg lm-sensors

    sudo snap install spotify
    
fi


# TODO: setup ssh keys

# Clone all of my repos
# gg-clone
# developer setup my repos


# TODO: setup nvidia drivers on appropriate systems: see init_cuda 
