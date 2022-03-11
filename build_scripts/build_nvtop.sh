__heredoc__='''
bash ~/local/build_scripts/build_nvtop.sh

Deps:
    sudo apt install cmake git -y
    sudo apt install libncurses5-dev libncursesw5-dev -y
    yum install ncurses-devel
    

NOTES:
    DEACTIVATE YOUR CONDA ENVIRONMENT BEFORE RUNNING THIS SCRIPT
'''

if [ ! -d "$HOME/code/nvtop/.git" ]; then
    git clone https://github.com/Syllo/nvtop.git $HOME/code/nvtop
fi


if [ -f "$HOME/local/init/utils.sh" ]; then
    source "$HOME/local/init/utils.sh"
    apt_ensure libncurses5-dev libncursesw5-dev
fi


(type cmake || (echo "requires cmake" || false)) && mkdir -p $HOME/code/nvtop/build && \
cd $HOME/code/nvtop/build && \
cmake -G "Unix Makefiles" -D CMAKE_INSTALL_PREFIX=$HOME/.local -DNVML_RETRIEVE_HEADER_ONLINE=True -DCMAKE_BUILD_TYPE=Optimized .. && \
make && \
make install
