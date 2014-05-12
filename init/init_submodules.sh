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
