ln -s ~/local/bashrc.sh ~/.bashrc
ln -s ~/local/profile.sh ~/.profile
# Different on windows
ln -s ~/local/vim/vimfiles ~/.vim

mkdir ~/.vim_tmp

echo "" > ~/.vimrc
echo "source ~/local/vim/clean_vimrc" >> ~/.vimrc
echo "source ~/local/vim/portable_vimrc" >> ~/.vimrc 
