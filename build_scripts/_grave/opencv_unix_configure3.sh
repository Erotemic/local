#!/bin/bash
cd ~/code/opencv3
mkdir build
cd build
#rm CMakeCache.txt


uninstall_opencv()
{
    sudo rm -rf /usr/local/bin/opencv*
    sudo rm -rf /usr/local/include/opencv
    sudo rm -rf /usr/local/include/opencv2
    sudo rm -rf /usr/local/lib/libopencv*
    sudo rm -rf /usr/local/lib/pkgconfig/opencv.pc
    sudo rm -rf /opt/local/Library/Frameworks/Python.framework/Versions/2.7/lib/python2.7/site-packages/cv2.so
    sudo rm -rf /opt/local/Library/Frameworks/Python.framework/Versions/2.7/lib/python2.7/site-packages/cv.py
    sudo rm -rf /opt/local/Library/Frameworks/Python.framework/Versions/2.7/lib/python2.7/site-packages/cv2.pyd
}

if [[ "$OSTYPE" == "darwin"* ]]; then
    # locate python libs
    export ports_PYFRAMEWORK=/opt/local/Library/Frameworks/Python.framework/Versions/2.7
    export PYTHON_LIBRARY=$ports_PYFRAMEWORK/lib/python2.7/config/libpython2.7.dylib
    export PYTHON_PACKAGES_PATH=$ports_PYFRAMEWORK/lib/python2.7/site-packages
    export PYTHON_INCLUDE_DIR=$ports_PYFRAMEWORK/Headers
    # OXS cmake command
    # Need to have port install libpng
        #-DCMAKE_OSX_DEPLOYMENT_TARGET=10.9 \
    cmake -G "Unix Makefiles"\
        `#ARCHITECTURES options: i386, x86_64, ppc, ppc64`\
        -DCMAKE_OSX_ARCHITECTURES=x86_64\
        -DCMAKE_C_FLAGS=-m32\
        -DCMAKE_CXX_FLAGS=-m32\
        `#PYTHON`\
        -DPYTHON_LIBRARY=$PYTHON_LIBRARY \
        -DPYTHON_PACKAGES_PATH=$PYTHON_PACKAGES_PATH \
        -DPYTHON_INCLUDE_DIR=$PYTHON_INCLUDE_DIR \
        -DINSTALL_PYTHON_EXAMPLES=OFF \
        `#DEBUGS`\
        -DCMAKE_BUILD_TYPE="Debug" \
        -DBUILD_WITH_DEBUG_INFO=ON \
        -DOPENCV_WARNINGS_ARE_ERRORS=OFF \
        `#BUILDS`\
        -DBUILD_SHARED_LIBS=ON \
        -DBUILD_PERF_TESTS=OFF \
        -DBUILD_DOCS=OFF \
        -DBUILD_TESTS=OFF \
        -DBUILD_opencv_gpu=OFF \
        -DBUILD_opencv_flann=ON \
        -DBUILD_PNG=OFF \
        -DBUILD_OPENEXR=OFF \
        -DBUILD_JPEG=OFF \
        -DBUILD_JASPER=OFF \
        -DBUILD_ZLIB=OFF \
        `#ENABLES`\
        -DENABLE_SSE=OFF \
        -DENABLE_SSE2=OFF \
        -DENABLE_SSE3=OFF \
        `#WITH PACKAGES`\
        -DWITH_QT=OFF \
        -DWITH_QUICKTIME=OFF \
        -DWITH_OPENEXR=ON \
        `# * CUDA * `\
        -DWITH_CUDA=OFF  \
        -DWITH_CUFFT=OFF `#CUDA FFT`\
        `# * OPENCL * `\
        -DWITH_OPENCL=OFF \
        -DWITH_OPENCLAMDBLAS=OFF \
        -DWITH_OPENCLAMDFFT=OFF \
        `# * VIDEO * `\
        -DWITH_1394=OFF `# Firewire`\
        -DWITH_FFMPEG=ON \
        -DWITH_GIGEAPI=ON \
        -DWITH_PVAPI=ON \
        -DWITH_V4L=ON \
        `# * OTHER * `\
        -DWITH_EIGEN=ON \
        `# * IMAGE FORMATS * `\
        -DWITH_JAPSER=ON \
        -DWITH_TIFF=ON \
        -DWITH_JPEG=ON \
        -DWITH_PNG=ON \
        ~/code/opencv
else
    # Linux command
    #$(which /usr/bin/python2.7)
    #$(python2.7-config --exec-prefix)/bin/python2.7
    #export $PYTHON27_PREFIX=$(python2.7-config --exec-prefix)


    # Get information for the correct (2.7) version of python
    #PYTHON_EXECUTABLE = /usr/bin/python2.7
    #PYTHON_LIBRARY = /usr/lib/libpython2.7.so
    #PYTHON_INCLUDE_DIR = /usr/include/python2.7
    #PYTHON_PACKAGES_PATH = /usr/local/lib/python2.7/dist-packages
    
    export PYEXE=python3.4
    print_py_config_vars()
    {
        $PYEXE -c "from distutils import sysconfig; print('\n'.join(map(str, sysconfig.get_config_vars().items())))"
    }
    get_py_config_var()
    {
        $PYEXE -c "from distutils import sysconfig; print(sysconfig.get_config_vars()['$1'])"
    }

    #export PYTHON_EXECUTABLE="$(get_py_config_var 'BINDIR')/$PYEXE"
    #export PYTHON_PACKAGES_PATH=$($PYEXE -c "import site; print(site.getsitepackages()[0])")  # depricate in 3.4
    #export PYTHON_INCLUDE_DIR=$($PYEXE -c "from distutils.sysconfig import
    #get_python_lib; print(get_python_inc())")
    export PYTHON_EXECUTABLE=$($PYEXE -c "import sys; print(sys.executable)")
    #export PYTHON_LIBRARY=$(get_py_config_var 'LIBDIR')/$(get_py_config_var 'LDLIBRARY')
    export PYTHON_LIBRARY=$(get_py_config_var 'LIBDIR')/$(get_py_config_var 'MULTIARCH')/$(get_py_config_var 'LDLIBRARY')
    export PYTHON_INCLUDE_DIR=$(get_py_config_var 'INCLUDEPY')
    export PYTHON_PACKAGES_PATH=$($PYEXE -c "from distutils.sysconfig import get_python_lib; print(get_python_lib())")
    export PYTHON_NUMPY_INCLUDE_DIR=$(python -c "import numpy; print(numpy.get_include())")

    echo "PYTHON_EXECUTABLE = $PYTHON_EXECUTABLE"
    echo "PYTHON_LIBRARY = $PYTHON_LIBRARY"
    echo "PYTHON_INCLUDE_DIR = $PYTHON_INCLUDE_DIR"
    echo "PYTHON_PACKAGES_PATH = $PYTHON_PACKAGES_PATH"
    echo "PYTHON_NUMPY_INCLUDE_DIR = $PYTHON_NUMPY_INCLUDE_DIR"
    #-DPYTHON_EXECUTABLE=$PYTHON27_PREFIX/bin/python \
    #-DPYTHON_INCLUDE_DIR=$PYTHON27_PREFIX/include/python \

    cmake -G "Unix Makefiles" \
        -DCMAKE_INSTALL_PREFIX=~/py3env \
        -DCMAKE_BUILD_TYPE="Release" \
        -DINSTALL_PYTHON_EXAMPLES=ON \
        -DPYTHON_EXECUTABLE=$PYTHON_EXECUTABLE \
        -DPYTHON_INCLUDE_DIR=$PYTHON_INCLUDE_DIR \
        -DPYTHON_LIBRARY=$PYTHON_LIBRARY \
        -DPYTHON_PACKAGES_PATH=$PYTHON_PACKAGES_PATH \
        -DPYTHON_NUMPY_INCLUDE_DIR=$PYTHON_NUMPY_INCLUDE_DIR \
        -DWITH_QT=OFF \
        ..
         #~/code/opencv3
    
fi

#python -c "import cv2; print(cv2.__version__)"
# OpenCV says this is python 2.7.6
#/opt/local/bin/python
# OpenCV says this is python 2.7.5
#/opt/local/Library/Frameworks/Python.framework/Versions/2.7/lib/python2.7/config/libpython2.7.dylib 
# this is a symlink to 
#/opt/local/Library/Frameworks/Python.framework/Versions/2.7/lib/python2.7/config/libpython2.7.dylib ->
#../../../Python
# python2.7.6 links to (via otool)

#/opt/local/Library/Frameworks/Python.framework/Versions/2.7/Python

#sudo port install zlib
#sudo port install jasper
#sudo port install libpng
#sudo port install openexr

# OLD MAC BUILD

    # locate python libs
    #export MACPORTS_PYFRAMEWORK=/opt/local/Library/Frameworks/Python.framework/Versions/2.7
    #export PYTHON_LIBRARY="$MACPORTS_PYFRAMEWORK/lib/python2.7/config/libpython2.7.dylib"
    #export PYTHON_PACKAGES_PATH="$MACPORTS_PYFRAMEWORK/lib/python2.7/site-packages"
    # OXS cmake command
    #cmake -G "Unix Makefiles" \
        #-D PYTHON_LIBRARY=$PYTHON_LIBRARY \
        #-D PYTHON_PACKAGES_PATH=$PYTHON_PACKAGES_PATH \
        #-D CMAKE_BUILD_TYPE="Release" \
        #-D INSTALL_PYTHON_EXAMPLES=ON \
        ..
        #~/code/opencv3
