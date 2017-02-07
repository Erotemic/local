co
git clone https://github.com/vim/vim.git
cd ~/code/vim

#mkdir tmpinstall

help() {
    ./configure --help
}

#export CC=gcc
#export =clang

#make distclean
#sudo apt-get build-dep vim
sudo apt-get install build-essential -y
sudo apt-get install libtinfo-dev -y
sudo apt-get build-dep vim-gtk
#sudo apt-get build-dep vim-gnome

deactivate

make distclean

./configure \
    --prefix=$HOME \
    --enable-pythoninterp=yes \
    --enable-gui=gtk2

    #--with-vim-name=vim-8 \
    #--with-ex-name=ex-8 \
    #--with-view-name=view-8 \

    #--enable-python3interp=yes \

cat src/auto/config.mk

make -j9
make install

ls -al ~/bin/*vim*
ls tmpinstall/bin/

/usr/local/bin/gvim-8 --version
/usr/bin/gvim --version
