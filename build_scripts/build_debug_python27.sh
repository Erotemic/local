deps(){
    sudo apt-get install valgrind

}

cd ~/code
git clone https://github.com/python/cpython.git cpython-27
deactivate_venv

REPO_DIR=$HOME/code/cpython-27
cd $REPO_DIR
git checkout v2.7.12

PYINSTALL="$REPO_DIR/install-py27-debug"
echo "PYINSTALL = $PYINSTALL"

./configure \
    --prefix="$PYINSTALL" \
    --with-ensurepip=install \
    --without-pymalloc --with-pydebug --with-valgrind \
    --enable-shared --enable-unicode=ucs4 
make -j5

# Installs to to the repo dir for debug mode
make install
make altinstall


CUSTOM_VENV_BASE=$REPO_DIR/venvs
mkdir -p $CUSTOM_VENV_BASE

PYEXE="$PYINSTALL/bin/python2.7"


# SETUP ENVIRONMENT 
export PATH=$PYINSTALL/bin:$PATH
export LD_LIBRARY_PATH=$PYINSTALL/lib:$LD_LIBRARY_PATH
export C_INCLUDE_PATH=$PYINSTALL/include:$C_INCLUDE_PATH
export CPATH=$PYINSTALL/include:$CPATH

# TEST we can import stuff
$PYEXE -c "import ctypes"   # Works now that the env is right


setup_debug_venv27(){
    # Inhouse version
    # Ensure PIP, setuptools, and virtual are on the SYSTEM
    $PYEXE -m pip install pip setuptools virtualenv -U
    PYVERSUFF=$($PYEXE -c "import sysconfig; print(sysconfig.get_config_var('VERSION'))")

    PYTHON_VENV_DPATH="$CUSTOM_VENV_BASE/venv$PYVERSUFF"
    mkdir -p $PYTHON_VENV_DPATH
    python3 -m virtualenv -p $PYEXE $PYTHON_VENV_DPATH 
    python3 -m virtualenv --relocatable $PYTHON_VENV_DPATH 

    #python3 -m virtualenv -p /usr/bin/python3 $PYTHON_VENV_DPATH
    source $PYTHON_VENV_DPATH/bin/activate

    # Test
    python -c "import ctypes"
}







custom_virtualenv(){
    # Do we need to use this version?
    if [! -d "$HOME/code/virtualenv"]; then
        cd ~/code
        git clone https://github.com/pypa/virtualenv.git
        cd virtualenv
    fi
    git remote add gst https://github.com/gst/virtualenv.git
    git checkout -b test
    git merge gst/fix_for_shared_lib_and_rpath_origin


    $PYEXE -m pip install pip setuptools -U
    cd ~/code/virtualenv
    $PYEXE -m pip install -e .

    cd ~/code/cpython-27

    VENV_DIR="$HOME/code/cpython-27/venvs/venv2-debug"
    mkdir -p $VENV_DIR
    $PYEXE -m virtualenv --include-lib -p $PYEXE $VENV_DIR 
    VENV_DIR="$HOME/code/cpython-27/venvs/venv2-debug"
    source $VENV_DIR/bin/activate
}


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
    -DPYTHON_EXECUTABLE=$PYEXE
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

PYEXE=$PYINSTALL/bin/python2.7
$PYEXE --version
LDFLAGS="-Wl,-rpath /usr/local/lib"
export LDFLAGS="-Wl,-rpath $PYINSTALL/lib/python2.7/lib-dynload/"
export LD_LIBRARY_PATH=$PYINSTALL/lib/python2.7/lib-dynload:$LD_LIBRARY_PATH
export LD_LIBRARY_PATH=$PYINSTALL/lib:$LD_LIBRARY_PATH
export LD_LIBRARY_PATH=~/code/cpython-27/install-py27-debug/lib:$LD_LIBRARY_PATH
$PYEXE -c "import ctypes" 


$PYEXE -m pip install pip setuptools virtualenv -U
export VENV_DIR="$HOME/code/cpython-27/venvs/venv2-debug"
mkdir -p $VENV_DIR
$PYEXE -m virtualenv -p $PYEXE $VENV_DIR 

#NOTE for viame

PYTHON_LIBRARY = ~/code/cpython-27/install-py27-debug/lib/libpython2.7.so
PYTHON_INCLUDE_DIR = ~/code/cpython-27/install-py27-debug/include/python2.7
PYTHON_LIBRARY_DEBUG = ~/code/cpython-27/install-py27-debug/lib

#http://pythonextensionpatterns.readthedocs.io/en/latest/debugging/debug_python.html
#grep CONFIG_ARGS /usr/lib/python2.7/config-x86_64-linux-gnu/Makefile
# http://pythonsweetness.tumblr.com/post/151938194807/debugging-c-extension-memory-safety-with-valgrind
# https://github.com/docker-library/python/issues/21
# https://docs.python.org/2/using/unix.html#building-python
# https://hg.python.org/cpython/file/2.7/README
# https://github.com/pyenv/pyenv/issues/65
# http://www.gem5.org/Using_a_non-default_Python_installation

#deactivate_venv
#rm -rf $REPO_DIR* && git checkout *
#PYINSTALL="$HOME/code/cpython-27/install-py27-debug"
#cd ~/code/cpython-27
#./configure \
#    --prefix="$PYINSTALL" \
#    --with-ensurepip=install \
#    --without-pymalloc --with-pydebug --with-valgrind \
#    --enable-shared --enable-unicode=ucs4 
#make -j5
#make altinstall
