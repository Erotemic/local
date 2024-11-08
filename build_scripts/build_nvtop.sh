#!/bin/bash
__doc__='''
bash ~/local/build_scripts/build_nvtop.sh

https://github.com/Syllo/nvtop

Deps:
    sudo apt install cmake git -y
    sudo apt install libncurses5-dev libncursesw5-dev -y
    yum install ncurses-devel

    # Ubuntu 18.04
    sudo apt install libudev-dev


NOTES:
    DEACTIVATE YOUR CONDA ENVIRONMENT BEFORE RUNNING THIS SCRIPT
'''

if [ ! -d "$HOME/code/nvtop/.git" ]; then
    git clone https://github.com/Syllo/nvtop.git "$HOME"/code/nvtop
fi


if [ -f "$HOME/local/init/utils.sh" ]; then
    source "$HOME"/local/init/utils.sh
    #libudev-dev ?
    apt_ensure libncurses5-dev libncursesw5-dev
fi


(type cmake || (echo "requires cmake" || false)) && mkdir -p "$HOME"/code/nvtop/build && \
cd "$HOME"/code/nvtop/build && \
cmake -G "Unix Makefiles" -D CMAKE_INSTALL_PREFIX="$HOME"/.local -DNVML_RETRIEVE_HEADER_ONLINE=True -DCMAKE_BUILD_TYPE=Optimized .. && \
make && \
make install


__notes__='
sudo apt install libncurses5-dev libncursesw5-dev
git clone https://github.com/Syllo/nvtop.git $HOME/code/nvtop
(type cmake || (echo "requires cmake" || false)) && mkdir -p $HOME/code/nvtop/build && \
cd $HOME/code/nvtop/build && \
cmake -G "Unix Makefiles" -D CMAKE_INSTALL_PREFIX=$HOME/.local -DNVML_RETRIEVE_HEADER_ONLINE=True -DCMAKE_BUILD_TYPE=Optimized .. && \
make && \
make install
'
