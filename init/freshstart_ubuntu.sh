sudo apt-get install git -y

git clone https://github.com/Erotemic/local.git
cd local/init 


customize_sudoers()
{ 
    # Make timeout for sudoers a bit longer
    sudo cat /etc/sudoers > ~/tmp/sudoers.tmp  
    sed -i 's/^Defaults.*env_reset/Defaults    env_reset, timestamp_timeout=480/' ~/tmp/sudoers.tmp 
    #cat ~/tmp/sudoers.tmp  
    # Copy over the new sudoers file
    visudo -c -f ~/tmp/sudoers.tmp
    if [ "$?" -eq "0" ]; then
        sudo cp ~/tmp/sudoers.tmp /etc/sudoers
    fi 
    rm ~/tmp/sudoers.tmp
    #sudo cat /etc/sudoers 
} 

setup_homefolder()
{ 
mkdir ~/tmp
mkdir ~/code
cd ~
git clone https://github.com/Erotemic/local.git
cd ~/code
git clone https://github.com/Erotemic/ibeis.git

}

bashrc_symlinks()
{ 
  mv ~/.bashrc ~/.bashrc.orig
  mv ~/.profile ~/.profile.orig
  ln -s ~/local/bashrc.sh ~/.bashrc
  ln -s ~/local/profile.sh ~/.profile 
  source ~/.bashrc
}


install_fonts()
{
sudo cp ~/Dropbox/Installers/Fonts/*.ttf /usr/share/fonts/truetype/
sudo cp ~/Dropbox/Installers/Fonts/*.otf /usr/share/fonts/opentype/
sudo fc-cache
}


recover_backup()
{
    export BACKUPHOME="/media/joncrall/Seagate Backup Plus Drive/sep14bak/home/joncrall"
    cd "$BACKUPHOME/.ssh"
    # Recover ssh keys
    mkdir ~/.ssh
    cp -r * ~/.ssh
    cd ~/.ssh
    #cd ~/.ssh
    #cp -r "$BACKUPHOME/.ssh" .
    #mv .ssh/* .
    #rm -rf  ~/.ssh/.ssh
    export BACKUPLOCAL="/media/joncrall/HADES/local"
    cd "$BACKUPLOCAL"
}
 
init_git()
{
    git config --global user.name joncrall
    git config --global user.email crallj@rpi.edu
    git config --global push.default current
}
 

bashrc_symlinks()
source ~/local/vim/init_vim.sh
customize_sudoers()  
bashrc_symlinks()
