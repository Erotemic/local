#!/usr/bin/env bash
source "$HOME/local/init/utils.sh"


install_basic_config(){
    source "$HOME/local/init/utils.sh"
    HAVE_SUDO=${HAVE_SUDO:=$(have_sudo)}
    if [ "$HAVE_SUDO" == "True" ]; then
        apt_ensure symlinks
    else
        echo "We dont have sudo. Hopefully we wont need it"
    fi
    echo "ENSURE SYMLINKS"
    # TODO: terminator doesnt configure to automatically use the joncrall profile
    # in the terminator config. Why?
    source "$HOME/local/init/ensure_symlinks.sh"
    ensure_config_symlinks
}

install_git_config(){
    _GITUSER="$(git config --global user.name)"
    if [ "$_GITUSER" == "" ]; then
      echo "ENSURE GIT CONFIG"
      # TODO: need to determine the right user.email depending on the system being set up
      set_global_git_config
      mkdir -p ~/tmp
      mkdir -p ~/code
    fi
}

local_remote_presetup(){
    __doc__="
    Run this script on the local computer to setup the remote with data that
    must be pushed to it (i.e. we cannot pull these files)
    "
    REMOTE=somemachine.com
    REMOTE_USER=jon.crall
    ssh-copy-id $REMOTE_USER@$REMOTE
    #In event of slowdown: sshpass -f <(printf '%s\n' yourpass) ssh-copy-id $REMOTE_USER@$REMOTE
    rsync -avzupR ~/./tpl-archive/ $REMOTE_USER@$REMOTE:.
}

set_global_git_config(){

    #git config --global user.email crallj@rpi.edu
    git config --global user.name "$USER"
    #git config --global user.email erotemic@gmail.com
    git config --global user.email jon.crall@kitware.com
    git config --global push.default current

    git config --global core.editor "vim"
    git config --global rerere.enabled false
    git config --global core.fileMode false
    git config --global alias.co checkout
    git config --global alias.submodpull 'submodule update --init --recursive'
    #git config --global merge.conflictstyle diff3
    git config --global merge.conflictstyle merge

    git config --global core.autocrlf false
}

setup_single_use_ssh_keys(){
    # References: https://security.stackexchange.com/questions/50878/ecdsa-vs-ecdh-vs-ed25519-vs-curve25519
    mkdir -p ~/.ssh
    cd ~/.ssh

    # WHERES MY POST-QUANTUM CRYPTO AT?!
    # Unfortunately I think ED25519 cant be PQ-resistant because its fixed at 256 bits :(
    # Note: add a passphrase in -N for extra secure
    echo "USER = $USER"
    echo "HOSTNAME = $HOSTNAME"
    EMAIL=erotemic@gmail.com
    EMAIL=jon.crall@kitware.com
    FPATH="$HOME/.ssh/id_${HOSTNAME}_${USER}_ed25519"
    ssh-keygen -t ed25519 -b 256 -C "${EMAIL}" -f "$FPATH" -N ""

    chmod 700 ~/.ssh
    chmod 400 ~/.ssh/id_*
    chmod 644 ~/.ssh/id_*.pub

    eval "$(ssh-agent -s)"
    ssh-add ~/.ssh/id_"${HOSTNAME}"_"${USER}"_ed25519

    echo "TODO: Register public key with appropriate services"
    echo " https://github.com/profile/keys "
    echo " https://gitlab.com/profile/keys "
    cat ~/.ssh/id_"${HOSTNAME}"_"${USER}"_ed25519.pub

    # Note: RSA with longer keys will be post-quantum resistant for longer
    # The NSA recommends a minimum 3072 key length, probably should go longer than that
    # ssh-keygen -t rsa -b 8192 -C "erotemic@gmail.com" -f id_${HOSTNAME}_${USER}_rsa -N ""

    # See: https://github.com/open-quantum-safe/liboqs

}

setup_remote_ssh_keys(){
    # DO THIS ONCE, THEN MOVE THESE KEY AROUND TO REMOTE MACHINES. ROTATE REGULARLY
    # IDEALLY MAKE ONE PER MACHINE: see setup_single_use_ssh_keys.
    mkdir -p ~/.ssh
    cd ~/.ssh
    ssh-keygen -t rsa -b 8192 -C "erotemic@gmail.com" -f id_myname_rsa -N ""

    # setup local machine with a special public / private key pair
    ssh-add id_myname_rsa

    # Add this public key to remote authorized_keys so they recognize you.
    # You may have to type in your password for each of these, but it will be
    # the last time.
    REMOTE_USER=jon.crall
    REMOTE_HOST=remote_machine
    # ENSURE YOU HAVE ALL COMPUTERS UPDATED IN YOUR SSH CONFIG
    REMOTES=( remote1 remote2 remote3 remote4 remote5 )

    ssh-copy-id $REMOTE_USER@$REMOTE_HOST

    for remote in "${REMOTES[@]}"
    do
        echo "UPDATING remote = $remote"
        # move .ssh config to other computers
        rsync ~/.ssh/./config "$remote":.ssh/./
    done

    ###
    # ALTERNATE
    # Copy from a remote to local computer
    REMOTE_USER=jon.crall
    REMOTE_HOST=hocus-pocus
    rsync $REMOTE_USER@$REMOTE_HOST:.ssh/./id_* "$HOME"/.ssh/
    rsync $REMOTE_USER@$REMOTE_HOST:.ssh/./config "$HOME"/.ssh/

    REMOTE_ALIAS=
    rsync -avprPRL "$HOME"/.ssh/./id_*  "$REMOTE_ALIAS":.ssh/
    rsync -avprPRL "$HOME"/.ssh/./config "$REMOTE_ALIAS":.ssh/
}


new_setup_ssh_keys(){
    mkdir -p ~/.ssh
    cd ~/.ssh
    ssh-keygen -t rsa -b 4096 -C "jon.crall@kitware.com"
    # Add new key to ssh agent if it is already running

    ssh-add
    # Manual Step:
    # Add public key to github https://github.com/settings/keys
    # Add public key to other places

    fix_ssh_permissions
}

fix_ssh_permissions(){
    # Fix ssh keys if you have them
    echo "
    CommandLine:
        source ~/local/init/freshstart_ubuntu.sh && fix_ssh_permissions
    " > /dev/null
    ls -al ~/.ssh
    chmod 700 ~/.ssh
    chmod 600 ~/.ssh/authorized_keys
    chmod 600 ~/.ssh/known_hosts
    chmod 600 ~/.ssh/config
    chmod 400 ~/.ssh/id_*
    ls -al ~/.ssh
}


entry_prereq_git_and_local()
{
    # This is usually done manually
    sudo apt install git -y
    cd ~

    # sudo usermod -l newUsername oldUsername
    # usermod -d /home/newHomeDir -m newUsername

    # If on a new computer, then make a new ssh key

    if [[ "$HOSTNAME" == "calculex"  ]]; then
        new_setup_ssh_keys
    fi

    fix_ssh_permissions

    # Fix ssh keys if you have them
    ls -al ~/.ssh
    chmod 700 ~/.ssh
    chmod 600 ~/.ssh/authorized_keys
    chmod 600 ~/.ssh/known_hosts
    chmod 600 ~/.ssh/config
    chmod 400 ~/.ssh/id_rsa*
    chmod 400 ~/.ssh/id_ed*

    # If local does not exist
    if [ ! -f ~/local ]; then
        git clone https://github.com/Erotemic/local.git
        cd local/init
    fi
}

freshtart_ubuntu_script()
{
    __doc__="
    CommandLine:
        source ~/local/init/freshstart_ubuntu.sh
        freshtart_ubuntu_script
    "
    mkdir -p ~/tmp
    mkdir -p ~/code
    cd ~
    if [ ! -d ~/local ]; then
        git clone https://github.com/Erotemic/local.git
    fi

    sudo apt install symlinks -y

    source ~/local/init/freshstart_ubuntu.sh
    source ~/local/init/ensure_symlinks.sh
    ensure_config_symlinks

    source ~/.bashrc

    set_global_git_config

    source ~/local/init/freshstart_ubuntu.sh
    #make_sshkey

    #sudo apt install trash-cli
    sudo apt install -y exuberant-ctags

    # Vim
    #sudo apt install -y vim
    #sudo apt install -y vim-gtk
    sudo apt install -y vim-gnome

    # Terminal settings
    #sudo apt install terminator -y

    if [ "$(which terminator)" == "" ]; then
        # Dont use buggy gtk2 version
        # https://bugs.launchpad.net/ubuntu/+source/terminator/+bug/1568132

        #sudo add-apt-repository ppa:gnome-terminator
        #sudo apt update
        #sudo apt install terminator -y
        #cat /etc/apt/sources.list
        #sudo apt remove terminator
        #sudo add-apt-repository --remove ppa:gnome-terminator

        sudo add-apt-repository ppa:gnome-terminator/nightly-gtk3
        sudo apt update
        sudo apt install terminator -y
    fi

    # Development Environment
    sudo apt install gcc g++ gfortran build-essential -y
    sudo apt install -y python3-dev python3-tk
    sudo apt install -y python3-tk

    #sudo update-alternatives --install /usr/bin/python python /usr/bin/python2.7 10

    # Python
    setup_venv3
    source ~/venv3/bin/activate

    pip install setuptools --upgrade
    pip install six
    pip install jedi
    pip install ipython
    pip install pep8 autopep8 flake8 pylint line_profiler

    mkdir -p ~/local/vim/vimfiles/bundle
    source ~/local/vim/init_vim.sh
    #mkdir ~/.vim_tmp
    echo "source ~/local/vim/portable_vimrc" > ~/.vimrc
    python ~/local/init/ensure_vim_plugins.py

    source ~/local/init/ubuntu_core_packages.sh

    # Get latex docs
    #cd ~/latex
    #if [ ! -f ~/latex ]; then
    #    mkdir -p ~/latex
    #    git clone git@hyrule.cs.rpi.edu.com:crall-candidacy-2015.git
    #fi

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
    sudo apt install -y pkg-config
    sudo apt install -y libtk-img-dev
    sudo apt install -y libblas-dev liblapack-dev
    sudo apt install -y libav-tools libgeos-dev
    sudo apt install -y libfftw3-dev libfreetype6-dev
    sudo apt install -y libatlas-base-dev liblcms1-dev zlib1g-dev
    sudo apt install -y libjpeg-dev libopenjpeg-dev libpng12-dev libtiff5-dev

    pip install numpy
    pip install scipy
    pip install Cython
    pip install pandas
    pip install requests

    pip install six
    pip install parse
    pip install Pygments
    pip install colorama

    pip install matplotlib

    pip install statsmodels
    pip install scikit-learn

    #pip install functools32
    #pip install psutil
    #pip install dateutils
    #pip install pyreadline
    #pip install pyparsing

    #pip install networkx

    #pip install simplejson
    #pip install flask
    #pip install flask-cors

    #pip install lockfile
    #pip install lru-dict
    #pip install shapely

    # pydot is currently broken
    #http://stackoverflow.com/questions/15951748/pydot-and-graphviz-error-couldnt-import-dot-parser-loading-of-dot-files-will
    #pip uninstall pydot
    pip uninstall pyparsing
    pip install -Iv 'https://pypi.python.org/packages/source/p/pyparsing/pyparsing-1.5.7.tar.gz#md5=9be0fcdcc595199c646ab317c1d9a709'
    pip install pydot
    python -c "import pydot"

    # Ubuntu hack for pyqt4
    # http://stackoverflow.com/questions/15608236/eclipse-and-google-app-engine-importerror-no-module-named-sysconfigdata-nd-u
    #sudo apt install python-qt4-dev
    #sudo apt remove python-qt4-dev
    #sudo apt remove python-qt4
    #sudo ln -s /usr/lib/python2.7/plat-*/_sysconfigdata_nd.py /usr/lib/python2.7/
    #python -c "import PyQt4"
    # TODO: install from source this is weird it doesnt work
    # sudo apt autoremove

    # Install utool
    if [ ! -d ~/code/utool ]; then
        git clone git@github.com:Erotemic/utool.git ~/code/utool
        pip install -e ~/code/utool
    fi

    if [ ! -d ~/code/ubelt ]; then
        git clone git@github.com:Erotemic/ubelt.git ~/code/ubelt
        pip install -e ~/code/ubelt
    fi

    git clone git@github.com:Erotemic/networkx.git ~/code/networkx
    pip install -e ~/code/networkx

    python ~/local/init/init_ipython_config.py
}

ensure_curl(){
    HAVE_SUDO=$(have_sudo)
    if [ "$(which curl)" == "" ]; then
        echo "Need to install curl"
        if [ "$HAVE_SUDO" == "True" ]; then
            sudo apt install curl -y
        else
            echo "Cannot install curl without sudo"
        fi
    fi
}

install_fonts()
{
    # Download fonts
    #sudo apt -y install nautilus-dropbox
    #
    #

    mkdir -p ~/tmp
    cd ~/tmp
    wget https://github.com/antijingoist/open-dyslexic/archive/e98e98ce61d4ee628e6c173cb54eb35cbd01bc4c.zip
    7z x e98e98ce61d4ee628e6c173cb54eb35cbd01bc4c.zip

    #wget https://downloads.sourceforge.net/project/cm-unicode/cm-unicode/0.7.0/cm-unicode-0.7.0-ttf.tar.xz
    #7z x cm-unicode-0.7.0-ttf.tar.xz && 7z x cm-unicode-0.7.0-ttf.tar && rm cm-unicode-0.7.0-ttf.tar

    _SUDO ""
    #_SUDO sudo
    #FONT_DIR=/usr/share/fonts
    FONT_DIR=$HOME/.fonts
    TTF_FONT_DIR=$FONT_DIR/truetype
    OTF_FONT_DIR=$FONT_DIR/truetype
    mkdir -p "$TTF_FONT_DIR"
    mkdir -p "$OTF_FONT_DIR"

    cp "$HOME"/code/erotemic/safe/assets/DyslexicBundle.zip "$HOME"/tmp
    mkdir -p "$HOME"/tmp/DyslexicBundle
    rm -rf "$HOME"/tmp/DyslexicBundle
    mkdir -p "$HOME"/tmp/DyslexicBundle
    unzip "$HOME"/code/erotemic/safe/assets/DyslexicBundle.zip -d "$HOME"/tmp/DyslexicBundle
    ls "$HOME"/tmp/DyslexicBundle
    $_SUDO cp -v "$HOME"/tmp/DyslexicBundle/*.ttf "$TTF_FONT_DIR"/
    $_SUDO cp -v "$HOME"/tmp/DyslexicBundle/*.otf "$OTF_FONT_DIR"/

    #ls ~/Dropbox/Fonts/
    #cd ~/Dropbox/Fonts/
    #$_SUDO cp -v ~/Dropbox/Fonts/*.ttf "$TTF_FONT_DIR"/
    #$_SUDO cp -v ~/Dropbox/Fonts/*.otf "$OTF_FONT_DIR"/
    #$_SUDO cp -v ~/tmp/open-dyslexic-master/otf/*.otf "$OTF_FONT_DIR"/
    #$_SUDO cp -v ~/tmp/cm-unicode-0.7.0/*.ttf "$TTF_FONT_DIR"/

    $_SUDO fc-cache -f -v

    # Delete matplotlib cache if you install new fonts
    rm ~/.cache/matplotlib/fontList*
}


install_dropbox_fonts2(){
    # DEPENDS: Linked Dropbox
    mkdir -p "$HOME"/.fonts/truetype
    cp -v ~/Dropbox/Fonts/*.ttf "$HOME"/.fonts/truetype
    cp -v ~/Dropbox/Fonts/*.otf "$HOME"/.fonts/truetype
    fc-cache -f -v
}

virtualbox_ubuntu_init()
{
    sudo apt install dkms
    sudo apt update
    sudo apt upgrade
    # Press Ctrl+D to automatically install virtualbox addons do this
    sudo apt install virtualbox-guest-additions-iso
    sudo apt install dkms build-essential linux-headers-generic
    sudo apt install build-essential "linux-headers-$(uname -r)"
    sudo apt install virtualbox-ose-guest-x11
    # setup virtualbox for ssh
    VBoxManage modifyvm virtual-ubuntu --natpf1 "ssh,tcp,,3022,,22"
}

nopassword_on_sudo()
{
    # DEPRICATE: we dont do this anymore
    # CAREFUL. THIS IS HUGE SECURITY RISK
    # References: http://askubuntu.com/questions/147241/execute-sudo-without-password
    cat /etc/sudoers > ~/tmp/sudoers.next
    echo "$USERNAME ALL=(ALL) NOPASSWD: ALL" >> ~/tmp/sudoers.next
    # Copy over the new sudoers file
    visudo -c -f ~/tmp/sudoers.next
    if [ "$?" -eq "0" ]; then
        sudo cp ~/tmp/sudoers.next /etc/sudoers
    fi
    rm ~/tmp/sudoers.next
}


nautilus_hide_unwanted_sidebar_items()
{
    __doc__="
    CommandLine:
        source ~/local/init/freshstart_ubuntu.sh && nautilus_hide_unwanted_sidebar_items

    Refernces:
        https://askubuntu.com/questions/762591/how-to-remove-unwanted-default-bookmarks-in-nautilus
        https://askubuntu.com/questions/79150/how-to-remove-bookmarks-from-the-nautilus-sidebar/1042059#1042059
    "

    echo "Removing unwanted nautilus sidebar items"

    # shellcheck disable=SC2050
    if [ "1" == "0" ]; then
        # Sidebar items are governed by files in $HOME and /etc
        ls ~/.config/user-dirs*
        ls /etc/xdg/user-dirs*

        cat ~/.config/user-dirs.dirs
        cat ~/.config/user-dirs.locale

        cat /etc/xdg/user-dirs.conf
        cat /etc/xdg/user-dirs.defaults

        #cat ~/.config/user-dirs.conf
    fi

    ### --------------------------------------
    ### modify local config files in $HOME/.config
    ### --------------------------------------

    chmod u+w ~/.config/user-dirs.dirs
    #sed -i 's/XDG_DOCUMENTS_DIR/#XDG_DOCUMENTS_DIR/' ~/.config/user-dirs.dirs
    sed -i 's/XDG_TEMPLATES_DIR/#XDG_TEMPLATES_DIR/' ~/.config/user-dirs.dirs
    sed -i 's/XDG_PUBLICSHARE_DIR/#XDG_PUBLICSHARE_DIR/' ~/.config/user-dirs.dirs
    sed -i 's/XDG_MUSIC_DIR/#XDG_MUSIC_DIR/' ~/.config/user-dirs.dirs
    sed -i 's/XDG_PICTURES_DIR/#XDG_PICTURES_DIR/' ~/.config/user-dirs.dirs
    sed -i 's/XDG_VIDEOS_DIR/#XDG_VIDEOS_DIR/' ~/.config/user-dirs.dirs
    ###
    echo "enabled=true" >> ~/.config/user-dirs.conf
    chmod u-w ~/.config/user-dirs.dirs

    ### --------------------------------------
    ### Modify global config files in /etc/xdg
    ### --------------------------------------

    #sudo sed -i 's/DOCUMENTS/#DOCUMENTS/'     /etc/xdg/user-dirs.defaults
    sudo sed -i 's/TEMPLATES/#TEMPLATES/'     /etc/xdg/user-dirs.defaults
    sudo sed -i 's/PUBLICSHARE/#PUBLICSHARE/' /etc/xdg/user-dirs.defaults
    sudo sed -i 's/MUSIC/#MUSIC/'             /etc/xdg/user-dirs.defaults
    sudo sed -i 's/PICTURES/#PICTURES/'       /etc/xdg/user-dirs.defaults
    sudo sed -i 's/VIDEOS/#VIDEOS/'           /etc/xdg/user-dirs.defaults
    ###
    sudo sed -i "s/enabled=true/enabled=false/" /etc/xdg/user-dirs.conf
    sudo_appendto /etc/xdg/user-dirs.conf  "enabled=false"
    sudo sed -i "s/enabled=true/enabled=false/" /etc/xdg/user-dirs.conf

    # Trigger an update
    xdg-user-dirs-gtk-update

    echo "
    NOTE:
        After restarting nautilus the unwanted items will be demoted to regular
        bookmarks. You can now removed them via the right click context menu.
    "
}


nautilus_settings()
{
    #echo "Get Open In Terminal in context menu"
    #sudo apt install nautilus-open-terminal -y

    # Tree view for nautilus
    gsettings set org.gnome.nautilus.window-state side-pane-view "tree"

    #http://askubuntu.com/questions/411430/open-the-parent-folder-of-a-symbolic-link-via-right-click
    mkdir -p ~/.gnome2/nautilus-scripts
}

customize_sudoers()
{
    # References: http://askubuntu.com/questions/147241/execute-sudo-without-password
    # Make timeout for sudoers a bit longer
    cat /etc/sudoers > ~/tmp/sudoers.next
    sed -i 's/^Defaults.*env_reset/Defaults    env_reset, timestamp_timeout=480/' ~/tmp/sudoers.next
    # Copy over the new sudoers file
    sudo visudo -c -f ~/tmp/sudoers.next
    if [ "$?" -eq "0" ]; then
        sudo cp ~/tmp/sudoers.next /etc/sudoers
    fi
    rm ~/tmp/sudoers.next
    #cat ~/tmp/sudoers.next
    #sudo cat /etc/sudoers
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
    #sudo apt install -y gnome-tweak-tool

    #gconftool-2 --set "/apps/gnome-terminal/profiles/Default/background_color" --type string "#1111111"
    #gconftool-2 --set "/apps/gnome-terminal/profiles/Default/foreground_color" --type string "#FFFF6999BBBB"
    #gconftool-2 --set /apps/gnome-screensaver/lock_enabled --type bool false
    #gconftool-2 --set /desktop/gnome/sound/event_sounds --type=bool false

    # try and disable password after screensaver lock
    gsettings get org.gnome.desktop.lockdown disable-lock-screen
    gsettings get org.gnome.desktop.screensaver lock-enabled
    gsettings set org.gnome.desktop.lockdown disable-lock-screen 'true'
    gsettings set org.gnome.desktop.screensaver lock-enabled false

    # need to enable to super+L works
    # gsettings set org.gnome.desktop.lockdown disable-lock-screen 'false'

    # Fix search in nautilus (remove recurison)
    # http://askubuntu.com/questions/275883/traditional-search-as-you-type-on-newer-nautilus-versions
    gsettings set org.gnome.nautilus.preferences enable-interactive-search true
    #gsettings set org.gnome.nautilus.preferences enable-interactive-search false

    #gconftool-2 --get /apps/gnome-screensaver/lock_enabled
    #gconftool-2 --get /desktop/gnome/sound/event_sounds
    #sudo apt install nautilus-open-terminal
}


jupyter_mime_association(){
    python -m utool.util_ubuntu --exec-add_new_mimetype_association --mime-name=ipynb+json --ext=.ipynb --exe-fpath=/usr/local/bin/ipynb
    python -m utool.util_ubuntu --exec-add_new_mimetype_association --mime-name=ipynb+json --ext=.ipynb --exe-fpath=jupyter-notebook --force
}



retro_console(){
    # https://github.com/Swordfish90/cool-retro-term
    wget https://github.com/Swordfish90/cool-retro-term/releases/download/1.1.1/Cool-Retro-Term-1.1.1-x86_64.AppImage
    chmod a+x Cool-Retro-Term-1.1.1-x86_64.AppImage
    ./Cool-Retro-Term-1.1.1-x86_64.AppImage
}

brio_webcam(){
    # https://www.kurokesu.com/main/2016/01/16/manual-usb-camera-settings-in-linux/
    sudo apt-get install v4l-utils
    v4l2-ctl --list-devices

    v4l2-ctl -d /dev/video1 --list-ctrls

    v4l2-ctl -d /dev/video0 --list-ctrls
    v4l2-ctl -d /dev/video1 --list-ctrls

    watch -n 0.5 v4l2-ctl -d /dev/video0 --set-ctrl=focus_auto=1
    v4l2-ctl -d /dev/video0 --set-ctrl=focus_auto=1
    v4l2-ctl -d /dev/video0 --set-ctrl=exposure_auto_priority=1
    v4l2-ctl -d /dev/video0 --set-ctrl=backlight_compensation=0
    v4l2-ctl -d /dev/video0 --set-ctrl=focus_absolute=10
    v4l2-ctl -d /dev/video0 --set-ctrl=zoom_absolute=100

    #v4l2-ctl -d /dev/video0 --set-ctrl=focus_auto=0
    #v4l2-ctl -d /dev/video0 --set-ctrl=focus_absolute=255
    #v4l2-ctl -d /dev/video0 --set-ctrl=focus_absolute=0
    #v4l2-ctl -d /dev/video0 --set-ctrl=zoom_absolute=100
    v4l2-ctl -d /dev/video0 --set-ctrl=zoom_absolute=150
    v4l2-ctl -d /dev/video0 --set-ctrl=zoom_absolute=180

}

fix_dns_issue(){
    # Reference: https://bugs.launchpad.net/ubuntu/+source/dnsmasq/+bug/1639776
    # Reference: https://askubuntu.com/questions/233222/how-can-i-disable-the-dns-that-network-manager-uses
    #There is a workaround for the openvpn issue on ubuntu
    #16.04. After connecting to the vpn, run:
    sudo pkill dnsmasq
    sudo sed -i 's/^\(dns=dnsmasq\)/#\1/g' /etc/NetworkManager/NetworkManager.conf
}

gnome_extensions(){
    __doc__='
    https://extensions.gnome.org/extension/352/middle-click-to-close-in-overview/
    https://extensions.gnome.org/extension/15/alternatetab/
    https://extensions.gnome.org/extension/120/system-monitor/
    https://extensions.gnome.org/extension/9/systemmonitor/
    '
}

install_travis_cmdline_tool(){
    sudo apt install ruby ruby-dev -y
    sudo gem install travis
}

disable_screen_lock(){
    # References: https://askubuntu.com/questions/1041230/how-to-disable-screen-locking-in-ubuntu-18-04-gnome-shell
    gsettings get org.gnome.desktop.screensaver lock-enabled
    gsettings set org.gnome.desktop.screensaver lock-enabled false
    # also can do it via settings -> privacy -> screen lock
}


install_basic_extras(){
    # Vera Crypt
    sudo add-apt-repository ppa:unit193/encryption -y
    sudo apt update
    sudo apt install veracrypt -y

    # Dropbox
    #sudo apt -y install nautilus-dropbox
}

stop_evolution_cpu_hogging(){
    # STOP USING MY CPU. EVOLUTION!
    sudo chmod -x /usr/lib/evolution/evolution-calendar-factory
    sudo chmod -x /usr/lib/evolution/evolution-*
}


fix_ubuntu_18_04_sound_pop_issue(){
    __doc__="
    Script that fixes a popping sound due to a power saving feature

    References:
        https://superuser.com/questions/1493096/linux-ubuntu-speakers-popping-every-few-seconds
        https://www.youtube.com/watch?v=Pdmy8dMWitg
    "
    sudo echo "obtaining sudo"
    # First, there are two system files that need modification
    # Changing the values here should fix the issue in your current session.
    cat /sys/module/snd_hda_intel/parameters/power_save
    cat /sys/module/snd_hda_intel/parameters/power_save_controller
    # Flip the 1 to a 0
    sudo sh -c "echo 0 > /sys/module/snd_hda_intel/parameters/power_save"
    # Flip the Y to a N
    sudo sh -c "echo N > /sys/module/snd_hda_intel/parameters/power_save_controller"

    # To make this change persistant we must modify a config file
    if [ -f "/etc/default/tlp" ]; then
        # Some systems (usually laptops) have this controlled via TLP
        sudo sed -i 's/SOUND_POWER_SAVE_ON_BAT=1/SOUND_POWER_SAVE_ON_BAT=0/' /etc/default/tlp
        sudo sed -i 's/SOUND_POER_SAVE_CONTROLLER=Y/SOUND_POER_SAVE_CONTROLLER=N/' /etc/default/tlp
    elif [ -f "/etc/modprobe.d/alsa-base.conf" ]; then
        # Append this line to the end of the file
        text="options snd-hda-intel power_save=0 power_save_controller=N"
        fpath="/etc/modprobe.d/alsa-base.conf"
        # Apppend the text only if it doesn't exist
        found="$(grep -F "$text" "$fpath")"
        if [ "$found" == "" ]; then
            sudo sh -c "echo \"$text\" >> $fpath"
        fi
        cat "$fpath"
    else
        echo "Error!, unknown system audio configuration" 1>&2
        exit 1
    fi
}

test_lan_speed(){
    # https://askubuntu.com/questions/7976/how-do-you-test-the-network-speed-between-two-boxes
    sudo apt install iperf
}

latest_clickclose_gnome(){
    # Also: Try this first -> enable quick close
    sudo apt install gnome-tweaks
    # https://github.com/p91paul/middleclickclose

    mkdir -p "$HOME"/tmp/prep_middleclickclose
    cd "$HOME"/tmp/prep_middleclickclose
    source "$HOME"/local/init/utils.sh
    #curl_verify_hash https://codeload.github.com/p91paul/middleclickclose/zip/7c1653bf00da0bc28296ce921cc79ccf4d91e6d4 middleclickclose.zip f0890d8ad6d967844
    curl_verify_hash https://codeload.github.com/p91paul/middleclickclose/zip/9700cda07e6a644b5c4704efeb701f87f6991939 middleclickclose.zip 1ac8f0984412f744d4

    #curl https://codeload.github.com/p91paul/middleclickclose/zip/7c1653bf00da0bc28296ce921cc79ccf4d91e6d4 -o middleclickclose.zip
    7z x -y middleclickclose.zip

    mkdir -p "$HOME"/.local/share/gnome-shell/extensions
    # Remove old version
    rm -rf "$HOME/.local/share/gnome-shell/extensions/middleclickclose@paolo.tranquilli.gmail.com"
    cp -r middleclickclose-*/middleclickclose@paolo.tranquilli.gmail.com "$HOME/.local/share/gnome-shell/extensions/"
    glib-compile-schemas "$HOME/.local/share/gnome-shell/extensions/middleclickclose@paolo.tranquilli.gmail.com/schemas"

    # reload gnome shell (alternative to alt-f2 + r)
    killall -3 gnome-shell

}


htop_like_resource_monitors(){

    # Core: Also
    nvtop
    htop

    # Disk monitor
    sudo apt install iotop

    # nmon shows usage per disk (and others info)
    sudo apt install nmon

    # Network monitor tools
    # bmon shows usage network interface
    sudo apt install bmon

    # Requires sudo shows usge per program
    sudo apt install nethogs

    # requires sudo, not obvious what it does
    sudo apt install iftop

    # https://itsfoss.com/linux-system-monitoring-tools/

    # https://www.reddit.com/r/linux/comments/na637t/diskgraph_for_if_youre_wondering_what_your_disk/

    #sudo apt install bashtop
    bashtop
    pip install bpytop

    #sudo add-apt-repository ppa:bashtop-monitor/bashtop
    #sudo apt update
    #sudo apt install bashtop
}



check_hdd_health(){
    # https://superuser.com/questions/171195/how-to-check-the-health-of-a-hard-drive
    sudo apt-get install gsmartcontrol
    sudo smartctl -a /dev/sda | less
}

benchmark()
{
    # https://linuxconfig.org/how-to-benchmark-your-linux-system

    sudo apt install sysbench

    sysbench cpu run

    sysbench cpu run --threads=1 --cpu-max-prime=10000
    sysbench cpu run --threads=1 --cpu-max-prime=100000
    sysbench cpu run --threads=4 --cpu-max-prime=400000
    sysbench cpu run --threads=8 --cpu-max-prime=8000000

    sysbench memory run

    sysbench fileio --file-test-mode=seqwr run

    #time (python -m pip install xdoctest && python -m xdoctest xdoctest)


    # https://hewlettpackard.github.io/dlcookbook-dlbs/#/
    git clone https://github.com/HewlettPackard/dlcookbook-dlbs.git ./dlbs   # Install benchmarking suite
    cd ./dlbs
    source ./scripts/environment.sh                                          # Initialize host environment
    python ./python/dlbs/experimenter.py help --frameworks                   # List supported DL frameworks
    docker pull nvcr.io/nvidia/pytorch:18.06-py3                             # Pull PyTorch docker image from NGC
    docker pull nvcr.io/nvidia/pytorch:18.06-py3

    export BENCH_ROOT="."
    . ./scripts/environment.sh
    # MASSIVE HACK:
    # fixes dlbs scripts that use the old "nvida-docker" to use "docker <arg1> --runtime=nvidia <arg-rest>"
    mkdir -p hack_bin
    codeblock()
    {
        __doc__="helper to deindent text in bash scripts"
        PYEXE=python
        echo "$1" | $PYEXE -c "import sys; from textwrap import dedent; print(dedent(sys.stdin.read()).strip('\n'))"
    }
    codeblock '
    FIRST=$1
    shift
    nvidia-docker $FIRST --runtime=nvidia $@
    ' > ./hack_bin/nvidia-docker
    chmod +x ./hack_bin/nvidia-docker
    PATH="$PWD/hack_bin:$PATH"

    rm -rf ./pytorch ./logs
    python "$DLBS_ROOT"/python/dlbs/experimenter.py run \
        --log-level="debug" \
        -Pexp.framework='"pytorch"' \
        -Vexp.gpus='"1"' \
        -Vexp.rerun='"always"' \
        -Ppytorch.cudnn_benchmark=false \
        -Ppytorch.cudnn_fastest=true \
        -Ppytorch.num_loader_threads=4 \
        -Pexp.device_type='"gpu"' \
        -Pexp.dtype='"float32"' \
        -Pexp.num_batches='2' \
        -Pexp.phase='"inference"' \
        -Vexp.model='"resnet50"' \
        -Pexp.docker=true \
        -Pexp.log_file='"${BENCH_ROOT}/pytorch/${exp.model}_${exp.effective_batch}_${exp.num_gpus}.log"' \
        -Pexp.docker_args='"--rm --shm-size=1g --ulimit memlock=-1 --ulimit stack=67108864"'

    params="exp.status,exp.framework_title,exp.effective_batch,results.time,results.throughput,exp.model_title,exp.docker_image"

    #python "$logparser" ./pytorch/logs/*.log --output_file './results.json'
    #python "$reporter" --summary_file '${HOME}/dlbs/results.json'\             # Parse summary file and build
    #                 --type 'weak-scaling'\                                  #     weak scaling report
    #                 --target_variable 'results.time'                        #     using batch time as performance metric

    python "$DLBS_ROOT"/python/dlbs/bench_data.py parse ./pytorch/*.log  --output results.json

    python "$DLBS_ROOT"/python/dlbs/bench_data.py summary  results.json

    python "$DLBS_ROOT"/python/dlbs/bench_data.py report  results.json --report strong
    python "$DLBS_ROOT"/python/dlbs/bench_data.py report  results.json --report regular
    python "$DLBS_ROOT"/python/dlbs/bench_data.py report  results.json --report '{"inputs": ["exp.status","exp.framework_title","exp.effective_batch","results.time","results.throughput","exp.model_title","exp.docker_image"], "output": "exp.num_gpus", "report_efficiency": true}'
    echo "params = $params"


    python "$DLBS_ROOT"/python/dlbs/bench_data.py summary results.json --report weak
    python "$DLBS_ROOT"/python/dlbs/bench_data.py summary results.json --report string
    #--output_params ${params}

    docker run -ti nvcr.io/nvidia/tensorflow:18.07-py3 /bin/bash
    nvidia-docker run -ti nvcr.io/nvidia/tensorflow:18.07-py3 /bin/bash

}


fix_ipython_highlights(){
    offending_fpath=$(python -c "import IPython, pathlib; print(str(pathlib.Path(IPython.__file__).parent / 'core/ultratb.py'))")
    sed -i 's/bg:ansiyellow/bg:ansibrightblack/g' "$offending_fpath"
}

fix_legacy_trust_store(){
    __doc__="
        Recommended: Instead of placing keys into the /etc/apt/trusted.gpg.d
        directory, you can place them anywhere on your filesystem by using the
        Signed-By option in your sources.list and pointing to the filename of the
        key.

       /etc/apt/trusted.gpg
           Keyring of local trusted keys, new keys will be added here. Configuration Item: Dir::Etc::Trusted.

       /etc/apt/trusted.gpg.d/
           File fragments for the trusted keys, additional keyrings can be stored here (by other packages or the administrator). Configuration Item Dir::Etc::TrustedParts.

       /etc/apt/keyrings/
           Place to store additional keyrings to be used with Signed-By.
    "
    # https://askubuntu.com/questions/1398344/apt-key-deprecation-warning-when-updating-system/1398346#1398346
    sudo apt-key list 2>&1 | \
        grep -E '\/(trusted.gpg.d)' -A 3 | \
        grep -v '^\-\-' | \
        grep -v '^pub ' | \
        /bin/sed 's@.*/trusted.gpg.d/\(.*\)@\1@g' | \
        /bin/awk 'NR%2{printf "%s ",$0;next;}1' | \
        /bin/awk '{print "sudo apt-key export "$10$11" | sudo gpg --dearmour -o /usr/share/keyrings/"$1}' | \
        xargs -I'{}' bash -c "eval '{}'"

    python -c "if 1:
        import subprocess
        import re
        from collections import defaultdict
        import pathlib
        # List all apt-keys
        proc = subprocess.Popen(
            'sudo apt-key list',
            shell=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE)
        stdout, stderr = proc.communicate()

        # Build a regex that matches a 20 byte hex string
        key_pat_part = '  *'.join(['[A-F0-9]{4}'] * 10)
        gpg_pat = re.compile(' *' + key_pat_part)

        # Parse stdout to map filenames to keys
        lines = stdout.decode('utf8').split(chr(10))
        current_fpath = None
        path_to_keys = defaultdict(list)
        for line in lines:
            if set(line) == '-':
                current_fpath = None
            if line.startswith('/etc/apt/trusted'):
                current_fpath = line
            if gpg_pat.match(line):
                key = line.replace(' ', '')
                path_to_keys[current_fpath].append(key)

        # Build commands to export to the keyrings path and execute them
        keyrings_dpath = pathlib.Path('/usr/share/keyrings/')
        for fpath, keys in path_to_keys.items():
            if 'trusted.gpg.d' in fpath:
                assert len(keys) == 1
                key_tail = keys[0][-8:]
                old_fpath = pathlib.Path(fpath)
                new_fpath = keyrings_dpath / old_fpath.name
                if not new_fpath.exists():
                    command = f'sudo apt-key export {key_tail} | sudo gpg --dearmour -o {new_fpath}'
                    subprocess.check_output(command, shell=True)
    "

    # sudo apt-key export 0EBFCD88 | sudo gpg --dearmor -o /usr/share/keyrings/docker-ce.gpg

    # For slack
    sudo apt-key list 2>&1 | grep slack -B 2 -A 1

    # Unsure how to automate finding where the corresponding sources and key should be
    SLACK_KEY_ID=038651BD
    SLACK_KEYRING_FPATH=/usr/share/keyrings/slack.gpg
    SLACK_SOURCES_FPATH=/etc/apt/sources.list.d/slack.list
    # Export the key from the deprecated apt-key registry into a file in the share keyrings folder
    sudo apt-key export "$SLACK_KEY_ID" | sudo gpg --dearmour -o "$SLACK_KEYRING_FPATH"
    # Then update the sources list such that it points to the file
    cat $SLACK_SOURCES_FPATH
    sudo sed -i "s|deb https|deb [signed-by=$SLACK_KEYRING_FPATH] https|" $SLACK_SOURCES_FPATH
    cat $SLACK_SOURCES_FPATH
    # Remove the key
    sudo apt-key del "$SLACK_KEY_ID"

}

install_rust(){
    # https://rust-lang.github.io/rustup/environment-variables.html
    #export RUSTUP_HOME=$HOME/.local/
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
}


connect_to_wifi_headless(){
    # https://askubuntu.com/questions/294257/connect-to-wifi-network-through-ubuntu-terminal
    # https://www.linuxbabe.com/ubuntu/connect-to-wi-fi-from-terminal-on-ubuntu-18-04-19-04-with-wpa-supplicant
    load_secrets

    # https://help.ubuntu.com/community/WifiDocs/Scan_for_Wireless_Network
    # List network devices (find the wifi one)
    # (note it will not show up in ifconfig if it is disabled, so this is safer)
    ls /sys/class/net

    # This will list all devices that have wireless capability
    echo /sys/class/net/*/wireless/

    # This will list the actual names
    # TODO: write in bash
    python -c "import pathlib; [print(p.name) for p in pathlib.Path('/sys/class/net/').glob('*') if (p / 'wireless').exists()]"

    WIFI_DEVICE=$(python3 -c "import pathlib; [print(p.name) for p in pathlib.Path('/sys/class/net/').glob('*') if (p / 'wireless').exists()][0]")
    echo "WIFI_DEVICE = $WIFI_DEVICE"

    # Enable the device (may not work, see link)
    # https://bbs.archlinux.org/viewtopic.php?id=173808
    sudo ip link set dev "$WIFI_DEVICE" up
    sudo ifconfig "$WIFI_DEVICE" up

    # Bring down / up / set to managed mode (Not sure if that is right)
    sudo ifconfig "$WIFI_DEVICE" down
    sudo iwconfig "$WIFI_DEVICE" mode Managed
    sudo ifconfig "$WIFI_DEVICE" up

    # List WIFI networks:
    sudo iwlist "$WIFI_DEVICE"  scan

    # Just get the available names
    sudo iwlist "$WIFI_DEVICE" scan | grep "ESSID"

    #sudo systemctl status wpa_supplicant.service

    echo "
    WIFI_DEVICE='$WIFI_DEVICE'
    HOME_WIFI_NAME='$HOME_WIFI_NAME'
    HOME_WIFI_PASS='$HOME_WIFI_PASS'
    "
    # Did not work in 22.04
    #sudo iwconfig "$WIFI_DEVICE" essid "$HOME_WIFI_NAME" key "s:$HOME_WIFI_PASS"

    # This does seem to work on the PI, not on main machine
    # https://linuxconfig.org/ubuntu-22-04-connect-to-wifi-from-command-line
    #cat /etc/netplan/50-cloud-init.yaml
    # Edit it
    #sudo netplan apply

    nmcli connection up id "$WIFI_DEVICE"

    # https://www.linuxfordevices.com/tutorials/ubuntu/connect-wifi-terminal-command-line
    nmcli dev wifi connect "$HOME_WIFI_NAME" password "$HOME_WIFI_PASS"

}


allow_power_read(){
    # https://github.com/mlco2/codecarbon/issues/244
    sudo apt install sysfsutils


    # Add a group called "power".
    GROUP_NAME=power

    if ! grep -q "$GROUP_NAME" /etc/group ; then
        echo "Adding Group: $GROUP_NAME"
        sudo groupadd "$GROUP_NAME"
    else
        echo "Group already exists: $GROUP_NAME"
    fi

    if ! groups | grep -q power ; then

        if ! cat /etc/group | grep "$USER" | grep -q "$GROUP_NAME"; then
            echo "User $USER is is not in the group $GROUP_NAME. Adding them"
            # Add your user to this group
            sudo usermod -aG "$GROUP_NAME" "$USER"
        fi

        if cat /etc/group | grep "$USER" | grep -q "$GROUP_NAME"; then
            echo "The user $USER is in the group $GROUP_NAME, but the shell has not refreshed".
            # TODO: can we make ourselves this group with a new login?
            echo "
            Run:

            sudo su '$USER'

            and try again
            "
        fi
    else
        echo "User $USER is already in group $GROUP_NAME"
    fi

    POWER_DPATH=/sys/class/powercap/intel-rapl
    POWER_FPATH="$POWER_DPATH/intel-rapl:0/energy_uj"
    echo "
    POWER_DPATH='$POWER_DPATH'
    POWER_FPATH='$POWER_FPATH'
    "
    ls -al "$POWER_FPATH"
    sudo chmod -R g+r "$POWER_DPATH"
    sudo chown -R root:power "$POWER_DPATH"
    tree "$POWER_DPATH"
    ls -al "$POWER_FPATH"

    sudo chown root:power /sys/class/powercap/intel-rapl/intel-rapl:0/energy_uj

    groups
    ls -al /sys/class/powercap/intel-rapl/intel-rapl:0/energy_uj
    cat /sys/class/powercap/intel-rapl/intel-rapl:0/energy_uj
}


remove_sticky_dock_on_second_monitor(){
    __doc__="
    I had an issue where when I had 3 setup setup horizontally, so monitors 1,
    2, and 3 were aranged from left to right, and my main monitor (2) was in
    the middle. When I moved from 2 to 1 my mouse got stuck on the left edge.
    This seems to be due to 'dock pressure'.

    The following post gave inspiration for the fix:
    https://askubuntu.com/questions/1432443/ubuntu-22-04-only-display-side-bar-when-activities-button-clicked-windows-key-p

    which was to set 'require-pressure-to-show' in org.gnome.shell.extensions.dash-to-dock to false

    This has the effect of not letting me see the dock anymore without using
    the super key, but that doesn't bother me.
    "
    gsettings set org.gnome.shell.extensions.dash-to-dock require-pressure-to-show false
    gsettings get org.gnome.shell.extensions.dash-to-dock require-pressure-to-show

}

install_tor(){

    curl_grabdata https://archive.torproject.org/tor-package-archive/torbrowser/13.0.8/tor-expert-bundle-linux-x86_64-13.0.8.tar.gz
    curl_grabdata https://archive.torproject.org/tor-package-archive/torbrowser/13.0.8/tor-expert-bundle-linux-x86_64-13.0.8.tar.gz.asc

    gpg --auto-key-locate nodefault,wkd --locate-keys torbrowser@torproject.org

    gpg --verify tor-expert-bundle-linux-x86_64-13.0.8.tar.gz.asc tor-expert-bundle-linux-x86_64-13.0.8.tar.gz

    mkdir -p .local/opt/tor
    mv tor-expert-bundle-linux-x86_64-13.0.8.tar.gz .local/opt/tor/
    cd .local/opt/tor/
    tar -xvf tor-expert-bundle-linux-x86_64-13.0.8.tar.gz .local/opt/tor/
}

startup_disk_creator(){
    sudo apt install usb-creator-gtk
}

fix_2204_slow_terminal(){
    # https://askubuntu.com/questions/1509058/input-delay-on-terminal-ubuntu-22-04-4/1509474#1509474
    sudo add-apt-repository ppa:vanvugt/mutter
    sudo apt update
    sudo apt upgrade

    sudo apt-get install gir1.2-mutter-10=42.9-0ubuntu7vv1 mutter-common=42.9-0ubuntu7vv1 libmutter-10-0=42.9-0ubuntu7vv1
    sudo apt-mark hold gir1.2-mutter-10 mutter-common libmutter-10-0
}
