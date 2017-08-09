#!/bin/bash


test_fletch_branch-opencv-3-1()
{
    FLETCH_BRANCH="test/update-opencv-3.3"
    mkdir -p $HOME/dash/$FLETCH_BRANCH
    FLETCH_REPO_DIR=$HOME/dash/$FLETCH_BRANCH/fletch
    git clone -b $FLETCH_BRANCH https://github.com/Erotemic/fletch.git $FLETCH_REPO_DIR
    git checkout $FLETCH_BRANCH
    git reset origin/$FLETCH_BRANCH --hard
    git pull

    workon_py2

    echo FLETCH_REPO_DIR = $FLETCH_REPO_DIR
    mkdir -p $FLETCH_REPO_DIR/build
    cd $FLETCH_REPO_DIR/build 
    rm -rf $FLETCH_REPO_DIR/build/*
    cmake -G "Unix Makefiles" \
        -D fletch_BUILD_WITH_PYTHON=On \
        -D fletch_ENABLE_ALL_PACKAGES=On \
        $FLETCH_REPO_DIR

    # Disable building really big repos
    cmake -G "Unix Makefiles" \
        -D fletch_ENABLE_Qt=Off \
        -D fletch_ENABLE_VTK=Off \
        $FLETCH_REPO_DIR

    make
}

test_fletch_branch_31()
{
    FLETCH_PYTHON_VENV=2
    FLETCH_BRANCH="test/update-opencv-3.3"
    FLETCH_BUILD_SUFFIX="-3-1"
    FLETCH_CMAKE_ARGS="-D OpenCV_SELECT_VERSION=3.1.0 -D fletch_ENABLE_Qt=Off -D fletch_ENABLE_VTK=Off"
    test_fletch_py2_branch
}

test_fletch_branch_33()
{
    source ~/local/build_scripts/init_fletch.sh
    FLETCH_ENABLE_ALL="On"
    FLETCH_REBUILD="On"
    TEST_KWIVER="On"
    FLETCH_PYTHON_VENV=2
    FLETCH_BRANCH="test/update-opencv-3.3"
    FLETCH_BUILD_SUFFIX="-3-3"
    NCPUS=9
    FLETCH_CMAKE_ARGS="\
        -D OpenCV_SELECT_VERSION=3.3.0 -D fletch_ENABLE_Qt=Off \
        -D fletch_ENABLE_VTK=Off -D fletch_BUILD_WITH_PYTHON=On"
    test_fletch_py2_branch

    source ~/local/build_scripts/init_fletch.sh
    FLETCH_ENABLE_ALL="Off"
    FLETCH_REBUILD="On"
    TEST_KWIVER="Off"
    FLETCH_PYTHON_VENV=2
    NCPUS=3
    FLETCH_BRANCH="test/update-opencv-3.3"
    FLETCH_BUILD_SUFFIX="-3-3-cv-ff"
    FLETCH_CMAKE_ARGS="\
        -D OpenCV_SELECT_VERSION=3.3.0 -D fletch_ENABLE_OpenCV=On \
        -D fletch_ENABLE_FFmpeg=On -D fletch_ENABLE_Qt=Off \
        -D fletch_ENABLE_VTK=Off -D fletch_BUILD_WITH_PYTHON=On"
    test_fletch_py2_branch 
}


test_fletch_master()
{
    source ~/local/build_scripts/init_fletch.sh
    FLETCH_ENABLE_ALL="Off"
    FLETCH_REBUILD="Off"
    FLETCH_PYTHON_VENV=2
    TEST_KWIVER="Off"

    FLETCH_BRANCH="master"
    FLETCH_BUILD_SUFFIX="-ffmpeg-only"
    FLETCH_CMAKE_ARGS="-D fletch_ENABLE_FFmpeg=On"
    test_fletch_py2_branch

    FLETCH_REBUILD="On"
    FLETCH_BRANCH="dev/update-ffmpeg-3.3.3"
    FLETCH_BUILD_SUFFIX="-ffmpeg-only-3.3"
    FLETCH_CMAKE_ARGS="-D fletch_ENABLE_FFmpeg=On -D FFMpeg_SELECT_VERSION=3.3.3"
    test_fletch_py2_branch 
    ldd install/lib/libavcodec.so

    FLETCH_BRANCH="dev/update-ffmpeg-3.3.3"
    FLETCH_BUILD_SUFFIX="-ffmpeg-only-2.6"
    FLETCH_CMAKE_ARGS="-D fletch_ENABLE_FFmpeg=On -D FFMpeg_SELECT_VERSION=2.6.2"
    test_fletch_py2_branch 
    ldd install/lib/libavcodec.so

    rm -rf build/src/FFmpeg-stamp/
    find . -iname *.so -delete

    cat ../CMake/External_FFmpeg.cmake
}


test_fletch_py2_branch()
{
    "
    source ~/local/build_scripts/init_fletch.sh
    "
    echo " 
    FLETCH_BRANCH = $FLETCH_BRANCH
    FLETCH_BUILD_SUFFIX = $FLETCH_BUILD_SUFFIX
    FLETCH_CMAKE_ARGS = $FLETCH_CMAKE_ARGS
    TEST_KWIVER = $TEST_KWIVER
    FLETCH_ENABLE_ALL = $FLETCH_ENABLE_ALL
    FLETCH_REBUILD = $FLETCH_REBUILD
    FLETCH_PYTHON_VENV = $FLETCH_PYTHON_VENV
    "

    FLETCH_REPO_DIR=$HOME/dash/$FLETCH_BRANCH/fletch

    mkdir -p $HOME/dash/$FLETCH_BRANCH
    git clone -b $FLETCH_BRANCH https://github.com/Erotemic/fletch.git $FLETCH_REPO_DIR
    cd $FLETCH_REPO_DIR
    git checkout $FLETCH_BRANCH
    git fetch origin
    git reset origin/$FLETCH_BRANCH --hard

    if [ "$FLETCH_PYTHON_VENV" == "2" ]; then
        workon_py2
    else
        workon_py3
    fi

    echo " 
    FLETCH_REPO_DIR = $FLETCH_REPO_DIR
    FLETCH_CMAKE_ARGS = $FLETCH_CMAKE_ARGS
    "

    FLETCH_BUILD_DIR=$FLETCH_REPO_DIR/build$FLETCH_BUILD_SUFFIX
    mkdir -p $FLETCH_BUILD_DIR
    cd $FLETCH_BUILD_DIR 
    if [ "$FLETCH_REBUILD" == "On" ]; then
        rm -rf $FLETCH_BUILD_DIR/*
    fi

    if [ "$FLETCH_ENABLE_ALL" == "On" ]; then
        # enable everything first
        cmake -G "Unix Makefiles" \
            -D fletch_ENABLE_ALL_PACKAGES=On \
            $FLETCH_CMAKE_ARGS \
            $FLETCH_REPO_DIR
    fi 

    # then disable packages as needed
    cmake -G "Unix Makefiles" \
        $FLETCH_CMAKE_ARGS \
        $FLETCH_REPO_DIR

    make -j$NCPUS

    if [ "$TEST_KWIVER" == "On" ]; then
        # TEST WITH KWIVER
        #KWIVER_BRANCH=release
        KWIVER_BRANCH=master
        KWIVER_REPO_DIR=$HOME/dash/$KWIVER_BRANCH/kwiver
        mkdir -p $HOME/dash/$KWIVER_BRANCH
        git clone -b $KWIVER_BRANCH https://github.com/Erotemic/kwiver.git $KWIVER_REPO_DIR

        cd $KWIVER_REPO_DIR
        git checkout $KWIVER_BRANCH
        git fetch origin
        git reset origin/$KWIVER_BRANCH --hard

        KWIVER_BUILD_DIR=$KWIVER_REPO_DIR/build/$FLETCH_BRANCH/$SUFFIX
        mkdir -p $KWIVER_BUILD_DIR
        cd $KWIVER_BUILD_DIR
        rm -rf $KWIVER_BUILD_DIR/*

        cmake -G "Unix Makefiles" \
            -D fletch_DIR:PATH=$FLETCH_BUILD_DIR \
            -D KWIVER_ENABLE_ARROWS=On \
            -D KWIVER_ENABLE_TRACK_ORACLE=On \
            -D KWIVER_ENABLE_SPROKIT=On \
            -D KWIVER_ENABLE_PROCESSES=On \
            -D KWIVER_ENABLE_TESTS=On \
            -D KWIVER_ENABLE_LOG4CPLUS=On \
            -D KWIVER_ENABLE_TOOLS=On \
            $KWIVER_REPO_DIR

        make -j$NCPUS

        ctest
    fi
}

update_symbolic_rebases()
{
    symbolic_rebase -e master -b test/update-opencv-3.3 -d="dev/update-openblas-0.2.20 test/update-opencv dev/update-ffmpeg-3.3.3"

    BASE=master 
    BRANCH=test/update-opencv-3.3 
    DEPENDS="dev/update-openblas-0.2.20 test/update-opencv dev/update-ffmpeg-3.3.3"
    symbolic_rebase $BASE $BRANCH $DEPENDS
        
    BASE=master
    BRANCH=dev/python3-support
    DEPENDS="dev/find_numpy dev/update-openblas-0.2.20 dev/update-vtk dev/update-caffe dev/update-ffmpeg-3.3.3 test/update-opencv-3.3"

    symbolic_rebase --base=master --branch=dev/python3-support --depends="$DEPENDS"

    symbolic_rebase.sh --base=master --branch=dev/python3-support \
        --depends="dev/find_numpy dev/update-openblas-0.2.20 dev/update-opencv dev/update-vtk dev/update-caffe"
}

# delete remote branch
#git push origin --delete test/upate-opencv

symbolic_rebase_clean(){
    git checkout master
    git reset --hard source/master

    git checkout $BASE
    git branch -D $BRANCH
    git branch -D $PRE_BRANCH
    
    git branch -D new/$PRE_BRANCH
    git push origin --delete new/$PRE_BRANCH

    git branch -D tmp/pre/test/update-opencv-3.3
    git push origin --delete test/update-opencv-3.3
}


#symbolic_rebase(){
# See ~/local/scripts/ubuntu_scripts/symbolic_rebase.sh
#}

main(){

    git clone https://github.com/Erotemic/fletch.git ~/code/fletch


    cd ~/code/fletch
    git checkout dev/python3-support


    PYTHON_EXECUTABLE=$(which python)
    PY_VERSION=$(python -c "import sys; info = sys.version_info; print('{}.{}'.format(info.major, info.minor))")
    PLAT_NAME=$(python -c "import setuptools, distutils; print(distutils.util.get_platform())")
    REPO_DIR=~/code/fletch
    #BUILD_DIR="$REPO_DIR/cmake_builds/build.$PLAT_NAME-$PY_VERSION"
    BUILD_DIR="$REPO_DIR/build"

    get_py_config_var()
    {
        python -c "from distutils import sysconfig; print(sysconfig.get_config_vars()['$1'])"
    }

    # Check if we have a venv setup
    if [[ "$VIRTUAL_ENV" == ""  ]]; then
        # The case where we are installying system-wide
        # It is recommended that a virtual enviornment is used instead
        _SUDO="sudo"
        if [[ '$OSTYPE' == 'darwin'* ]]; then
            # Mac system info
            LOCAL_PREFIX=/opt/local
            PYTHON_PACKAGES_PATH=$($PYTHON_EXECUTABLE -c "import site; print(site.getsitepackages()[0])")
        else
            # Linux system info
            LOCAL_PREFIX=/usr/local
            PYTHON_PACKAGES_PATH=$LOCAL_PREFIX/lib/python$PY_VERSION/dist-packages
        fi
        export PYTHON_LIBRARY=$(get_py_config_var 'LIBDIR')/$(get_py_config_var 'LDLIBRARY')
        export PYTHON_INCLUDE_DIR=$(get_py_config_var 'INCLUDEPY')
        # No windows support here
    else
        # The prefered case where we are in a virtual environment
        #LOCAL_PREFIX=$VIRTUAL_ENV/local
        _SUDO=""
        LOCAL_PREFIX=$VIRTUAL_ENV
        PYTHON_PACKAGES_PATH=$LOCAL_PREFIX/lib/python$PY_VERSION/site-packages
        PYTHON_INCLUDE_DIR=$LOCAL_PREFIX/include/python"$PY_VERSION"m
        PYTHON_LIBRARY=$LOCAL_PREFIX/lib/python$PY_VERSION/config-"$PY_VERSION"m-x86_64-linux-gnu/libpython"$PY_VERSION".so
    fi


    echo "
    ======================
    VARIABLE CONFIGURATION
    ======================
    # Intermediate vars
    PY_VERSION=$PY_VERSION
    PLAT_NAME=$PLAT_NAME
    # Final vars
    _SUDO=$_SUDO
    REPO_DIR=$REPO_DIR
    BUILD_DIR=$BUILD_DIR
    LOCAL_PREFIX=$LOCAL_PREFIX
    PYTHON_EXECUTABLE=$PYTHON_EXECUTABLE
    PYTHON_LIBRARY=$PYTHON_LIBRARY
    PYTHON_INCLUDE_DIR=$PYTHON_INCLUDE_DIR
    PYTHON_PACKAGES_PATH=$PYTHON_PACKAGES_PATH
    "


    mkdir -p $BUILD_DIR
    cd $BUILD_DIR
    cmake -G "Unix Makefiles" \
        -D fletch_ENABLE_ALL_PACKAGES=True \
        -D fletch_BUILD_WITH_PYTHON=True \
        -D fletch_BUILD_WITH_MATLAB=False \
        -D fletch_BUILD_WITH_CUDA=False \
        -D fletch_BUILD_WITH_CUDNN=False \
        $REPO_DIR


    mkdir -p $BUILD_DIR
    (cd $BUILD_DIR && cmake -G "Unix Makefiles" \
        -D CMAKE_BUILD_TYPE=RELEASE \
        -D CMAKE_INSTALL_PREFIX=$LOCAL_PREFIX \
        -D fletch_ENABLE_ALL_PACKAGES=True \
        -D fletch_BUILD_WITH_PYTHON=True \
        -D fletch_BUILD_WITH_MATLAB=False \
        -D fletch_BUILD_WITH_CUDA=False \
        -D fletch_BUILD_WITH_CUDNN=False \
        -D OpenCV_SELECT_VERSION=3.2.0 \
        -D VTK_SELECT_VERSION=8.0.0 \
        -D fletch_PYTHON_VERSION=3.5 \
        -D PYTHON_EXECUTABLE=$PYTHON_EXECUTABLE \
        -D PYTHON_INCLUDE_DIR=$PYTHON_INCLUDE_DIR \
        -D PYTHON_LIBRARY=$PYTHON_LIBRARY \
        -D fletch_ENABLE_Boost=True \
        -D fletch_ENABLE_Caffe=True \
        -D fletch_ENABLE_Ceres=True \
        -D fletch_ENABLE_Eigen=True \
        -D fletch_ENABLE_FFmpeg=True \
        -D fletch_ENABLE_GeographicLib=True \
        -D fletch_ENABLE_GFlags=True \
        -D fletch_ENABLE_GLog=True \
        -D fletch_ENABLE_HDF5=True \
        -D fletch_ENABLE_ITK=FALSE \
        -D fletch_ENABLE_jom=True \
        -D fletch_ENABLE_LevelDB=True \
        -D fletch_ENABLE_libjpeg-turbo=True \
        -D fletch_ENABLE_libjson=True \
        -D fletch_ENABLE_libkml=True \
        -D fletch_ENABLE_libtiff=True \
        -D fletch_ENABLE_libxml2=True \
        -D fletch_ENABLE_LMDB=True \
        -D fletch_ENABLE_log4cplus=True \
        -D fletch_ENABLE_OpenBLAS=True \
        -D fletch_ENABLE_OpenCV=True \
        -D fletch_ENABLE_OpenCV_contrib=True \
        -D fletch_ENABLE_PNG=True \
        -D fletch_ENABLE_PROJ4=True \
        -D fletch_ENABLE_Protobuf=True \
        -D fletch_ENABLE_Qt=True \
        -D fletch_ENABLE_shapelib=True \
        -D fletch_ENABLE_Snappy=True \
        -D fletch_ENABLE_SuiteSparse=True \
        -D fletch_ENABLE_TinyXML=True \
        -D fletch_ENABLE_VTK=True \
        -D fletch_ENABLE_VXL=True \
        -D fletch_ENABLE_yasm=True \
        -D fletch_ENABLE_ZLib=True \
        $REPO_DIR)
    # Did Cmake fail?
    CMAKE_EXITCODE=$?
    echo "CMAKE_EXITCODE = $CMAKE_EXITCODE"

    echo "--- FINISHED CMAKE ---"
    #sleep 5s

    codeblock()
    {
        # Prevents python indentation errors in bash
        python -c "from textwrap import dedent; print(dedent('''$1''').strip('\n'))"
        #python -c "import utool as ut; print(ut.codeblock('''$1'''))"
    }

    cpu_arch_id()
    {
        TO_PARSE=$(gcc -march=native -Q --help=target|grep march)
        # TODO: it would be nice to figure out a bash way to unindent
        python -c "$(codeblock "
        import re
        march_str = '$TO_PARSE'
        parts = re.sub('  *', ' ', march_str.replace('\\t', '')).strip().split(' ')
        print(parts[-1].upper()) 
        ")"
    }



    if [[ $CMAKE_EXITCODE == 0 ]]; then
        NCPUS=$(grep -c ^processor /proc/cpuinfo)
        #NCPUS=1

        if [ "$CLEAN_MARCH" == "$(cpu_arch_id)" ]; then
            # use target=haswell on broadwell systems
            #make -j$NCPUS --directory=$BUILD_DIR TARGET=HASWEL
            #(cd $BUILD_DIR && make TARGET=HASWELL)
            (cd $BUILD_DIR && make -j$NCPUS TARGET=HASWELL)
            #make --directory=$BUILD_DIR TARGET=HASWEL
        else
            #(cd $BUILD_DIR && make)
            (cd $BUILD_DIR && make -j$NCPUS)
            #make -j$NCPUS --directory=$BUILD_DIR
            #make --directory=$BUILD_DIR
        fi
    else
        echo "Cmake Generation Failed"
    fi
}
