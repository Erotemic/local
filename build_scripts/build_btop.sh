#!/bin/bash
__notes__='

Get ubuntu version:
    lsb_release -a”

'

__install_gcc11_on_2004__(){
    # https://lindevs.com/install-gcc-on-ubuntu/
    sudo add-apt-repository -y ppa:ubuntu-toolchain-r/test
    sudo apt install -y gcc-11 g++-11
    gcc-11 --version
    g++-11 --version
}

git_ensure(){
    GIT_URL=$1
    GIT_DPATH=$2
    if [ ! -d "$GIT_DPATH" ]; then 
        git clone "$GIT_URL" "$GIT_DPATH"
    fi
}
git_ensure https://github.com/aristocratos/btop.git "$HOME/code/btop"
cd "$HOME/code/btop"
PREFIX=$HOME/.local make
PREFIX=$HOME/.local make install
