ubuntu_system_deps(){
    sudo apt-get install -y google-mock

    # following can be optional if you turn them off in cmake or install via fletch
    sudo apt install -y liblmdb-dev
    sudo apt install -y libgflags-dev
    sudo apt install -y libgoogle-glog-dev
}

# References:
# https://caffe2.ai/docs/getting-started.html?platform=ubuntu&configuration=compile
cd ~/code
git clone --recursive https://github.com/caffe2/caffe2.git && cd caffe2

cd ~/code/caffe2
git pull
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
      -D USE_MPI=Off 
      -D USE_METAL=Off 
      -D USE_GLOO=Off 
      -D USE_GLOG=Off 
      -D USE_GFLAGS=Off 
      -D USE_ROCKSDB=Off 
      -D USE_MOBILE_OPENGL=Off 
      -D USE_CUDA=On"

    cd ~/code/caffe2
    CMAKE_ARGS="$CAFFE2_CMAKE_ARGS" python setup.py build
    #pip install -e $HOME/code/caffe2
}


build_gpu(){
    # BUILD WITH GPU
    cd ~/code/caffe2
    mkdir -p ~/code/caffe2/build_py3
    cd ~/code/caffe2/build_py3

    CAFFE2_CMAKE_ARGS="
      -D USE_MPI=Off 
      -D USE_METAL=Off 
      -D USE_GLOO=Off 
      -D USE_GLOG=Off 
      -D USE_GFLAGS=Off 
      -D USE_ROCKSDB=Off 
      -D USE_MOBILE_OPENGL=Off 
      -D USE_CUDA=On"

    CAFFE2_CMAKE_ARGS="
      -D USE_GLOG=On 
      -D USE_GFLAGS=On 
      -D USE_MPI=Off 
      -D USE_METAL=Off 
      -D USE_GLOO=Off 
      -D USE_ROCKSDB=Off 
      -D USE_MOBILE_OPENGL=Off 
      -D USE_CUDA=On"


    cmake -G "Unix Makefiles" \
      $CAFFE2_CMAKE_ARGS \
      -D CMAKE_INSTALL_PREFIX=$HOME/venv3 \
      -D PYTHON_LIBRARY="$VENV_LIB" \
      -D PYTHON_INCLUDE_DIR="$VENV_INCLUDE" \
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
