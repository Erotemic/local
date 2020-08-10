build_fletch_for_viame(){

    FLETCH_REPO=$HOME/code/fletch

    # Manually clone fletch 
    mkdir -p $FLETCH_REPO/build-for-vivia
    cd $FLETCH_REPO/build-for-vivia

    cmake -G "Ninja"  \
        -D fletch_ENABLE_Qt=True \
        -D fletch_ENABLE_VTK=True \
        -D fletch_ENABLE_GDAL=True \
        -D fletch_ENABLE_Boost=True \
        -D fletch_ENABLE_libjson=True \
        -D fletch_ENABLE_libkml=True \
        -D fletch_ENABLE_GeographicLib=True \
        -D fletch_ENABLE_OpenCV=True \
        -D fletch_ENABLE_libgeotiff=True \
        -D fletch_ENABLE_libtiff=True \
        -D fletch_ENABLE_libjpeg-turbo=True \
        -D fletch_ENABLE_PROJ4=True \
        -D fletch_ENABLE_VXL=True \
        -D Qt_SELECT_VERSION=5.11.2 \
        -D VTK_SELECT_VERSION=8.2 \
        -D GDAL_SELECT_VERSION=1.11.5 \
        -D fletch_ENABLE_ZLib:BOOL=True \
        -D fletch_ENABLE_PNG:BOOL=True \
        -D fletch_ENABLE_CppDB:BOOL=True \
        -D fletch_ENABLE_Eigen:BOOL=True \
        -D fletch_ENABLE_PostgreSQL:BOOL=True \
        -D fletch_ENABLE_FFmpeg:BOOL=True \
        -D fletch_ENABLE_log4cplus:BOOL=True \
        -D fletch_ENABLE_libxml2:BOOL=True \
        -D fletch_ENABLE_TinyXML1:BOOL=True \
        $HOME/code/fletch

    #-D GDAL_SELECT_VERSION=1.11.5  # Breaks with libtiff
    make -j20

    FLETCH_INSTALL=$HOME/code/fletch/build-for-vivia-internal/install
}


build_viame(){

    # Qt has an issue with libSM and libuuid when building in a conda environment
    conda install -c conda-forge xorg-libsm

    cd ~/code
    if [ ! -d "$HOME/code/VIAME" ]; then
        git clone https://github.com/Kitware/VIAME.git ~/code/VIAME
        cd ~/code/VIAME
        #git remote add Erotemic https://github.com/Erotemic/VIAME.git
        git pull source master
    fi

    REPO_DIR=$HOME/code/VIAME
    cd $REPO_DIR

    #git checkout next
    #git pull origin next
    git submodule update --init --recursive


    PYTHON_VERSION=$(python -c "import sys; info = sys.version_info; print('{}.{}'.format(info.major, info.minor))")
    PYTHON_MAJOR_VERSION==$(python -c "import sys; info = sys.version_info; print('{}'.format(info.major))")
    echo "PYTHON_VERSION = $PYTHON_VERSION"
    echo "PYTHON_MAJOR_VERSION = $PYTHON_MAJOR_VERSION"
    # Check if we have a venv setup
    # The prefered case where we are in a virtual environment

    #LOCAL_PREFIX=$CONDA_PREFIX
    ##LOCAL_PREFIX=$VIRTUAL_ENV/
    #PYTHON_PACKAGES_PATH=$LOCAL_PREFIX/lib/python$PY_VERSION/site-packages
    #PYTHON_INCLUDE_DIR=$LOCAL_PREFIX/include/python"$PY_VERSION"m
    #PYTHON_LIBRARY=$LOCAL_PREFIX/lib/python$PY_VERSION/config-"$PY_VERSION"m-x86_64-linux-gnu/libpython"$PY_VERSION".so

    VIAME_BUILD=$HOME/code/VIAME/build-py$PYTHON_VERSION

    echo "VIAME_BUILD = $VIAME_BUILD"

    mkdir -p $VIAME_BUILD
    cd $VIAME_BUILD

    cmake \
        -D VIAME_ENABLE_PYTHON:BOOL=True \
        -D VIAME_DISABLE_PYTHON_CHECK:BOOL=True \
        -D VIAME_SYMLINK_PYTHON:BOOL=True \
        $REPO_DIR

        #-D VIAME_OPENCV_VERSION="3.3.0" \
        #-D VIAME_ENABLE_CUDA:BOOL=True \
        #-D VIAME_ENABLE_CUDNN:BOOL=True \
        #-D VIAME_ENABLE_SMQTK:BOOL=True \
        #-D VIAME_ENABLE_VIVIA:BOOL=True \
        #-D VIAME_ENABLE_VIVIA:BOOL=True \
        #-D VIAME_ENABLE_CAFFE:BOOL=True \



        #-D VIAME_ENABLE_KWANT:BOOL=True \
}


build_noenv_python(){

    #sysconfig.get_config_vars()['SO']  # .cpython-38-x86_64-linux-gnu.so
    #sysconfig.get_config_vars()['multiarchsubdir']  # /x86_64-linux-gnu
    #sysconfig.get_config_vars()['SOABI']  # cpython-36m-x86_64-linux-gnu
    #sysconfig.get_config_vars()['PY3LIBRARY']  # libpython3.so
    #sysconfig.get_config_vars()['MULTIARCH']  # x86_64-linux-gnu
    #sysconfig.get_config_vars()['LIBPL']  # /usr/lib/python3.6/config-3.6m-x86_64-linux-gnu
    #sysconfig.get_config_vars()['LDLIBRARY']  # libpython3.6m.so
    #sysconfig.get_config_vars()['.cpython-38-x86_64-linux-gnu.so']

    PYTHON_EXECUTABLE=$(which python3)
    PYTHON_VERSION=$($PYTHON_EXECUTABLE -c "import sys; print('{}.{}'.format(*sys.version_info[0:2]))")
    PYTHON_INCLUDE_DIR=$($PYTHON_EXECUTABLE -c "import sysconfig; print(sysconfig.get_paths()['include'])")
    PYTHON_LIBRARY=$($PYTHON_EXECUTABLE -c "import sysconfig; print(sysconfig.get_config_vars()['LIBPL'] + '/' + sysconfig.get_config_vars()['LDLIBRARY'])")


    export CUDA_SDK_ROOT_DIR=$CUDA_TOOLKIT_ROOT_DIR
    export CUDA_HOST_COMPILER=$(which nvcc)

    export __PYTHON_ARGS__="
        -D PYTHON_VERSION=3.6 
        -D PYTHON_EXECUTABLE=$PYTHON_EXECUTABLE 
        -D PYTHON_LIBRARY=$PYTHON_LIBRARY 
        -D PYTHON_INCLUDE_DIR=$PYTHON_INCLUDE_DIR 
    "

    export __CUDA_ARGS__="
        -D CUDA_HOST_COMPILER=$CUDA_HOST_COMPILER 
        -D CUDA_SDK_ROOT_DIR=$CUDA_SDK_ROOT_DIR 
        -D CUDA_TOOLKIT_ROOT_DIR=$CUDA_TOOLKIT_ROOT_DIR 
    "
    echo "__PYTHON_ARGS__ = $__PYTHON_ARGS__"
    echo "__CUDA_ARGS__ = $__CUDA_ARGS__"

    CMAKE_ARGS="\
        $(echo $__PYTHON_ARGS__ | tr -d '\n') \
        $(echo $__CUDA_ARGS__ | tr -d '\n') \
    "
    cmake $CMAKE_ARGS ..
}
