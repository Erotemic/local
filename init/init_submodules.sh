cd ~/local/vim/vimfiles/bundle
cd %USERPROFILE%/local/vim/vimfiles/bundle

git clone https://github.com/zhaocai/GoldenView.Vim.git

git clone https://github.com/koron/minimap-vim.git

# Setup initial symbolic links and file permissions
git submodule init
git submodule update
cd ~/local/vim/vimfiles/bundle/jedi-vim
#cd %HOME%/local/vim/vimfiles/bundle/jedi-vim
git submodule init
git submodule update
