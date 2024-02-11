#!/usr/bin/env bash

# https://gist.github.com/ryin/3106801

# Script for installing tmux on systems where you don't have root access.
# tmux will be installed in $PREFIX/bin.
# It's assumed that wget and a C/C++ compiler are installed.

# exit on error
set -e


PREFIX=$HOME/.local
SRCDIR=$HOME/tmp/src
mkdir -p "$SRCDIR"

# create our directories
cd "$SRCDIR"

NCPUS=$(grep -c ^processor /proc/cpuinfo)

COMPILE_DEPS=0

# extract files, configure, and compile


if [[ "$COMPILE_DEPS" == "1" ]]; then

    ############
    # libevent #
    ############
    #
    if ! ldconfig -p | grep libevent ; then
        cd "$SRCDIR"
        wget https://github.com/downloads/libevent/libevent/libevent-2.0.19-stable.tar.gz
        tar xvzf libevent-2.0.19-stable.tar.gz
        cd "$SRCDIR"/libevent-2.0.19-stable
        ./configure --prefix="$PREFIX" --disable-shared
        make -j"$NCPUS"
        make install
    fi

    ############
    # ncurses  #
    ############
    # https://stackoverflow.com/questions/37475222/ncurses-6-0-compilation-error-error-expected-before-int
    if ! ldconfig -p | grep libncurses ; then
        NCURSES_DPATH=$SRCDIR/ncurses-5.9
        if [ ! -d "$HTOP_DPATH" ]; then
            cd "$SRCDIR"
            wget ftp://ftp.gnu.org/gnu/ncurses/ncurses-5.9.tar.gz
            tar xvzf ncurses-5.9.tar.gz
        fi
        cd "$NCURSES_DPATH"
        CPPFLAGS="-P"  ./configure --prefix="$PREFIX" --enable-widec --with-shared
        CPPFLAGS="-P" make -j"$NCPUS"
        make install
        NCURSES_INCLUDE_DIR=$PREFIX/include/ncursesw
    else
        NCURSES_INCLUDE_DIR=/usr/include/ncursesw
    fi
fi

############
# tmux     #
############

#TMUX_VERSION=3.3a
TMUX_VERSION=HEAD

if [[ "$TMUX_VERSION" == "HEAD" ]]; then

    sudo apt-get install bison flex

    TMUX_DPATH=$HOME/code/tmux
    if [ ! -d "$TMUX_DPATH" ]; then
        git clone https://github.com/tmux/tmux.git "$TMUX_DPATH"
    fi
    cd "$TMUX_DPATH"
    git fetch
    git pull
    sh autogen.sh
    ./configure --prefix="$PREFIX"
    make -j"$NCPUS"
else

    TMUX_DPATH=$SRCDIR/tmux-${TMUX_VERSION}
    if [ ! -d "$TMUX_DPATH" ]; then
        cd "$SRCDIR"
        wget -O tmux-${TMUX_VERSION}.tar.gz https://github.com/tmux/tmux/releases/download/${TMUX_VERSION}/tmux-${TMUX_VERSION}.tar.gz
        tar xvzf tmux-${TMUX_VERSION}.tar.gz
    fi
    cd "$TMUX_DPATH"
fi


if [[ "$COMPILE_DEPS" == "1" ]]; then
    #./configure CFLAGS="-I$PREFIX/include -I$NCURSES_INCLUDE_DIR" LDFLAGS="-L$PREFIX/lib -L$NCURSES_INCLUDE_DIR -L$PREFIX/include" --prefix="$PREFIX"
    ./configure \
        CFLAGS="-I$PREFIX/include -I$NCURSES_INCLUDE_DIR" \
        LDFLAGS="-L$PREFIX/lib" \
        --prefix="$PREFIX"

    CPPFLAGS="-I$PREFIX/include -I$NCURSES_INCLUDE_DIR" LDFLAGS="-static -L$PREFIX/include -L$NCURSES_INCLUDE_DIR -L$PREFIX/lib" make -j"$NCPUS"
else
    ./configure --prefix="$PREFIX"
    make -j"$NCPUS"
fi

make install


#cp tmux $PREFIX/bin

# cleanup
#rm -rf $HOME/tmp/tmux
echo "$PREFIX/bin/tmux is now available. You can optionally add $PREFIX/bin to your PATH."
