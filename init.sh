ln -s ~/local/profile.sh ~/.profile
ln -s ~/local/vim/vimfiles ~/.vim

git config --global user.name joncrall
git config --global user.email crallj@rpi.edu
git config --global push.default simple


echo "" > ~/.vimrc
echo "source ~/local/vim/clean_vimrc" >> ~/.vimrc
echo "source ~/local/vim/portable_vimrc" >> ~/.vimrc 


