#!/bin/bash
#REPODIR=$(cd $(dirname $0) ; pwd)
#cd $REPODIR/flann

#rm -rf build
python2.7 -c "import utool as ut; print('keeping build dir' if not ut.get_argflag('--rmbuild') else ut.delete('build'))" $@
mkdir build

#sudo apt-get install libhdf5-serial-1.8.4
#libhdf5-openmpi-dev

cd build

#sudo apt-get install libcr-dev mpich2 mpich2-doc

# Grab correct python executable
export PYEXE=$(which python2.7)
export PYTHON_EXECUTABLE=$($PYEXE -c "import sys; print(sys.executable)")
# This gives /usr for python2.7, should give /usr/local?
#export CMAKE_INSTALL_PREFIX=$($PYEXE -c "import sys; print(sys.prefix)")
#export CMAKE_INSTALL_PREFIX=/usr/local
echo "CMAKE_INSTALL_PREFIX     = $CMAKE_INSTALL_PREFIX"
echo "PYTHON_EXECUTABLE        = $PYTHON_EXECUTABLE"
echo "PYEXE        = $PYEXE"

## Configure make build install
#cmake -G "Unix Makefiles" \
#    -DBUILD_MATLAB_BINDINGS=Off \
#    -DCMAKE_BUILD_TYPE=Release \
#    -DPYTHON_EXECUTABLE=$PYTHON_EXECUTABLE \
#    ..

    #-DCMAKE_INSTALL_PREFIX=$CMAKE_INSTALL_PREFIX \


# Configure make build install
cmake -G "Unix Makefiles" \
    -DCMAKE_BUILD_TYPE="Debug" \
    -DPYTHON_EXECUTABLE=$PYTHON_EXECUTABLE \
    -DBUILD_PYTHON_BINDINGS=On \
    -DBUILD_MATLAB_BINDINGS=Off \
    -DLATEX_OUTPUT_PATH=. \
    -DBUILD_CUDA_LIB=Off\
    ..

    #-DNVCC_COMPILER_BINDIR=/usr/bin/gcc \
    #-DCUDA_BUILD_CUBIN=On \
    #-DCUDA_npp_LIBRARY=/usr/local/cuda-6.0/lib64/libnppc.so \
    #-DHDF5_DIR=/home/joncrall/usr \
    #-DHDF5_C_INCLUDE_DIR=/home/joncrall/usr/include \

    #-DCMAKE_VERBOSE_MAKEFILE=On\
    #-DCUDA_VERBOSE_BUILD=On\
    #-DCUDA_NVCC_FLAGS=-gencode;arch=compute_20,code=sm_20;-gencode;arch=compute_20,code=sm_21 

make -j$NCPUS 
make -j$NCPUS || { echo "FAILED MAKE" ; exit 1; }

sudo make install || { echo "FAILED MAKE INSTALL" ; exit 1; }

#python -c "import pyflann; print(pyflann)"

#copying pyflann/__init__.py -> build/lib.linux-x86_64-2.7/pyflann
#copying pyflann/flann_ctypes.py -> build/lib.linux-x86_64-2.7/pyflann
#copying pyflann/index.py -> build/lib.linux-x86_64-2.7/pyflann
#copying pyflann/exceptions.py -> build/lib.linux-x86_64-2.7/pyflann
#creating build/lib.linux-x86_64-2.7/pyflann/lib
#copying /home/joncrall/tmp/flann/build/lib/libflann.so -> build/lib.linux-x86_64-2.7/pyflann/lib
#package init file '/home/joncrall/tmp/flann/build/lib/__init__.py' not found (or not a regular file)
#running install_lib
#creating /home/joncrall/venv/lib/python2.7/site-packages/pyflann
#copying build/lib.linux-x86_64-2.7/pyflann/__init__.py -> /home/joncrall/venv/lib/python2.7/site-packages/pyflann
#copying build/lib.linux-x86_64-2.7/pyflann/flann_ctypes.py -> /home/joncrall/venv/lib/python2.7/site-packages/pyflann
#copying build/lib.linux-x86_64-2.7/pyflann/index.py -> /home/joncrall/venv/lib/python2.7/site-packages/pyflann
#creating /home/joncrall/venv/lib/python2.7/site-packages/pyflann/lib
#copying build/lib.linux-x86_64-2.7/pyflann/lib/libflann.so -> /home/joncrall/venv/lib/python2.7/site-packages/pyflann/lib
#copying build/lib.linux-x86_64-2.7/pyflann/exceptions.py -> /home/joncrall/venv/lib/python2.7/site-packages/pyflann
#byte-compiling /home/joncrall/venv/lib/python2.7/site-packages/pyflann/__init__.py to __init__.pyc
#byte-compiling /home/joncrall/venv/lib/python2.7/site-packages/pyflann/flann_ctypes.py to flann_ctypes.pyc
#byte-compiling /home/joncrall/venv/lib/python2.7/site-packages/pyflann/index.py to index.pyc
#byte-compiling /home/joncrall/venv/lib/python2.7/site-packages/pyflann/exceptions.py to exceptions.pyc


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


debug_flann()
{
    wget http://svn.python.org/projects/python/trunk/Misc/valgrind-python.supp

    sh -c 'cat >> valgrind-python.supp << EOL
{
   ADDRESS_IN_RANGE/Invalid read of size 4
   Memcheck:Addr4
   fun:PyObject_Free
}

{
   ADDRESS_IN_RANGE/Invalid read of size 4
   Memcheck:Value4
   fun:PyObject_Free
}

{
   ADDRESS_IN_RANGE/Conditional jump or move depends on uninitialised value
   Memcheck:Cond
   fun:PyObject_Free
}

{
   ADDRESS_IN_RANGE/Invalid read of size 4
   Memcheck:Addr4
   fun:PyObject_Realloc
}

{
   ADDRESS_IN_RANGE/Invalid read of size 4
   Memcheck:Value4
   fun:PyObject_Realloc
}

{
   ADDRESS_IN_RANGE/Conditional jump or move depends on uninitialised value
   Memcheck:Cond
   fun:PyObject_Realloc
}
EOL' 
    valgrind --tool=memcheck --suppressions=valgrind-python.supp python -E -tt ./examples/example.py

    valgrind --tool=memcheck --suppressions=valgrind-python.supp python  ./examples/example.py
    
}
