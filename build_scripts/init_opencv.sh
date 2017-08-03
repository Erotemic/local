#!/bin/sh

# Partially generated using ibeis ./super_setup.py --dump 


# ===============================================
# Configure variables based on the current system 
# ===============================================

PYTHON_EXECUTABLE=$(which python)
PY_VERSION=$(python -c "import sys; info = sys.version_info; print('{}.{}'.format(info.major, info.minor))")
PLAT_NAME=$(python -c "import setuptools, distutils; print(distutils.util.get_platform())")
REPO_DIR=~/code/opencv
BUILD_DIR="$REPO_DIR/cmake_builds/build.$PLAT_NAME-$PY_VERSION"

# Check if we have a venv setup
if [[ "$VIRTUAL_ENV" == ""  ]]; then
    # The case where we are installying system-wide
    # It is recommended that a virtual enviornment is used instead
    _SUDO="sudo"
    if [[ '$OSTYPE' == 'darwin'* ]]; then
        # Mac system info
        LOCAL_PREFIX=/opt/local
        PYTHON3_PACKAGES_PATH=$($PYTHON_EXECUTABLE -c "import site; print(site.getsitepackages()[0])")
    else
        # Linux system info
        LOCAL_PREFIX=/usr/local
        PYTHON3_PACKAGES_PATH=$LOCAL_PREFIX/lib/python$PY_VERSION/dist-packages
    fi
    # No windows support here
else
    # The prefered case where we are in a virtual environment
    #LOCAL_PREFIX=$VIRTUAL_ENV/local
    _SUDO=""
    LOCAL_PREFIX=$VIRTUAL_ENV
    PYTHON3_PACKAGES_PATH=$LOCAL_PREFIX/lib/python$PY_VERSION/site-packages
fi

# print out configuration options
echo "
====================
OPENCV CONFIGURATION
====================
# Intermediate vars
PY_VERSION=$PY_VERSION
PLAT_NAME=$PLAT_NAME
# Final vars
_SUDO=$_SUDO
REPO_DIR=$REPO_DIR
BUILD_DIR=$BUILD_DIR
LOCAL_PREFIX=$LOCAL_PREFIX
PYTHON_EXECUTABLE=$PYTHON_EXECUTABLE
PYTHON3_PACKAGES_PATH=$PYTHON3_PACKAGES_PATH
"




# ====================
# Download source code
# ====================

# Checkout opencv core and extras
git clone https://github.com/Itseez/opencv.git $REPO_DIR
git clone https://github.com/Itseez/opencv_contrib.git $REPO_DIR/opencv_contrib

# Update core and extras
(cd $REPO_DIR && git pull)
(cd $REPO_DIR/opencv_contrib && git pull)



# =======================
# Configure build options
# =======================

# Create build directory
mkdir -p $BUILD_DIR
(cd $BUILD_DIR && cmake -G "Unix Makefiles" \
    -D WITH_OPENMP=ON \
    -D CMAKE_BUILD_TYPE=RELEASE \
    -D BUILD_opencv_python2=Off \
    -D BUILD_opencv_python3=On \
    -D PYTHON_DEFAULT_EXECUTABLE="$PYTHON_EXECUTABLE" \
    -D PYTHON3_PACKAGES_PATH=$PYTHON3_PACKAGES_PATH \
    -D CMAKE_INSTALL_PREFIX=$LOCAL_PREFIX \
    -D OPENCV_EXTRA_MODULES_PATH=$REPO_DIR/opencv_contrib/modules \
    -D WITH_CUDA=Off \
    -D BUILD_opencv_dnn=Off \
    -D BUILD_opencv_dnn_modern=Off \
    -D WITH_VTK=Off \
    -D WITH_CUDA=Off \
    -D WITH_MATLAB=Off \
    $REPO_DIR
    # -D WITH_OPENCL=Off \
    # -D BUILD_opencv_face=Off \
    # -D BUILD_opencv_objdetect=Off \
    # -D BUILD_opencv_video=Off \
    # -D BUILD_opencv_videoio=Off \
    # -D BUILD_opencv_videostab=Off \
    # -D BUILD_opencv_ximgproc=Off \
    # -D BUILD_opencv_xobjdetect=Off \
    # -D BUILD_opencv_xphoto=Off \
    # -D BUILD_opencv_datasets=Off \
    # -D CXX_FLAGS="-std=c++11" \ %TODO
)




# =================
# Build and Install
# =================

# Build 
NCPUS=$(grep -c ^processor /proc/cpuinfo)
make -j$NCPUS --directory=$BUILD_DIR

# Install
$_SUDO make install --directory=$BUILD_DIR


# =================
# Test installation
# =================

# Test makesure things working
python -c "import numpy; print(numpy.__file__)"
python -c "import numpy; print(numpy.__version__)"
python -c "import cv2; print(cv2.__version__)"
python -c "import cv2; print(cv2.__file__)"
# Check if we have contrib modules
python -c "import cv2; print(cv2.xfeatures2d)"
# ENDBLOCK
