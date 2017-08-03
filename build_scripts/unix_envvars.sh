# Put target python version here
#export PYEXE=python3.4
export PYEXE=python

export NCPUS=$(grep -c ^processor /proc/cpuinfo)

print_py_config_vars()
{
    python -c "from distutils import sysconfig; print('\n'.join(map(str, sysconfig.get_config_vars().items())))"
}
get_py_config_var()
{
    python -c "from distutils import sysconfig; print(sysconfig.get_config_vars()['$1'])"
}

#export PYTHON_EXECUTABLE="$(get_py_config_var 'BINDIR')/$PYEXE"
#export PYTHON_PACKAGES_PATH=$($PYEXE -c "import site; print(site.getsitepackages()[0])")  # depricate in 3.4
#export PYTHON_INCLUDE_DIR=$($PYEXE -c "from distutils.sysconfig import
#get_python_lib; print(get_python_inc())")
export PYTHON_EXECUTABLE=$(python -c "import sys; print(sys.executable)")
export PYTHON_LIBRARY=$(get_py_config_var 'LIBDIR')/$(get_py_config_var 'LDLIBRARY')
export PYTHON_INCLUDE_DIR=$(get_py_config_var 'INCLUDEPY')
export PYTHON_PACKAGES_PATH=$(python -c "from distutils.sysconfig import get_python_lib; print(get_python_lib())")
export PYTHON_NUMPY_INCLUDE_DIR=$(python -c "import numpy; print(numpy.get_include())")
export CMAKE_INSTALL_PREFIX=$(python -c "import sys; print(sys.prefix)")

echo "CMAKE_INSTALL_PREFIX     = $CMAKE_INSTALL_PREFIX"
echo "PYTHON_EXECUTABLE        = $PYTHON_EXECUTABLE"
echo "PYTHON_LIBRARY           = $PYTHON_LIBRARY"
echo "PYTHON_INCLUDE_DIR       = $PYTHON_INCLUDE_DIR"
echo "PYTHON_PACKAGES_PATH     = $PYTHON_PACKAGES_PATH"
echo "PYTHON_NUMPY_INCLUDE_DIR = $PYTHON_NUMPY_INCLUDE_DIR"

echo "
PYTHON_EXECUTABLE        = $PYTHON_EXECUTABLE
PYTHON_LIBRARY           = $PYTHON_LIBRARY
PYTHON_INCLUDE_DIR       = $PYTHON_INCLUDE_DIR
PYTHON_PACKAGES_PATH     = $PYTHON_PACKAGES_PATH
PYTHON_NUMPY_INCLUDE_DIR = $PYTHON_NUMPY_INCLUDE_DIR
CMAKE_INSTALL_PREFIX     = $CMAKE_INSTALL_PREFIX
"
