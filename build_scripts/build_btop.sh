#!/usr/bin/env bash
__notes__='

Get ubuntu version:
    lsb_release -a

'

__install_gcc11_on_2004__(){
    # btop requires C++20 features, which need gcc10 or higher.
    #
    # https://lindevs.com/install-gcc-on-ubuntu/
    sudo add-apt-repository -y ppa:ubuntu-toolchain-r/test
    sudo apt install -y gcc-11 g++-11
    gcc-11 --version
    g++-11 --version

    # Make cmake recognize gcc11 first
    export CC=gcc-11
    export CXX=g++-11

    # prereq
    # LDflags needed for 20.04
    export LDFLAGS='-ldl'
    pip install cmake
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
git pull

mkdir -p "$HOME/code/btop/build"
cd "$HOME/code/btop/build"
cmake -DCMAKE_INSTALL_PREFIX="$HOME/.local" -DBTOP_GPU=true "$HOME/code/btop"
make -j9
make install


cd "$HOME/code/btop"
PREFIX=$HOME/.local make
PREFIX=$HOME/.local make install
