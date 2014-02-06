# Grab all the .gitconfig files
export dump=$(for i in $(/bin/ls); do cat $i/.git/config; done)
# Dump the github urls
python -c "import re, sys; print('\\n'.join([line for line in sys.argv if re.search('github', line)]))" $dump
#ls | xargs -n1 checkgit

cd ~/local
git submodule add https://github.com/scrooloose/nerdtree.git  vim/vimfiles/bundle/nerdtree
git submodule add https://github.com/davidhalter/jedi-vim.git vim/vimfiles/bundle/jedi-vim
git submodule add https://github.com/scrooloose/syntastic.git vim/vimfiles/bundle/syntastic
git submodule add https://github.com/tpope/vim-unimpaired.git vim/vimfiles/bundle/vim-unimpaired


cd vim/vimfiles/bundle
mv jedi-vim ../bundle_disabled
mv syntastic ../bundle_disabled
mv vim-unimpaired ../bundle_disabled
