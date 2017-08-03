
#DEPRICATE

source init_bashrc_symlinks.sh

git config --global user.name joncrall
git config --global user.email crallj@rpi.edu
git config --global push.default simple
git config --global push.default simple
git config --global filter.tabspace.clean 'expand --tabs=4 --initial'
git config --global core.editor gvim
git config --global color.ui true


sudo chmod 700 ~/.ssh
sudo chmod 640 ~/.ssh/authorized_keys

source init/init_submodules.sh
