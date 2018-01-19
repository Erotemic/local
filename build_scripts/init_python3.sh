# Probably the easier option if available, but hey your building python from source
apt_install_deps(){
    sudo apt-get install libreadline-dev 
    sudo apt-get install libssl-dev
    sudo apt-get install libsqlite3-dev
    sudo apt-get install libgdbm-dev
    sudo apt-get install liblzma-dev
}

set -e

NCPUS=$(grep -c ^processor /proc/cpuinfo)
export PREFIX=$HOME/.local
mkdir -p $PREFIX

# --------------------------
# PYTHON DEPENDS ON OPENSSL
# (build from source if you cant apt install the dev packages)
cd ~/code
git clone https://github.com/openssl/openssl.git
cd ~/code/openssl
./config --prefix=$PREFIX
make -j$NCPUS
make test
make install
# --------------------------


# --------------------------
# PYTHON DEPENDS ON READLINE
# (build from source if you cant apt install the dev packages)
cd ~/code
git clone https://git.savannah.gnu.org/git/readline.git
cd ~/code/readline
./configure --prefix=$PREFIX
make -j$NCPUS
make install
# --------------------------


# ensure custom build libs are finable
export LD_LIBRARY_PATH="$PREFIX/lib:$LD_LIBRARY_PATH"
export CPATH="$PREFIX/include:$CPATH"



#=====================
# SOURCE: BUILD PYTHON
cd ~/code
git clone https://github.com/python/cpython.git
cd ~/code/cpython
#git checkout 3.4
#git checkout 3.4_ctypes_errmsg
git checkout 3.6
# Configure cflags

cd ~/code/cpython
CFLAGS="-fno-strict-aliasing -fstack-protector --param=ssp-buffer-size=4 -Wformat -Wformat-security -Werror=format-security -O2" ./configure --prefix="$PREFIX" --enable-shared LDFLAGS="-Wl,-rpath /usr/local/lib" --enable-optimizations

NCPUS=$(grep -c ^processor /proc/cpuinfo)
make -j$NCPUS
make test
make install
