co
git clone https://github.com/vim/vim.git

#mkdir tmpinstall

help() {
    ./configure --help
}

export CC=gcc
#export =clang

make distclean

./configure \
    --prefix=$HOME \
    --enable-pythoninterp=yes \
    --with-vim-name=vim-8 \
    --with-ex-name=ex-8 \
    --with-view-name=view-8 \
    --enable-gui=auto

    --enable-gui=gnome
\
    --with-gnome 
gtk2/gnome2/gtk3
#--prefix=/home/joncrall/code/vim/tmpinstall
make -j9
sudo make install

ls tmpinstall/bin/

/usr/local/bin/gvim-8 --version
/usr/bin/gvim --version
