#!/bin/bash
__doc__="
References:
    # https://github.com/pytorch/pytorch/tree/v1.10.0-rc1#install-dependencies


Issues:
    https://stackoverflow.com/questions/33868486/parameter-packs-not-expanded-with
    https://discuss.pytorch.org/t/solved-error-in-cuda-extension-compilation-from-pytorch-advanced-tutorial/26834
    https://github.com/NVlabs/instant-ngp/issues/119
"


prereq(){
    "$HOME"/local/init/utils.sh
    apt_ensure liblapack-dev
}


git clone --recursive https://github.com/pytorch/pytorch
cd pytorch
git submodule sync
# if you are updating an existing checkout
git submodule sync
git submodule update --init --recursive --jobs 0



clean_the_repo(){
    # https://gist.github.com/nicktoumpelis/11214362
    python setup.py clean
    git clean -xfdf
    git submodule foreach --recursive git clean -xfdf
    git reset --hard
    git submodule foreach --recursive git reset --hard
    git submodule update --init --recursive
}



dev_notes(){
    # What cuda do we have?
    cat "$HOME"/.local/cuda/version.json
}


# For me this should already be setup 
# as $HOME/.local/cuda::$HOME/.local
echo "$CMAKE_PREFIX_PATH"
# export CMAKE_PREFIX_PATH=${CONDA_PREFIX:-"$(dirname $(which conda))/../"}

DEFAULT_GCC_VERSION=$(gcc --version | head -n 1 | awk '{print $NF}')
echo "DEFAULT_GCC_VERSION = $DEFAULT_GCC_VERSION"
if [[ $DEFAULT_GCC_VERSION == "10.3.0" ]]; then
    # Bugs with 10.3.0
    # https://gcc.gnu.org/bugzilla/show_bug.cgi?id=100240
    # https://gcc.gnu.org/bugzilla/show_bug.cgi?id=100102
    # Fix by expcility using a different gcc
    #sudo apt install g++-9 gcc-9
    #MAX_JOBS=1 CC=/usr/bin/gcc-9 CXX=/usr/bin/g++-9 python setup.py install
    # Max jobs does not seem to be respected
    #CC=/usr/bin/gcc-9 CXX=/usr/bin/g++-9 python setup.py install

    ### GCC workaround
    # https://github.com/NVlabs/instant-ngp/issues/119
    sudo apt install gcc-10 g++-10
    ln -s /usr/bin/gcc-10 "$CUDA_ROOT"/bin/gcc
    ln -s /usr/bin/g++-10 "$CUDA_ROOT"/bin/g++
    export CC=/usr/bin/gcc-10
    export CXX=/usr/bin/g++-10
    export CUDA_ROOT="$CUDA_HOME"
    MAX_JOBS=10 python setup.py develop
else
    MAX_JOBS=10 python setup.py install
fi
