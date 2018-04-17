cd $HOME/code && \
git clone https://github.com/Syllo/nvtop.git && \
mkdir -p $HOME/code/nvtop/build && \
cd $HOME/code/nvtop/build && \
cmake -G "Unix Makefiles" -D CMAKE_INSTALL_PREFIX=$HOME/.local .. && \
make && \
make install

