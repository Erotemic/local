#!/bin/bash
git_ensure(){
    GIT_URL=$1
    GIT_DPATH=$2
    if [ ! -d "$GIT_DPATH" ]; then 
        git clone "$GIT_URL" "$GIT_DPATH"
    fi
}
git_ensure https://github.com/aristocratos/btop.git "$HOME/code/btop"
cd "$HOME/code/btop"
PREFIX=$HOME/.local make
PREFIX=$HOME/.local make install
