source init_bashrc_symlinks.sh

git config --global user.name joncrall
git config --global user.email crallj@rpi.edu
git config --global push.default simple


echo "" > ~/.vimrc
echo "source ~/local/vim/clean_vimrc" >> ~/.vimrc
echo "source ~/local/vim/portable_vimrc" >> ~/.vimrc 

sudo chmod 700 ~/.ssh
sudo chmod 640 ~/.ssh/authorized_keys

source init/init_submodules.sh
