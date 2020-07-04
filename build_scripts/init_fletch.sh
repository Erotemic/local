#!/bin/bash

prereq(){
    sudo apt install libreadline-dev
}


simple(){
    cd ~/code
    if [ ! -d "$HOME/code/fletch" ]; then
        git clone https://github.com/Erotemic/fletch.git ~/code/fletch
        cd ~/code/fletch
        git remote add source https://github.com/Kitware/fletch.git
        git pull source master
    fi


    OpenCV_SELECT_VERSION="3.4.0"
    #OpenCV_SELECT_VERSION=$(python -c "import cv2; print(cv2.__version__)")

    PYTHON_VERSION=$(python -c "import sys; info = sys.version_info; print('{}.{}'.format(info.major, info.minor))")
    PYTHON_MAJOR_VERSION==$(python -c "import sys; info = sys.version_info; print('{}'.format(info.major))")
    # Check if we have a venv setup
    # The prefered case where we are in a virtual environment
    LOCAL_PREFIX=$VIRTUAL_ENV/
    PYTHON_PACKAGES_PATH=$LOCAL_PREFIX/lib/python$PY_VERSION/site-packages
    PYTHON_INCLUDE_DIR=$LOCAL_PREFIX/include/python"$PY_VERSION"m
    PYTHON_LIBRARY=$LOCAL_PREFIX/lib/python$PY_VERSION/config-"$PY_VERSION"m-x86_64-linux-gnu/libpython"$PY_VERSION".so

    echo "
    ======================
    VARIABLE CONFIGURATION
    ======================
    # Intermediate vars
    PY_VERSION=$PY_VERSION
    PLAT_NAME=$PLAT_NAME
    # Final vars
    REPO_DIR=$REPO_DIR
    BUILD_DIR=$BUILD_DIR
    LOCAL_PREFIX=$LOCAL_PREFIX
    PYTHON_EXECUTABLE=$PYTHON_EXECUTABLE
    PYTHON_LIBRARY=$PYTHON_LIBRARY
    PYTHON_INCLUDE_DIR=$PYTHON_INCLUDE_DIR
    PYTHON_PACKAGES_PATH=$PYTHON_PACKAGES_PATH
    OpenCV_SELECT_VERSION=$OpenCV_SELECT_VERSION
    "

    # splitting out dependencies for easier visibility
    # dont build opencv with cuda, I dont think we use it
    export OPENCV_DEPENDS="
        -D fletch_ENABLE_OpenCV_CUDA:BOOL=False \
        -D fletch_ENABLE_ZLib:BOOL=True \
        -D fletch_ENABLE_VXL:BOOL=True \
        -D fletch_ENABLE_PNG:BOOL=True \
        -D fletch_ENABLE_libtiff:BOOL=True \
        -D fletch_ENABLE_libjson:BOOL=True \
        -D fletch_ENABLE_libjpeg-turbo:BOOL=True \
        -D fletch_ENABLE_libxml2:BOOL=True"

    export CAFFE_DEPENDS="
        -D fletch_ENABLE_Protobuf:BOOL=True \
        -D Protobuf_SELECT_VERSION=3.4.1 \
        -D fletch_ENABLE_LevelDB:BOOL=True \
        -D fletch_ENABLE_HDF5:BOOL=True \
        -D fletch_ENABLE_Snappy:BOOL=True \
        -D fletch_ENABLE_SuiteSparse:BOOL=True \
        -D fletch_ENABLE_GLog:BOOL=True \
        -D fletch_ENABLE_OpenBLAS:BOOL=True \
        -D fletch_ENABLE_OpenCV:BOOL=True \
        -D fletch_ENABLE_LMDB:BOOL=True \
        -D fletch_ENABLE_Boost:BOOL=True \
        -D fletch_ENABLE_GFlags:BOOL=True"

    export OTHER_OPTIONS="
        -D fletch_ENABLE_PostgreSQL:BOOL=True \
        -D fletch_ENABLE_pybind11:BOOL=True \
        -D fletch_ENABLE_GTest:BOOL=True \
        -D fletch_ENABLE_FFmpeg:BOOL=True \
        -D fletch_ENABLE_Eigen:BOOL=True \
        -D fletch_ENABLE_log4cplus:BOOL=True \
        -D fletch_ENABLE_Ceres=True"

    export BIG_OPTIONS="
        -D fletch_ENABLE_GeographicLib=True \
        -D fletch_ENABLE_VTK:BOOL=ON \
        -D fletch_ENABLE_PROJ4:BOOL=ON \
        -D fletch_ENABLE_libkml:BOOL=ON \
        -D fletch_ENABLE_TinyXML:BOOL=True \
        -D fletch_ENABLE_Qt:BOOL=ON"

    # Setup a build directory and build fletch
    FLETCH_BUILD=$HOME/code/fletch/build-py$PYTHON_VERSION

    mkdir -p $FLETCH_BUILD
    cd $FLETCH_BUILD
    cmake -G "Unix Makefiles" \
        -D fletch_BUILD_WITH_CUDA:BOOL=True \
        -D fletch_BUILD_WITH_CUDNN:BOOL=True \
        -D fletch_BUILD_WITH_PYTHON:BOOL=True \
        -D fletch_ENABLE_Caffe:BOOL=True \
        -D fletch_PYTHON_MAJOR_VERSION=$PYTHON_MAJOR_VERSION \
        -D CMAKE_INSTALL_PREFIX=$LOCAL_PREFIX \
        -D fletch_PYTHON_MAJOR_VERSION=3 \
        -D OpenCV_SELECT_VERSION=$OpenCV_SELECT_VERSION \
        $OPENCV_DEPENDS $CAFFE_DEPENDS $OTHER_OPTIONS $BIG_OPTIONS \
        ..

    NCPUS=$(grep -c ^processor /proc/cpuinfo)
    make -j$NCPUS

    # TEST
    #(cd ../python && python -c "import caffe")
}


update_symbolic_rebases()
{

    #symbolic_rebase(){
    # See ~/local/scripts/ubuntu_scripts/symbolic_rebase.sh
    #}
    
    symbolic_rebase -e master -b test/update-opencv-3.3 -d="dev/update-openblas-0.2.20 test/update-opencv dev/update-ffmpeg-3.3.3"

    BASE=master 
    BRANCH=test/update-opencv-3.3 
    DEPENDS="dev/update-openblas-0.2.20 dev/update-opencv dev/update-ffmpeg-3.3.3"
    symbolic_rebase $BASE $BRANCH $DEPENDS
        
    BASE=master
    BRANCH=dev/python3-support
    DEPENDS="dev/find_numpy dev/update-caffe dev/update-ffmpeg-3.3.3 dev/update-openblas-0.2.20 dev/update-opencv dev/update-vtk"
    ~/scripts/symbolic_rebase.sh --base=master --branch=dev/python3-support --depends="$DEPENDS"
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

test_fletch_master()
{
    source ~/local/build_scripts/init_fletch.sh
    FLETCH_ENABLE_ALL="On"
    FLETCH_REBUILD="Off"
    FLETCH_PYTHON_VENV=2
    TEST_KWIVER="On"

    FLETCH_BRANCH="master"
    FLETCH_BUILD_SUFFIX="-nogui"
    FLETCH_CMAKE_ARGS="\
        -D fletch_BUILD_WITH_PYTHON=On \
        -D fletch_ENABLE_VTK=Off -D fletch_ENABLE_Qt=Off \
    "
    if [ "$HOSTNAME" == "calculex" ]; then
        FLETCH_MAKE_EXTRA="TARGET=HASWELL"
        NCPUS=3
    else
        NCPUS=3
    fi
    test_fletch_branch
}

test_fletch_configure()
{
    FLETCH_SOURCE_DIR=$HOME/code/fletch
    BINARY_DIR=$HOME/code/fletch/build-testconfigure
    rm -rf $BINARY_DIR
    mkdir -p $BINARY_DIR

    # Make sure configure happens with no errors, then do bigger tests
    cd $BINARY_DIR
    cmake -G "Unix Makefiles" \
        -D fletch_BUILD_WITH_PYTHON=On \
        -D fletch_ENABLE_ALL_PACKAGES=On \
        $FLETCH_SOURCE_DIR
}

test_fletch_branch_python3()
{
    # Python3 branch with (mostly) old (stable) versions enabled
    source ~/local/build_scripts/init_fletch.sh
    FLETCH_ENABLE_ALL="On"
    FLETCH_REBUILD="On"
    TEST_KWIVER="On"
    FLETCH_BRANCH="dev/python3-support"
    FLETCH_PYTHON_VENV=2
    FLETCH_BUILD_SUFFIX="-stable"
    NCPUS=5
    FLETCH_CMAKE_ARGS="\
        -D fletch_BUILD_WITH_PYTHON=On \
        -D fletch_PYTHON_VERSION=$FLETCH_PYTHON_VENV \
        -D FFMpeg_SELECT_VERSION=2.6.2 \
        -D OpenCV_SELECT_VERSION=3.1.0 \
        -D fletch_ENABLE_Qt=Off -D fletch_ENABLE_VTK=Off \
    "
    test_fletch_branch

    # Python3 branch with (mostly) new versions enabled
    source ~/local/build_scripts/init_fletch.sh
    FLETCH_BUILD_SUFFIX="-new-ocvff"
    NCPUS=5
    FLETCH_CMAKE_ARGS="\
        -D fletch_BUILD_WITH_PYTHON=On \
        -D fletch_PYTHON_VERSION=$FLETCH_PYTHON_VENV \
        -D FFMpeg_SELECT_VERSION=3.3.3 \
        -D OpenCV_SELECT_VERSION=3.3.0 \
        -D fletch_ENABLE_Qt=Off -D fletch_ENABLE_VTK=Off \
    "
    test_fletch_branch
}

test_fletch_vtk()
{
    # Python3 branch with (mostly) old (stable) versions enabled
    source ~/local/build_scripts/init_fletch.sh
    FLETCH_ENABLE_ALL="On"
    FLETCH_REBUILD="On"
    TEST_KWIVER="On"
    FLETCH_PYTHON_VENV=2
    FLETCH_BRANCH="dev/python3-support"
    FLETCH_BUILD_SUFFIX="-stable"
    NCPUS=3
    FLETCH_CMAKE_ARGS="\
        -D fletch_BUILD_WITH_PYTHON=On \
        -D fletch_PYTHON_VERSION=$FLETCH_PYTHON_VENV \
        -D FFMpeg_SELECT_VERSION=3.3.3 \
        -D OpenCV_SELECT_VERSION=3.3.0 \
        -D VTK_SELECT_VERSION=6.2 \
        -D fletch_ENABLE_Qt=Off -D fletch_ENABLE_VTK=Off \
    "
    test_fletch_branch
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
    test_fletch_branch

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
    test_fletch_branch 
}


test_fletch_ffmpeg()
{
    source ~/local/build_scripts/init_fletch.sh
    FLETCH_ENABLE_ALL="Off"
    FLETCH_REBUILD="Off"
    FLETCH_PYTHON_VENV=2
    TEST_KWIVER="Off"

    FLETCH_BRANCH="master"
    FLETCH_BUILD_SUFFIX="-ffmpeg-only"
    FLETCH_CMAKE_ARGS="-D fletch_ENABLE_FFmpeg=On"
    test_fletch_branch

    FLETCH_REBUILD="On"
    FLETCH_BRANCH="dev/update-ffmpeg-3.3.3"
    FLETCH_BUILD_SUFFIX="-ffmpeg-only-3.3"
    FLETCH_CMAKE_ARGS="-D fletch_ENABLE_FFmpeg=On -D FFMpeg_SELECT_VERSION=3.3.3"
    test_fletch_branch 
    ldd install/lib/libavcodec.so

    FLETCH_BRANCH="dev/update-ffmpeg-3.3.3"
    FLETCH_BUILD_SUFFIX="-ffmpeg-only-2.6"
    FLETCH_CMAKE_ARGS="-D fletch_ENABLE_FFmpeg=On -D FFMpeg_SELECT_VERSION=2.6.2"
    test_fletch_branch 
    ldd install/lib/libavcodec.so

    rm -rf build/src/FFmpeg-stamp/
    find . -iname *.so -delete

    cat ../CMake/External_FFmpeg.cmake
}


test_fletch_branch-opencv-3-1()
{
    FLETCH_BRANCH="test/update-opencv-3.3"
    mkdir -p $HOME/dash/$FLETCH_BRANCH
    FLETCH_SOURCE_DIR=$HOME/dash/$FLETCH_BRANCH/fletch
    git clone -b $FLETCH_BRANCH https://github.com/Erotemic/fletch.git $FLETCH_SOURCE_DIR
    git checkout $FLETCH_BRANCH
    git reset origin/$FLETCH_BRANCH --hard
    git pull

    workon_py2

    echo FLETCH_SOURCE_DIR = $FLETCH_SOURCE_DIR
    mkdir -p $FLETCH_SOURCE_DIR/build
    cd $FLETCH_SOURCE_DIR/build 
    rm -rf $FLETCH_SOURCE_DIR/build/*
    cmake -G "Unix Makefiles" \
        -D fletch_BUILD_WITH_PYTHON=On \
        -D fletch_ENABLE_ALL_PACKAGES=On \
        $FLETCH_SOURCE_DIR

    # Disable building really big repos
    cmake -G "Unix Makefiles" \
        -D fletch_ENABLE_Qt=Off \
        -D fletch_ENABLE_VTK=Off \
        $FLETCH_SOURCE_DIR

    make
}


test_fletch_branch()
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
    NCPUS = $NCPUS
    "

    FLETCH_DASHBORD_ROOT=$HOME/dash/fletch/$FLETCH_BRANCH
    FLETCH_SOURCE_DIR=$FLETCH_DASHBORD_ROOT/fletch
    FLETCH_BINARY_DIR=$FLETCH_SOURCE_DIR/build$FLETCH_BUILD_SUFFIX

    echo " 
    FLETCH_DASHBORD_ROOT = $FLETCH_DASHBORD_ROOT
    FLETCH_SOURCE_DIR = $FLETCH_SOURCE_DIR
    FLETCH_BINARY_DIR = $FLETCH_BINARY_DIR
    FLETCH_CMAKE_ARGS = $FLETCH_CMAKE_ARGS
    "

    mkdir -p $FLETCH_DASHBORD_ROOT
    git clone -b $FLETCH_BRANCH https://github.com/Erotemic/fletch.git $FLETCH_SOURCE_DIR
    cd $FLETCH_SOURCE_DIR
    git checkout $FLETCH_BRANCH
    git fetch origin
    git reset origin/$FLETCH_BRANCH --hard

    if [ "$FLETCH_PYTHON_VENV" == "2" ]; then
        workon_py2
    else
        workon_py3
    fi

    mkdir -p $FLETCH_BINARY_DIR
    cd $FLETCH_BINARY_DIR 
    if [ "$FLETCH_REBUILD" == "On" ]; then
        rm -rf $FLETCH_BINARY_DIR/*
    fi

    if [ "$FLETCH_ENABLE_ALL" == "On" ]; then
        # enable everything first
        cmake -G "Unix Makefiles" \
            -D fletch_ENABLE_ALL_PACKAGES=On \
            $FLETCH_CMAKE_ARGS \
            $FLETCH_SOURCE_DIR
    fi 

    # then disable packages as needed
    cmake -G "Unix Makefiles" \
        $FLETCH_CMAKE_ARGS \
        $FLETCH_SOURCE_DIR
    CMAKE_GENERATE_SUCCESS=$?
    echo "CMAKE_GENERATE_SUCCESS = $CMAKE_GENERATE_SUCCESS (0 means success)"
    if [ CMAKE_GENERATE_SUCCESS != 0 ]; then
        return 1
    fi

    make -j$NCPUS $FLETCH_MAKE_EXTRA

    if [ "$TEST_KWIVER" == "On" ]; then

        KWIVER_BRANCH=master
        #if [ "False" == "On" ]; then
        #    KWIVER_REPO_DIR=$HOME/dash/$KWIVER_BRANCH/kwiver
        #    # TEST WITH KWIVER
        #    #KWIVER_BRANCH=release
        #    mkdir -p $HOME/dash/$KWIVER_BRANCH
        #    git clone -b $KWIVER_BRANCH https://github.com/Erotemic/kwiver.git $KWIVER_REPO_DIR

        #    cd $KWIVER_REPO_DIR
        #    git checkout $KWIVER_BRANCH
        #    git fetch origin
        #    git reset origin/$KWIVER_BRANCH --hard

        #    KWIVER_BUILD_DIR=$KWIVER_REPO_DIR/build/$FLETCH_BRANCH/$FLETCH_BUILD_SUFFIX
        #    mkdir -p $KWIVER_BUILD_DIR
        #    cd $KWIVER_BUILD_DIR
        #    rm -rf $KWIVER_BUILD_DIR/*

        #    cmake -G "Unix Makefiles" \
        #        -D fletch_DIR:PATH=$FLETCH_BINARY_DIR \
        #        -D KWIVER_ENABLE_ARROWS=On \
        #        -D KWIVER_ENABLE_TRACK_ORACLE=On \
        #        -D KWIVER_ENABLE_SPROKIT=On \
        #        -D KWIVER_ENABLE_PROCESSES=On \
        #        -D KWIVER_ENABLE_TESTS=On \
        #        -D KWIVER_ENABLE_LOG4CPLUS=On \
        #        -D KWIVER_ENABLE_TOOLS=On \
        #        $KWIVER_REPO_DIR
        #    make -j$NCPUS
        #    ctest 
        #fi

        # References:
        # https://cmake.org/Wiki/CMake_Scripting_Of_CTest
        CTEST_BUILD_NAME="Linux-C++ fletch-$FLETCH_BRANCH$FLETCH_BUILD_SUFFIX kwiver-$KWIVER_BRANCH"
        CTEST_DASHBOARD_ROOT=$HOME/dash/kwiver/$KWIVER_BRANCH

        kwiver_binary_name="kwiver/build/$FLETCH_BRANCH/$FLETCH_BUILD_SUFFIX"
        kwiver_source_name="kwiver"
        KWIVER_BINARY_DIR="$CTEST_DASHBOARD_ROOT/$kwiver_binary_name"
        KWIVER_SOURCE_DIR="$CTEST_DASHBOARD_ROOT/$kwiver_source_name"

        # Clone even though ctest will do it
        git clone -b $KWIVER_BRANCH https://github.com/Erotemic/kwiver.git $KWIVER_SOURCE_DIR

        mkdir -p $CTEST_DASHBOARD_ROOT
        cd $CTEST_DASHBOARD_ROOT
        cp $KWIVER_SOURCE_DIR/CMake/dashboard-scripts/KWIVER_common.cmake $CTEST_DASHBOARD_ROOT
        source ~/local/build_scripts/init_fletch.sh

        # Dump ctest script
        echo "$(codeblock "
        cmake_minimum_required(VERSION 2.8.2 FATAL_ERROR)
        set(dashboard_git_branch $KWIVER_BRANCH)
        set(dashboard_model Experimental)
        # set(dashboard_no_submit On)
        set(dashboard_source_name $kwiver_source_name)
        set(dashboard_binary_name \"$kwiver_binary_name\")
        set(CTEST_SITE \"$HOSTNAME\")
        set(CTEST_DASHBOARD_ROOT \"$CTEST_DASHBOARD_ROOT\")
        set(CTEST_BUILD_FLAGS -j$NCPUS)
        set(CTEST_BUILD_NAME \"$CTEST_BUILD_NAME\")
        set(CTEST_CONFIGURATION_TYPE Release)
        set(CTEST_CMAKE_GENERATOR \"Unix Makefiles\")
        set(CTEST_SOURCE_DIRECTORY \\\"${KWIVER_SOURCE_DIR}\\\")
        set(CTEST_BINARY_DIRECTORY \\\"${KWIVER_BINARY_DIR}\\\")
        set(CTEST_CONFIGURE_COMMAND \"\${CMAKE_COMMAND} \
            -G \\\\\"\${CTEST_CMAKE_GENERATOR}\\\\\" \
            -D fletch_DIR:PATH=$FLETCH_BINARY_DIR \
            -D KWIVER_ENABLE_ARROWS=On \
            -D KWIVER_ENABLE_TRACK_ORACLE=On \
            -D KWIVER_ENABLE_SPROKIT=On \
            -D KWIVER_ENABLE_PROCESSES=On \
            -D KWIVER_ENABLE_TESTS=On \
            -D KWIVER_ENABLE_LOG4CPLUS=On \
            -D KWIVER_ENABLE_TOOLS=On \
            \\\\\"\${CTEST_SOURCE_DIRECTORY}\\\\\" \
            \")

        # Helper macro to write initial cache
        macro(write_cache)
          set(cache_build_type \"\")
          set(cache_make_program \"\")
          if(CTEST_CMAKE_GENERATOR MATCHES \"Make\")
            set(cache_build_type \"CMAKE_BUILD_TYPE:STRING=\\${CTEST_CONFIGURATION_TYPE}\")
            if(CMAKE_MAKE_PROGRAM)
              set(cache_make_program \"CMAKE_MAKE_PROGRAM:FILEPATH=\\${CMAKE_MAKE_PROGRAM}\")
            endif()
          endif()
          file(WRITE \"\${CTEST_BINARY_DIRECTORY}/CMakeCache.txt\" \"
        SITE:STRING=\${CTEST_SITE}
        BUILDNAME:STRING=\${CTEST_BUILD_NAME}
        CTEST_TEST_CTEST:BOOL=\${CTEST_TEST_CTEST}
        CTEST_USE_LAUNCHERS:BOOL=\${CTEST_USE_LAUNCHERS}
        DART_TESTING_TIMEOUT:STRING=\${CTEST_TEST_TIMEOUT}
        GIT_EXECUTABLE:FILEPATH=\${CTEST_GIT_COMMAND}
        \${cache_build_type}
        \${cache_make_program}
        \${dashboard_cache}
        \")
        endmacro(write_cache)

        if (\"$FLETCH_ENABLE_ALL\" STREQUAL \"On\")
            ctest_empty_binary_directory(\"\${CTEST_BINARY_DIRECTORY}\")
        endif()

        ctest_start(\${dashboard_model})
        message(\"Reset cache cache...\")
        write_cache()
        ctest_update(RETURN_VALUE count)
        message(\"Found \${count} changed files\")

        message(\"Configure step\")
        ctest_configure()

        message(\"Read custom files step\")
        ctest_read_custom_files(\"\${CTEST_BINARY_DIRECTORY}\")

        message(\"Build step\")
        ctest_build()


        # version of setup_KWIVER.sh
        # FIXME: this should be handled by kwiver, not us
        set(CTEST_ENVIRONMENT 
            \"VG_PLUGIN_PATH=\${CTEST_BINARY_DIRECTORY}\"
            \"PATH=\${CTEST_BINARY_DIRECTORY}/bin:\$PATH\"
            \"LD_LIBRARY_PATH=\${CTEST_BINARY_DIRECTORY}/lib:$FLETCH_BINARY_DIR/install/lib:\$LD_LIBRARY_PATH\"
            \"KWIVER_PLUGIN_PATH=\${CTEST_BINARY_DIRECTORY}/lib/modules:\${CTEST_BINARY_DIRECTORY}/lib/sprokit:\$KWIVER_PLUGIN_PATH\"
            \"VITAL_LOGGER_FACTORY=\${CTEST_BINARY_DIRECTORY}/lib/modules/vital_log4cplus_logger\"
            \"KWIVER_DEFAULT_LOG_LEVEL=debug\"
            \"LOG4CPLUS_CONFIGURATION=\${CTEST_BINARY_DIRECTORY}/log4cplus.properties\"
            \"PYTHONPATH=\${CTEST_BINARY_DIRECTORY}/lib/python2.7/site-packages:\$PYTHONPATH\"
            \"SPROKIT_PYTHON_MODULES=kwiver.processes\"
        )

        message(\"Test step\")
        ctest_test(\${CTEST_TEST_ARGS})
        #ctest_coverage()
        #ctest_memcheck()

        message(\"Submit step\")
        ctest_submit()

        #include(\"\${CTEST_SCRIPT_DIRECTORY}/KWIVER_common.cmake\")
        ")" > $CTEST_DASHBOARD_ROOT/my_dashboard.cmake

        cd $CTEST_DASHBOARD_ROOT
        ctest -S $CTEST_DASHBOARD_ROOT/my_dashboard.cmake -VV

        # Ugggg, paths
        cd $KWIVER_BINARY_DIR
        source $KWIVER_BINARY_DIR/setup_KWIVER.sh
        $KWIVER_BINARY_DIR/bin/pipeline_runner -p $KWIVER_SOURCE_DIR/sprokit/pipelines/number_flow.pipe
        $KWIVER_BINARY_DIR/bin/pipeline_runner -p number_flow.pipe
        
        cd $KWIVER_BINARY_DIR
        bin/pipeline_runner -p $KWIVER_SOURCE_DIR/sprokit/pipelines/number_flow.pipe
        #cat numbers.txt
    fi
}
main(){
    git clone https://github.com/Erotemic/fletch.git ~/code/fletch

    cd ~/code/fletch
    git remote add source https://github.com/Kitware/fletch.git
    git pull source master


    cd ~/code/fletch
    git checkout dev/python3-support


    PYTHON_EXECUTABLE=$(which python)
    PY_VERSION=$(python -c "import sys; info = sys.version_info; print('{}.{}'.format(info.major, info.minor))")
    PLAT_NAME=$(python -c "import setuptools, distutils; print(distutils.util.get_platform())")
    REPO_DIR=~/code/fletch
    #BUILD_DIR="$REPO_DIR/cmake_builds/build.$PLAT_NAME-$PY_VERSION"
    BUILD_DIR="$REPO_DIR/build"

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
        get_py_config_var()
        {
            python -c "from distutils import sysconfig; print(sysconfig.get_config_vars()['$1'])"
        }
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
        # Usage:
        # 
        # >>> echo "$(codeblock "
        # ...     a long
        # ...     multiline string.
        # ...     this is the last line that will be considered.
        # ...     ")"
        # 
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


prebuild_fletch_caffe_segnet(){
    # Recommended way to install caffe-segnet and ALL dependencies 
    # Note: caffe-segnet only supports cudnn 5.1.
    # Disable cudnn if you don't have this.

    # See https://github.com/Erotemic/local/blob/master/init/init_cuda.sh for this sweet script
    # source ~/local/init/init_cuda.sh
    # change_cudnn_version 5.1

    # Define these variables before continuing
    # (ensure they agree with other script vars)
    CODE_DIR="$HOME/code"
    FLETCH_BUILD="$CODE_DIR/fletch/build-segnet"

    # Clone the fletch repo
    mkdir -p $CODE_DIR
    cd $CODE_DIR
    git clone https://github.com/Kitware/fletch.git

    # splitting out dependencies for easier visibility
    export OPENCV_DEPENDS="
        -D fletch_ENABLE_ZLib:BOOL=True \
        -D fletch_ENABLE_VXL:BOOL=True \
        -D fletch_ENABLE_PNG:BOOL=True \
        -D fletch_ENABLE_libtiff:BOOL=True \
        -D fletch_ENABLE_libjson:BOOL=True \
        -D fletch_ENABLE_libjpeg-turbo:BOOL=True \
        -D fletch_ENABLE_libxml2:BOOL=True"

    export CAFFE_DEPENDS="
        -D fletch_ENABLE_Protobuf:BOOL=True \
        -D Protobuf_SELECT_VERSION=3.4.1 \
        -D fletch_ENABLE_LevelDB:BOOL=True \
        -D fletch_ENABLE_HDF5:BOOL=True \
        -D fletch_ENABLE_Snappy:BOOL=True \
        -D fletch_ENABLE_SuiteSparse:BOOL=True \
        -D fletch_ENABLE_GLog:BOOL=True \
        -D fletch_ENABLE_OpenBLAS:BOOL=True \
        -D fletch_ENABLE_OpenCV:BOOL=True \
        -D fletch_ENABLE_LMDB:BOOL=True \
        -D fletch_ENABLE_Boost:BOOL=True \
        -D fletch_ENABLE_GFlags:BOOL=True"

    # Setup a build directory and build fletch
    mkdir -p $FLETCH_BUILD
    cd $FLETCH_BUILD
    cmake -G "Unix Makefiles" \
        -D fletch_ENABLE_Caffe_Segnet:BOOL=True \
        -D fletch_BUILD_WITH_CUDA:BOOL=True \
        -D fletch_BUILD_WITH_CUDNN:BOOL=True \
        -D fletch_BUILD_WITH_PYTHON:BOOL=True \
        -D fletch_PYTHON_MAJOR_VERSION=3 \
        $OPENCV_DEPENDS $CAFFE_DEPENDS \
        ..

    make -j5

    # TEST
    (cd ../python && python -c "import caffe")
}


