#https://github.com/dropbox/pyston/blob/master/docs/INSTALLING.md

sudo apt-get install libgmp-dev libmpfr-dev libmpc-dev make build-essential libtool zip gcc-multilib autogen
sudo apt-get install ccache
sudo apt-get install libncurses5-dev zlib1g-dev liblzma-dev
sudo apt-get install texlive-extra-utils autoconf
sudo apt-get install zsh
sudo apt-get install libreadline-dev
sudo apt-get install libgmp3-dev


python -c "import utool as ut; ut.sedfile(
            ut.truepath('~/code/pyston/src/Makefile'),
            r'DEPS_DIR := \\\$\\(HOME\\)\\/pyston_deps',
            r'DEPS_DIR := \$(HOME)/external/pyston_deps',
            veryverbose=True, force=True)"

#python -c "import utool as ut; ut.sedfile(
#            ut.truepath('~/code/pyston/src/Makefile'),
#            'GCC_DIR := \\\$\\(DEPS_DIR\\)/gcc-4.8.2-install',
#            'GCC_DIR := /usr',
#            veryverbose=True, force=True)"


mkdir ~/external
mkdir ~/external/pyston_deps
cd ~/external/pyston_deps

wget 'http://www.netgull.com/gcc/releases/gcc-4.8.2/gcc-4.8.2.tar.bz2'
tar xvf gcc-4.8.2.tar.bz2
mkdir gcc-4.8.2-{build,install}
git clone http://llvm.org/git/llvm.git llvm-trunk
git clone http://llvm.org/git/clang.git llvm-trunk/tools/clang
git clone git://github.com/vinzenz/pypa
mkdir pypa-install


cd ~/external/pyston_deps/gcc-4.8.2-build
# Space- and time-saving configuration:
../gcc-4.8.2/configure --disable-bootstrap --enable-languages=c,c++ --prefix=$HOME/external/pyston_deps/gcc-4.8.2-install
make -j4
make check
make install
~/external/pyston_deps/gcc-4.8.2-install/bin/gcc --version


cd ~/external/pyston_deps
cd ~/code/pyston/src
make llvm_up
make llvm_configure
make llvm -j4


cd ~/external/pyston_deps/pypa
./autogen.sh
./configure --prefix=$HOME/external/pyston_deps/pypa-install CXX=$HOME/external/pyston_deps/gcc-4.8.2-install/bin/g++


