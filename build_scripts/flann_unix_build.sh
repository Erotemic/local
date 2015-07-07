#!/bin/bash
#REPODIR=$(cd $(dirname $0) ; pwd)
#cd $REPODIR/flann
#cd ~/code/flann

# cd 
checkout_flann()
{
    code
    git clone https://github.com/mariusmuja/flann.git
}
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


uninstall_flann()
{
    pip list | grep flann
    python -c "import pyflann; print(pyflann.__file__)"
    python -c "import pyflann, os.path; print(os.path.dirname(pyflann.__file__))"
    sudo rm -rf /home/joncrall/venv/local/lib/python2.7/site-packages/pyflann
    python -c "import pyflann; print(pyflann.FLANN.add_points)"
    python -c "import pyflann; print(pyflann.__tmp_version__)"

    ls -al /home/joncrall/venv/local/lib/python2.7/site-packages/pyflann/lib

    # The add remove/error branch info 
    # Seems to work here: 880433b352d190fcbef78ea95d94ec8324059424
    # Seems to fail here: e5b9cbeabc9f790e231fbb91376a6842207565ba
}



python3_flann_hack()
{
    cd ~/code/flann/src/python
    sudo python3 ~/code/flann/build/src/python/setup.py install
}
