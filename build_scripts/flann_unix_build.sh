#!/bin/bash
#REPODIR=$(cd $(dirname $0) ; pwd)
#cd $REPODIR/flann
#cd ~/code/flann
mkdir build
cd build

#sudo apt-get install libcr-dev mpich2 mpich2-doc

# Grab correct python executable
export PYEXE=python
export PYTHON_EXECUTABLE=$($PYEXE -c "import sys; print(sys.executable)")
# This gives /usr for python2.7, should give /usr/local?
export CMAKE_INSTALL_PREFIX=$($PYEXE -c "import sys; print(sys.prefix)")
#export CMAKE_INSTALL_PREFIX=/usr/local
echo "CMAKE_INSTALL_PREFIX     = $CMAKE_INSTALL_PREFIX"
echo "PYTHON_EXECUTABLE        = $PYTHON_EXECUTABLE"

# Configure make build install
cmake -G "Unix Makefiles" \
    -DCMAKE_INSTALL_PREFIX=$CMAKE_INSTALL_PREFIX \
    -DBUILD_MATLAB_BINDINGS=Off \
    -DCMAKE_BUILD_TYPE=Release \
    -DLATEX_OUTPUT_PATH=. \
    -DPYTHON_EXECUTABLE=$PYTHON_EXECUTABLE \
    ..  || { echo "FAILED CMAKE CONFIGURE" ; exit 1; }

export NCPUS=$(grep -c ^processor /proc/cpuinfo)
make -j$NCPUS || { echo "FAILED MAKE" ; exit 1; }

make install || { echo "FAILED MAKE INSTALL" ; exit 1; }


python -c "import pyflann; print(pyflann)"
