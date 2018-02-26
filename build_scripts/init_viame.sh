cd ~/code
if [ ! -d "$HOME/code/VIAME" ]; then
    git clone https://github.com/Kitware/VIAME.git ~/code/VIAME
    cd ~/code/VIAME
    #git remote add Erotemic https://github.com/Erotemic/VIAME.git
    git pull source master
fi
cd ~/code/VIAME
git checkout next
git pull origin next
git submodule update --init --recursive


PYTHON_VERSION=$(python -c "import sys; info = sys.version_info; print('{}.{}'.format(info.major, info.minor))")
PYTHON_MAJOR_VERSION==$(python -c "import sys; info = sys.version_info; print('{}'.format(info.major))")
# Check if we have a venv setup
# The prefered case where we are in a virtual environment
LOCAL_PREFIX=$VIRTUAL_ENV/
PYTHON_PACKAGES_PATH=$LOCAL_PREFIX/lib/python$PY_VERSION/site-packages
PYTHON_INCLUDE_DIR=$LOCAL_PREFIX/include/python"$PY_VERSION"m
PYTHON_LIBRARY=$LOCAL_PREFIX/lib/python$PY_VERSION/config-"$PY_VERSION"m-x86_64-linux-gnu/libpython"$PY_VERSION".so


VIAME_BUILD=$HOME/code/VIAME/build-py$PYTHON_VERSION

mkdir -p $VIAME_BUILD
cd $VIAME_BUILD

cmake -G "Unix Makefiles" \
    -D VIAME_ENABLE_PYTHON:BOOL=True \
    -D VIAME_DISABLE_PYTHON_CHECK:BOOL=True \
    -D VIAME_SYMLINK_PYTHON:BOOL=True \
    -D VIAME_ENABLE_CUDA:BOOL=True \
    -D VIAME_ENABLE_CUDNN:BOOL=True \
    -D VIAME_ENABLE_CAFFE:BOOL=True \
    -D VIAME_ENABLE_KWANT:BOOL=True \
    -D VIAME_ENABLE_SMQTK:BOOL=True \
    -D VIAME_ENABLE_VIVIA:BOOL=True \
    -D VIAME_ENABLE_VIVIA:BOOL=True \
    -D VIAME_OPENCV_VERSION="3.3.0" \
    ..
