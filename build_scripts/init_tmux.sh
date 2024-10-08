#!/usr/bin/env bash
__doc__='
References:
    https://gist.github.com/ryin/3106801

Script for installing tmux on systems where you dont have root access.
tmux will be installed in $PREFIX/bin.
Its assumed that wget and a C/C++ compiler are installed.

Ignore:
'

# exit on error
set -e


PREFIX=$HOME/.local
SRCDIR=$HOME/tmp/src
mkdir -p "$SRCDIR"

# create our directories
cd "$SRCDIR"

NCPUS=$(grep -c ^processor /proc/cpuinfo)

COMPILE_DEPS=0


apt_ensure(){
    # Note the $@ is not actually an array, but we can convert it to one
    # https://linuxize.com/post/bash-functions/#passing-arguments-to-bash-functions
    ARGS=("$@")
    MISS_PKGS=()
    HIT_PKGS=()
    _SUDO=""
    if [ "$(whoami)" != "root" ]; then
        # Only use the sudo command if we need it (i.e. we are not root)
        _SUDO="sudo "
    fi
    for PKG_NAME in "${ARGS[@]}"
    do
        # Check if the package is already installed or not
        if dpkg-query -W -f='${Status}' "$PKG_NAME" 2>/dev/null | grep -q "install ok installed"; then
            echo "Already have PKG_NAME='$PKG_NAME'"
            HIT_PKGS+=("$PKG_NAME")
        else
            echo "Do not have PKG_NAME='$PKG_NAME'"
            MISS_PKGS+=("$PKG_NAME")
        fi
    done

    # Install the packages if any are missing
    if [ "${#MISS_PKGS[@]}" -gt 0 ]; then
        if [ "${UPDATE}" != "" ]; then
            $_SUDO apt update -y
        fi
        DEBIAN_FRONTEND=noninteractive $_SUDO apt install -y "${MISS_PKGS[@]}"
    else
        echo "No missing packages"
    fi
}

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
TMUX_VERSION=3.5
USE_SOURCE=true

if [[ "$USE_SOURCE" == "true" ]]; then

    apt_ensure bison flex autotools-dev automake

    TMUX_DPATH=$HOME/code/tmux
    if [ ! -d "$TMUX_DPATH" ]; then
        git clone https://github.com/tmux/tmux.git "$TMUX_DPATH"
    fi
    cd "$TMUX_DPATH"
    git fetch
    if [[ "$TMUX_VERSION" == "HEAD" ]]; then
        git checkout master
    else
        git checkout $TMUX_VERSION
    fi
    git pull
    sh autogen.sh
    ./configure --prefix="$PREFIX"
    make -j"$NCPUS"
else
    # Tarball build?
    if [[ "$TMUX_VERSION" == "HEAD" ]]; then
        echo "CANNOT BUILD HEAD WITHOUT SOURCE"
        false
    else
        TMUX_DPATH=$SRCDIR/tmux-${TMUX_VERSION}
        if [ ! -d "$TMUX_DPATH" ]; then
            cd "$SRCDIR"
            wget -O tmux-${TMUX_VERSION}.tar.gz https://github.com/tmux/tmux/releases/download/${TMUX_VERSION}/tmux-${TMUX_VERSION}.tar.gz
            tar xvzf tmux-${TMUX_VERSION}.tar.gz
        fi
        cd "$TMUX_DPATH"

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
    fi
fi


#cp tmux $PREFIX/bin
# cleanup
#rm -rf $HOME/tmp/tmux
echo "$PREFIX/bin/tmux is now available. You can optionally add $PREFIX/bin to your PATH."


test_rich_hyperlinks(){
    __doc__='
    References:
        https://superuser.com/questions/1771573/file-hyperlink-not-working-under-tmux
        https://github.com/tmux/tmux/issues/911

    Note: adding:
        tmux -T hyperlinks

    seems to make this work

    List features


    '

    # Check version of system ncurses
    dpkg -l '*ncurses*' | grep '^ii'

     tmux display -p "#{client_termfeatures}"
     tmux display-message -p "This is a list of config files: #{config_files}"
     tmux source ~/.tmux.conf
     tmux display -p "#{client_termfeatures}"
     # test rich hyperlinks
     python -c "if 1:
         import rich
         import pathlib
         dpath = pathlib.Path('~').expanduser()
         rich.print(f'[link={dpath}]{dpath}[/link]')
     "
}
