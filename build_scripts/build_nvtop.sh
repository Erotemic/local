__heredoc__='''
bash ~/local/build_scripts/build_nvtop.sh

Deps:
    sudo apt install cmake libncurses5-dev git
    sudo apt install libncurses5-dev libncursesw5-dev
    sudo apt install libncursesw5-dev

    yum install ncurses-devel
    

NOTES:
    DEACTIVATE YOUR CONDA ENVIRONMENT BEFORE RUNNING THIS SCRIPT
'''

if [ ! -d "$HOME/code/nvtop/.git" ]; then
    git clone https://github.com/Syllo/nvtop.git $HOME/code/nvtop
fi

mkdir -p $HOME/code/nvtop/build && \
cd $HOME/code/nvtop/build && \
cmake -G "Unix Makefiles" -D CMAKE_INSTALL_PREFIX=$HOME/.local -DNVML_RETRIEVE_HEADER_ONLINE=True -DCMAKE_BUILD_TYPE=Optimized .. && \
make && \
make install
