#!/usr/bin/env bash
__doc__="

Idempotent script for initializing an ubuntu system

Don't put something in here that can't run twice efficiently.

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

    export SETUP_PYTHON=True
    export HAVE_SUDO=True
    export IS_HEADLESS=False
    export WITH_SSH_KEYS=False
    source ~/local/init.sh
"

#if [[ "$(type -P python)" == "" ]]; then
#    if [[ "$(type -P python3)" != "" ]]; then
#        alias python=python3
#    fi
#fi

# shellcheck disable=SC1091
# source "$HOME/local/init/freshstart_ubuntu.sh"
# shellcheck disable=SC1091
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
# shellcheck disable=SC1091
source "$HOME/local/init/ensure_symlinks.sh"
ensure_config_symlinks

if [ "$HAVE_SUDO" == "True" ]; then
    # minimal server
    # https://ubuntu.com/server/docs/service-openssh
    apt_ensure openssh-server openssh-client
    apt_ensure net-tools
    cat /etc/ssh/sshd_config
    sudo systemctl restart sshd.service

    # shellcheck disable=SC2016
    __notes__='
    To setup ssh, get the service working with basic password auth, so you can
    login with password auth as a one-time thing to send over your ssh public
    key.

    Note: the ``-o PubkeyAuthentication=no`` is important to login to the
    machine for the first time.

    ..code:: bash

        REMOTE_USER=$USER
        REMOTE_HOST=<IP-OR-DNS-NAME>
        SSH_PRIVATE_KEY=$HOME/.ssh/<private-key-fname>
        ssh-copy-id -i "${SSH_PRIVATE_KEY}" -o PreferredAuthentications=password -o PubkeyAuthentication=no "$REMOTE_USER@$REMOTE_HOST"

    Now a regular login should work:

        ssh -i "${SSH_PRIVATE_KEY}" "$REMOTE_USER@$REMOTE_HOST"

    Now, on the remote machine disable password login:

        cat /etc/ssh/sshd_config
        sudo systemctl restart sshd.service
    '
fi

if [ "$HAVE_SUDO" == "True" ]; then
    apt_ensure openssh-server openssh-client sshfs net-tools
    apt_ensure gcc g++ gfortran build-essential
    apt_ensure git curl jq expect htop tmux tree p7zip-full gpg pgpgpg lm-sensors btop
    apt_ensure rsync symlinks fd-find
    # apt_ensure valgrind codespell
    # apt_ensure astyle synaptic


    if [[ "$IS_HEADLESS" == "False" ]]; then
        #apt_ensure redshift  # ubuntu has nightlight now
        apt_ensure wmctrl xdotool xclip
        apt_ensure gparted okular remmina gitk xsel graphviz feh
        # apt_ensure astyle psensor nmap caffeine
        # packages not in 20.04, but maybe other ones?
        # 7z sensors

        #if [[ "$(type -P google-chrome)" == "" ]]; then
        #    # shellcheck disable=SC1091
        #    source "$HOME/local/init/freshstart_ubuntu.sh"
        #    install_chrome
        #    sudo apt-get install chrome-gnome-shell # for gnome shell extension integration
        #fi
        #if [ ! -e /snap/bin/spotify ]; then
        #    sudo snap install spotify
        #fi
        # TODO:
        # do a new way to install veracrypt securely
        # https://askubuntu.com/questions/929195/what-is-the-recommended-way-to-use-veracrypt-in-ubuntu
        #if [[ "$(type -P veracrypt)" == "" ]]; then
        #    sudo add-apt-repository ppa:unit193/encryption -y
        #    sudo apt update && sudo apt install veracrypt -y
        #fi
        #if [[ "$(type -P zotero)" == "" ]]; then
        #    sh ~/local/build_scripts/install_zotero.sh
        #fi

        apt_ensure python3-pip vim-gtk3
        #if [ ! -d ~/.local/share/vim ]; then
        #    #if [ "$(type -P ctags)" = "" ]; then
        #    #    # apt_ensure exuberant-ctags
        #    #    apt_ensure libgtk-3-dev gnome-devel ncurses-dev build-essential libtinfo-dev
        #    #fi
        #fi
        # If you need to build from scratch
        #source ~/local/build_scripts/init_vim.sh
        #do_vim_build

        # In 2024 on 22.04 there is an issue with terminator
        # https://askubuntu.com/questions/1509058/input-delay-on-terminal-ubuntu-22-04-4

        #if [ "$(type -P terminator)" == "" ]; then
        #    echo "ENSURE TERMINATOR"
        #        # Dont use buggy gtk2 version
        #        # https://bugs.launchpad.net/ubuntu/+source/terminator/+bug/1568132
        #        #sudo add-apt-repository ppa:gnome-terminator/nightly-gtk3 -y
        #        sudo apt update
        #        sudo apt install terminator -y
        #fi

    fi

else
    echo "We dont have sudo. Hopefully we wont need it"
fi


_GITUSER="$(git config --global user.name)"
if [ "$_GITUSER" == "" ]; then
    echo "ENSURE GIT CONFIG"
    # TODO: need to determine the right user.email depending on the system being set up
    git config --global user.name "$USER"
    git config --global user.email erotemic@gmail.com
    #git config --global user.email jon.crall@kitware.com
    git config --global push.default current
    git config --global core.editor "vim"
    git config --global rerere.enabled false
    git config --global core.fileMode false
    git config --global alias.co checkout
    git config --global alias.submodpull 'submodule update --init --recursive'
    #git config --global merge.conflictstyle diff3
    git config --global merge.conflictstyle merge
    git config --global core.autocrlf false

    mkdir -p ~/tmp
    mkdir -p ~/code
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


#
if [ ! -d ~/.vim/autoload/plug.vim ]; then
    curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
fi

install_chrome()
{
    # Google PPA
    # https://askubuntu.com/questions/79280/how-to-install-chrome-browser-properly-via-command-line
    wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
    sudo sh -c 'echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list'
    sudo apt update
    # Google Chrome
    sudo apt install -y google-chrome-stable


    # for extensions.gnome.org integration
    sudo apt install chrome-gnome-shell
}


install_veracrypt(){
    __doc__="
    The official website is:
        https://veracrypt.fr/en/Downloads.html
    "

    sudo apt install libfuse-dev

    # Copied link to the generic installer on 2024-04-25
    mkdir -p "$HOME"/temp/veracrypt
    cd "$HOME"/temp/veracrypt
    curl -L https://launchpad.net/veracrypt/trunk/1.26.7/+download/veracrypt-1.26.7-setup.tar.bz2 -o veracrypt-1.26.7-setup.tar.bz2
    curl -L https://launchpad.net/veracrypt/trunk/1.26.7/+download/veracrypt-1.26.7-setup.tar.bz2.sig -o veracrypt-1.26.7-setup.tar.bz2.sig

    VERACRYPT_FINGERPRINT=5069A233D55A0EEB174A5FC3821ACD02680D16DE
    if ! test -f VeraCrypt_PGP_public_key.asc; then
        curl -L https://www.idrix.fr/VeraCrypt/VeraCrypt_PGP_public_key.asc -o VeraCrypt_PGP_public_key.asc
        if printf "1507915290af06da1d2ac0f37f26a70b2340d3fcbdffb1930228f6a590dfcef6 VeraCrypt_PGP_public_key.asc" | sha256sum --check --status ; then
            echo "Looks Ok"
            gpg --import ./VeraCrypt_PGP_public_key.asc
            if ! gpg -k "$VERACRYPT_FINGERPRINT" ; then
                echo "Bad Fingerprint!"
            else
                echo "Good Fingerprint"
                # Optional for ultimate trust
                python3 ~/local/scripts/xgpg.py edit_trust "$VERACRYPT_FINGERPRINT" ultimate
            fi
        else
            echo "BAD HASH"
        fi
    fi
    gpg --verify veracrypt-1.26.7-setup.tar.bz2.sig veracrypt-1.26.7-setup.tar.bz2
    tar xvjf veracrypt-1.26.7-setup.tar.bz2

    mkdir -p "$HOME"/.local/opt/veracrypt
    # FIXME: has interactive step
    ./veracrypt-1.26.7-setup-console-x64 --target "$HOME"/.local/opt/veracrypt

}


if [[ "$IS_HEADLESS" == "False" ]]; then
    #install_transcrypt
    git clone https://github.com/Erotemic/transcrypt.git "$HOME"/code/transcrypt

    # shellcheck disable=SC1091
    source "$HOME"/local/init/utils.sh
    mkdir -p "$HOME"/.local/bin
    safe_symlink "$HOME"/code/transcrypt/transcrypt "$HOME"/.local/bin/transcrypt

    echo "YOU WILL NEED TO INPUT PASSWORDS"
    # NOTE: if you have valid gitlab ssh keys, you can change to a git@ url
    git clone https://gitlab.com/Erotemic/erotemic.git "$HOME"/code/erotemic
    # Input username
    # Input password
    cd "$HOME"/code/erotemic || exit

    # The user must supply a password here
    transcrypt -c aes-256-cbc
    # Reply no to using a random password
    # Input password

    # Setup private personal environment if possible
    PRIVATE_INIT="$HOME"/code/erotemic/init.sh
    if is_probably_decrypted "$PRIVATE_INIT"; then
        echo "Seems like we are decrypted"
        bash "$PRIVATE_INIT"
    else
        echo "Does not look decrypted"
    fi
fi


if [[ "$WITH_SSH_KEYS" == "True" ]]; then
    # shellcheck disable=SC1091
    source "$HOME"/local/init/freshstart_ubuntu.sh
    setup_single_use_ssh_keys
fi

HAS_NVIDIA=$(which nvidia-smi)
if [ "$HAVE_SUDO" == "True" ]; then
    if [[ "$HAS_NVIDIA" != "" ]]; then
        apt_ensure nvtop
    fi
fi

if [[ "$SETUP_PYTHON" == "True" ]]; then

    # If we need to use conda, do this instead
    # TODO: Dont use conda anymore, use pyenv or something else instead
    # Hmm, maybe use conda when we need something quick and without ANY root
    # privledges?
    #if [ ! -d ~/.local/conda ]; then
    #    echo "SETUP CONDA ENV"
    #    source "$HOME"/local/init/freshstart_ubuntu.sh
    #    setup_conda_env
    #    pip install six ubelt xdoctest xinspect xdev
    #    pip install pyperclip psutil pep8 autopep8 flake8 pylint pytest
    #fi

    # Dependencies for building Python
    apt_ensure make build-essential libssl-dev zlib1g-dev \
        libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm libncurses5-dev \
        libncursesw5-dev xz-utils tk-dev libffi-dev liblzma-dev

    #source "$HOME"/local/init/freshstart_ubuntu.sh
    # shellcheck disable=SC1091
    source "$HOME"/local/tools/pyenv_ext/pyenv_ext_commands.sh
    install_pyenv
    export PYENV_ROOT="$HOME/.pyenv"
    export PATH="$PYENV_ROOT/bin:$PATH"
    # shellcheck disable=SC2086
    eval "$($PYENV_ROOT/bin/pyenv init -)"
    #pyenv_create_virtualenv 3.12.3 full
    #
    source "$HOME"/local/tools/pyenv_ext/pyenv_ext_commands.sh
    pyenv_create_virtualenv 3.11.2 full
    #pip install -e ~/local/rob

    python3 ~/local/init/util_git1.py 'clone_repos'

    # Optional
    __option__='
    source ~/local/tools/pyenv_ext/pyenv_ext_commands.sh
    build_vim_for_pyenv
    '
else
    echo "Skipping Python setup"
fi

# Unset the python alias we set earlier because now we should be in a conda env
#if [ "$(alias | grep 'alias python=')" != "" ]; then
#    unalias python
#fi

init_vim(){
    source ~/local/init/utils.sh
    #safe_symlink ~/local/vim/vimfiles ~/.vim
    safe_symlink ~/local/vim/portable_vimrc ~/.vimrc

    # To use vimtk at the system level we want to get relevant packages from
    # the system manager.
    apt_ensure python3-pyperclip python3-flake8


    if [[ -d "$HOME/code/vimtk" ]]; then
        rm -rf "$HOME"/.vim/bundle/vimtk
        safe_symlink "$HOME"/code/vimtk "$HOME"/.vim/bundle/vimtk
    else
        git clone https://github.com/Erotemic/vimtk.git "$HOME"/code/vimtk
        echo "no vimtk dev"
    fi

    # Run vim once to install plugins
    vim -en -c ":q"
    vim -en -c ":PlugInstall | qa"

    mkdir -p ~/.vim_tmp
}


# TODO: ensure we pip install vimtk requirements
# ubelt, pyperclip

#hack_vimtk_deps(){
#    deactivate_venv
#    pip3 install pyperclip psutil pep8 autopep8 flake8 pylint pytest --user

#}
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

    python3 ~/local/init/util_git1.py 'clone_repos'
    python3 ~/local/init/util_git1.py 'install_repos'

    # Not needed, should be handled by the git tools
    mylibs=(
    ubelt
    mkinit
    xdoctest
    vimtk
    timerit
    progiter
    scriptconfig
    git_sync
    cmd_queue
    liberator
    xinspect
    xdev
    )

    #shitspotter
    #pypogo
    #torch_liberator

    for name in "${mylibs[@]}"
    do
        echo "name = $name"
        dpath=$HOME/code/$name
        if [[ -d $dpath ]]; then
            #base_fpath=$(python -c "import $name; print($name.__file__)")
            if python -c "import sys, $name; sys.exit(1 if 'site-packages' in $name.__file__ else 0)"; then
                echo "already have dpath = $dpath"
            else
                echo "ensuring dpath = $dpath"
                pip uninstall "$name" -y
                pip uninstall "$name" -y
                pip install -e "$dpath"
            fi
        else
            echo "does not exist dpath = $dpath"
        fi
    done

    pip install shellcheck-py
}


customize_ubuntu_dock(){
    gsettings get org.gnome.shell favorite-apps
    gsettings set org.gnome.shell favorite-apps "['org.gnome.Nautilus.desktop', 'gvim.desktop', 'google-chrome.desktop', 'terminator.desktop']"
    # gsettings set org.gnome.desktop.interface clock-format '12h'
}

if [[ "$IS_HEADLESS" != "True" ]]; then
    customize_ubuntu_dock
fi


# Include a symlink to the root in the user folder
if [ ! -d "$HOME"/root ]; then
    ln -fs "/" "$HOME/root"
fi
mkdir -p "$HOME"/.local
mkdir -p "$HOME"/.local/bin
mkdir -p "$HOME"/.local/opt


export DID_MY_BASHRC_INIT=""

echo "Reloading the updated bashrc"
# shellcheck disable=SC1091
source "$HOME/.bashrc"
