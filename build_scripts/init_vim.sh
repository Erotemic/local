# https://github.com/vim/vim/issues/1483

clone_vim(){
git clone https://github.com/vim/vim.git ~/code/
}
#mkdir tmpinstall

prereq(){
    #sudo apt-get build-dep vim
    sudo apt install build-essential libtinfo-dev -y
    sudo apt build-dep vim-gtk -y
    sudo apt install ncurses-dev
    sudo apt build-dep vim-gtk
    #sudo apt-get build-dep vim-gnome

    sudo apt install gnome-devel -y
    sudo apt install libgtk-3-dev -y
}

help(){
    ./configure --help
    ./configure --help | grep python
}

prechecks(){
#export CC=gcc
#export =clang

#make distclean


#sudo apt-get update
# We want to be on gtk-3.22.4, but ubuntu16.04 defaults to 3.17
# TODO: upgrade gtk3
# https://github.com/vim/vim/issues/1483
#sudo apt-get install libgtk-3-0

# Check version of gtk
dpkg -l libgtk* | grep -e '^i' | grep -e 'libgtk-*[0-9]'
#pkg-config --modversion gtk+-3.0


#CFLAGS="$CFLAG -O3"
#deactivate
make distclean

# GUI options:
#auto/no/gtk2/gnome2/gtk3/motif/athena/neXtaw/photon/carbon

#PYTHON3_SRC	= if_python3.c
#PYTHON3_OBJ	= objects/if_python3.o
#PYTHON3_CFLAGS	= -I/home/joncrall/venv3/include/python3.5m -DPYTHON3_HOME='L"/home/joncrall/venv3"' -pthread -fPIE
#PYTHON3_LIBS	= -L/usr/lib/python3.5/config-3.5m-x86_64-linux-gnu -lpython3.5m -lpthread -ldl -lutil -lm
#PYTHON3_CONFDIR	= /usr/lib/python3.5/config-3.5m-x86_64-linux-gnu

#PYTHON3_SRC	= if_python3.c
#PYTHON3_OBJ	= objects/if_python3.o
#PYTHON3_CFLAGS	= -I/usr/include/python3.5m -DPYTHON3_HOME='L"/usr"' -pthread -fPIE
#PYTHON3_LIBS	= -L/usr/lib/python3.5/config-3.5m-x86_64-linux-gnu -lpython3.5m -lpthread -ldl -lutil -lm
#PYTHON3_CONFDIR	= /usr/lib/python3.5/config-3.5m-x86_64-linux-gnu

#PYTHON3_CFLAGS="-I$VIRTUAL_ENV/include/python3.7m -DPYTHON3_HOME=L$VIRTUAL_ENV -pthread -fPIE"
#PYTHON3_LIBS="-L$VIRTUAL_ENV/lib/python3.7/config-3.7m-x86_64-linux-gnu -lpython3.7m -lpthread -ldl -lutil -lm"
#PYTHON3_CONFDIR="$VIRTUAL_ENV/lib/python3.7/config-3.7m-x86_64-linux-gnu"
}

vim_python37_version(){
    make distclean
    ./configure \
        --prefix=$HOME/.local \
        --enable-pythoninterp=no \
        --enable-python3interp=yes \
        --with-python3-config-dir=$(python3.7-config --configdir) \
        --enable-gui=gtk3
    cat src/auto/config.mk 
    cat src/auto/config.mk | grep PYTHON3
    make -j9
    ./src/vim -u NONE --cmd "source test.vim"
}
    #--prefix=$HOME/.local \
    #--exec-prefix=$HOME/.local \
    #--with-vim-name=vim-8 \
    #--with-ex-name=ex-8 \
    #--with-view-name=view-8 \

    #--enable-python3interp=yes \

with_conda_python36(){
    # NOTE:
    # https://github.com/ContinuumIO/anaconda-issues/issues/6619
    #conda install gxx_linux-64
    #conda install ncurses

    #conda install pkg-config autoconf automake cmake libtool
    #conda install -c anaconda gtk2-devel-cos6-x86_64 
    #conda install -c anaconda libx11-devel-cos6-x86_64 

    #conda install -c anaconda libiconv 
    #conda install -c anaconda glib 

    conda create -n vim80build python=3.6 
    conda activate vim80build

    #conda install gcc_linux-64
    #conda install gxx_linux-64 ncurses pkg-config autoconf automake cmake libtool libx11-devel-cos6-x86_64 libiconv glib libxml2 libpng cairo

    conda install ncurses libx11-devel-cos6-x86_64 libiconv glib libxml2 libpng cairo
    conda install -c pkgw/label/superseded gtk3

    # Remove gxx_linux-64 and gcc_linux-64 after you are done?
    cd ~/code/vim
    make distclean
    LDFLAGS="-L$CONDA_PREFIX/lib -Wl,-rpath,$CONDA_PREFIX/lib" ./configure --prefix=$CONDA_PREFIX --enable-pythoninterp=no --enable-python3interp=yes --enable-gui=gtk3 --with-local-dir==$CONDA_PREFIX
    cat src/auto/config.mk | grep GUI

    
    # GTK2 VERSION ALSO WORKS
    conda config --add channels loopbio
    conda install gtk2


    NCPUS=$(grep -c ^processor /proc/cpuinfo)
    make -j$NCPUS

    # Potential GTK issue
    # https://github.com/vim/vim/issues/1149

    #conda install -c mw gtk2
    #conda install -c pkgw/label/superseded gtk3
    #conda install -c pkgw-forge gtk3 
    #conda install -c anaconda libxt-devel-cos6-x86_64 
    #apt-cache showsrc vim-gtk | grep ^Build-Depends



    #make distclean
    #LDFLAGS="-L$CONDA_PREFIX/lib -Wl,-rpath,$CONDA_PREFIX/lib -L. -Wl,-Bsymbolic-functions -Wl,-z,relro -Wl,-z,now -fstack-protector -rdynamic -Wl,-export-dynamic -Wl,-O2 -Wl,--sort-common -Wl,--as-needed -Wl,-z,relro -Wl,-z,now -L/usr/local/lib -L/usr/lib/x86_64-linux-gnu" \
    #    ./configure --prefix=$CONDA_PREFIX --enable-pythoninterp=no --enable-python3interp=yes --enable-gui=gtk2 \
    #    --with-local-dir==$CONDA_PREFIX --with-gnome-libs=$CONDA_PREFIX/lib --with-gnome-includes=$CONDA_PREFIX/include
    #cat src/auto/config.mk | grep GUI
}

do_vim_build(){

if [ ! -d ~/code/vim ]; then
    git clone https://github.com/vim/vim.git ~/code/vim
fi
cd $HOME/code/vim
./configure \
    --prefix=$HOME/.local \
    --enable-pythoninterp=no \
    --enable-python3interp=yes \
    --enable-gui=gtk3

cat src/auto/config.mk 
cat src/auto/config.mk | grep GUI
cat src/auto/config.mk | grep PYTHON3

# Build
NCPUS=$(grep -c ^processor /proc/cpuinfo)
make -j$NCPUS

# Test
~/code/vim/src/vim --version
#~/code/vim/src/vim -u NONE
# Install
make install

ls -al ~/.local/bin/*vim*
}
#ls tmpinstall/bin/
#/usr/local/bin/gvim-8 --version
#/usr/bin/gvim --version

echo "hi"#!/bin/bash
__heredoc__="""
Builds mmdetection wheels for specific docker images 

Notes:
    DOCKER_IMAGE=nvidia/cuda:9.1-cudnn7-devel-ubuntu16.04
    DOCKER_IMAGE=nvidia/cuda:9.2-cudnn7-devel-ubuntu18.04
    DOCKER_IMAGE=nvidia/cuda:10.0-cudnn7-devel-ubuntu18.04
    DOCKER_IMAGE=nvidia/cuda:10.1-cudnn7-devel-ubuntu18.04
"""

DOCKER_IMAGE=${DOCKER_IMAGE:="nvidia/cuda:9.1-cudnn7-devel-ubuntu16.04"}
echo "DOCKER_IMAGE = $DOCKER_IMAGE"

if [ "$_INSIDE_DOCKER" != "YES" ]; then

    set -e
    docker run --runtime=nvidia --rm \
        -v $PWD:/io \
        -e _INSIDE_DOCKER="YES" \
        $DOCKER_IMAGE bash -c 'cd /io && ./build_mmdet_wheels.sh'

    __interactive__='''
    # notes for running / debugging interactively 

    docker run --runtime=nvidia --rm \
        -v $PWD:/io \
        -e _INSIDE_DOCKER="YES" \
        -it $DOCKER_IMAGE bash

    set +e
    set +x
    '''
    #BDIST_WHEEL_PATH=$(ls wheelhouse/$NAME-$VERSION-$MB_PYTHON_TAG*.whl)
    #echo "BDIST_WHEEL_PATH = $BDIST_WHEEL_PATH"
else

    apt-get update --fix-missing -y 
    apt-get install -y wget bzip2 ca-certificates libglib2.0-0 libxext6 libsm6 libxrender1 git mercurial subversion libgl1-mesa-glx
    #apt-get install locate

    export PATH=/opt/conda/bin:$PATH

    cd $HOME

    wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-4.7.12-Linux-x86_64.sh -O ~/miniconda.sh && \
        /bin/bash ~/miniconda.sh -b -p /opt/conda -u && \
        rm ~/miniconda.sh && \
        /opt/conda/bin/conda clean -tipsy

    ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh 

    echo ". /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc && \
        echo "conda activate vigilant" >> ~/.bashrc && \
        find /opt/conda/ -follow -type f -name '*.a' -delete && \
        find /opt/conda/ -follow -type f -name '*.js.map' -delete && \
        /opt/conda/bin/conda clean -afy && \
        conda config --set channel_priority strict

    git clone https://github.com/open-mmlab/mmdetection.git
    cd mmdetection

    pip install Cython
    pip install torch==1.2 torchvision==0.4.0
    pip install -r requirements/build.txt

    CUDA_VERSION=$(ls /usr/local/cuda/lib64/libcudart.so.*|sort|tac | head -1 | rev | cut -d"." -f -3 | rev) # 10.1.243
    CUDA_VERSION_SHORT=$(ls /usr/local/cuda/lib64/libcudart.so.*|sort|tac | head -1 | rev | cut -d"." -f -3 | rev | cut -f1,2 -d".") # 10.1
    CUDNN_VERSION=$(ls /usr/lib/x86_64-linux-gnu/libcudnn.so.*|sort|tac | head -1 | rev | cut -d"." -f -3 | rev)
    echo "
    CUDA_VERSION = $CUDA_VERSION
    CUDA_VERSION_SHORT = $CUDA_VERSION_SHORT
    CUDNN_VERSION = $CUDNN_VERSION
    "
    
    #TORCH_CUDA_ARCH_LIST="6.0 6.1 7.0+PTX"
    TORCH_CUDA_ARCH_LIST="Pascal;Volta"
    #TORCH_CUDA_ARCH_LIST="3.7+PTX;5.0;6.0;6.1;7.0;7.5"
    TORCH_NVCC_FLAGS="-Xfatbin -compress-all"
    #export LD_LIBRARY_PATH=/usr/local/cuda/lib64/:$LD_LIBRARY_PATH
    echo "
    TORCH_CUDA_ARCH_LIST = $TORCH_CUDA_ARCH_LIST
    TORCH_NVCC_FLAGS = $TORCH_NVCC_FLAGS
    LD_LIBRARY_PATH = $LD_LIBRARY_PATH
    "

    python setup.py bdist_wheel

    WHEEL_FPATH=$(ls dist/mmdet*.whl)
    chmod 666 $WHEEL_FPATH
    echo $WHEEL_FPATH

    pip install ubelt
    TORCH_VERSION=$(python -c "import torch; print(torch.__version__)")
    echo "TORCH_VERSION = $TORCH_VERSION"
    DEST_WHEEL_FPATH=$(python -c "import ubelt as ub; print(ub.augpath('$WHEEL_FPATH', dpath='', suffix='_cuda${CUDA_VERSION_SHORT}_torch${TORCH_VERSION}'))")
    echo $DEST_WHEEL_FPATH
     
    cp "$WHEEL_FPATH" "/io/${DEST_WHEEL_FPATH}"
    chmod 666 "/io/${DEST_WHEEL_FPATH}"



    __debug__="""

    pip install dist/*.whl

    python -c 'import mmdet.ops' 

    cd ~/mmdetection/tests
    pip install pytest xdoctest
    pytest test_forward.py

    cd /io/wheelhouse

    pip install -r /io/requirements.txt

    pip install mmdet.*.whl

    cd /io/_skbuild/linux-x86_64-3.7/cmake-install/mmdet/ops/nms
    python -c 'import torch; import nms_cuda' 

    python -c 'import mmdet.ops' 
    python -c 'import soft_nms_cpu' 

    find . -iname 'lib*.so' -delete

    conda create -n test37 python=3.7

    find /usr/local/ -iname 'libc10*'
    find $TORCH_DPATH -iname 'libc10*'

    """
fi
