# https://github.com/pytorch/pytorch/tree/v1.10.0-rc1#install-dependencies

git clone --recursive https://github.com/pytorch/pytorch
cd pytorch
git submodule sync
# if you are updating an existing checkout
git submodule sync
git submodule update --init --recursive --jobs 0



# For me this should already be setup 
# as $HOME/.local/cuda::$HOME/.local
echo $CMAKE_PREFIX_PATH
# export CMAKE_PREFIX_PATH=${CONDA_PREFIX:-"$(dirname $(which conda))/../"}

DEFAULT_GCC_VERSION=$(gcc --version | head -n 1 | awk '{print $NF}')
if [[ $DEFAULT_GCC_VERSION == "10.3.0" ]]; then
    # Bugs with 10.3.0
    # https://gcc.gnu.org/bugzilla/show_bug.cgi?id=100240
    # https://gcc.gnu.org/bugzilla/show_bug.cgi?id=100102
    # Fix by expcility using a different gcc
    #sudo apt install g++-9 gcc-9
    #MAX_JOBS=1 CC=/usr/bin/gcc-9 CXX=/usr/bin/g++-9 python setup.py install
    # Max jobs does not seem to be respected
    CC=/usr/bin/gcc-9 CXX=/usr/bin/g++-9 python setup.py install
else:
    MAX_JOBS=10 python setup.py install
fi
