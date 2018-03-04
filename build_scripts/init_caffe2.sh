ubuntu_system_deps(){
    sudo apt-get install -y google-mock

    # following can be optional if you turn them off in cmake or install via fletch
    sudo apt install -y liblmdb-dev
    sudo apt install -y libgflags-dev
    sudo apt install -y libgoogle-glog-dev

    # NOTE: the ubuntu 16.04 system protobuf is too old, need to build a newer version
}

# References:
# https://caffe2.ai/docs/getting-started.html?platform=ubuntu&configuration=compile
cd ~/code
git clone --recursive https://github.com/caffe2/caffe2.git && cd caffe2

cd ~/code/caffe2
git checkout v0.8.1
#git pull
git submodule update --init --recursive

# make && cd build && sudo make install
# python -c 'from caffe2.python import core' 2>/dev/null && echo "Success" || echo "Failure"


# Get venv location of the include dir
VENV_INCLUDE=$(python -c "import os, sys, distutils; print(os.path.join(sys.prefix, 'include', 'python' + distutils.sysconfig.get_config_var('LDVERSION')))")
# Venv doesnt actually store lib, so link to the system one
VENV_LIB=$(python -c "
import sys, distutils, os
vars = distutils.sysconfig.get_config_vars()
libpath = os.path.join(vars['LIBDIR'], vars['MULTIARCH'], vars['LDLIBRARY'])
print(libpath)
")
echo "VENV_INCLUDE = $VENV_INCLUDE"
echo "VENV_LIB = $VENV_LIB"


#export CUDNN_INCLUDE_DIR=/usr/local/cuda/include
#export CUDNN_LIB_DIR=/usr/local/cuda/lib64
#export CUDNN_LIBRARY=$CUDNN_LIB_DIR/libcudnn.so
#export CUDNN_LIBRARIES=$CUDNN_LIBRARY


# I assume you have these variables defined in your bashrc
echo "CUDNN_LIBRARY = $CUDNN_LIBRARY"
echo "CUDNN_INCLUDE_DIR = $CUDNN_INCLUDE_DIR"

# Do we need to add fletch?
if []; then
    export FLETCH_INSTALL=$HOME/code/fletch/build-py3/install
    export CMAKE_PREFIX_PATH=$FLETCH_INSTALL:$CMAKE_PREFIX_PATH
    export CPATH=$FLETCH_INSTALL/include:$CPATH
    export LD_LIBRARY_PATH=$FLETCH_INSTALL/lib:$LD_LIBRARY_PATH
fi


build_withpip(){
    CAFFE2_CMAKE_ARGS="
      -D CMAKE_EXPORT_NO_PACKAGE_REGISTRY=True
      -D CMAKE_FIND_PACKAGE_NO_PACKAGE_REGISTRY=True
      -D CMAKE_FIND_PACKAGE_NO_SYSTEM_PACKAGE_REGISTRY=True
      -D USE_MPI=Off 
      -D USE_METAL=Off 
      -D USE_GLOO=Off 
      -D USE_GLOG=Off 
      -D USE_GFLAGS=Off 
      -D USE_ROCKSDB=Off 
      -D BUILD_CUSTOM_PROTOBUF=ON
      -D BLAS=OpenBLAS 
      -D USE_MOBILE_OPENGL=Off 
      -D USE_CUDA=On"

    cd ~/code/caffe2
    CMAKE_ARGS="$CAFFE2_CMAKE_ARGS" python setup.py build
    #pip install -e $HOME/code/caffe2
}


build_gpu(){
    # BUILD WITH GPU
    cd ~/code/caffe2
    mkdir -p ~/code/caffe2/build_gpu
    cd ~/code/caffe2/build_gpu

    #CAFFE2_CMAKE_ARGS="
    #  -D USE_MPI=Off 
    #  -D USE_METAL=Off 
    #  -D USE_GLOO=Off 
    #  -D USE_GLOG=Off 
    #  -D BUILD_CUSTOM_PROTOBUF=ON
    #  -D USE_GFLAGS=Off 
    #  -D USE_ROCKSDB=Off 
    #  -D USE_MOBILE_OPENGL=Off 
    #  -D BLAS=OpenBLAS 
    #  -D CMAKE_EXPORT_NO_PACKAGE_REGISTRY=True
    #  -D CMAKE_FIND_PACKAGE_NO_PACKAGE_REGISTRY=True
    #  -D CMAKE_FIND_PACKAGE_NO_SYSTEM_PACKAGE_REGISTRY=True
    #  -D USE_CUDA=On"

    CAFFE2_CMAKE_ARGS="
      -D USE_GLOG=On 
      -D USE_GFLAGS=On 
      -D USE_MPI=Off 
      -D USE_METAL=Off 
      -D BUILD_CUSTOM_PROTOBUF=ON
      -D USE_GLOO=Off 
      -D USE_NCCL=Off 
      -D BUILD_TEST=Off 
      -D USE_ROCKSDB=Off 
      -D BLAS=OpenBLAS 
      -D USE_OPENCV=OFF
      -D CMAKE_EXPORT_NO_PACKAGE_REGISTRY=True
      -D CMAKE_FIND_PACKAGE_NO_PACKAGE_REGISTRY=True
      -D CMAKE_FIND_PACKAGE_NO_SYSTEM_PACKAGE_REGISTRY=True
      -D USE_MOBILE_OPENGL=Off 
      -D USE_CUDA=On"

    VENV_INCLUDE=$(python -c "import os, sys, distutils; print(os.path.join(sys.prefix, 'include', 'python' + distutils.sysconfig.get_config_var('LDVERSION')))")
    # Venv doesnt actually store lib, so link to the system one
    VENV_LIB=$(python -c "
    import sys, distutils, os
    vars = distutils.sysconfig.get_config_vars()
    libpath = os.path.join(vars['LIBDIR'], vars['MULTIARCH'], vars['LDLIBRARY'])
    print(libpath)
    ")
    echo "VENV_INCLUDE = $VENV_INCLUDE"
    echo "VENV_LIB = $VENV_LIB"
    NUMPY_INCLUDE_DIR=$(python -c "import numpy as np; print(np.get_include())")
    echo "NUMPY_INCLUDE_DIR = $NUMPY_INCLUDE_DIR"

    # USE FLETCH DEPS
    CAFFE2_INSTALL_PREFIX=$HOME/code/fletch/build-caffe2/install
    export PYTHONPATH=$CAFFE2_INSTALL_PREFIX/lib/python3.5/site-packages:$PYTHONPATH
    export CPATH=$CAFFE2_INSTALL_PREFIX/include:$CPATH
    export LD_LIBRARY_PATH=$CAFFE2_INSTALL_PREFIX/lib:$LD_LIBRARY_PATH
    ####

    #rm CMakeCache.txt && 
    cmake -G "Unix Makefiles" \
      $CAFFE2_CMAKE_ARGS \
      -D CMAKE_INSTALL_PREFIX=$HOME/venv3 \
      -D PYTHON_LIBRARY="$VENV_LIB" \
      -D PYTHON_INCLUDE_DIR="$VENV_INCLUDE" \
      -D NUMPY_INCLUDE_DIR=$NUMPY_INCLUDE_DIR \
      -D NUMPY_VERSION=python -c "import numpy as np; print(np.__version__)" \
      -D CUDNN_LIBRARY="$CUDNN_LIBRARY" \
      -D CUDNN_INCLUDE_DIR="$CUDNN_INCLUDE_DIR" \
      ~/code/caffe2
      make -j20

    # OR
    CMAKE_ARGS="-DUSE_CUDA=On" python setup.py build
}


build_cpu(){
    # BUILD WITH CPU ONLY
    cd ~/code/caffe2
    mkdir -p ~/code/caffe2/build_cpu_py3
    cd ~/code/caffe2/build_cpu_py3

    CMAKE_ARGS="
      -D USE_MPI=Off \
      -D USE_METAL=Off \
      -D USE_GLOO=Off \
      -D USE_GLOG=Off \
      -D USE_GFLAGS=Off \
      -D USE_GMOCK=Off \
      -D USE_ROCKSDB=Off \
      -D USE_MOBILE_OPENGL=Off \
      -D USE_CUDA=Off
      "

    cmake -G "Unix Makefiles" \
        $CMAKE_ARGS \
      -D CMAKE_INSTALL_PREFIX=$HOME/venv3 \
      -D PYTHON_LIBRARY="$VENV_LIB" \
      -D PYTHON_INCLUDE_DIR="$VENV_INCLUDE" \
      ~/code/caffe2
    make -j5

    # OR
    CMAKE_ARGS="$CMAKE_ARGS" python setup.py build
}

fixup(){
    # https://github.com/caffe2/caffe2/issues/1676
    SITE_DIR=$(python -c "from distutils import sysconfig; print(sysconfig.get_python_lib(prefix=''))")
    # Currently need to move caffe2 into PYTHONPATH
    PREFIX=$(python -c "import sys; print(sys.prefix)")
    mv $PREFIX/caffe2 $PREFIX/$SITE_DIR
}

cleanup(){
    cd ~/venv3
    find . -iname "*caffe2*"
    find . -iname "*caffe*"
    PREFIX=$HOME/venv3
    rm -rf $PREFIX/share/cmake/Caffe2
    rm -rf $PREFIX/caffe2
    rm -rf $PREFIX/include/caffe2

    pip uninstall onnx_caffe2

    # REMOVE caffe

    SITE_DIR=$(python -c "from distutils import sysconfig; print(sysconfig.get_python_lib(prefix=''))")
    PREFIX=$(python -c "import sys; print(sys.prefix)")
    rm -rf $PREFIX/$SITE_DIR/caffe2
    rm -rf $PREFIX/$SITE_DIR/caffe
}

test(){

    python -c "from caffe2.python import core"
    python -c 'from caffe2.python import core'
    python -c 'from caffe2.python import core' 2>/dev/null && echo "Success" || echo "Failure"
    python -m caffe2.python.operator_test.relu_op_test
}

build_caffe2_deps_via_fletch(){
    cd ~/code
    if [ ! -d "$HOME/code/fletch" ]; then
        git clone https://github.com/Erotemic/fletch.git ~/code/fletch
        cd ~/code/fletch
        git remote add source https://github.com/Kitware/fletch.git
        git pull source master
    fi

    we-py2
    PYTHON_VERSION=$(python -c "import sys; info = sys.version_info; print('{}.{}'.format(info.major, info.minor))")
    PYTHON_MAJOR_VERSION==$(python -c "import sys; info = sys.version_info; print('{}'.format(info.major))")
    
    # splitting out dependencies for easier visibility
    export OPENCV_DEPENDS=" \
        -D OpenCV_SELECT_VERSION=3.4.0 \
        -D fletch_ENABLE_OpenCV_CUDA:BOOL=False \
        -D fletch_ENABLE_ZLib:BOOL=True \
        -D fletch_ENABLE_VXL:BOOL=True \
        -D fletch_ENABLE_PNG:BOOL=True \
        -D fletch_ENABLE_libtiff:BOOL=True \
        -D fletch_ENABLE_libjson:BOOL=True \
        -D fletch_ENABLE_libjpeg-turbo:BOOL=True \
        -D fletch_ENABLE_libxml2:BOOL=True"

    export CAFFE2_DEPENDS=" \
        -D fletch_ENABLE_CUB:BOOL=True \
        -D fletch_ENABLE_Caffe2:BOOL=False \
        -D fletch_ENABLE_Eigen:BOOL=True \
        -D fletch_ENABLE_Protobuf:BOOL=True \
        -D Protobuf_SELECT_VERSION=3.4.1 \
        -D fletch_ENABLE_OpenBLAS:BOOL=True \
        -D fletch_ENABLE_OpenCV:BOOL=True \
        -D fletch_ENABLE_Snappy:BOOL=True \
        -D fletch_ENABLE_SuiteSparse:BOOL=True \
        -D fletch_ENABLE_LevelDB:BOOL=True \
        -D fletch_ENABLE_LMDB:BOOL=True \
        -D fletch_ENABLE_GLog:BOOL=True \
        -D fletch_ENABLE_GFlags:BOOL=True \
        -D fletch_ENABLE_GTest:BOOL=True \
        -D fletch_ENABLE_pybind11:BOOL=True \
        -D fletch_ENABLE_FFmpeg:BOOL=True \
        -D FFmpeg_SELECT_VERSION=3.3.3 \
        -D Boost_SELECT_VERSION=1.65.1 \
        -D fletch_ENABLE_Boost:BOOL=True"

    export PYTHON_DEPENDS=" \
        -D fletch_BUILD_WITH_PYTHON:BOOL=True \
        -D fletch_PYTHON_MAJOR_VERSION=3"
    echo "PYTHON_DEPENDS = $PYTHON_DEPENDS"

    export OTHER_DEPENDS=" \
        -D fletch_ENABLE_VXL:BOOL=False \
        -D fletch_BUILD_WITH_CUDA:BOOL=True \
        -D fletch_BUILD_WITH_CUDNN:BOOL=True"

    FLETCH_CMAKE_ARGS="$OTHER_DEPENDS $PYTHON_DEPENDS $OPENCV_DEPENDS $CAFFE2_DEPENDS"
    
    # Setup a build directory and build fletch
    FLETCH_BUILD=$HOME/code/fletch/build-caffe2-deps-py$PYTHON_MAJOR_VERSION
    mkdir -p $FLETCH_BUILD
    cd $FLETCH_BUILD

    cmake -G "Unix Makefiles" $FLETCH_CMAKE_ARGS ..

    NCPUS=$(grep -c ^processor /proc/cpuinfo)
    make -j$NCPUS

    # Need to fix the post-intall in version .8.1
    #mv install/caffe2 install/lib/python3.5/site-packages
    #mv install/caffe install/lib/python3.5/site-packages

    # TEST
    #(cd ../python && python -c "import caffe")
}



build_caffe2_via_fletch(){
    cd ~/code
    if [ ! -d "$HOME/code/fletch" ]; then
        git clone https://github.com/Erotemic/fletch.git ~/code/fletch
        cd ~/code/fletch
        git remote add source https://github.com/Kitware/fletch.git
        git pull source master
    fi

    # splitting out dependencies for easier visibility
    export OPENCV_DEPENDS=" \
        -D OpenCV_SELECT_VERSION=3.4.0 \
        -D fletch_ENABLE_OpenCV_CUDA:BOOL=False \
        -D fletch_ENABLE_ZLib:BOOL=True \
        -D fletch_ENABLE_VXL:BOOL=True \
        -D fletch_ENABLE_PNG:BOOL=True \
        -D fletch_ENABLE_libtiff:BOOL=True \
        -D fletch_ENABLE_libjson:BOOL=True \
        -D fletch_ENABLE_libjpeg-turbo:BOOL=True \
        -D fletch_ENABLE_libxml2:BOOL=True"

    export CAFFE2_DEPENDS=" \
        -D fletch_ENABLE_CUB:BOOL=True \
        -D fletch_ENABLE_Caffe2:BOOL=True \
        -D fletch_ENABLE_Eigen:BOOL=True \
        -D fletch_ENABLE_Protobuf:BOOL=True \
        -D Protobuf_SELECT_VERSION=3.4.1 \
        -D fletch_ENABLE_OpenBLAS:BOOL=True \
        -D fletch_ENABLE_OpenCV:BOOL=True \
        -D fletch_ENABLE_Snappy:BOOL=True \
        -D fletch_ENABLE_SuiteSparse:BOOL=True \
        -D fletch_ENABLE_LevelDB:BOOL=True \
        -D fletch_ENABLE_LMDB:BOOL=True \
        -D fletch_ENABLE_GLog:BOOL=True \
        -D fletch_ENABLE_GFlags:BOOL=True \
        -D fletch_ENABLE_GTest:BOOL=True \
        -D fletch_ENABLE_pybind11:BOOL=True \
        -D fletch_ENABLE_FFmpeg:BOOL=True \
        -D FFmpeg_SELECT_VERSION=3.3.3 \
        -D Boost_SELECT_VERSION=1.65.1 \
        -D fletch_ENABLE_Boost:BOOL=True"

    export PYTHON_DEPENDS=" \
        -D fletch_BUILD_WITH_PYTHON:BOOL=True \
        -D fletch_PYTHON_MAJOR_VERSION=3"
    echo "PYTHON_DEPENDS = $PYTHON_DEPENDS"

    export OTHER_DEPENDS=" \
        -D fletch_ENABLE_VXL:BOOL=False \
        -D fletch_BUILD_WITH_CUDA:BOOL=True \
        -D fletch_BUILD_WITH_CUDNN:BOOL=True"

    FLETCH_CMAKE_ARGS="$OTHER_DEPENDS $PYTHON_DEPENDS $OPENCV_DEPENDS $CAFFE2_DEPENDS"
    
    # Setup a build directory and build fletch
    FLETCH_BUILD=$HOME/code/fletch/build-caffe2
    mkdir -p $FLETCH_BUILD
    cd $FLETCH_BUILD

    cmake -G "Unix Makefiles" $FLETCH_CMAKE_ARGS ..

    NCPUS=$(grep -c ^processor /proc/cpuinfo)
    make -j$NCPUS

    # Need to fix the post-intall in version .8.1
    mv install/caffe2 install/lib/python3.5/site-packages
    mv install/caffe install/lib/python3.5/site-packages


    # TEST
    #(cd ../python && python -c "import caffe")
}

detectron(){
    CAFFE2_INSTALL_PREFIX=$HOME/code/fletch/build-caffe2/install
    export PYTHONPATH=$CAFFE2_INSTALL_PREFIX/lib/python3.5/site-packages:$PYTHONPATH
    export CPATH=$CAFFE2_INSTALL_PREFIX/include:$CPATH
    export LD_LIBRARY_PATH=$CAFFE2_INSTALL_PREFIX/lib:$LD_LIBRARY_PATH

    # To check if Caffe2 build was successful
    python -c 'from caffe2.python import core'
    python -c 'from caffe2.python import workspace; print(workspace.NumCudaDevices())'

    CAFFE2_BUILD=$HOME/code/fletch/build-caffe2/build/src/Caffe2-build

    CAFFE2_BUILD=$HOME/code/caffe2/build
    CAFFE2_INSTALL_PREFIX=$CAFFE2_BUILD
    export LD_LIBRARY_PATH=$CAFFE2_INSTALL_PREFIX/lib:$LD_LIBRARY_PATH
    export CMAKE_PREFIX_PATH=$CAFFE2_INSTALL_PREFIX:$CMAKE_PREFIX_PATH
    export PYTHONPATH=$CAFFE2_BUILD:$PYTHONPATH

    echo "CAFFE2_BUILD = $CAFFE2_BUILD"

    cd ~/code/Detectron/lib
    # Edit to remove the dumb python2 references
    make
    DETECTRON=$HOME/code/Detectron
    python $DETECTRON/tests/test_spatial_narrow_as_op.py

    mkdir -p ~/code/Detectron/lib/build
    cd ~/code/Detectron/lib/build

    cmake -G "Unix Makefiles" -D Caffe2_DIR=$CAFFE2_BUILD .
    cmake -G "Unix Makefiles" .

    #$FLETCH_CMAKE_ARGS ..
    #cmake -G "Unix Makefiles" -D Caffe2_DIR=$HOME/code/fletch/build-caffe2/build/src/Caffe2-build ..
    

    

}
