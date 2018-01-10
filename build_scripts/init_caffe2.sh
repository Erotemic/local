
# References:
# https://caffe2.ai/docs/getting-started.html?platform=ubuntu&configuration=compile
git clone --recursive https://github.com/caffe2/caffe2.git && cd caffe2

#git submodule update --init --recursive

cd ~/code/caffe2
# make && cd build && sudo make install
# python -c 'from caffe2.python import core' 2>/dev/null && echo "Success" || echo "Failure"

cd ~/code/caffe2
mkdir -p ~/code/caffe2/build_py3
cd ~/code/caffe2/build_py3


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


cmake -G "Unix Makefiles" \
  -D USE_MPI=Off \
  -D USE_METAL=Off \
  -D USE_GLOO=Off \
  -D USE_GLOG=Off \
  -D USE_GFLAGS=Off \
  -D USE_ROCKSDB=Off \
  -D USE_MOBILE_OPENGL=Off \
  -D PYTHON_LIBRARY="$VENV_LIB" \
  -D PYTHON_INCLUDE_DIR="$VENV_INCLUDE" \
  ~/code/caffe2

  #USE_CUDA=On \

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
}

test(){

    python -c "from caffe2.python import core"
    python -c 'from caffe2.python import core'
    python -c 'from caffe2.python import core' 2>/dev/null && echo "Success" || echo "Failure"
    python -m caffe2.python.operator_test.relu_op_test
}

