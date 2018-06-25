# https://github.com/vim/vim/issues/1483

co
git clone https://github.com/vim/vim.git
cd ~/code/vim

#mkdir tmpinstall

prereq(){
    #sudo apt-get build-dep vim
    sudo apt install build-essential libtinfo-dev -y
    sudo apt build-dep vim-gtk -y
    sudo apt install ncurses-dev
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


#sudo apt-get update
# We want to be on gtk-3.22.4, but ubuntu16.04 defaults to 3.17
# TODO: upgrade gtk3
# https://github.com/vim/vim/issues/1483
#sudo apt-get install libgtk-3-0

# Check version of gtk
dpkg -l libgtk* | grep -e '^i' | grep -e 'libgtk-*[0-9]'
#pkg-config --modversion gtk+-3.0


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


vim_python37_version(){
    make distclean
    ./configure \
        --prefix=$HOME/.local \
        --enable-pythoninterp=no \
        --enable-python3interp=yes \
        --with-python3-config-dir=$(python3.7-config --configdir) \
        --enable-gui=gtk3
    cat src/auto/config.mk 
    cat src/auto/config.mk | grep PYTHON3
    make -j9
    ./src/vim -u NONE --cmd "source test.vim"
}
    #--prefix=$HOME/.local \
    #--exec-prefix=$HOME/.local \
    #--with-vim-name=vim-8 \
    #--with-ex-name=ex-8 \
    #--with-view-name=view-8 \

    #--enable-python3interp=yes \

with_conda_python36(){
    # NOTE:
    # https://github.com/ContinuumIO/anaconda-issues/issues/6619
    #conda install gxx_linux-64
    #conda install ncurses

    #conda install pkg-config autoconf automake cmake libtool
    #conda install -c anaconda gtk2-devel-cos6-x86_64 
    #conda install -c anaconda libx11-devel-cos6-x86_64 

    #conda install -c anaconda libiconv 
    #conda install -c anaconda glib 

    conda create -n vim80build python=3.6 
    conda activate vim80build

    #conda install gcc_linux-64
    #conda install gxx_linux-64 ncurses pkg-config autoconf automake cmake libtool libx11-devel-cos6-x86_64 libiconv glib libxml2 libpng cairo

    conda install ncurses libx11-devel-cos6-x86_64 libiconv glib libxml2 libpng cairo
    conda install -c pkgw/label/superseded gtk3

    # Remove gxx_linux-64 and gcc_linux-64 after you are done?
    cd ~/code/vim
    make distclean
    LDFLAGS="-L$CONDA_PREFIX/lib -Wl,-rpath,$CONDA_PREFIX/lib" ./configure --prefix=$CONDA_PREFIX --enable-pythoninterp=no --enable-python3interp=yes --enable-gui=gtk3 --with-local-dir==$CONDA_PREFIX
    cat src/auto/config.mk | grep GUI

    
    # GTK2 VERSION ALSO WORKS
    conda config --add channels loopbio
    conda install gtk2


    NCPUS=$(grep -c ^processor /proc/cpuinfo)
    make -j$NCPUS

    # Potential GTK issue
    # https://github.com/vim/vim/issues/1149

    #conda install -c mw gtk2
    #conda install -c pkgw/label/superseded gtk3
    #conda install -c pkgw-forge gtk3 
    #conda install -c anaconda libxt-devel-cos6-x86_64 
    #apt-cache showsrc vim-gtk | grep ^Build-Depends



    #make distclean
    #LDFLAGS="-L$CONDA_PREFIX/lib -Wl,-rpath,$CONDA_PREFIX/lib -L. -Wl,-Bsymbolic-functions -Wl,-z,relro -Wl,-z,now -fstack-protector -rdynamic -Wl,-export-dynamic -Wl,-O2 -Wl,--sort-common -Wl,--as-needed -Wl,-z,relro -Wl,-z,now -L/usr/local/lib -L/usr/lib/x86_64-linux-gnu" \
    #    ./configure --prefix=$CONDA_PREFIX --enable-pythoninterp=no --enable-python3interp=yes --enable-gui=gtk2 \
    #    --with-local-dir==$CONDA_PREFIX --with-gnome-libs=$CONDA_PREFIX/lib --with-gnome-includes=$CONDA_PREFIX/include
    #cat src/auto/config.mk | grep GUI
}

./configure \
    --prefix=$HOME/.local \
    --enable-pythoninterp=no \
    --enable-python3interp=yes \
    --enable-gui=gtk2

cat src/auto/config.mk 
cat src/auto/config.mk | grep GUI
cat src/auto/config.mk | grep PYTHON3

# Build
NCPUS=$(grep -c ^processor /proc/cpuinfo)
make -j$NCPUS

# Test
~/code/vim/src/vim --version
~/code/vim/src/vim -u NONE
# Install
make install

ls -al ~/bin/*vim*
#ls tmpinstall/bin/
#/usr/local/bin/gvim-8 --version
#/usr/bin/gvim --version
