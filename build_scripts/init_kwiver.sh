cd ~/code
if [ ! -d "$HOME/code/KWIVER" ]; then
    git clone https://github.com/Kitware/KWIVER.git ~/code/KWIVER
    cd ~/code/KWIVER
    #git remote add Erotemic https://github.com/Erotemic/KWIVER.git
    git pull source master
fi
cd ~/code/KWIVER
git checkout master
git pull origin master
git submodule update --init --recursive


PYTHON_VERSION=$(python -c "import sys; info = sys.version_info; print('{}.{}'.format(info.major, info.minor))")
PYTHON_MAJOR_VERSION=$(python -c "import sys; info = sys.version_info; print('{}'.format(info.major))")
echo "PYTHON_MAJOR_VERSION = $PYTHON_MAJOR_VERSION"


KWIVER_BUILD=$HOME/code/KWIVER/build-py$PYTHON_VERSION
FLETCH_BUILD=$HOME/code/fletch/build-py$PYTHON_VERSION

mkdir -p $KWIVER_BUILD
cd $KWIVER_BUILD

cmake -G "Unix Makefiles" \
    -D KWIVER_ENABLE_ARROWS=TRUE \
    -D KWIVER_ENABLE_C_BINDINGS=TRUE \
    -D KWIVER_ENABLE_PYTHON=TRUE \
    -D KWIVER_ENABLE_TESTS=TRUE \
    -D KWIVER_ENABLE_EXTRAS:BOOL=ON \
    -D KWIVER_ENABLE_LOG4CPLUS:BOOL=ON \
    -D KWIVER_ENABLE_PROCESSES:BOOL=ON \
    -D KWIVER_ENABLE_SPROKIT:BOOL=ON \
    -D KWIVER_ENABLE_TOOLS:BOOL=ON \
    -D KWIVER_SYMLINK_PYTHON=TRUE \
    -D KWIVER_PYTHON_MAJOR_VERSION=$PYTHON_MAJOR_VERSION \
    -D fletch_DIR=$FLETCH_BUILD \
    ..
