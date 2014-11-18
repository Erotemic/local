freshtart_ubuntu_main()
{
    source ~/local/init/frestart_ubuntu.sh
    entry_prereq_git_and_local
    freshtart_ubuntu_entry_point
}


entry_prereq_git_and_local()
{
    # This is usually done manually
    sudo apt-get install git -y
    cd ~
    # If local does not exist
    if [ ! -f ~/local ]; then
        git clone https://github.com/Erotemic/local.git
        cd local/init 
    fi
}

#setup_homefolder()
freshtart_ubuntu_entry_point()
{ 
    if [ ! -f ~/local ]; then
    mkdir ~/tmp
    fi
    if [ ! -f ~/code ]; then
    mkdir ~/code
    fi
    cd ~
    if [ ! -f ~/local ]; then
        git clone https://github.com/Erotemic/local.git
    fi
    # TODO UTOOL
    mv ~/.bashrc ~/.bashrc.orig
    mv ~/.profile ~/.profile.orig
    ln -s ~/local/bashrc.sh ~/.bashrc
    ln -s ~/local/profile.sh ~/.profile 
    source ~/.bashrc

    git config --global user.name joncrall
    git config --global user.email crallj@rpi.edu
    git config --global push.default current

    mkdir ~/local/vim/vimfiles/bundle
    source ~/local/vim/init_vim.sh
    python ~/local/init/ensure_vim_plugins.py
    cd ~/code
}


install_dropbox()
{
    # Dropbox 
    #cd ~/tmp
    #cd ~/tmp && wget -O - "https://www.dropbox.com/download?plat=lnx.x86_64" | tar xzf -
    #.dropbox-dist/dropboxd
    sudo apt-get -y install nautilus-dropbox
}


install_fonts()
{
    sudo cp ~/Dropbox/Installers/Fonts/*.ttf /usr/share/fonts/truetype/
    sudo cp ~/Dropbox/Installers/Fonts/*.otf /usr/share/fonts/opentype/
    sudo fc-cache
}

virtualbox_ubuntu_init()
{
    sudo apt-get install dkms 
    sudo apt-get update
    sudo apt-get upgrade
    # Press Ctrl+D to automatically install virtualbox addons do this
    sudo apt-get install virtualbox-guest-additions-iso
    sudo apt-get install dkms build-essential linux-headers-generic
    sudo apt-get install build-essential linux-headers-$(uname -r)
    sudo apt-get install virtualbox-ose-guest-x11
    # setup virtualbox for ssh
    VBoxManage modifyvm virtual-ubuntu --natpf1 "ssh,tcp,,3022,,22"
}

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

 
gnome_settings()
{
    #gconftool-2 --all-dirs "/"
    #gconftool-2 --all-dirs "/desktop/url-handlers"
    #gconftool-2 -a "/desktop/url-handlers"
    #gconftool-2 -a "/desktop/applications"
    #gconftool-2 --all-dirs "/schemas/desktop"
    #gconftool-2 --all-dirs "/apps"
    #gconftool-2 -R /desktop
    #gconftool-2 -R /
    #gconftool-2 --get /apps/nautilus/preferences/desktop_font
    #gconftool-2 --get /desktop/gnome/interface/monospace_font_name

    #gconftool-2 -a "/apps/gnome-terminal/profiles/Default" 
    #gsettings set org.gnome.desktop.lockdown disable-lock-screen 'true'
    #sudo -u gdm gconftool-2 --type=bool --set /desktop/gnome/sound/event_sounds false

    gconftool-2 --set "/apps/gnome-terminal/profiles/Default/background_color" --type string "#1111111"
    gconftool-2 --set "/apps/gnome-terminal/profiles/Default/foreground_color" --type string "#FFFF6999BBBB"
    gconftool-2 --set /apps/gnome-screensaver/lock_enabled --type bool false
    gconftool-2 --set /desktop/gnome/sound/event_sounds --type=bool false

    gconftool-2 --get /apps/gnome-screensaver/lock_enabled 
    gconftool-2 --get /desktop/gnome/sound/event_sounds
}


nautilus_settings()
{
    chmod +w ~/.config/user-dirs.dirs
    sed -i 's/XDG_TEMPLATES_DIR/#XDG_TEMPLATES_DIR/' ~/.config/user-dirs.dirs 
    sed -i 's/XDG_PUBLICSHARE_DIR/#XDG_PUBLICSHARE_DIR/' ~/.config/user-dirs.dirs
    sed -i 's/XDG_DOCUMENTS_DIR/#XDG_DOCUMENTS_DIR/' ~/.config/user-dirs.dirs
    sed -i 's/XDG_MUSIC_DIR/#XDG_MUSIC_DIR/' ~/.config/user-dirs.dirs
    sed -i 's/XDG_PICTURES_DIR/#XDG_PICTURES_DIR/' ~/.config/user-dirs.dirs
    sed -i 's/XDG_VIDEOS_DIR/#XDG_VIDEOS_DIR/' ~/.config/user-dirs.dirs
    echo "enabled=true" >> ~/.config/user-dirs.conf
    chmod -w ~/.config/user-dirs.dirs
    #cat ~/.config/user-dirs.conf 
    #cat ~/.config/user-dirs.dirs 
    #cat ~/.config/user-dirs.locale
    #cat /etc/xdg/user-dirs.conf 
    #cat /etc/xdg/user-dirs.defaults 
    ###
    sudo sed -i 's/TEMPLATES/#TEMPLATES/'     /etc/xdg/user-dirs.defaults 
    sudo sed -i 's/PUBLICSHARE/#PUBLICSHARE/' /etc/xdg/user-dirs.defaults 
    sudo sed -i 's/DOCUMENTS/#DOCUMENTS/'     /etc/xdg/user-dirs.defaults 
    sudo sed -i 's/MUSIC/#MUSIC/'             /etc/xdg/user-dirs.defaults 
    sudo sed -i 's/PICTURES/#PICTURES/'       /etc/xdg/user-dirs.defaults 
    sudo sed -i 's/VIDEOS/#VIDEOS/'           /etc/xdg/user-dirs.defaults 
    ###
    sudo sed -i "s/enabled=true/enabled=false/" /etc/xdg/user-dirs.conf
    sudo echo "enabled=false" >> /etc/xdg/user-dirs.conf
    sudo sed -i "s/enabled=true/enabled=false/" /etc/xdg/user-dirs.conf
    xdg-user-dirs-gtk-update
}

setup_ibeis()
{
    if [ ! -f ~/code ]; then
        mkdir ~/code
    fi
    if [ ! -f ~/ibeis ]; then
        git clone https://github.com/Erotemic/ibeis.git
    fi
    cd ~/code/ibeis
    git checkout next
    ./_scripts/bootstrap.py
    ./_scripts/__install_prereqs__.sh
    ./super_setup.py --build --develop
    ./super_setup.py --checkout next
    ./super_setup.py --build --develop
}

setup_sshd()
{  
    # This is Hyrule Specific

    # small change to default sshd_config
    sudo sed -i 's/#AuthorizedKeysFile\t%h\/.ssh\/authorized_keys/AuthorizedKeysFile\t%h\/.ssh\/authorized_keys/' /etc/ssh/sshd_config
}

dosetup_hyrule()
{
    customize_sudoers
    setup_homefolder
    source settings_hyrule.sh
    hyrule_setup_sshd
    hyrule_setup_fstab
    hyrule_create_users
}

dosetup_virtual()
{
    customize_sudoers
    source ~/local/init/ubuntu_core_packages.sh
    setup_homefolder
    gnome_settings
    nautilus_settings
}

extrafix()
{
    chmod og-w ~/.python-eggs
}
