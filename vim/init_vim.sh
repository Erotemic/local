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
else 
    git clone git@github.com:Erotemic/vimtk.git $HOME/code/vimtk
    echo "no vimtk dev"
fi

mkdir -p ~/.vim_tmp


# TODO: ensure we pip install vimtk requirements
# ubelt, pyperclip

hack_vimtk_deps(){
    deactivate_venv
    pip3 install pyperclip psutil pep8 autopep8 flake8 pylint pytest --user

}


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
