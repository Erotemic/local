#https://github.com/dropbox/pyston/blob/master/docs/INSTALLING.md
export CODE_DIR=~/code
export EXTERNAL_DIR=~/external
 
cd $CODE_DIR
git clone https://github.com/dropbox/pyston.git 
cd $CODE_DIR/pyston
git submodule update --init --recursive
git pull
#git clone --recursive https://github.com/dropbox/pyston.git ~/pyston


sudo apt-get install libgmp-dev libmpfr-dev libmpc-dev make build-essential libtool zip gcc-multilib autogen
sudo apt-get install ccache
sudo apt-get install libncurses5-dev zlib1g-dev liblzma-dev
sudo apt-get install texlive-extra-utils autoconf
sudo apt-get install zsh
sudo apt-get install libreadline-dev
sudo apt-get install libgmp3-dev
sudo apt-get install ninja-build


mkdir ~/external
mkdir ~/external/pyston_deps
cd ~/external/pyston_deps
cd $EXTERNAL_DIR/pyston_deps


# Download GCC
wget 'http://www.netgull.com/gcc/releases/gcc-4.8.2/gcc-4.8.2.tar.bz2'
tar xvf gcc-4.8.2.tar.bz2
mkdir gcc-4.8.2-{build,install}
# Download LLVM
git clone http://llvm.org/git/llvm.git llvm-trunk
# Download Clang
git clone http://llvm.org/git/clang.git llvm-trunk/tools/clang
# Download PYPA
git clone git://github.com/vinzenz/pypa
mkdir pypa-install

# GTest
wget https://googletest.googlecode.com/files/gtest-1.7.0.zip
unzip gtest-1.7.0.zip
cd gtest-1.7.0
./configure CXXFLAGS=-fno-omit-frame-pointer
make -j4

# Install external GCC
cd ~/external/pyston_deps/gcc-4.8.2-build
../gcc-4.8.2/configure --disable-bootstrap --enable-languages=c,c++ --prefix=$HOME/external/pyston_deps/gcc-4.8.2-install
make -j4
make check
make install
~/external/pyston_deps/gcc-4.8.2-install/bin/gcc --version


python -c "import utool as ut; ut.sedfile(
            ut.truepath('$CODE_DIR/pyston/Makefile'),
            r'DEPS_DIR := \\\$\\(HOME\\)\\/pyston_deps',
            r'DEPS_DIR := \$(HOME)/external/pyston_deps',
            veryverbose=True, force=True)"

#python -c "import utool as ut; ut.sedfile(
#            ut.truepath('~/code/pyston/src/Makefile'),
#            'GCC_DIR := \\\$\\(DEPS_DIR\\)/gcc-4.8.2-install',
#            'GCC_DIR := /usr',
#            veryverbose=True, force=True)"


# Install LLVM
cd $EXTERNAL_DIR/pyston_deps
cd $CODE_DIR/pyston
make llvm_up
make llvm_configure
make llvm -j4


# Install PYPA
cd $EXTERNAL_DIR/pyston_deps
cd $EXTERNAL_DIR/pyston_deps/pypa
./autogen.sh
./configure --prefix=$HOME/external/pyston_deps/pypa-install CXX=$EXTERNAL_DIR/pyston_deps/gcc-4.8.2-install/bin/g++

# Ninja
cd $EXTERNAL_DIR/pyston_deps
git clone https://github.com/martine/ninja.git
cd ninja
git checkout v1.4.0
./bootstrap.py

# Cmake 3.0
cd $EXTERNAL_DIR/pyston_deps
wget http://www.cmake.org/files/v3.0/cmake-3.0.0.tar.gz
tar zxvf cmake-3.0.0.tar.gz
cd cmake-3.0.0
./configure
make -j9

# Build LLVM
cd $EXTERNAL_DIR/pyston_deps
mkdir llvm-trunk-cmake
cd llvm-trunk-cmake
CXX=g++ CC=gcc PATH=$EXTERNAL_DIR/pyston_deps/gcc-4.8.2-install/bin:$PATH:$EXTERNAL_DIR/pyston_deps/ninja CMAKE_MAKE_PROGRAM=$EXTERNAL_DIR/pyston_deps/ninja/ninja $EXTERNAL_DIR/pyston_deps/cmake-3.0.0/bin/cmake ../llvm-trunk -G Ninja -DLLVM_TARGETS_TO_BUILD=host -DCMAKE_BUILD_TYPE=RELEASE -DLLVM_ENABLE_ASSERTIONS=ON
$EXTERNAL_DIR/pyston_deps/ninja/ninja # runs in parallel

# Experimental CMAKe
cd $CODE_DIR/pyston
mkdir $CODE_DIR/pyston/pyston-build
cd $CODE_DIR/pyston/pyston-build
CC=gcc CXX=g++ cmake -GNinja $CODE_DIR/pyston
ninja check-pyston
