cd ~
git clone git@github.com:Erotemic/local.git

mkdir ~/code
cd ~/code

git clone git@github.com:Erotemic/utool.git
git clone git@github.com:Erotemic/vtool.git
git clone git@github.com:Erotemic/ibeis.git
git clone git@github.com:Erotemic/flann.git
git clone git@github.com:Erotemic/guitool.git
git clone git@github.com:Erotemic/plottool.git
git clone git@github.com:Erotemic/hesaff.git
git clone git@github.com:Erotemic/opencv.git

sudo easy_install --upgrade setuptools
sudo pip install setuptools --upgrade
#sudo pip install matplotlib --upgrade
sudo easy_install pylru
#sudo pip install pylru


sudo port install py27-matplotlib +qt4


git submodule init
git submodule update
#cd ~/local/vim/vimfiles/bundle/jedi-vim
cd %HOME%/local/vim/vimfiles/bundle/jedi-vim
git submodule init
git submodule update


cd ~/local/vim/vimfiles/bundle
git clone https://github.com/tpope/vim-surround.git
git clone https://github.com/tpope/vim-repeat.git


cd ~/local/vim/vimfiles/bundle
#cd %USERPROFILE%/local/vim/vimfiles/bundle

git clone https://github.com/tpope/vim-fugitive.git

git clone https://github.com/zhaocai/GoldenView.Vim.git
git clone https://github.com/terryma/vim-multiple-cursors.git
git clone https://github.com/bling/vim-airline.git
git clone https://github.com/koron/minimap-vim.git
git clone https://github.com/scrooloose/nerdtree.git
git clone https://github.com/davidhalter/jedi-vim.git
git clone https://github.com/scrooloose/syntastic.git
git clone https://github.com/tpope/vim-unimpaired.git
git clone https://github.com/mhinz/vim-startify.git


# Setup initial symbolic links and file permissions
git submodule init
git submodule update
cd ~/local/vim/vimfiles/bundle/jedi-vim
#cd %USERPROFILE%/local/vim/vimfiles/bundle/jedi-vim
git submodule init
git submodule update
