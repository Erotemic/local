#!/bin/bash
set -e

PREFIX=$HOME/.local
SRCDIR=$HOME/tmp/src
mkdir -p $SRCDIR

HTOP_VERSION=2.0.2
HTOP_DPATH=$SRCDIR/htop-$HTOP_VERSION

CPATH=$PREFIX/include/ncursesw:$CPATH

if [ ! -d "$HTOP_DPATH" ]; then 
    echo "downloading and extract htop"
    cd $SRCDIR
    wget https://hisham.hm/htop/releases/$HTOP_VERSION/htop-$HTOP_VERSION.tar.gz
    tar xvzf htop-$HTOP_VERSION.tar.gz
else
    echo "htop already downloaded"
fi
cd $HTOP_DPATH
export CPPFLAGS="-I$PREFIX/include/ncursesw"
./configure CFLAGS="-I$PREFIX/include -I$PREFIX/include/ncursesw" --prefix=$PREFIX
CPPFLAGS="-I$PREFIX/include/ncursesw"
