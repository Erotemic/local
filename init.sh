ln -s ~/local/profile.sh ~/.profile
ln -s ~/local/vim/vimfiles ~/.vim

echo "" > ~/.vimrc
echo "source ~/local/vim/clean_vimrc" >> ~/.vimrc
echo "source ~/local/vim/portable_vimrc" >> ~/.vimrc 
