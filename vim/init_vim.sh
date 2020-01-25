#!/bin/sh
# Different on windows  
ln -s ~/local/vim/vimfiles ~/.vim
mkdir ~/.vim_tmp

VIMRC_FPATH=$HOME/.vimrc
if [[ -L "$VIMRC_FPATH" ]]; then 
    echo "Removing old vimrc symlink"
    unlink $VIMRC_FPATH
elif [[ -f "$VIMRC_FPATH" ]]; then 
    echo "Moving old vimrc to backup file"
    mv $VIMRC_FPATH $VIMRC_FPATH.$(date +"%s").bakup
fi
echo "Create new vimrc symlink"
ln -s ~/local/vim/portable_vimrc ~/.vimrc
