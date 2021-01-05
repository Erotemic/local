#!/bin/sh
# Different on windows  
source ~/local/init/utils.sh
#safe_symlink ~/local/vim/vimfiles ~/.vim
safe_symlink ~/local/vim/portable_vimrc ~/.vimrc

# Run vim once to install plugins
vim -en -c ":q"
vim -en -c ":PlugInstall | qa"

if [[ -d "$HOME/code/vimtk" ]]; then
    rm -rf $HOME/.vim/bundle/vimtk
    safe_symlink $HOME/code/vimtk $HOME/.vim/bundle/vimtk
fi

mkdir -p ~/.vim_tmp


# TODO: ensure we pip install vimtk requirements
# ubelt, pyperclip


#ln -s 
#VIMRC_FPATH=$HOME/.vimrc
#if [[ -L "$VIMRC_FPATH" ]]; then 
#    echo "Removing old vimrc symlink"
#    unlink $VIMRC_FPATH
#elif [[ -f "$VIMRC_FPATH" ]]; then 
#    echo "Moving old vimrc to backup file"
#    mv $VIMRC_FPATH $VIMRC_FPATH.$(date +"%s").bakup
#fi
#echo "Create new vimrc symlink"
#ln -s ~/local/vim/portable_vimrc ~/.vimrc
