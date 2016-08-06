entry_prereq_git_and_local()
{
    # This is usually done manually
    sudo apt-get install git -y
    cd ~

    # Fix ssh keys if you have them
    chmod 700 ~/.ssh
    chmod 600 ~/.ssh/authorized_keys

    # If local does not exist
    if [ ! -f ~/local ]; then
        git clone https://github.com/Erotemic/local.git
        cd local/init 
    fi
}


freshstart_ubuntu_entry_point()
{
    source ~/local/init/freshstart_ubuntu.sh
    entry_prereq_git_and_local
    freshstart_ubuntu_entry_point
}


ensure_config_symlinks()
{
    # Remove dead symlinks
    cd
    sudo apt-get install symlinks
    symlinks -d .
    
    mkdir -p ~/.config
    export HOMELINKS=~/local/homelinks
    export LINKFILES=$(/bin/ls -Ap  $HOMELINKS | grep -v /)
    export CONFIGDIRS=$(/bin/ls -A $HOMELINKS/config)
    # Symlink all homelinks files 
    for f in $LINKFILES; do ln -s $HOMELINKS/$f ~/.$f; done
    # Symlink config subdirs
    for f in $CONFIGDIRS; do ln -s $HOMELINKS/config/$f ~/.config/$f; done
}

freshtart_ubuntu_entry_point()
{ 
    mkdir -p ~/tmp
    mkdir -p ~/code
    cd ~
    if [ ! -f ~/local ]; then
        git clone https://github.com/Erotemic/local.git
    fi
    # TODO UTOOL
    mv ~/.bashrc ~/.bashrc.orig
    mv ~/.profile ~/.profile.orig

    ensure_config_symlinks

    #ln -s ~/local/homelinks/.ctags ~/.ctags
    #ln -s ~/local/bashrc.sh ~/.bashrc
    #ln -s ~/local/profile.sh ~/.profile 
    #ln -s ~/local/config/.pypirc ~/.pypirc 
    #ln -s ~/local/config/.theanorc ~/.theanorc 
    #ln -s ~/local/config/.theanorc ~/.theanorc 
    #mkdir -p ~/.config/terminator
    #ln -s ~/local/config/terminator_config ~/.config/terminator/config
    #
    ln -s ~/local/scripts/ubuntu_scripts ~/scripts
    source ~/.bashrc

    git config --global user.name joncrall
    git config --global user.email crallj@rpi.edu
    git config --global push.default current

    #sudo apt-get install trash-cli

    # Vim
    sudo apt-get install -y vim
    sudo apt-get install -y vim-gtk
    sudo apt-get install -y exuberant-ctags 

    # Terminal settings
    sudo apt-get install terminator -y

    # Development Environment
    sudo apt-get install gcc g++  -y
    sudo apt-get install -y gfortran

    # Python 
    sudo apt-get install python-dev -y
    sudo apt-get install -y python-tk
    sudo apt-get install python-pip -y
    sudo pip install pip --upgrade
    sudo pip install virtualenv
    sudo pip install virtualenv --upgrade

    # setup virtual env
    export PYTHON_VENV="$HOME/venv"
    mkdir -p $PYTHON_VENV
    virtualenv -p /usr/bin/python2.7 $PYTHON_VENV
    virtualenv -p /usr/bin/python2.7 $HOME/abs_venv --always-copy
    source $PYTHON_VENV/bin/activate

    # FIX ISSUE WITH SIP
    virtualenv --relocatable venv
    virtualenv --relocatable $HOME/abs_venv
    ls venv/include
    ls abs_venv/include
    # //

    # Python3 VENV
    sudo pip3 install virtualenv
    sudo pip3 install virtualenv -U
    export PYTHON3_VENV="$HOME/venv3"
    mkdir -p $PYTHON3_VENV
    virtualenv -p /usr/bin/python3 $PYTHON3_VENV
    # source $PYTHON3_VENV/bin/activate

    # FIX ISSUE WITH SIP
    virtualenv --relocatable venv
    virtualenv --relocatable $HOME/abs_venv
    ls venv/include
    ls abs_venv/include

    pip install setuptools --upgrade
    pip install six
    pip install jedi
    pip install ipython
    pip install pep8
    pip install autopep8
    pip install flake8
    pip install pylint
    pip install line_profiler

    mkdir -p ~/local/vim/vimfiles/bundle
    source ~/local/vim/init_vim.sh
    python ~/local/init/ensure_vim_plugins.py

    source ~/local/init/ubuntu_core_packages.sh

    # Install utool
    cd ~/code
    if [ ! -f ~/utool ]; then
        git clone git@github.com:Erotemic/utool.git
        cd utool
        python setup.py develop
    fi

    # Get latex docs
    cd ~/latex
    if [ ! -f ~/latex ]; then
        mkdir -p ~/latex
        git clone git@hyrule.cs.rpi.edu.com:crall-candidacy-2015.git
    fi

    # Install machine specific things

    if [[ "$HOSTNAME" == "hyrule"  ]]; then 
        echo "SETUP HYRULE STUFF"
        customize_sudoers
        source settings_hyrule.sh
        hyrule_setup_sshd
        hyrule_setup_fstab
        hyrule_create_users
    elif [[ "$HOSTNAME" == "Ooo"  ]]; then 
        echo "SETUP Ooo STUFF"
        install_dropbox
        customize_sudoers
        nautilus_settings
        gnome_settings
        install_chrome
        # Make sure dropbox has been initialized first
        install_fonts

        # 
        install_spotify
    else
        echo "UNKNOWN HOSTNAME"
    fi

    # Extended development environment
    sudo apt-get install -y pkg-config
    sudo apt-get install -y libtk-img-dev
    sudo apt-get install -y libav-tools libgeos-dev 
    sudo apt-get install -y libfftw3-dev libfreetype6-dev 
    sudo apt-get install -y libatlas-base-dev liblcms1-dev zlib1g-dev
    sudo apt-get install -y libjpeg-dev libopenjpeg-dev libpng12-dev libtiff5-dev

    pip install numpy
    pip install scipy
    pip install Cython
    pip install pandas
    pip install statsmodels
    pip install scikit-learn

    pip install matplotlib

    pip install functools32
    pip install psutil
    pip install six
    pip install dateutils
    pip install pyreadline
    #pip install pyparsing
    pip install parse
    
    pip install networkx
    pip install Pygments
    pip install colorama

    pip install requests
    pip install simplejson
    pip install flask
    pip install flask-cors

    pip install lockfile
    pip install lru-dict
    pip install shapely

    # pydot is currently broken
    #http://stackoverflow.com/questions/15951748/pydot-and-graphviz-error-couldnt-import-dot-parser-loading-of-dot-files-will
    #pip uninstall pydot
    pip uninstall pyparsing
    pip install -Iv 'https://pypi.python.org/packages/source/p/pyparsing/pyparsing-1.5.7.tar.gz#md5=9be0fcdcc595199c646ab317c1d9a709'
    pip install pydot
    python -c "import pydot"

    # Ubuntu hack for pyqt4
    # http://stackoverflow.com/questions/15608236/eclipse-and-google-app-engine-importerror-no-module-named-sysconfigdata-nd-u
    #sudo apt-get install python-qt4-dev
    #sudo apt-get remove python-qt4-dev
    #sudo apt-get remove python-qt4
    #sudo ln -s /usr/lib/python2.7/plat-*/_sysconfigdata_nd.py /usr/lib/python2.7/
    #python -c "import PyQt4"
    # TODO: install from source this is weird it doesnt work
    # sudo apt-get autoremove
}


install_python()
{
    sudo pip install pillow
    # Virtual Environment 
    cd
    mkdir -p venv
    sudo pip2.7 install virtualenv
    #python2.7 -m virtualenv -p /usr/bin/python2.7 venv
    python2.7 -m virtualenv -p /usr/bin/python2.7 venv --system-site-packages
    source ~/venv/bin/activate
}


install_fonts()
{
    sudo cp ~/Dropbox/Fonts/*.ttf /usr/share/fonts/truetype/
    sudo cp ~/Dropbox/Fonts/*.otf /usr/share/fonts/opentype/
    sudo fc-cache

    mkdir -p ~/tmp 
    cd ~/tmp
    wget https://github.com/antijingoist/open-dyslexic/archive/master.zip
    7z x master.zip
    sudo cp ~/tmp/open-dyslexic-master/otf/*.otf /usr/share/fonts/opentype/
    sudo fc-cache

    wget http://www.myfontfree.com/zip.php?itnetid=37252&submit=70lcpj0ftroiesv26mvtqkbph3
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
    # References: http://askubuntu.com/questions/147241/execute-sudo-without-password
    # Make timeout for sudoers a bit longer
    sudo cat /etc/sudoers > ~/tmp/sudoers.next  
    sed -i 's/^Defaults.*env_reset/Defaults    env_reset, timestamp_timeout=480/' ~/tmp/sudoers.next 
    # Copy over the new sudoers file
    visudo -c -f ~/tmp/sudoers.next
    if [ "$?" -eq "0" ]; then
        sudo cp ~/tmp/sudoers.next /etc/sudoers
    fi 
    rm ~/tmp/sudoers.next
    #cat ~/tmp/sudoers.next  
    #sudo cat /etc/sudoers 
} 


nopassword_on_sudo()
{ 
    # CAREFUL. THIS IS HUGE SECURITY RISK
    # References: http://askubuntu.com/questions/147241/execute-sudo-without-password
    sudo cat /etc/sudoers > ~/tmp/sudoers.next  
    echo "$USERNAME ALL=(ALL) NOPASSWD: ALL" >> ~/tmp/sudoers.next  
    # Copy over the new sudoers file
    visudo -c -f ~/tmp/sudoers.next
    if [ "$?" -eq "0" ]; then
        sudo cp ~/tmp/sudoers.next /etc/sudoers
    fi 
    rm ~/tmp/sudoers.next
} 

 
gnome_settings()
{
    # NOTE: mouse scroll wheel behavior was fixed by unplugging and replugging
    # the mouse. Odd. 

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

    sudo apt-get install -y gnome-tweak-tool

    gconftool-2 --set "/apps/gnome-terminal/profiles/Default/background_color" --type string "#1111111"
    gconftool-2 --set "/apps/gnome-terminal/profiles/Default/foreground_color" --type string "#FFFF6999BBBB"
    gconftool-2 --set /apps/gnome-screensaver/lock_enabled --type bool false
    gconftool-2 --set /desktop/gnome/sound/event_sounds --type=bool false

    # try and disable password after screensaver lock
    gsettings set org.gnome.desktop.lockdown disable-lock-screen 'true'
    /usr/bin/gsettings set org.gnome.desktop.screensaver lock-enabled false


    # Fix search in nautilus (remove recurison)
    # http://askubuntu.com/questions/275883/traditional-search-as-you-type-on-newer-nautilus-versions
    gsettings set org.gnome.nautilus.preferences enable-interactive-search true
    #gsettings set org.gnome.nautilus.preferences enable-interactive-search false

    gconftool-2 --get /apps/gnome-screensaver/lock_enabled 
    
    gconftool-2 --get /desktop/gnome/sound/event_sounds

    sudo apt-get install nautilus-open-terminal
    # TODO:
    # echo out the .config/terminator/config file
}


nautilus_settings()
{
    # Get rid of anyonying nautilus sidebar items
    echo "Get Rid of anoying sidebar items"
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

    echo "Get Open In Terminal in context menu"
    sudo apt-get install nautilus-open-terminal -y
}

setup_ibeis()
{
    mkdir -p ~/code
    cd ~/code
    if [ ! -f ~/ibeis ]; then
        git clone https://github.com/Erotemic/ibeis.git
    fi
    cd ~/code/ibeis
    git pull
    git checkout next
    ./_scripts/bootstrap.py
    ./_scripts/__install_prereqs__.sh
    ./super_setup.py --build --develop
    ./super_setup.py --checkout next
    ./super_setup.py --build --develop

    # Options
    ./_scripts/bootstrap.py --no-syspkg --nosudo

    cd 
    export IBEIS_WORK_DIR="$(python -c 'import ibeis; print(ibeis.get_workdir())')"
    echo $IBEIS_WORK_DIR
    ln -s $IBEIS_WORK_DIR  work
}

setup_sshd()
{  
    # This is Hyrule Specific

    # small change to default sshd_config
    sudo sed -i 's/#AuthorizedKeysFile\t%h\/.ssh\/authorized_keys/AuthorizedKeysFile\t%h\/.ssh\/authorized_keys/' /etc/ssh/sshd_config
}

dosetup_virtual()
{
    customize_sudoers
    source ~/local/init/ubuntu_core_packages.sh
    gnome_settings
    nautilus_settings
}

extrafix()
{
    chmod og-w ~/.python-eggs
}
