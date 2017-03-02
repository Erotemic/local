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
sudo apt-get install libgtk-3-0



#CFLAGS="$CFLAG -O3"
deactivate
make distclean

# GUI options:
#auto/no/gtk2/gnome2/gtk3/motif/athena/neXtaw/photon/carbon

./configure \
    --prefix=$HOME \
    --enable-pythoninterp=no \
    --enable-python3interp=yes \
    --enable-gui=gtk3

    #--with-vim-name=vim-8 \
    #--with-ex-name=ex-8 \
    #--with-view-name=view-8 \

    #--enable-python3interp=yes \

cat src/auto/config.mk

make -j9
make install

ls -al ~/bin/*vim*
#ls tmpinstall/bin/
#/usr/local/bin/gvim-8 --version
#/usr/bin/gvim --version
