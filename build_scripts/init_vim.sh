# https://github.com/vim/vim/issues/1483

co
git clone https://github.com/vim/vim.git
cd ~/code/vim

#mkdir tmpinstall

prereq(){
    #sudo apt-get build-dep vim
    sudo apt-get install build-essential -y
    sudo apt-get install libtinfo-dev -y
    sudo apt-get build-dep vim-gtk
    #sudo apt-get build-dep vim-gnome
}

help(){
    ./configure --help
    ./configure --help | grep python
}

#export CC=gcc
#export =clang

#make distclean


# Check version of gtk
dpkg -l libgtk* | grep -e '^i' | grep -e 'libgtk-*[0-9]'
pkg-config --modversion gtk+-3.0

sudo apt-get update
# TODO: upgrade gtk3
# https://github.com/vim/vim/issues/1483
sudo apt-get install libgtk-3-0



#CFLAGS="$CFLAG -O3"
#deactivate
make distclean

# GUI options:
#auto/no/gtk2/gnome2/gtk3/motif/athena/neXtaw/photon/carbon

#PYTHON3_SRC	= if_python3.c
#PYTHON3_OBJ	= objects/if_python3.o
#PYTHON3_CFLAGS	= -I/home/joncrall/venv3/include/python3.5m -DPYTHON3_HOME='L"/home/joncrall/venv3"' -pthread -fPIE
#PYTHON3_LIBS	= -L/usr/lib/python3.5/config-3.5m-x86_64-linux-gnu -lpython3.5m -lpthread -ldl -lutil -lm
#PYTHON3_CONFDIR	= /usr/lib/python3.5/config-3.5m-x86_64-linux-gnu

#PYTHON3_SRC	= if_python3.c
#PYTHON3_OBJ	= objects/if_python3.o
#PYTHON3_CFLAGS	= -I/usr/include/python3.5m -DPYTHON3_HOME='L"/usr"' -pthread -fPIE
#PYTHON3_LIBS	= -L/usr/lib/python3.5/config-3.5m-x86_64-linux-gnu -lpython3.5m -lpthread -ldl -lutil -lm
#PYTHON3_CONFDIR	= /usr/lib/python3.5/config-3.5m-x86_64-linux-gnu

#PYTHON3_CFLAGS="-I$VIRTUAL_ENV/include/python3.7m -DPYTHON3_HOME=L$VIRTUAL_ENV -pthread -fPIE"
#PYTHON3_LIBS="-L$VIRTUAL_ENV/lib/python3.7/config-3.7m-x86_64-linux-gnu -lpython3.7m -lpthread -ldl -lutil -lm"
#PYTHON3_CONFDIR="$VIRTUAL_ENV/lib/python3.7/config-3.7m-x86_64-linux-gnu"

./configure \
    --prefix=$HOME \
    --enable-pythoninterp=no \
    --enable-python3interp=yes \
    --enable-gui=gtk3

    #--prefix=$HOME/.local \
    #--exec-prefix=$HOME/.local \
    #--with-vim-name=vim-8 \
    #--with-ex-name=ex-8 \
    #--with-view-name=view-8 \

    #--enable-python3interp=yes \

cat src/auto/config.mk 
cat src/auto/config.mk | grep PYTHON3

# Build
make -j9
# Test
~/code/vim/src/vim
#~/code/vim/src/vim --version
# Install
make install

ls -al ~/bin/*vim*
#ls tmpinstall/bin/
#/usr/local/bin/gvim-8 --version
#/usr/bin/gvim --version
