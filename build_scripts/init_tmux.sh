#!/bin/bash

# https://gist.github.com/ryin/3106801

# Script for installing tmux on systems where you don't have root access.
# tmux will be installed in $PREFIX/bin.
# It's assumed that wget and a C/C++ compiler are installed.

# exit on error
set -e

TMUX_VERSION=2.6

PREFIX=$HOME/.local

# create our directories
mkdir -p $PREFIX $HOME/tmp/tmux 
cd $HOME/tmp/tmux 

NCPUS=$(grep -c ^processor /proc/cpuinfo)

# download source files for tmux, libevent, and ncurses
wget -O tmux-${TMUX_VERSION}.tar.gz https://github.com/tmux/tmux/releases/download/${TMUX_VERSION}/tmux-${TMUX_VERSION}.tar.gz
wget https://github.com/downloads/libevent/libevent/libevent-2.0.19-stable.tar.gz
wget ftp://ftp.gnu.org/gnu/ncurses/ncurses-5.9.tar.gz

# extract files, configure, and compile

############
# libevent #
############
cd $HOME/tmp/tmux 
tar xvzf libevent-2.0.19-stable.tar.gz
cd libevent-2.0.19-stable
./configure --prefix=$PREFIX --disable-shared
make -j$NCPUS
make install

############
# ncurses  #
############
# https://stackoverflow.com/questions/37475222/ncurses-6-0-compilation-error-error-expected-before-int
export 
cd $HOME/tmp/tmux 
tar xvzf ncurses-5.9.tar.gz
cd ncurses-5.9
./configure --prefix=$PREFIX
CPPFLAGS="-P" make -j$NCPUS
make install

############
# tmux     #
############
cd $HOME/tmp/tmux 
tar xvzf tmux-${TMUX_VERSION}.tar.gz
cd $HOME/tmp/tmux/tmux-${TMUX_VERSION}
./configure CFLAGS="-I$PREFIX/include -I$PREFIX/include/ncurses" LDFLAGS="-L$PREFIX/lib -L$PREFIX/include/ncurses -L$PREFIX/include" --prefix=$PREFIX
CPPFLAGS="-I$PREFIX/include -I$PREFIX/include/ncurses" LDFLAGS="-static -L$PREFIX/include -L$PREFIX/include/ncurses -L$PREFIX/lib" make -j$NCPUS
make install


#cp tmux $PREFIX/bin

# cleanup
#rm -rf $HOME/tmp/tmux 
echo "$PREFIX/bin/tmux is now available. You can optionally add $PREFIX/bin to your PATH."
