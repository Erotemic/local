cd ~/code
git clone https://github.com/python/cpython.git cpython-27
deactivate_venv

REPO_DIR=~/code/cpython-27
cd $REPO_DIR
git checkout v2.7.12

PYINSTALL="$REPO_DIR/install-py27-debug"

./configure \
    --prefix="$PYINSTALL" \
    --with-ensurepip=install \
    --without-pymalloc --with-pydebug --with-valgrind \
    --enable-shared --enable-unicode=ucs4 
make -j5
make install
make altinstall


mkdir -p ~/code/cpython-27/venvs

#http://pythonextensionpatterns.readthedocs.io/en/latest/debugging/debug_python.html
#grep CONFIG_ARGS /usr/lib/python2.7/config-x86_64-linux-gnu/Makefile
# http://pythonsweetness.tumblr.com/post/151938194807/debugging-c-extension-memory-safety-with-valgrind
# https://github.com/docker-library/python/issues/21
# https://docs.python.org/2/using/unix.html#building-python
# https://hg.python.org/cpython/file/2.7/README
# https://github.com/pyenv/pyenv/issues/65
# http://www.gem5.org/Using_a_non-default_Python_installation

deactivate_venv
rm -rf ~/code/cpython-27/* && git checkout *
PYINSTALL="$HOME/code/cpython-27/install-py27-debug"
cd ~/code/cpython-27
./configure \
    --prefix="$PYINSTALL" \
    --with-ensurepip=install \
    --without-pymalloc --with-pydebug --with-valgrind \
    --enable-shared --enable-unicode=ucs4 
make -j5
make altinstall

PYINSTALL="$HOME/code/cpython-27/install-py27-debug"
PY_EXE="$HOME/code/cpython-27/install-py27-debug/bin/python2.7"

$PY_EXE -c "import ctypes"  # Breaks
export PATH=$PYINSTALL/bin:$PATH
export LD_LIBRARY_PATH=$PYINSTALL/lib:$LD_LIBRARY_PATH
export C_INCLUDE_PATH=$PYINSTALL/include:$C_INCLUDE_PATH
export CPATH=$PYINSTALL/include:$CPATH
$PY_EXE -c "import ctypes"   # Works now that the env is right

cd ~/code
git clone https://github.com/pypa/virtualenv.git
cd virtualenv
git remote add gst https://github.com/gst/virtualenv.git
git checkout -b test
git merge gst/fix_for_shared_lib_and_rpath_origin


$PY_EXE -m pip install pip setuptools -U
cd ~/code/virtualenv
$PY_EXE -m pip install -e .

cd ~/code/cpython-27

VENV_DIR="$HOME/code/cpython-27/venvs/venv2-debug"
mkdir -p $VENV_DIR
$PY_EXE -m virtualenv --include-lib -p $PY_EXE $VENV_DIR 


VENV_DIR="$HOME/code/cpython-27/venvs/venv2-debug"
source $VENV_DIR/bin/activate



"""
_OLD_VIRTUAL_PATH="$PATH"
_OLD_C_INCLUDE_PATH="$C_INCLUDE_PATH"
_OLD_VIRTUAL_LD_LIBRARY_PATH="$LD_LIBRARY_PATH"

PATH="$VIRTUAL_ENV/bin:$PATH"
C_INCLUDE_PATH="$C_INCLUDE_PATH/lib:$C_INCLUDE_PATH"
LD_LIBRARY_PATH="$VIRTUAL_ENV/lib:$LD_LIBRARY_PATH"

export PATH
export C_INCLUDE_PATH
export LD_LIBRARY_PATH
"""



# CURRENT ISSUE: 
#    from config import *
#ImportError: /home/joncrall/code/VIAME/build-relwithdeb/install/lib/libboost_python.so.1.55.0: undefined symbol: Py_InitModule4_64

# NOTES: BOOST MAY NEED SPECIAL DEBUG SYMBOL
# http://www.boost.org/doc/libs/1_58_0/libs/python/doc/building.html
# https://github.com/pypa/virtualenv/pull/1045
 
mkdir -p ~/code/VIAME/debug-py2
cd ~/code/VIAME/debug-py2
cmake -G "Unix Makefiles" \
    -DPYTHON_EXECUTABLE=$PY_EXE
    -PYTHON_LIBRARY = ~/code/cpython-27/install-py27-debug/lib/libpython2.7.so
    PYTHON_INCLUDE_DIR = ~/code/cpython-27/install-py27-debug/include/python2.7
    PYTHON_LIBRARY_DEBUG = ~/code/cpython-27/install-py27-debug/lib

cat /etc/ld.so.conf

RUN ldconfig -v


cat /etc/ld.so.conf



    #'--enable-ipv6' '--enable-unicode=ucs4' '--with-dbmliborder=bdb:gdbm' '--with-system-expat' '--with-computed-gotos' '--with-system-ffi' '--with-fpectl' 'CC=x86_64-linux-gnu-gcc' 'CFLAGS=-Wdate-time -D_FORTIFY_SOURCE=2 -g -fstack-protector-strong -Wformat -Werror=format-security ' 'LDFLAGS=-Wl,-Bsymbolic-functions -Wl,-z,relro'

    #--enable-shared \
    #--with-fpectl \
    #--enable-unicode=ucs4
make -j5
make altinstall

PY_EXE=$PYINSTALL/bin/python2.7
$PY_EXE --version
LDFLAGS="-Wl,-rpath /usr/local/lib"
export LDFLAGS="-Wl,-rpath $PYINSTALL/lib/python2.7/lib-dynload/"
export LD_LIBRARY_PATH=$PYINSTALL/lib/python2.7/lib-dynload:$LD_LIBRARY_PATH
export LD_LIBRARY_PATH=$PYINSTALL/lib:$LD_LIBRARY_PATH
export LD_LIBRARY_PATH=~/code/cpython-27/install-py27-debug/lib:$LD_LIBRARY_PATH
$PY_EXE -c "import ctypes" 


$PY_EXE -m pip install pip setuptools virtualenv -U
export VENV_DIR="$HOME/code/cpython-27/venvs/venv2-debug"
mkdir -p $VENV_DIR
$PY_EXE -m virtualenv -p $PY_EXE $VENV_DIR 

#NOTE for viame

PYTHON_LIBRARY = ~/code/cpython-27/install-py27-debug/lib/libpython2.7.so
PYTHON_INCLUDE_DIR = ~/code/cpython-27/install-py27-debug/include/python2.7
PYTHON_LIBRARY_DEBUG = ~/code/cpython-27/install-py27-debug/lib
