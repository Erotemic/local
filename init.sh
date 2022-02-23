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
    export HAVE_SUDO=False
    export IS_HEADLESS=True
    export WITH_SSH_KEYS=False
    source ~/local/init.sh

    export HAVE_SUDO=True
    export IS_HEADLESS=False
    export WITH_SSH_KEYS=False
    source ~/local/init.sh
"""

#if [[ "$(type -P python)" == "" ]]; then
#    if [[ "$(type -P python3)" != "" ]]; then
#        alias python=python3
#    fi
#fi

source "$HOME/local/init/freshstart_ubuntu.sh"
source "$HOME/local/init/utils.sh"

HAVE_SUDO=${HAVE_SUDO:=$(have_sudo)}
IS_HEADLESS=${IS_HEADLESS:=$(is_headless)}
WITH_SSH_KEYS=${WITH_SSH_KEYS:="False"}
SETUP_PYTHON=${SETUP_PYTHON:="False"}

echo "IS_HEADLESS = $IS_HEADLESS"
echo "HAVE_SUDO = $HAVE_SUDO"

if [ "$HAVE_SUDO" == "True" ]; then
    apt_ensure symlinks
else
    echo "We dont have sudo. Hopefully we wont need it"
fi

echo "ENSURE SYMLINKS"
# TODO: terminator doesnt configure to automatically use the joncrall profile
# in the terminator config. Why?
source "$HOME/local/init/ensure_symlinks.sh"
ensure_config_symlinks


if [ "$HAVE_SUDO" == "True" ]; then
    apt_ensure git 
    apt_ensure gcc g++ build-essential 
    apt_ensure gfortran 
    apt_ensure curl net-tools
    apt_ensure jq expect
    apt_ensure htop tmux tree 
    apt_ensure sshfs 
    apt_ensure p7zip-full pgpgpg lm-sensors
    apt_ensure astyle codespell
    apt_ensure synaptic
    apt_ensure rsync valgrind symlinks
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

if [ "$HAVE_SUDO" == "True" ]; then
    apt_ensure python3-pip
    apt_ensure vim-gtk3
    if [ ! -d ~/.local/share/vim ]; then
        if [ "$(type -P ctags)" = "" ]; then
            apt_ensure exuberant-ctags 
            apt_ensure libgtk-3-dev gnome-devel ncurses-dev build-essential libtinfo-dev
        fi
    fi
    # If you need to build from scratch
    #source ~/local/build_scripts/init_vim.sh
    #do_vim_build
fi


# 
if [ ! -d ~/.vim/autoload/plug.vim ]; then
    curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
fi


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
    apt_ensure psensor
    apt_ensure gitk gparted okular remmina rsync gitk xsel graphviz feh

    if [[ "$(type -P google-chrome)" == "" ]]; then
        source "$HOME/local/init/freshstart_ubuntu.sh"
        install_chrome

        sudo apt-get install chrome-gnome-shell # for gnome shell extension integration
    fi
    if [ ! -e /snap/bin/spotify ]; then
        sudo snap install spotify
    fi
    if [[ "$(type -P veracrypt)" == "" ]]; then
        sudo add-apt-repository ppa:unit193/encryption -y
        sudo apt update && sudo apt install veracrypt -y
    fi
    #if [[ "$(type -P zotero)" == "" ]]; then
    #    sh ~/local/build_scripts/install_zotero.sh
    #fi
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

    # Run:
    sh $HOME/code/erotemic/init.sh

fi


if [[ "$WITH_SSH_KEYS" == "True" ]]; then
    source $HOME/local/init/freshstart_ubuntu.sh
    setup_single_use_ssh_keys
fi



if [[ "$SETUP_PYTHON" == "True" ]]; then

    # If we need to use conda, do this instead
    # TODO: Dont use conda anymore, use pyenv or something else instead
    # Hmm, maybe use conda when we need something quick and without ANY root
    # privledges?
    #if [ ! -d ~/.local/conda ]; then
    #    echo "SETUP CONDA ENV"
    #    source $HOME/local/init/freshstart_ubuntu.sh
    #    setup_conda_env
    #    pip install six ubelt xdoctest xinspect xdev
    #    pip install pyperclip psutil pep8 autopep8 flake8 pylint pytest
    #fi

    # Dependencies for building Python
    apt_ensure make build-essential libssl-dev zlib1g-dev \
        libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm libncurses5-dev \
        libncursesw5-dev xz-utils tk-dev libffi-dev liblzma-dev 

    #source $HOME/local/init/freshstart_ubuntu.sh
    source $HOME/local/tools/pyenv_ext/pyenv_ext_commands.sh
    install_pyenv
    pyenv_create_virtualenv 3.9.9 full
    pip install -e ~/local/rob

    python ~/local/init/util_git1.py 'clone_repos'
    #export PYENV_ROOT="$HOME/.pyenv"
    #if [ -d "$PYENV_ROOT" ]; then
    #    export PATH="$PYENV_ROOT/bin:$PATH"
    #    eval "$($PYENV_ROOT/bin/pyenv init -)"
    #    eval "$($PYENV_ROOT/bin/pyenv init --path)"
    #    #eval "$(pyenv init --path)"
    #    #eval "$(pyenv init -)"
    #    source $PYENV_ROOT/completions/pyenv.bash
    #    export PYENV_PREFIX=$(pyenv prefix)
    #    #pyenv_create_virtualenv 3.8.6 most
    #    pyenv_create_virtualenv 3.9.9 full
    #fi

    python ~/local/init/util_git1.py 'clone_repos'
    pip install -e ~/local/rob

fi

# Unset the python alias we set earlier because now we should be in a conda env
#if [ "$(alias | grep 'alias python=')" != "" ]; then
#    unalias python
#fi


#source ~/local/vim/init_vim.sh

# TODO: setup ssh keys

# Clone all of my repos
# gg-clone
# developer setup my repos

# TODO: setup nvidia drivers on appropriate systems: see init_cuda 

# TODO: setup secrets and internal state

#source ~/.bashrc
#deactivate_venv

## 
## TODO: get the netharn supersetup working with my "repos"
## Do this after the encrypted repo is setup
## Then do it once more, as we may pull more secret repos
# $(system_python) ~/local/init/util_git1.py 'clone_repos'
# $(system_python) ~/local/init/util_git1.py 'clone_repos'

ensure_dev_versions_of_my_libs(){

    mylibs=(
    ubelt 
    xdoctest 
    mkinit
    xdoctest
    git_sync
    vimtk
    xdev)

    for name in "${mylibs[@]}" 
    do
        dpath=$HOME/code/$name
        if [[ -d $dpath ]]; then
            base_fpath=$(python -c "import $name; print($name.__file__)")
            result=$?
            if [[ "$result" == "1" ]]; then
                echo "ensuring dpath = $dpath"
                pip uninstall $name -y
                pip uninstall $name -y
                pip install -e $dpath
            else
                echo "already have dpath = $dpath"
            fi
        else
            echo "does not exist dpath = $dpath"
        fi
    done

}

