source $HOME/local/init/utils.sh

common_paths()
{
    cat ~/local/init/ensure_vim_plugins.py
}

#isntall_xnconvert(){
#    # https://www.unixmen.com/install-xnconvert-ubuntu/
#    sudo add-apt-repository --remove ppa:dhor/myway
#    sudo add-apt-repository ppa:dhor/myway -y
#    sudo apt-get update 
#    sudo apt-get install xnconvert -y
#}

install_languagetool(){

# https://www.languagetool.org/

cd ~/tmp
wget https://www.languagetool.org/download/LanguageTool-3.7.zip
7z x LanguageTool-3.7.zip

mkdir -p ~/opt
mv LanguageTool-3.7 ~/opt/

cd ~/opt/LanguageTool-3.7/
cd ~/bin
echo '
#!/bin/sh
java -jar ~/opt/LanguageTool-3.7/languagetool-commandline.jar $@
' > langtool
chmod +x langtool


langtool --help
langtool --disable WHITESPACE_RULE,EN_QUOTES,EN_UNPAIRED_BRACKETS chapter1-intro.tex
}


custom_tmux() 
{
    sudo apt install autotools-dev automake libevent-dev libncurses5-dev
    co
    git clone https://github.com/tmux/tmux.git
    cd tmux
    sh autogen.sh
    ./configure --prefix=$HOME
    make -j9
    make install

    # Install plugin manager
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

    ln -vs $HOME/local/homelinks/tmux.conf $HOME/.tmux.conf
}


install_core()
{
    sudo apt update -y 
    sudo apt upgrade -y
    # Git
    sudo apt install -y git

    # latest git
    sudo add-apt-repository ppa:git-core/ppa -y
    sudo apt update
    sudo apt install git -y
    git --version
    

    # Vim / Gvim
    #sudo apt install -y vim
    #sudo apt install -y vim-gtk
    #sudo apt remove -y vim
    #sudo apt remove -y vim-gnome

    sudo apt install -y exuberant-ctags 

    # Trash put
    #sudo apt install -y trash-cli
    sudo apt install -y gvfs-bin
    # make sure you have permission to trash
    #ls -al ~/.local/share/
    #sudo chown -R $USERNAME:$USERNAME ~/.local/share/Trash 
    #sudo chown $USERNAME:$USERNAME ~/.local/share/Trash/files
    #sudo chown -R $USERNAME:$USERNAME ~/.local/share/Trash/info
    #ls -al ~/.local/share/
    #ls -al ~/.local/share/Trash
    #sudo ls -al ~/.local/share/Trash/files
    #sudo ls -al ~/.local/share/Trash/info
    
    # Commonly used and frequently forgotten
    sudo apt install -y wmctrl xsel xdotool xclip
    sudo apt install -y xclip
    sudo apt install -y gparted htop tree
    sudo apt install -y tmux astyle
    sudo apt install -y synaptic okular
    sudo apt install -y openssh-server

    sudo apt install p7zip-full -y
    sudo apt install graphviz -y
    sudo apt install imagemagick -y

    # sqlite db  editor
    #sudo apt install sqliteman
    sudo apt install -y postgresql
    sudo apt install -y sqlitebrowser 
    #References: http://stackoverflow.com/questions/7454796/taglist-exuberant-ctags-not-found-in-path
    sudo apt install -y hdfview

    # for editing desktop sidebar icons
    sudo apt install alacarte

    # anti-virus 
    # https://www.upcloud.com/support/scanning-ubuntu-14-04-server-for-malware/
    sudo apt install clamav clamav-daemon
    sudo freshclam
    sudo clamscan -r /home

    sudo apt install rkhunter
}

truely_ergonomic_keyboard_setup()
{
    
    __readme__="""
    Truly Ergonomic keyboard - Firmware Upgrade
    -------------------------------------------

    To upgrade the Firmware of your Truly Ergonomic keyboard, you need permission to access the raw usb device.

    To give yourself this permission, copy 40-tek.rules into /etc/udev/rules.d.
    Otherwise, you might have to run the tool as root.
    """

    # REQUIRES:
    # libwx_gtk2u_webview-3.0.so.0
    # https://packages.debian.org/jessie/amd64/libs/libwxbase3.0-0

    #export LD_LIBRARY_PATH=$(realpath usr/lib/x86_64-linux-gnu):$LD_LIBRARY_PATH
    export LD_LIBRARY_PATH=$(realpath .):$LD_LIBRARY_PATH
    echo "LD_LIBRARY_PATH = $LD_LIBRARY_PATH"

    wget http://ftp.us.debian.org/debian/pool/main/w/wxwidgets3.0/libwxbase3.0-0_3.0.2-1+b1_amd64.deb
    wget http://ftp.us.debian.org/debian/pool/main/w/wxwidgets3.0/libwxgtk-webview3.0-0_3.0.2-1+b1_amd64.deb
    wget http://ftp.us.debian.org/debian/pool/main/w/wxwidgets3.0/libwxgtk3.0-0_3.0.2-1+b1_amd64.deb
    wget http://ftp.us.debian.org/debian/pool/main/w/wxwidgets3.0/libwxgtk-media3.0-0_3.0.2-1+b1_amd64.deb
    wget http://ftp.us.debian.org/debian/pool/main/w/webkitgtk/libwebkitgtk-1.0-0_2.4.9-1~deb8u1_amd64.deb
    wget http://ftp.us.debian.org/debian/pool/main/libp/libpng/libpng12-0_1.2.50-2+deb8u3_amd64.deb
    wget http://ftp.us.debian.org/debian/pool/main/w/webkitgtk/libjavascriptcoregtk-1.0-0_2.4.9-1~deb8u1_amd64.deb
    wget http://ftp.us.debian.org/debian/pool/main/i/icu/libicu52_52.1-8+deb8u7_amd64.deb

    # Manually extract debian packages to the local directory
    dpkg -x libwxbase3.0-0_3.0.2-1+b1_amd64.deb .
    dpkg -x libwxgtk-media3.0-0_3.0.2-1+b1_amd64.deb .
    dpkg -x libwxgtk-webview3.0-0_3.0.2-1+b1_amd64.deb .
    dpkg -x libwxgtk3.0-0_3.0.2-1+b1_amd64.deb .
    dpkg -x libwebkitgtk-1.0-0_2.4.9-1~deb8u1_amd64.deb .
    dpkg -x libpng12-0_1.2.50-2+deb8u3_amd64.deb .
    dpkg -x libjavascriptcoregtk-1.0-0_2.4.9-1~deb8u1_amd64.deb .
    dpkg -x libicu52_52.1-8+deb8u7_amd64.deb .

    ls -al usr/lib/x86_64-linux-gnu

    # Move the libs into the cwd
    mv usr/lib/x86_64-linux-gnu/* .
    mv lib/x86_64-linux-gnu/* .

    sudo LD_LIBRARY_PATH=$(realpath .):$LD_LIBRARY_PATH ./tek

    # new link for the 229
    # https://trulyergonomic.com/store/layout-designer--configurator--reprogrammable--truly-ergonomic-mechanical-keyboard.html#KTo7PD0+P0BBQkNERUw5394rNR4fICEi4yMkJSYnLS4xOBQaCBUXTBwYDBITLzDhBBYHCQorCw0ODzPl4B0bBhkFKhEQNjc05OfiSktOTSwoLFBSUU/mRQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAX2BhAAAAAAAAAAAAAAAAXF1eVlcAAAAAAAAAAABZWltVAAAAAAAAAAAAYgBjVAAAAAAAAAAAWCsAAAAAAACTAQAMAiMBAAwBigEADAIhAQAMAZQBAAwBkgEADAGDAQAMALYBAAwAzQEADAC1AQAMAOIBAAwA6gEADADpAQAMALhJAEYAAAAAAEitR64AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACk6Ozw9Pj9AQUJDREVMOd/eKzUeHyAhImQjJCUmJy4qLzAUGggVF0wcGAwSEzQx4wQWBwkKLQsNDg8z5+EdGwYZBSoREDY3OOXg4kpLTk0sKCxQUlFP5uQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAF9gYQAAAAAAAAAAAAAAAFxdXlZXAAAAAAAAAAAAWVpbVQAAAAAAAAAAAGIAY1QAAAAAAAAAAFgrAAAAAAAAkwEADAIjAQAMAYoBAAwCIQEADAGUAQAMAZIBAAwBgwEADAC2AQAMAM0BAAwAtQEADADiAQAMAOoBAAwA6QEADAC4SQBGAAAAAABIrUeuAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=


    # OLD STUFF:
    
    #ar -x libwxbase3.0-0_3.0.2-1+b1_amd64.deb 
    #tar -xzvf control.tar.gz
    #tar -xzvf data.tar.gz

    https://packages.debian.org/jessie/amd64/libwxbase3.0-0/download

    # 
    
    #sudo apt remove libwxbase3.0-0 libwxgtk3.0-0 libwxgtk-webview3.0-0
    #In Ubuntu before 15.04 vivid (or derivatives like Linux Mint 17.2) you have to:
    #1. add the ubuntu-toolchain-r/test ppa to get libstdc++6-4.9
    sudo add-apt-repository ppa:ubuntu-toolchain-r/test 
    sudo apt update
    sudo apt upgrade
    sudo apt install libstdc++6
    wget http://security.ubuntu.com/ubuntu/pool/universe/w/wxwidgets3.0/libwxbase3.0-0_3.0.2-1_amd64.deb
    wget http://security.ubuntu.com/ubuntu/pool/universe/w/wxwidgets3.0/libwxgtk3.0-0_3.0.2-1_amd64.deb
    wget http://security.ubuntu.com/ubuntu/pool/universe/w/wxwidgets3.0/libwxgtk-webview3.0-0_3.0.2-1_amd64.deb
    sudo dpkg -i libwx*.deb

    sudo apt install lm-sensors
    sudo apt install hardinfo
    # TEK truely ergonomic keyboard setup
    # Link for TEK 229 Need to switch for 209
    # https://trulyergonomic.com/store/layout-designer--configurator--reprogrammable--truly-ergonomic-mechanical-keyboard/#KTo7PD0+P0BBQkNERUw5394rNR4fICEi4yMkJSYnLS4xOBQaCBUXTBwYDBITLzDhBBYHCQorCw0ODzPl4B0bBhkFKhEQNjc05OfiSktOTSwoLFBSUU/mRQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAX2BhAAAAAAAAAAAAAAAAXF1eVlcAAAAAAAAAAABZWltVAAAAAAAAAAAAYgBjVAAAAAAAAAAAWCsAAAAAAACTAQAMAiMBAAwBigEADAIhAQAMAZQBAAwBkgEADAGDAQAMALYBAAwAzQEADAC1AQAMAOIBAAwA6gEADADpAQAMALhJAEYAAAAAAEitR64AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACk6Ozw9Pj9AQUJDREVMOd/eKzUeHyAhImQjJCUmJy4qLzAUGggVF0wcGAwSEzQx4wQWBwkKLQsNDg8z5+EdGwYZBSoREDY3OOXg4kpLTk0sKCxQUlFP5uQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAF9gYQAAAAAAAAAAAAAAAFxdXlZXAAAAAAAAAAAAWVpbVQAAAAAAAAAAAGIAY1QAAAAAAAAAAFgrAAAAAAAAkwEADAIjAQAMAYoBAAwCIQEADAGUAQAMAZIBAAwBgwEADAC2AQAMAM0BAAwAtQEADADiAQAMAOoBAAwA6QEADAC4SQBGAAAAAABIrUeuAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=
    cd ~/tmp
    wget http://www.trulyergonomic.com/Truly_Ergonomic_Firmware_Upgrade_Linux_v2_0_0.tar.gz
    tar -xvf Truly_Ergonomic_Firmware_Upgrade_Linux_v2_0_0.tar.gz
    cd /home/joncrall/tmp/tek-linux
    cd ~/tmp/tex-linux

    ls /etc/udev/rules.d/
    sudo cp 40-tek.rules /etc/udev/rules.d/

    sudo ./tek
    # Now 
}

install_dropbox()
{
    # Dropbox 
    #cd ~/tmp
    #cd ~/tmp && wget -O - "https://www.dropbox.com/download?plat=lnx.x86_64" | tar xzf -
    #.dropbox-dist/dropboxd
    sudo apt -y install nautilus-dropbox
}

install_zotero()
{
    sh ~/local/build_scripts/install_zotero.sh
}


install_core_extras()
{
    # https://www.maketecheasier.com/copy-paste-images-clipboard-nautilus/
    sudo add-apt-repository ppa:atareao/nautilus-extensions
    sudo apt-get update
    sudo apt-get install nautilus-copypaste-images

    # Not commonly used but frequently forgotten
    sudo apt install -y valgrind synaptic gitg expect
    sudo apt install -y sysstat
    sudo apt install -y subversion
    sudo apt install -y remmina 


    #sudo apt install -y screen

    sudo apt install -y filezilla

    sudo apt install python-pydot -y

    sudo apt install dia-gnome -y

    # flux
    sudo add-apt-repository ppa:kilian/f.lux
    sudo apt update
    sudo apt install fluxgui -y

    # 7zip


    # Make vlc default app
    # http://askubuntu.com/questions/91701/how-to-set-vlc-as-default-video-player
    cat /usr/share/applications/defaults.list | grep video
    cat /usr/share/applications/defaults.list | grep totem.desktop
    cat ~/.local/share/applications/mimeapps.list
    sudo sed -i 's/\(^.*\)video\(.*\)=totem.desktop/\1video\2=vlc.desktop/' /usr/share/applications/defaults.list
    sudo sed -i 's/\(^.*\)audio\(.*\)=totem.desktop/\audio\2=vlc.desktop/' /usr/share/applications/defaults.list


    # ssh file system
    sudo apt install sshfs -y
    mkdir ~/ami    
    sshfs -o idmap=user ibeis-hackathon:/home/ubuntu ~/ami
    sshfs -o idmap=user lev:/ ~/lev

    mkdir -p ~/remote_machinename    
    sshfs -o follow_symlinks,idmap=user remote_machinename:/home/local/KHQ/jon.crall ~/remote_machinename

    # unmount
    fusermount -u ~/remote_machinename
    


    sudo apt update
    sudo apt install patchutils
    #http://superuser.com/questions/403664/how-can-i-copy-and-paste-text-out-of-a-remote-vim-to-a-local-vim
    # 
}

install_fresh_flash_player()
{
    # To allow to get the flash package from software center
    #http://askubuntu.com/questions/576562/apt-way-to-get-adobe-flash-player-latest-version-for-linux-not-working
    #http://blog.cacoo.com/2012/08/07/troubleshooting-chrome-flash/
    # NOTE probably not a great idea to install flash
    sudo add-apt-repository universe
    sudo apt install pepperflashplugin-nonfree
    sudo update-pepperflashplugin-nonfree --status
    sudo update-pepperflashplugin-nonfree --install 

    sudo add-apt-repository ppa:nilarimogard/webupd8
    sudo apt update
    sudo apt install freshplayerplugin
}


install_skype()
{
    # References: https://help.ubuntu.com/community/Skype
    #sudo dpkg --add-architecture i386
    sudo add-apt-repository "deb http://archive.canonical.com/ $(lsb_release -sc) partner"
    sudo apt update 
    sudo apt install skype -y
    #sudo apt install -y skype
}

install_evaluating()
{
    #sudo apt install inkscape -y
    #References: https://github.com/kayhayen/Nuitka#use-case-3-package-compilation
    sudo apt install nuitka
    nuitka --module ibeis --recurse-directory=ibeis
    nuitka --recurse-all main.py
}

install_ubuntu_tweak()
{
    # To clean up old kernels
    # References: http://askubuntu.com/questions/2793/how-do-i-remove-or-hide-old-kernel-versions-to-clean-up-the-boot-menu
    sudo add-apt-repository ppa:tualatrix/ppa
    sudo apt update
    sudo apt install -y ubuntu-tweak
}

install_chrome()
{
    # Google PPA
    wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
    sudo sh -c 'echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list'
    sudo apt update
    # Google Chrome
    sudo apt install -y google-chrome-stable 


    # for extensions.gnome.org integration
    sudo apt install chrome-gnome-shell
}
 
install_spotify()
{
    #cat /etc/apt/sources.list
    #sudo sh -c 'echo "deb http://repository.spotify.com stable non-free" >> /etc/apt/sources.list'
    #sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 94558F59
    #sudo apt update -y
    #sudo apt install -y spotify-client --force-yes
    ## https://community.spotify.com/t5/Help-Desktop-Linux-Windows-Web/Linux-users-important-update/td-p/1157534
    #sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys D2C19886

    sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 0DF731E45CE24F27EEEB1450EFDC8610341D9410
    echo deb http://repository.spotify.com stable non-free | sudo tee /etc/apt/sources.list.d/spotify.list
    sudo apt-get update -y
    sudo apt-get install spotify-client -y
    
}

install_vpn()
{

    # http://dotcio.rpi.edu/services/network-remote-access/vpn-connection-and-installation/using-vpnc-open-source-client

    # replaces cisco anyconnect
    sudo apt install network-manager-openconnect-gnome -y

    # gateway: vpn.net.rpi.edu

    #https://www.reddit.com/r/RPI/comments/2c3fd9/rpi_vpn_from_ubuntu/

    sudo openconnect -b vpn.net.rpi.edu -uyour_school_username -ucrallj
    alias rpivpn='sudo openconnect -b vpn.net.rpi.edu -uyour_school_username -ucrallj'



    sudo apt install network-manager-openvpn-gnome -y

    # https://askubuntu.com/questions/187511/how-can-i-use-a-ovpn-file-with-network-manager
    # Open network manager, click add, click vpn, then click add from file
    # select the *.ovpn file

    sudo chcon -t cert_t ~/.config/openvpn/* 


    Add the following tow lines to oovpn file
    up /etc/openvpn/update-resolve-conf
    down /etc/openvpn/update-resolve-conf


    openvpn --script-security 2 --config ~/.config/openvpn/imryrr1-udp-1194-VPN/imryrr1-udp-1194-VPN.ovpn \
        --x509-username-field jon.crall

    
    #Reference: https://bugs.launchpad.net/ubuntu/+source/dnsmasq/+bug/1639776
    #There is a workaround for the openvpn issue on ubuntu
    #16.04. After connecting to the vpn, run:

    sudo pkill dnsmasq

    #...after which dnsmasq "dumps all of the DNS server entries into
    #/etc/resolv.conf and removes 127.0.1.1 (thus temporarily fixing the
    #issue)."

    #Reference:
    #https://askubuntu.com/questions/233222/how-can-i-disable-the-dns-that-network-manager-uses
    #Tell Network Manager not to use dnsmasq:
    #Edit /etc/NetworkManager/NetworkManager.conf and comment out the line
    #dns=dnsmasq line, so it looks like "#dns=dnsmasq" and then restart
    #Network Manager with sudo restart network-manager.
    

}

 
install_latex()
{
    # texlive latest
    # https://www.tug.org/texlive/acquire-netinstall.html
    echo 'latex'
    # Latex (ubuntu uses texlive 2013, use something more recent)
    sudo apt purge texlive texlive-base pgf -y

    mkdir -p ~/tmp
    cd ~/tmp
    wget http://mirror.ctan.org/systems/texlive/tlnet/install-tl-unx.tar.gz
    tar xzvf install-tl-unx.tar.gz
    cd ~/tmp/install-tl-*
    #export TEXDIR=/opt/texlive
    #export TEXDIR=$HOME/.local/texlive

    #echo "$(codeblock "
    #    selected_scheme scheme-full
    #    TEXDIR $HOME/.local/texlive/2018
    #    TEXMFLOCAL $HOME/.local/texlive/texmf-local
    #    TEXMFSYSCONFIG $HOME/.local/texlive/2018/texmf-config
    #    TEXMFSYSVAR $HOME/.local/texlive/2018/texmf-var
    #    TEXMFCONFIG ~/.texlive2018/texmf-config
    #    TEXMFHOME ~/texmf
    #    TEXMFVAR ~/.texlive2018/texmf-var
    #    binary_x86_64-linux 1
    #    instopt_adjustpath 0
    #    instopt_adjustrepo 1
    #    instopt_letter 0
    #    instopt_portable 0
    #    instopt_write18_restricted 1
    #    tlpdbopt_autobackup 1
    #    tlpdbopt_backupdir tlpkg/backups
    #    tlpdbopt_create_formats 1
    #    tlpdbopt_desktop_integration 1
    #    tlpdbopt_file_assocs 1
    #    tlpdbopt_generate_updmap 0
    #    tlpdbopt_install_docfiles 1
    #    tlpdbopt_install_srcfiles 1
    #    tlpdbopt_post_code 1
    #    tlpdbopt_sys_bin /usr/local/bin
    #    tlpdbopt_sys_info /usr/local/share/info
    #    tlpdbopt_sys_man /usr/local/share/man
    #    tlpdbopt_w32_multi_user 1
    #")" > texlive.profile
    #chmod +x install-tl
    #./install-tl --profile=texlive.profile
    #sudo apt install texlive-latex-recommended texlive-latex-extra texlive-luatex texlive-luatex-extra latexmk -y
    sudo apt install texlive-latex-recommended texlive-latex-extra texlive-luatex latexmk -y
    luaotfload-tool --update

    # cd /usr/local/texlive/2015/bin/x86_64-linux
    # Installed to /usr/local/texlive/2015/
    # Need to add /usr/local/texlive/2015/bin/x86_64-linux to the PATH
    # In my second time doing this I'm trying adding symlinks to local files instead
    # lets see if that works...

    # Support for utf8
    #sudo tlmgr install euenc
     
    # Fix TL2016 bug
    # https://www.tug.org/pipermail/tex-live/2016-June/038678.html
    #http://tex.stackexchange.com/questions/27982/what-are-texlives-four-different-texmf-folders
    #file /usr/local/texlive/2016/texmf-dist/tex/latex/algorithm2e/algorithm2e.sty
    #cat /usr/local/texlive/2016/texmf-dist/tex/latex/algorithm2e/algorithm2e.sty
    #ls -al /usr/local/texlive/2016/texmf-dist/tex/latex/algorithm2e/algorithm2e.sty
    #sudo cp /usr/local/texlive/2016/texmf-dist/tex/latex/algorithm2e/algorithm2e.sty algorithm2e.sty.backup
    ##sudo cp algorithm2e.sty.backup /usr/local/texlive/2016/texmf-dist/tex/latex/algorithm2e/algorithm2e.sty
    #iconv -f ISO-8859-1 -t UTF-8//TRANSLIT algorithm2e.sty.backup -o ~/latex/crall-iccv-2017/algorithm3e.sty
    #file ~/latex/crall-iccv-2017/algorithm3e.sty
    
}


install_python()
{
    # Python
    #apt-get install python-qt4
    #apt-get install python-pip
    #apt-get install -y python-tk
    pip install virtualenv
    pip install jedi
    pip install pep8 autopep8 flake8 pylint
    pip install line_profiler
    # pip install Xlib
    pip install requests
    pip install objgraph
    pip install memory_profiler
    pip install guppy

    #https://github.com/rogerbinns/apsw/releases/download/3.8.6-r1/apsw-3.8.6-r1.win32-py2.7.exe
    sudo apt install -y libsqlite3-dev 
    sudo apt install -y sqlite3
    sudo apt install -y libsqlite3
    sudo apt install -y python-apsw
    #sudo pip install apsw


    sudo apt install libgeos-dev -y
    pip install shapely
}

install_hdf5()
{
    #sudo apt install -y libhdf5-serial-dev
    #The following extra packages will be installed:
    #  libhdf5-openmpi-7
    #Suggested packages:
    #  libhdf5-doc
    #The following packages will be REMOVED:
    #  libhdf5-7 libhdf5-dev libhdf5-serial-dev
    #The following NEW packages will be installed:
    #  libhdf5-openmpi-7 libhdf5-openmpi-dev
    sudo apt install -y libhdf5-serial-dev
    sudo apt install -y libhdf5-openmpi-dev
    #h5cc -showconfig
    sudo apt install hdf5-tools
}

install_cuda_prereq()
{
    sudo apt install -y libprotobuf-dev
    sudo apt install -y libleveldb-dev 
    sudo apt install -y libsnappy-dev 
    sudo apt install -y libboost-all-dev 
    sudo apt install -y libopencv-dev 

    install_hdf5

    sudo apt install -y libgflags-dev
    sudo apt install -y libgoogle-glog-dev
    sudo apt install -y liblmdb-dev
    sudo apt install -y protobuf-compiler 

    #sudo apt install -y gcc-4.6 
    #sudo apt install -y g++-4.6 
    #sudo apt install -y gcc-4.6-multilib
    #sudo apt install -y g++-4.6-multilib 
    sudo apt install libpthread-stubs0-dev

    sudo apt install -y gfortran
    sudo apt install -y libjpeg62
    sudo apt install -y libfreeimage-dev
    sudo apt install -y libatlas-base-dev 

    sudo apt install -y python-dev
    #sudo apt install -y python-pip
    #sudo apt install -y python-numpy
    #sudo apt install -y python-pillow
}


install_xlib()
{
    # for gnome-shell-grid
    sudo pip install svn+https://python-xlib.svn.sourceforge.net/svnroot/python-xlib/trunk/
    sudo apt install -y python-wnck 
    sudo apt install -y wmctrl 
    sudo apt install -y xdotool
}

install_virtualbox()
{
    # References: https://www.virtualbox.org/wiki/Linux_Downloads
    # Add oracle keys
    #wget -q https://www.virtualbox.org/download/oracle_vbox.asc -O- | sudo apt-key add -
    #sudo apt update
    #sudo apt install virtualbox-4.3
    sudo apt install virtualbox dkms
    # download addons and mount on guest machine
    #http://download.virtualbox.org/virtualbox/4.1.12/
    
    python -c 'import ubelt; print(ubelt.grabdata("http://releases.ubuntu.com/16.04/ubuntu-16.04.6-desktop-i386.iso"))'
    python -c 'import ubelt; print(ubelt.grabdata("http://download.virtualbox.org/virtualbox/4.1.12/VBoxGuestAdditions_4.1.12.iso"))'
    python -c 'import ubelt; print(ubelt.grabdata("http://mirror.solarvps.com/centos/7.0.1406/isos/x86_64/CentOS-7.0-1406-x86_64-DVD.iso"))'
    python -c 'import ubelt; print(ubelt.grabdata("http://download.virtualbox.org/virtualbox/4.1.12/VBoxGuestAdditions_4.1.12.iso"))'
    http://mirror.centos.org/centos/7/isos/x86_64/
    
}


lprof_dl()
{
    cd $CODE_DIR
    git clone https://github.com/rkern/line_profiler.git
    sudo pip uninstall line-profiler
}

install_captn_proto()
{
    sudo apt install capnproto
    sudo pip install pycapnp
    #References: http://kentonv.github.io/capnproto/install.html
    #curl -O https://capnproto.org/capnproto-c++-0.5.0.tar.gz
    #tar zxf capnproto-c++-0.5.0.tar.gz
    #cd capnproto-c++-0.5.0
    #./configure
    #make -j6 check
    #sudo make instal
}

install_clang()
{
    sudo apt install clang-3.5
    sudo apt install libstdc++-4.8-dev

    # Set clang as default C compiler
    sudo update-alternatives --install /usr/bin/cc cc /usr/bin/clang-3.5 100
    sudo update-alternatives --install /usr/bin/c++ c++ /usr/bin/clang++-3.5 100


    # Create alias for proper clang version
    CLANG_VERSION=3.5
    CLANG_VERSION_PRIORITY=$(python -c "print(int(100 * $CLANG_VERSION))")
    echo "CLANG_VERSION=$CLANG_VERSION"
    echo "CLANG_VERSION_PRIORITY=$CLANG_VERSION_PRIORITY"
    sudo update-alternatives --install /usr/bin/clang clang /usr/bin/clang-$CLANG_VERSION $CLANG_VERSION_PRIORITY \
        --slave /usr/bin/clang++ clang++ /usr/bin/clang++-$CLANG_VERSION \
        --slave /usr/bin/clang-check clang-check /usr/bin/clang-check-$CLANG_VERSION \
        --slave /usr/bin/clang-query clang-query /usr/bin/clang-query-$CLANG_VERSION \
        --slave /usr/bin/clang-rename clang-rename /usr/bin/clang-rename-$CLANG_VERSION
}


install_nomachine()
{
    # https://www.nomachine.com/download/download&id=1

    # NOT COMPLETELY DONE
    # FIX MANUALLY

    #utget http://download.nomachine.com/download/4.4/Linux/nomachine_4.4.6_8_i686.tar.gz
    exec 42<<'__PYSCRIPT__'
import utool as ut
import os
from os.path import join
#zipped_url = 'http://download.nomachine.com/download/4.4/Linux/nomachine_4.4.6_8_i686.tar.gz'
zipped_url = 'http://download.nomachine.com/download/4.4/Linux/nomachine_4.4.12_11_x86_64.tar.gz'
unzipped_fpath = ut.grab_zipped_url(zipped_url)
os.chdir(unzipped_fpath)
ut.cmd('ls')
ut.vd(unzipped_fpath)
os.chdir(unzipped_fpath + '/NX')
ut.cmd('ls')
ut.cmd('nxserver --install', sudo=True)
ut.cmd('/usr/NX/nxserver --install', sudo=True)
__PYSCRIPT__
python /dev/fd/42 $@

#ut.cmd('cp -r --verbose NX /usr/NX', sudo=True)

}


install_numba()
{
    # References: http://askubuntu.com/questions/588688/importerror-no-module-named-llvmlite-binding
    # References: http://askubuntu.com/questions/576510/error-while-trying-to-install-llvmlite-on-ubuntu-14-04
    sudo apt install zlib1g zlib1g-dev 
    sudo apt install libedit-dev
    sudo apt install llvm-3.5 llvm-3.5-dev llvm-dev
    sudo apt install llvm-3.6 llvm-3.6-dev llvm-dev
    pip install enum34 funcsigs

    sudo apt install libedit-dev -y
    sudo pip install enum34 -U
    sudo -H pip install pip --upgrade
    sudo -H pip install llvmlite
    sudo -H pip install funcsig
    which llvm-config-3.5
    sudo ln -s llvm-config-3.5 /usr/bin/llvm-config
    sudo apt install libedit-dev -y
    export LLVM_CONFIG=/usr/bin/llvm-config-3.5

    sudo LLVM_CONFIG=/usr/bin/llvm-config-3.6 pip install llvmlite -U
    sudo LLVM_CONFIG=/usr/bin/llvm-config-3.6 pip install numba -U

    sudo -H pip install llvmlite
    python -c "import numba; print(numba.__version__)"
    python -c "import llvmlite; print(llvmlite.__version__)"
}

# Cleanup
#sudo apt remove jasper -y

install_hpn()
{
    # References: https://spoutcraft.org/threads/blazing-fast-sftp-ssh-transfer.7682/
    ssh -V

    sudo apt install python-software-properties
    sudo add-apt-repository ppa:w-rouesnel/openssh-hpn
    sudo apt update -y
    sudo apt install openssh-server


    sudo gvim /etc/ssh/sshd_config
    sudo sh -c 'cat >> /etc/ssh/sshd_config << EOL
# +--- HPN SETTINGS
HPNDisabled no
TcpRcvBufPoll yes
HPNBufferSize 16384
NoneEnabled yes
# L___ HPN SETTINGS
EOL'
   sudo service ssh restart
   ssh -V
    

}


secure_ssl_pip()
{ 
    pip install pyasn1
    pip install ndg-httpsclient
    pip install pyopenssl
}


install_screen_capture()
{
    #sudo apt install recordmydesktop gtk-recordmydesktop
    sudo add-apt-repository ppa:obsproject/obs-studio -y
    sudo apt update && sudo apt install obs-studio -y

    sudo apt install kdenlive
    
}


encryprtion()
{
    # Vera Crypt
    sudo add-apt-repository ppa:unit193/encryption -y
    sudo apt update
    sudo apt install veracrypt -y

    cd ~/tmp
    utzget https://coderslagoon.com/download.php?file=trupax8A_linux64.zip
    cd TruPax8A
    chmod +x install.sh
    sudo ./install.sh

    trupaxgui

    # https://coderslagoon.com/home.php
    cryptkeeper()
    {
        sudo apt install cryptkeeper
        #http://superuser.com/questions/179150/reading-an-encfs-volume-from-windows
        #http://alternativeto.net/software/aescrypt/
        #http://www.getsafe.org/about#linuxversion
    }

    # Try OTFE
    sudo apt install cryptmount


    # TRUECRYPT IS DEPRICATED. DO NOT USE
    sudo add-apt-repository ppa:stefansundin/truecrypt -y
    sudo apt update
    sudo apt install truecrypt -y
}


install_xrdp_remote_desktop()
{
    # Installs an Remote Desktop RDP server

    # --- SERVER ---
    # Install xrdp server
    sudo apt install xrdp -y

    # Install an alternative desktop (apparently gnome-fallback has issues)
    sudo apt install mate-core mate-desktop-environment mate-notification-daemon

    # In Ubuntu 16.04 you have to modify /etc/xrdp/startwm.sh
    # References:
    #     https://askubuntu.com/questions/680413/14-04-3-xrdp-gnome-session-session-ubuntu-2d-not-work


    cat ~/.xsession 
    echo gnome-session --session=gnome-fallback > ~/.xsession
    


    # --- CLIENT ---
    # Update REMINA on the client to the latest and greatest
    #sudo apt-add-repository ppa:remmina-ppa-team/remmina-next -y
    #sudo apt update -y
    #sudo apt install remmina remmina-plugin-rdp libfreerdp-plugins-standard -y
    sudo apt install remmina remmina-plugin-rdp libfreerdp-plugins-standard -y

    # Add self to fuse group
    # https://superuser.com/questions/466304/how-do-i-make-sshfs-work-in-debian-i-get-dev-fuse-permission-denied
    sudo groupadd fuse
    sudo usermod -aG fuse $USER
    sudo chmod g+rw /dev/fuse
    sudo chgrp fuse /dev/fuse

    # ----OLD---
    # http://c-nergy.be/blog/?p=9962
    # https://docs.microsoft.com/en-us/azure/virtual-machines/linux/classic/remote-desktop
    # http://scarygliders.net/2011/11/17/x11rdp-ubuntu-11-10-gnome-3-xrdp-customization-new-hotness/
    # http://askubuntu.com/questions/445485/ubuntu-14-server-and-xrdp
    # http://askubuntu.com/questions/499088/ubuntu-14-x-with-xfce4-session-desktop-terminates-abruptly/499180#499180
    # http://askubuntu.com/questions/449785/ubuntu-14-04-xrdp-grey 
    sudo /etc/init.d/xrdp start
    sudo /etc/init.d/xrdp stop

    # try to fix 14.10 issues
    #sudo apt-add-repository ppa:ubuntu-mate-dev/ppa
    #sudo apt-add-repository ppa:ubuntu-mate-dev/trusty-mate
    #sudo add-apt-repository --remove ppa:ubuntu-mate-dev/ppa
    #sudo add-apt-repository --remove ppa:ubuntu-mate-dev/trusty-mate
    #sudo apt update 
    #sudo apt upgrade
    #sudo apt install ubuntu-mate-core ubuntu-mate-desktop
    #echo mate-session >~/.xsession
    #sudo service xrdp restart

    # http://askubuntu.com/questions/247501/i-get-failed-to-load-session-ubuntu-2d-when-using-xrdp

    sudo apt install gnome-session-fallback
    cat ~/.xsession 
    echo gnome-session --session=gnome-fallback > ~/.xsession

    # http://c-nergy.be/blog/?p=5305
    sudo apt update
    sudo apt install xfce4
 
    # this works but has tab key issue
    echo xfce4-session >~/.xsession
    sudo service xrdp restart

    # help escape sed command
    << __PYSCRIPT__
    import shlex
    str_ = r'<property name="&lt;Super&gt;Tab" type="string" value="switch_window_key"/>'

    import re
    print(re.escape(str_))
    print(str_.replace('switch_window_key', 'empty').replace('/', r'\/'))

    print(shlex.quote(str_))
__PYSCRIPT__

    #sed 's/\<property\ name\=\"\&lt\;Super\&gt\;Tab\"\ type\=\"string\"\ value\=\"switch\_window\_key\"\/\>/<property name="&lt;Super&gt;Tab" type="string" value="empty"\/>/' ~/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-keyboard-shortcuts.xml
    #sed -i 's/\<property\ name\=\"\&lt\;Super\&gt\;Tab\"\ type\=\"string\"\ value\=\"switch\_window\_key\"\/\>/<property name="&lt;Super&gt;Tab" type="string" value="empty"\/>/' ~/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-keyboard-shortcuts.xml

    sed -i 's/switch_window_key/empty/' ~/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-keyboard-shortcuts.xml

    sed 's/switch_window_key/empty/' ~/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-keyboard-shortcuts.xml | grep Super\&gt\;Tab
    



    gvim ~/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-keyboard-shortcuts.xml

    # tab key solution is here 
    #http://askubuntu.com/questions/352121/bash-auto-completion-with-xubuntu-and-xrdp-from-windows
    #vim ~/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-keyboard-shortcuts.xml
    # had a similar issue running XFCE4 over VNC and the workaround for me was
    # to edit the
    # ~/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-keyboard-shortcuts.xml
    # file to unset the following mapping
    #    <       <property name="&lt;Super&gt;Tab" type="string" value="switch_window_key"/>
    #    ---
    #    >    


    # Copy paste?
    #http://askubuntu.com/questions/498873/how-to-install-xrdp-on-ubuntu-14-04-trusty
    
    
    
     
    #echo >> ~/.xsession
}

install_vnc_client()
{
    sudo apt install x11vnc -y
    sudo apt install vinagre -y

    cd ~/tmp
    utzget http://www.karlrunge.com/x11vnc/etv/ssvnc_unix_only-1.0.20.tar.gz
#sudo apt install remmina
}

fix_softwarecenter_color()
{
    # http://askubuntu.com/questions/160932/text-in-ubuntu-software-center-is-unreadable
gksudo gedit /usr/share/software-center/ui/gtk3/css/softwarecenter.css

# Replace 
'@define-color light-aubergine #DED7DB;'
'@define-color super-light-aubergine #F4F1F3;'
# With 
'@define-color light-aubergine #333333;'
'@define-color super-light-aubergine #333333;'
    
}



fix_gnome3_workspaces_multimonior()
{
    sudo apt install gconf-editor 
    #http://gregcor.com/2011/05/07/fix-dual-monitors-in-gnome-3-aka-my-workspaces-are-broken/
    gsettings get org.gnome.shell.overrides workspaces-only-on-primary
    gsettings set org.gnome.shell.overrides workspaces-only-on-primary false
}


git_and_hg()
{
    # References:
    # https://felipec.wordpress.com/2012/11/13/git-remote-hg-bzr-2/
    http://github.com/felipec/git-remote-hg/blob/master/git-remote-hg
    http://github.com/felipec/git-remote-bzr/blob/master/git-remote-bzr

    hg clone https://bitbucket.org/birkenfeld/sphinx-contrib

    python -m utool.util_cplat --exec-get_path_dirs

    # put the extension in the path
    cd ~/bin
    wget https://raw.githubusercontent.com/felipec/git-remote-hg/master/git-remote-hg
    chmod +x ~/bin/git-remote-hg

    # Clone a mercurial repo with git
    code
    git clone hg::https://bitbucket.org/birkenfeld/sphinx-contrib

    od -c ~/bin/git-remote-hg

    sudo pip uninstall sphinxcontrib-napoleon
    cd ~/code/sphinx-contrib/napoleon
    sudo python setup.py develop

}


svn_repos()
{
    # https://code.google.com/p/groupsac/source/checkout 
    svn checkout http://groupsac.googlecode.com/svn/trunk/ groupsac-read-only
}

video_driver_info(){
    # find info on current video driver 
    # http://ubuntuforums.org/showthread.php?t=1795372 
    lspci  -mm | grep VGA

    # Which video driver is in use
    # http://askubuntu.com/questions/23238/how-can-i-find-what-video-driver-is-in-use-on-my-system
    lshw -c video
}


utool_settings()
{
    # Add ability to open ipython notebooks via double click
    python -m utool.util_ubuntu --exec-add_new_mimetype_association --mime-name=ipynb+json --ext=.ipynb --exe-fpath=jupyter-notebook --force
    update-desktop-database ~/.local/share/applications
    update-mime-database ~/.local/share/mime
}


make_venv_physical()
{
    # Hack to make venv physical
    cd $PYTHON_VENV
    cd $PYTHON_VENV/include
    dpath=$PYTHON_VENV/include/python2.7
    # Copy all things in the symlink dir into a physical one
    # TODO: keep track of source location
    if [[ -L "$dpath" && -d "$dpath" ]]; then\
        echo "$dpath is a symlink directory"; \
        mv $dpath "$dpath"_temp
        mkdir $dpath 
        cp -R "$dpath"_temp/* $dpath
        rm "$dpath"_temp
    elif [[ -d "$dpath" ]]; then echo \
        "$dpath is a physical directory dpath"; \
    else \
        echo "Did not match"; \
    fi
}

install_brightness_adjust()
{
    sudo apt update
    sudo apt install xbacklight
    xbacklight -dec 10

    xrandr -q | grep " connected"
    xrandr --output DVI-I-2 --brightness 0.2
    xrandr --output DVI-I-3 --brightness 0.2
    
}

trackball(){
    # http://askubuntu.com/questions/66253/how-to-configure-logitech-marble-trackball
    # Changes mouse behavior such that 
    # holding a special button and moving the trackball will scroll.

    #MOUSE_ID=$(xinput --list | grep -i -m 1 'mouse' | grep -o 'id=[0-9]\+' | grep -o '[0-9]\+')
    #STATE1=$(xinput --query-state $MOUSE_ID | grep 'button\[' | sort)
    #while true; do
    #    sleep 0.2
    #    xinput --query-state $MOUSE_ID
    #    #STATE2=$(xinput --query-state $MOUSE_ID | grep 'button\[' | sort)
    #    #comm -13 <(echo "$STATE1") <(echo "$STATE2")
    #    #STATE1=$STATE2
    #done

    #xinput --list | grep -i -m 1 'trackball' | grep -o 'id=[0-9]\+' | grep -o '[0-9]\+'
    #xinput --help 2>&1 >/dev/null | grep set-.*-prop

    xinput list-props "$dev"

    device="Logitech USB Trackball"
    we="Evdev Wheel Emulation"
    xinput set-int-prop "$dev" "$we Button" 8 8
    xinput set-int-prop "$dev" "$we" 8 1

    # Thise commands dont seemt to work even though set-int-prop is depricated
    xinput set-prop --type=int  "$device" "$we Button" 8 
    xinput set-prop --type=int  "$device" "$we" 1
    #xinput set-prop "$device" --type=int −−format=8 "$we" 1
    #xinput set-prop "$device" --type=int −−format=8 "$we Button" 8
    #xinput set-prop "$device" --type=int −−format=8 "$we" 1

    #--set-int-prop device property format value
    
    
    # --set-prop [--type=atom|float|int] [--format=8|16|32] device property value [...]
    #     Set the property to the given value(s).  If not specified, the format and type of the property are left as-is.  The
    #     arguments are interpreted according to the property type.
    #xinput get-feedbacks "$dev"
    #xinput query-state "$dev"
    #xinput list-props "$dev"
    #xinput get-button-map "$dev"

}


winestuff(){
    echo "See ubuntu_game_packages.sh"
}


edit_startup_commands()
{
    gvim /etc/rc.local
    gvim $HOME/.config/autostart
    gvim /home/joncrall/.config/autostart/update-monitor-position.desktop
    gvim /home/joncrall/tmp/update-monitor-position
    gvim /usr/local/sbin/update-monitor-position

    #[Desktop Entry]
    #Type=Application
    #Exec=update-monitor-position 5
    #Hidden=false
    #NoDisplay=false
    #X-GNOME-Autostart-enabled=true
    #Name[en_US]=Update Monitors Position
    #Name=Update Monitors Position
    #Comment[en_US]=Force monitors position from monitor.xml
    #Comment=Force monitors position from monitor.xml
    #Icon=display
}


fix_monitor_positions()
{
    # References:
    #https://bugs.launchpad.net/ubuntu/+source/xorg/+bug/1311399
    #http://askubuntu.com/questions/450767/multi-display-issue-with-ubuntu-gnome-14-04
    #http://bernaerts.dyndns.org/linux/74-ubuntu/309-ubuntu-dual-display-monitor-position-lost

    mkdir -p ~/tmp
    cd ~/tmp

    sudo wget -O /usr/local/sbin/update-monitor-position https://raw.githubusercontent.com/NicolasBernaerts/ubuntu-scripts/master/ubuntugnome/update-monitor-position
    sudo chmod +x /usr/local/sbin/update-monitor-position
    sudo wget -O /usr/share/applications/update-monitor-position.desktop https://raw.githubusercontent.com/NicolasBernaerts/ubuntu-scripts/master/ubuntugnome/update-monitor-position.desktop
    sudo chmod +x /usr/share/applications/update-monitor-position.desktop

    mkdir -p $HOME/.config/autostart
    wget -O $HOME/.config/autostart/update-monitor-position.desktop https://raw.githubusercontent.com/NicolasBernaerts/ubuntu-scripts/master/ubuntugnome/update-monitor-position.desktop
    sed -i -e 's/^Exec=.*$/Exec=update-monitor-position 5/' $HOME/.config/autostart/update-monitor-position.desktop
    chmod +x $HOME/.config/autostart/update-monitor-position.desktop
        

    mkdir ~/.config/autostart
    sh -c 'cat >> ~/.config/autostart/fixmonitor.desktop << EOL
[Desktop Entry]
Type=Application
Name=FixMonitor
Comment=Hyrule monitor fix
Exec=xrandr --output DVI-D-0 --pos 1920x0 --rotate left --output DVI-I-0 --pos 0x0
NoDisplay=false
#X-GNOME-Autostart-Delay=1
'
}


fix_dbus_issues()
{
    # http://askubuntu.com/questions/135573/gconf-error-no-d-bus-daemon-running-how-to-reinstall-or-fix
    sudo chown -R $USER:$USER ~/.dbus
    # http://askubuntu.com/questions/432604/couldnt-connect-to-accessibility-bus
    # add to sysvars NO_AT_BRIDGE=1
    # or use -Y with -X
}


fix_audio_hyrule(){
    # constant weird beeping sound
    # just installed new (second) graphics card

    # The reason was due to a bad sound card on the MOBO (likely)

    # Reinstall all audio things
    sudo aptitude --purge reinstall linux-sound-base alsa-base alsa-utils linux-image-`uname -r` linux-ubuntu-modules-`uname -r` libasound2

    aplay -l && arecord -l
    lspci -vvv
    lsmod

        

    pacmd list-cards
    pacmd set-card-profile 2  output:analog-stereo
    pacmd set-default-sink 2
       
    # http://askubuntu.com/questions/824481/constant-high-frequency-beep-on-startup-no-other-sound
    # https://answers.launchpad.net/ubuntu/+source/alsa-driver/+question/402824 

     # https://ubuntuforums.org/showthread.php?t=1121805
    sudo apt --purge remove linux-sound-base alsa-base alsa-utils
    sudo apt install linux-sound-base alsa-base alsa-utils
    sudo apt install gdm ubuntu-desktop

    # http://www.linuxquestions.org/questions/ubuntu-63/how-to-set-default-sound-card-in-ubuntu-4175480799/
    cat /proc/asound/modules 


    lspci | grep Audio
    #00:1b.0 Audio device: Intel Corporation 7 Series/C210 Series Chipset Family High Definition Audio Controller (rev 04)
    #01:00.1 Audio device: NVIDIA Corporation GK106 HDMI Audio Controller (rev a1)
    #02:00.1 Audio device: NVIDIA Corporation GK104 HDMI Audio Controller (rev a1)


    #https://bbs.archlinux.org/viewtopic.php?id=115277


    # https://help.ubuntu.com/community/OpenSound
    sudo apt purge pulseaudio gstreamer0.10-pulseaudio
    sudo dpkg-reconfigure linux-sound-base


    # http://askubuntu.com/questions/629634/after-reinstall-alsa-and-pulse-audio-system-setting-missing
    sudo apt remove --purge alsa-base pulseaudio
    sudo apt install alsa-base* pulseaudio* pulseaudio-module-bluetooth* pulseaudio-module-x11* 
    unity-control-center* unity-control-center-signon* webaccounts-extension-common* xul-ext-webaccounts*
    indicator-sound* libcanberra-pulse* osspd* osspd-pulseaudio*
    # http://techgage.com/news/disabling_nvidias_hdmi_audio_under_linux/
    kerneldirs=$(echo /usr/src/linux-headers-*)
    echo $kerneldirs
    cd ${kerneldirs[-1]}
    sudo make menuconfig
    D S 
}

old_setup_ssh_server()
{
    # See hyrule specific version
    sudo apt install -y openssh-server

    sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.factory-defaults
    sudo chmod a-w /etc/ssh/sshd_config.factory-defaults

    # Make changes
    sudo gvim /etc/ssh/sshd_config

    msudo restart ssh || sudo systemctl restart ssh
}

setup_ssh_server() {
    # This works for any computer and makes the computer name appear in bubble text on login
    sudo apt install openssh-server -y
    sudo service ssh status
    # small change to default sshd_config
    sudo sed -i 's/#Banner \/etc\/issue.net/Banner \/etc\/issue.net/' /etc/ssh/sshd_config
    sudo service ssh restart
    #sudo restart ssh
    cat /etc/issue.net 
    COMP_BUBBLE=$(python -c "import utool as ut; print(ut.bubbletext(ut.get_computer_name()))")
    #sh -c "echo \"$COMP_BUBBLE\" > tmp.txt" && cat tmp.txt && rm tmp.txt
    sudo sh -c "echo \"$COMP_BUBBLE\" >> /etc/issue.net"
    # Cheeck to see if its running
    ps -A | grep sshd

    # small change to default sshd_config
    # Allow authorized keys
    sudo sed -i 's/#AuthorizedKeysFile\t%h\/.ssh\/authorized_keys/AuthorizedKeysFile\t%h\/.ssh\/authorized_keys/' /etc/ssh/sshd_config
}


razer_mouse(){
    # http://www.webupd8.org/2016/06/configure-razer-mice-in-linux-with.html
    sudo add-apt-repository ppa:nilarimogard/webupd8
    sudo apt update
    sudo apt install razercfg qrazercfg
    
    # https://terrycain.github.io/razer-drivers/#ubuntu
    # NOTE THIS PPA IS DEPRICATED. SEE LINK FOR THE NEW ONE
    #sudo add-apt-repository ppa:terrz/razerutils
    sudo apt update
    sudo apt install python3-razer razer-kernel-modules-dkms razer-daemon razer-doc

    sudo add-apt-repository --remove ppa:terrz/razerutils
    ppa:whatever/ppa

    sudo ppa-purge ppa:terrz/razerutils

    ls /etc/apt/sources.list.d | grep terrz
    sudo rm /etc/apt/sources.list.d/terrz-ubuntu-razerutils-xenial.list
    sudo rm /etc/apt/sources.list.d/terrz-ubuntu-razerutils-xenial.list.save

}

tilix(){
    # http://www.webupd8.org/2016/07/terminix-now-available-in-ppa-for.html
    sudo add-apt-repository ppa:webupd8team/terminix -y
    sudo apt update
    sudo apt install tilix -y
    # https://gnunn1.github.io/tilix-web/manual/vteconfig/

}


add_ssh_authorized_pubkey()
{
    # This is for adding a pubkey on a remote machine
    mkdir -p ~/.ssh
    
    # MANUAL: append the contents of 
    local:~/.ssh/is_rsa 
    to 
    remote:~/.ssh/authorized_keys

    # Fix permissions
    chmod 700 ~/.ssh
    chmod 600 ~/.ssh/authorized_keys
}

fix_wacom(){
    # https://ubuntuforums.org/showthread.php?t=1656089

    xinput --list | grep Wacom
    xsetwacom --list devices
    xsetwacom --list parameters
    
    #xsetwacom --get "Wacom Bamboo 16FG 4x5 Pen stylus" all

    # Set pen devices to only use the first monitor
    WACOM_PEN_DEVICES=("Wacom Bamboo 16FG 4x5 Pen stylus"
                       "Wacom Bamboo 16FG 4x5 Pen eraser")
    for wacom_dev in "${WACOM_PEN_DEVICES[@]}"; do 
        xsetwacom --set "$wacom_dev" MapToOutput HEAD-0
    done

    # Invert the y-axis so I can use it "upside-down"
    WACOM_DEVICES=("Wacom Bamboo 16FG 4x5 Pen stylus"
                   "Wacom Bamboo 16FG 4x5 Pen eraser"        
                   "Wacom Bamboo 16FG 4x5 Finger touch"      
                   "Wacom Bamboo 16FG 4x5 Pad pad"
                   )
    for wacom_dev in "${WACOM_DEVICES[@]}"; do 
        xsetwacom --set "$wacom_dev" Rotate half
    done
}

mount_android()
{
    # http://www.mysolutions.it/mounting-your-mtp-androids-sd-card-on-ubuntu/
    sudo apt install mtpfs mtp-tools -y

    sudo mkdir /media/droid
    sudo chmod 775 /media/droid
    sudo mtpfs -o allow_other /media/droid

    sudo apt install jmtpfs

    sudo jmtpfs /media/droid
    fusermount -u /media/droid
}

android-ftp(){
    # https://www.omgubuntu.co.uk/2017/11/android-file-transfer-app-linux
    sudo add-apt-repository ppa:samoilov-lex/aftl-stable
    sudo apt-get update && sudo apt install android-file-transfer

}



python_keyring()
{

    # https://pypi.python.org/pypi/keyring
    sudo apt install libdbus-glib-1-dev
    pip install secretstorage dbus-python
    pip install keyring

    keyring set test-dummy-appname joncrall
    keyring get test-dummy-appname joncrall

    python -c "import keyring.util.platform_; print(keyring.util.platform_.config_root())"
}

install_octave(){

    sudo add-apt-repository ppa:octave/stable -y
    sudo apt update -y
    sudo apt install octave -y
}

remap_capslock_as_shift
{

    # ALSO SEE $HOME/local/tools/keyboard_mods.py

    # resets xkbmap
    setxkbmap us

    # https://unix.stackexchange.com/questions/65507/use-setxkbmap-to-swap-the-left-shift-and-left-control
    mkdir -p ~/.xkb/keymap
    mkdir -p ~/.xkb/symbols
    setxkbmap -print > ~/.xkb/keymap/mykbd
    
    echo "
    partial modifier_keys
    xkb_symbols "swap_l_shift_ctrl" {
        replace key <LCTL>  { [ Shift_L ] };
        replace key <LFSH> { [ Control_L ] };
    };
    "


    xkbcomp -I$HOME/.xkb ~/.xkb/keymap/mykbd $DISPLAY 


    #https://askubuntu.com/questions/371394/how-to-remap-caps-lock-key-to-shift-left-key
    #https://forums.freebsd.org/threads/48853/
    xmodmap -e "keycode 66 = Shift_L NoSymbol Shift_L" #this will make Caps Lock to act as Shift_L
    xmodmap -pke > .xmodmap
    echo xmodmap .xmodmap >> .xinitrc

    clear control
    clear mod1

    keycode 37 = Control_L NoSymbol Control_L
    keycode 50 = Shift_L ISO_Next_Group Shift_L ISO_Next_Group
    

    xmodmap -e "remove shift = Shift_L"
    xmodmap -e "add control = Shift_L"
    xmodmap -e "keycode 37 = Control_L"

    #xmodmap -e "remove Control = Control_L"
    xmodmap -e "remove Shift = Shift_L"
    xmodmap -e "keysym Shift_L = Control_L"
    xmodmap -e "keysym Control_L = Shift_L"
    xmodmap -e "add Control = Control_L"
    xmodmap -e "add Shift = Shift_L"

#clear control
#clear mod1
keycode 37 = Control_L
keycode 64 = Control_L
add control = Control_L Control_R
add mod1 = Alt_L Meta_L
    
}

gmail_api(){
    pip install --upgrade google-api-python-client
}

podman(){

    sudo rm /etc/apt/sources.list.d/nvidia-docker.*
    

    cat /etc/apt/sources.list

    ls /etc/apt/sources.list.d/
    cat /etc/apt/sources.list.d/*.list | grep nvidia-docker

    # https://clouding.io/hc/en-us/articles/360011382320-How-to-Install-and-Use-Podman-on-Ubuntu-18-04
    sudo apt-get install software-properties-common -y
    sudo add-apt-repository -y ppa:projectatomic/ppa
    sudo apt-get install podman -y
}

#install_docker_snap(){
#    sudo snap connect docker:home
#    #If you are using an alternative snap-compatible Linux distribution
#    #("classic" in snap lingo), and would like to run docker as a normal user:

#    # Add self to docker group
#    sudo groupadd docker
#    sudo usermod -aG docker $USER
#    # NEED TO LOGOUT / LOGIN to revaluate groups
#    su - $USER  # or we can do this

#    sudo snap disable docker
#    sudo snap enable docker
#}

docker(){
    # https://docs.docker.com/engine/installation/linux/docker-ce/ubuntu/#set-up-the-repository
    # https://github.com/NVIDIA/nvidia-docker

     sudo apt update
     sudo apt install apt-transport-https ca-certificates curl software-properties-common -y
     curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
     sudo apt-key fingerprint 0EBFCD88
     sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
     
     sudo apt update
     sudo apt install -y docker-ce

    # Add self to docker group
    sudo groupadd docker
    sudo usermod -aG docker $USER
    # NEED TO LOGOUT / LOGIN to revaluate groups
    su - $USER  # or we can do this

    # TEST:
    docker run hello-world
    sudo docker run hello-world


    # New Nvidia Docker Install Guide
    # https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html#docker
    distribution=$(. /etc/os-release;echo $ID$VERSION_ID) \
       && curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add - \
       && curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | sudo tee /etc/apt/sources.list.d/nvidia-docker.list
    sudo apt-get update
    sudo apt-get install -y nvidia-docker2
    sudo systemctl restart docker

    # TEST
    sudo docker run --rm --gpus all nvidia/cuda:11.0-base nvidia-smi
    




    ############################
    ############################
    ############################
    # OLD DO NOT USE
    # NVIDIA-Docker
    curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | \
      sudo apt-key add -
    curl -s -L https://nvidia.github.io/nvidia-docker/ubuntu16.04/amd64/nvidia-docker.list | \
      sudo tee /etc/apt/sources.list.d/nvidia-docker.list
    sudo apt update

    # Install nvidia-docker2 and reload the Docker daemon configuration
    sudo apt install -y nvidia-docker2
    sudo pkill -SIGHUP dockerd

    # https://github.com/moby/moby/issues/3127
    # ENSURE ALL DOCKER PROCS ARE CLOSED
    docker ps -q | xargs docker kill


    service docker stop
    #mv /var/lib/docker $dest

    # MOVE DOCKER TO EXTERNAL
    #Ubuntu/Debian: edit your /etc/default/docker file with the -g option: 
    # sudo vim /etc/default/docker
    #sudo mkdir -p /data/docker
    #sudo sed -ie 's/#DOCKER_OPTS.*/DOCKER_OPTS="-dns 8.8.8.8 -dns 8.8.4.4 -g \/data\/docker"/g' /etc/default/docker
    sudo sed -ie 's|^#* *DOCKER_OPTS.*|DOCKER_OPTS="-g /data/docker"|g' /etc/default/docker
    sudo sed -ie 's|^#* *export DOCKER_TMPDIR.*|export DOCKER_TMPDIR=/data/docker-tmp|g' /etc/default/docker
    cat /etc/default/docker
    #sudo sed -ie 's/#export DOCKER_TMPDIR.*/export DOCKER_TMPDIR="/data/docker/tmp"/g' /etc/default/docker

    cat /lib/systemd/system/docker.service

    # We need to point the systemctl docker serivce to this file

    # the proper way to edit systemd service file is to create a file in
    # /etc/systemd/system/docker.service.d/<something>.conf and only override
    # the directives you need. The file in /lib/systemd/system/docker.service
    # is "reserved" for the package vendor.
    sudo mkdir -p /etc/systemd/system/docker.service.d
    sudo sh -c 'cat >> /etc/systemd/system/docker.service.d/override.conf << EOL
[Service]
EnvironmentFile=-/etc/default/docker
ExecStart=
ExecStart=/usr/bin/dockerd -H fd:// \$DOCKER_OPTS
EOL'
    cat /etc/systemd/system/docker.service.d/override.conf
    sudo systemctl daemon-reload

    # SEE https://github.com/moby/moby/issues/9889#issuecomment-120927382

    # https://success.docker.com/article/Using_systemd_to_control_the_Docker_daemon
    service docker start
    sudo systemctl status docker
    sudo journalctl -u docker
    journalctl -xe

    #ln -s $dest /var/lib/docker
    #mv /var/lib/docker /data/docker
    #ln -s /data/docker /var/lib/docker
    

    # TEST
    docker run --runtime=nvidia --rm nvidia/cuda nvidia-smi

    rsync ~/docker/Dockerfile jon.crall@remote_machine.kitware.com:docker/Dockerfile
    
    # urban 
    nvidia-docker build -f ~/docker/Dockerfile -t joncrall/urban3d .
    #nvidia-docker run -t joncrall/urban3d nvidia-smi

    # interactive 
    nvidia-docker run -it joncrall/urban3d bash

    nvidia-docker run -v ~/data:/data -it joncrall/urban3d

    rsync -avRP final_model jon.crall@remote_machine:docker/

    # stop all containers
    docker stop $(docker ps -a -q)
    
    # remove all (non-running) containers (adding a -f does runing containser)
    docker rm $(docker ps -a -q)

    # remove all images
    docker rmi $(docker images -a -q)

    nvidia-docker run -v ~/data:/data -t joncrall/urban3d df -h /dev/shm
    nvidia-docker run --shm-size=12g -v ~/data:/data -t joncrall/urban3d df -h /dev/shm
    nvidia-docker run --shm-size=12g -v ~/data:/data -it joncrall/urban3d

    
    nvidia-docker run --shm-size=12g -v ~/data:/data -t joncrall/urban3d cat test.sh

    nvidia-docker run --shm-size=12g -v ~/data:/data -t joncrall/urban3d python3 -m clab.live.final train --train_data_path=/data/UrbanMapper3D/training --debug --num_workers=0
    --nopin

    nvidia-docker run --ipc=host -v ~/data:/data -t joncrall/urban3d python3 -m clab.live.final train --train_data_path=/data/UrbanMapper3D/training --debug --num_workers=2 --gpu=2


    cd ~/tmp
    wget http://www.topcoder.com/contest/problem/UrbanMapper3D/training.zip
    wget http://www.topcoder.com/contest/problem/UrbanMapper3D/testing.zip
    unzip testing.zip
    unzip training.zip
    mkdir -p ~/data/UrbanMapper3D
    mv testing ~/data/UrbanMapper3D/
    mv training ~/data/UrbanMapper3D/
}


make_private_permissions()
{
    # https://unix.stackexchange.com/questions/79395/how-does-the-sticky-bit-work 
    # https://unix.stackexchange.com/questions/129551/is-it-possible-to-prevent-files-created-being-world-readable

    #chmod g-r g-x [path]
    chmod -R og-wrx /super/secret/path
    chmod -R u+wrx /super/secret/path

    chmod ug-rx clab-private.git
    chmod 700 clab-private.git

    # TODO: setup umask so new directories are created with the same permissions?
}

list-all-ppas(){

    # listppa Script to get all the PPA installed on a system ready to share for reininstall
    #https://askubuntu.com/questions/148932/how-can-i-get-a-list-of-all-repositories-and-ppas-from-the-command-line-into-an

    for APT in `find /etc/apt/ -name \*.list`; do
        grep -o "^deb http://ppa.launchpad.net/[a-z0-9\-]\+/[a-z0-9\-]\+" $APT | while read ENTRY ; do
            echo "ENTRY = $ENTRY"
            USER=`echo $ENTRY | cut -d/ -f4`
            PPA=`echo $ENTRY | cut -d/ -f5`
            echo ppa:$USER
            echo ppa:$USER/$PPA
        done
    done

}

apt-add-repository-remove-ppa()
{
    # https://askubuntu.com/questions/307/how-can-ppas-be-removed

    # List sources
    cat /etc/apt/sources.list

    ls /etc/apt/sources.list.d/
    cat /etc/apt/sources.list.d/*.list | grep terminator

    sudo add-apt-repository --remove ppa;whatever/ppa

    http://ppa.launchpad.net/gnome-terminator/nightly-gtk3/ubuntu
    sudo add-apt-repository --remove ppa:gnome-terminator/ubuntu
}


new-vim-plugin(){
NAME=$1

co

mkdir -p ~/code/$NAME
cd ~/code/$NAME

mkdir doc
mkdir plugin
mkdir autoload

touch doc/$NAME.txt
touch plugin/$NAME.vim
touch autoload/$NAME.vim

touch README
touch LICENSE
}


fix_terminal_control_left(){
    # Solves the :5D problem
    # http://ubuntuforums.org/showthread.php?t=1646842
    # mappings for Ctrl-left-arrow and Ctrl-right-arrow for word moving
    "\e[1;5C": forward-word
    "\e[1;5D": backward-word
    "\e[1;5C": forward-word
    "\e[1;5D": backward-word
    "\e\e[C": forward-word
    "\e\e[D": backward-word
}

install_ipp(){
  mkdir -p ~/tpl-archive/ipp
  #mv ~/Downloads/l_ipp_2018.0.128.tgz ~/tpl-archive/ipp

  rsync -arvp ~/tpl-archive/ipp remote_machine:tpl-archive/

  # Please download and install IPP from https://software.intel.com/en-us/intel-ipp
  mkdir -p ~/tmp
  cd ~/tmp
  tar -xvzf ~/tpl-archive/ipp/l_ipp_2018.0.128.tgz 
  cd ~/tmp/l_ipp_2018.0.128

  ./install.sh --help
  ./install.sh --user-mode

  mkdir -p $HOME/.local/intel

echo "ACCEPT_EULA=accept
INSTALL_MODE=NONRPM
NONRPM_DB_DIR=$HOME/.local/intel
ARCH_SELECTED=ALL
COMPONENTS=DEFAULTS
PSET_MODE=install
CONTINUE_WITH_INSTALLDIR_OVERWRITE=yes
PSET_INSTALL_DIR=$HOME/.local/intel
CONTINUE_WITH_OPTIONAL_ERROR=yes
SIGNING_ENABLED=no
" > silent.cfg

  ./install.sh --user-mode --silent silent.cfg

  #./install.sh --user-mode --nonrpm-db-dir $HOME/.local/intel --silent silent.cfg


  # Enter the following commands
  __doc__ "
      ENTER
      q
      accept
      # gets hairy here
      ENTER
  "



  # installs to $HOME/intel
  # ENSURE YOU ADD $HOME/intel/lib/intel64 to your LD_LIBRARY_PATH
  # ALSO ADD $HOME/intel/ipp/include to CPATH
}

move_hdd(){
    # https://www.linux.com/learn/clone-your-ubuntu-installation-new-hard-disk
    # https://help.ubuntu.com/community/MovingLinuxPartition
    # https://suntong.github.io/blogs/2015/12/26/creating-gpt-partitions-easily-on-the-command-line/
    # https://www.rodsbooks.com/gdisk/sgdisk-walkthrough.html 
    # https://askubuntu.com/questions/741723/moving-entire-linux-installation-to-another-drive


    # Scan the hard disks and list their partitions
    sudo fdisk -l


    sudo apt install gddrescue -y

    echo "OLD_DISK = $OLD_DISK"
    echo "NEW_DISK = $NEW_DISK"

    sudo ddrescue -v $OLD_DISK $NEW_DISK


    # I opened gparted
    # I created a new GDP partition table (that erased all data on the drive)


    # Dump the partition table of the old disk
    cd ~/tmp
    sudo sfdisk -l $OLD_DISK > old_disk_partinfo.txt

    cat old_disk_partinfo.txt

    NEW_DISK=/dev/sdf
    echo "OLD_DISK = $OLD_DISK"
    sudo sfdisk $NEW_DISK


    echo "NEW_DISK = $NEW_DISK"

    # DEFINE which disk we are going to clober
    OLD_DISK=/dev/sdd
    NEW_DISK=/dev/sdf

    # Create a new GDP partition table.
    # Use -Z to zap (erase) all the data on the drive
    sudo sgdisk -Z $NEW_DISK

    # Create new paritions with -n, -t, and -c
    # ------------------------
    #     -n, --new=partnum:start:end                 create new partition
    #     -t, --typecode=partnum:{hexcode|GUID}       change partition type code
    #     -c, --change-name=partnum:name              change partition's name
    #
    # Notes: 
    #     Boot disks for EFI-based systems require an EFI System Partition (sgdisk
    #     internal code 0xEF00) formatted as FAT-32. The recommended size of this
    #     partition is between 100 and 300 MiB. Boot-related files are stored here.
    #     (Note that GNU Parted identifies such partitions as having the "boot
    #     flag" set.)

    # Enumerate some common typecodes
    BOOT_EFI_FAT32=ef00
    LINUX_SWAP=8200
    LINUX_FILESYSTEM=8300
    # we wont use these, but for reference
    BOOT_BIOS=ef02
    MS_RESERVE=0c01
    WINDOWS_FILESYSTEM=0700

    # Create the boot partition with 512 MB at the start of the disk
    sudo sgdisk -n 0:0:+512M -t 0:$BOOT_EFI_FAT32   -c 0:"boot"   $NEW_DISK
    # Use all but the last 8GB of space for the main filesystem
    sudo sgdisk -n 0:0:-8G   -t 0:$LINUX_FILESYSTEM -c 0:"system" $NEW_DISK
    # USe the last 8GB of space for disk swap
    sudo sgdisk -n 0:0:0     -t 0:$LINUX_SWAP       -c 0:"swap"   $NEW_DISK

    # print what we did
    sudo sgdisk -p $NEW_DISK

    # I did do a mkfs.ext4 -F -L "" ${NEW_DISK}2 using gparted to fix a warning
    sudo mkfs.ext4 -F -L "" ${NEW_DISK}2

    # inform the OS of partition table changes
    sudo partprobe $NEW_DISK

    # Mount the new disk to copy data onto it
    sudo mkdir -p /mnt/new_disk1
    sudo mkdir -p /mnt/new_disk2
    sudo mount ${NEW_DISK}1 /mnt/new_disk1
    sudo mount ${NEW_DISK}2 /mnt/new_disk2

    # Copy the system on the old hard drive onto the new one
    sudo rsync -aAXvP /* /mnt/new_disk2 --exclude={/dev/*,/proc/*,/sys/*,/tmp/*,/var/tmp/*,/run/*,/mnt/*,/media/*,/lost+found}

    # Install grub on the new disk
    echo "installing grub on NEW_DISK = $NEW_DISK"
    sudo grub-install $NEW_DISK

    # We need to modify fstab on the new disk, because the UUIDs have changed

    # For each old partition, we need to modify its mount UUID in fstab

    find_uuid_column(){
        # Helper script to find a UUID column
        python -c "$(codeblock "
        import sys
        for part in sys.stdin.read().split(' '):
            if part.startswith('UUID'):
                print(part[6:-1])
        ")" $@
    }

    echo "OLD_DISK = $OLD_DISK"
    echo "NEW_DISK = $NEW_DISK"

    OLD_UUID1=$(blkid | grep "${OLD_DISK}1" | find_uuid_column)
    OLD_UUID2=$(blkid | grep "${OLD_DISK}2" | find_uuid_column)
    OLD_UUID3=$(blkid | grep "${OLD_DISK}3" | find_uuid_column)

    NEW_UUID1=$(blkid | grep "${NEW_DISK}1" | find_uuid_column)
    NEW_UUID2=$(blkid | grep "${NEW_DISK}2" | find_uuid_column)
    NEW_UUID3=$(blkid | grep "${NEW_DISK}3" | find_uuid_column)

    # Replace the old UUIDs with the new ones in the new fstab file
    sudo sed -i "s/$OLD_UUID1/$NEW_UUID1/" /mnt/new_disk2/etc/fstab
    sudo sed -i "s/$OLD_UUID2/$NEW_UUID2/" /mnt/new_disk2/etc/fstab
    sudo sed -i "s/$OLD_UUID3/$NEW_UUID3/" /mnt/new_disk2/etc/fstab

    cat /mnt/new_disk2/etc/fstab | grep "$OLD_UUID1" 
    cat /mnt/new_disk2/etc/fstab | grep "$OLD_UUID2" 
    cat /mnt/new_disk2/etc/fstab | grep "$OLD_UUID3" 

    cat /mnt/new_disk2/etc/fstab | grep "$NEW_UUID1" 
    cat /mnt/new_disk2/etc/fstab | grep "$NEW_UUID2" 
    cat /mnt/new_disk2/etc/fstab | grep "$NEW_UUID3" 
}


fix_resolvconf(){
    # https://askubuntu.com/questions/54888/resolvconf-u-gives-the-error-resolvconf-error-etc-resolv-conf-must-be-a-sym
    sudo rm /etc/resolv.conf
    sudo ln -s ../run/resolvconf/resolv.conf /etc/resolv.conf
    sudo resolvconf -u
}

fix_resolvconf2(){
    # https://superuser.com/questions/983681/my-etc-resolv-conf-file-has-stopped-updating-itself-in-ubuntu-14-04-3
    sudo apt install resolvconf
    sudo resolvconf -u
    #sudo mv /etc/resolv.conf /etc/resolv.conf.bak
    #sudo ln -s /run/resolvconf/resolv.conf /etc/resolv.conf
}


ubuntu_media_codecs(){
    # https://help.ubuntu.com/community/RestrictedFormats
    sudo apt-get install ubuntu-restricted-extras
}


check_hdd_health(){
    #https://unix.stackexchange.com/questions/487346/ubuntu-18-04-is-freezing-randomly
    #https://help.ubuntu.com/community/Smartmontools
    sudo apt-get install smartmontools
}


ttygif(){
    sudo apt-get install imagemagick ttyrec gcc x11-apps make git -y
    cd $HOME/code
    git clone https://github.com/icholy/ttygif.git
    cd ttygif
    PREFIX=$HOME/.local make 
    PREFIX=$HOME/.local make install

    import pyperclip

    __notes__="""

    ttyrec progiter_record3
    ipython
    import progiter
    import time
    for i in progiter.ProgIter(range(1000)):
        time.sleep(0.02)

    export WINDOWID=$(xdotool getwindowfocus)
    ttygif progiter_record3 -f

    """
}


home_printer(){
    __doc__="""
    Brother HL-L3290CDW

    https://support.brother.com/g/b/downloadlist.aspx?c=us&lang=en&prod=hll3290cdw_us&os=128

    # Manually download the scanner driver due to EULA
    # It is a deb file: /home/joncrall/Downloads/brscan4-0.4.9-1.amd64.deb

    # Add Scanner to network
    sudo brsaneconfig4 -a name=BrotherScanner 'model=Brother HL-L3290CDW series' ip=192.168.222.229
    brsaneconfig4 -q 
    

    https://askubuntu.com/questions/314314/laser-printer-scanner-brother-dcp-8110dn-ubuntu-what-is-its-uri
    """

    cd Downloads
    cp $HOME/Downloads/linux-brprinter-installer-2.2.2-2.gz $HOME/tmp
    cd $HOME/tmp
    gunzip linux-brprinter-installer-2.2.2-2.gz
    sudo bash linux-brprinter-installer-2.2.2-2 MFC-J880DW
    sudo usermod -a -G scanner $USER
    
}


install_fun_packages(){
    # Fun packages

    # Cool Retro Term
    # https://github.com/Swordfish90/cool-retro-term
    mkdir -p $HOME/tmp
    cd $HOME/tmp
    wget https://github.com/Swordfish90/cool-retro-term/releases/download/1.1.1/Cool-Retro-Term-1.1.1-x86_64.AppImage
    chmod a+x Cool-Retro-Term-1.1.1-x86_64.AppImage
    ./Cool-Retro-Term-1.1.1-x86_64.AppImage

    # cmatrix
    # https://github.com/abishekvashok/cmatrix
    sudo apt-get install language-pack-ja
}

fix_spotify_at_4k(){
    __doc__="
    https://community.spotify.com/t5/Desktop-Linux/Linux-client-barely-usable-on-HiDPI-displays/td-p/1067272
    "
    FNAME=spotify.desktop

    # Set to 1 to see what changes would be made without making them
    DRY_RUN=0

    apt_ensure colordiff

    # Break multiline output into an array
    CANDIDATES=($(locate $FNAME))
    for IDX in "${!CANDIDATES[@]}"
    do
        FPATH=${CANDIDATES[$IDX]}
        echo "---"
        echo "IDX=$IDX"
        echo "FPATH=$FPATH"

        # This pattern will either add the scale factor or change an existing scale factor
        SED_PATTERN='s|spotify *\(--force-device-scale-factor=[^ ]*\)* *%U|spotify --force-device-scale-factor=1.0 %U|'
        sed "${SED_PATTERN}" $FPATH | colordiff $FPATH -
        if [ "$DRY_RUN" == "0" ]; then
            sudo sed -i "${SED_PATTERN}" $FPATH
        fi
    done

}

fix_bluetooth_headphones(){
    __doc__="
    https://askubuntu.com/questions/1139404/sony-noise-cancelling-headphones-wh-1000xm2-3-and-bluetooth-initial-autoconnec
    https://www.reddit.com/r/Ubuntu/comments/fwz6r4/sony_wh1000xm3_with_ubuntu_2004/
    "
    #mkdir -p $HOME/tmp/bluetooth_helpers
    #cd $HOME/tmp/bluetooth_helpers
    #wget https://launchpad.net/ubuntu/+source/bluez/5.52-0ubuntu2/+build/18277594/+files/bluez_5.52-0ubuntu2_amd64.deb
    #wget https://launchpad.net/ubuntu/+source/bluez/5.52-0ubuntu2/+build/18277594/+files/libbluetooth3_5.52-0ubuntu2_amd64.deb
    #wget https://launchpad.net/ubuntu/+source/bluez/5.52-0ubuntu2/+build/18277594/+files/bluez-cups_5.52-0ubuntu2_amd64.deb
    #wget https://launchpad.net/ubuntu/+source/bluez/5.52-0ubuntu2/+build/18277594/+files/bluez-obexd_5.52-0ubuntu2_amd64.deb 
    #sudo dpkg -i *.deb


    sudo apt install libsbc-dev -y
    sudo apt-get install bluez libbluetooth-dev -y

    MODDIR=`pkg-config --variable=modlibexecdir libpulse`
    echo "MODDIR = $MODDIR"

    find $MODDIR -regex ".*\(bluez5\|bluetooth\).*\.so.*" -exec sha1sum {} \;

    for FPATH in $(find $MODDIR -regex ".*\(bluez5\|bluetooth\).*\.so"); do
        SHA=$(sha1sum $FPATH | cut -d " " -f 1 | cut -c1-16)
        NEW_FPATH=$FPATH.${SHA}.bak
        sudo cp $FPATH $NEW_FPATH
    done

    # pull sources
    cd $HOME/code
    git clone https://github.com/EHfive/pulseaudio-modules-bt.git
    cd pulseaudio-modules-bt
    git submodule update --init

    TARGET_VERSION=v$(pkg-config libpulse --modversion|sed 's/[^0-9.]*\([0-9.]*\).*/\1/')
    echo "TARGET_VERSION = $TARGET_VERSION"
    git -C pa/ checkout  $TARGET_VERSION

    # install
    mkdir build && cd build
    cmake ..
    make
    sudo make install -n

    # Load modules
    pulseaudio -k
    pulseaudio --start

    sudo apt install pavucontrol -y
}


compress_image_directory(){
    __doc__="

    https://www.riksoft.it/wikiriks/software/7zip-maximum-compression-settings-for-images
    https://superuser.com/questions/281573/what-are-the-best-options-to-use-when-compressing-files-using-7-zip

    ### 7z archive options

    -mx=<num> # compression level between 0-9 (5 is default).

    -m0=<method>  # deflate lzma ppmd
    "
    # create an lzma archive with maximum compression
    7z a -m0=lzma -mx=9 archive.7z dpath

    # "ultra" settings

    7z a -t7z -m0=lzma -mx=9 -mfb=64 -md=32m -ms=on archive.7z dir1
}

install_keepass(){
    sudo apt install keepass2
}


install_go(){
    # Install GO
    python -c "import ubelt as ub; print(ub.grabdata(
        'https://golang.org/dl/go1.15.linux-amd64.tar.gz',
        hash_prefix='2d75848ac606061efe52a8068d0e647b35ce487a15bb52272c427df485193602',
        hasher='sha256',
        dpath=ub.ensuredir('$HOME/tmp'), verbose=3))"
    mkdir $HOME/.local
    tar -C $HOME/.local -xzf go1.15.linux-amd64.tar.gz
    # Add $HOME/.local/go to your path or make symlinks
    ln -s $HOME/.local/go/bin/go $HOME/.local/bin/go 
    ln -s $HOME/.local/go/bin/gofmt $HOME/.local/bin/gofmt
}


github_gh_api(){
    # Ensure that go1.15+ is installed
    mkdir $HOME/code/github
    git clone https://github.com/cli/cli.git $HOME/code/github/cli
    cd $HOME/code/github/cli
    make

    $HOME/code/github/cli/bin/gh version
    $HOME/code/github/cli/bin/gh help
    
}

circlci_cli(){
    curl -fLSs https://raw.githubusercontent.com/CircleCI-Public/circleci-cli/master/install.sh | DESTDIR=$HOME/.local/bin bash
}

setup_ssh_server(){
    # https://linuxize.com/post/how-to-enable-ssh-on-ubuntu-18-04/

    sudo apt update -y
    sudo apt install -y openssh-server
    sudo systemctl status ssh
    sudo ufw allow ssh
}


android_studio(){
    # https://android.stackexchange.com/questions/177990/how-to-find-out-which-app-is-trying-to-open-spam-websites

    # Stupid need-to-manually download and install software
    # https://developer.android.com/studio/install#linux
    sudo apt-get install libc6:i386 libncurses5:i386 libstdc++6:i386 lib32z1 libbz2-1.0:i386 -y

    mkdir -p $HOME/.local/opt
    tar -C $HOME/.local/opt -vxzf /home/joncrall/Downloads/android-studio-ide-193.6626763-linux.tar.gz

    # Need to enable kvm virtualization in bios
    # https://android.stackexchange.com/questions/117669/avd-doesnt-work-after-installing-android-studio
    sudo apt-get install qemu-kvm libvirt-bin ubuntu-vm-builder bridge-utils

    kvm-ok

    sudo modprobe kvm_intel

    $HOME/.local/opt/android-studio/bin/studio.sh


    # Download platform tools
    cd $HOME/tmp
    wget https://dl.google.com/android/repository/platform-tools-latest-linux.zip
    7z x platform-tools-latest-linux.zip
    cd platform-tools


    __doc__="""
    adb = android debugging tool
    """
    sudo apt-get install adb -y

    adb devices

    adb shell dumpsys activity activities | tee activities.txt
    adb logcat -v long,descriptive  | tee logcat.txt

}

disable_gpu_lights(){
    # Some of the LEDS can be disabled in the bios for the MOBO

    # Only dims one of the lights
    nvidia-settings --assign GPULogoBrightness=100
}


docker_modern_2021_04_22(){
    # https://docs.docker.com/engine/install/ubuntu/
    # https://docs.docker.com/engine/install/linux-postinstall/
    # https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html#docker

     sudo apt install apt-transport-https ca-certificates curl gnupg lsb-release -y

     curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

     echo \
      "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
      $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

     sudo apt update -y
     sudo apt install docker-ce docker-ce-cli containerd.io -y
     
    # Add self to docker group
    sudo groupadd docker
    sudo usermod -aG docker $USER
    # NEED TO LOGOUT / LOGIN to revaluate groups
    su - $USER  # or we can do this

     # Test
     docker run hello-world


    # Change docker to use storage on an external drive
    # Ubuntu/Debian: edit your /etc/default/docker file with the -g option: 
    cat /etc/default/docker
    sudo sed -ie 's|^#* *DOCKER_OPTS.*|DOCKER_OPTS="-g /data/docker"|g' /etc/default/docker
    sudo sed -ie 's|^#* *export DOCKER_TMPDIR.*|export DOCKER_TMPDIR=/data/docker-tmp|g' /etc/default/docker
    cat /etc/default/docker



    # Install the NVIDIA Runtime:
    DISTRIBUTION=$(. /etc/os-release;echo $ID$VERSION_ID) 
    echo "DISTRIBUTION = $DISTRIBUTION"
    curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add - 
    curl -s -L https://nvidia.github.io/nvidia-docker/$DISTRIBUTION/nvidia-docker.list | sudo tee /etc/apt/sources.list.d/nvidia-docker.list

    sudo apt-get update -y
    sudo apt-get install -y nvidia-docker2
    sudo systemctl restart docker

    sudo docker run --rm --gpus all nvidia/cuda:11.0-base nvidia-smi
    

}

world_community_grid(){
    ___doc__="
    Instructions for installing worldcommunitygrid
    https://www.worldcommunitygrid.org/join.action#os-linux-debian

    TODO:
        - [ ] How do we hook contributing to WCG up to ETH or some other cyrpto as a proof-of-useful-work mechanism?
    "
    #1. In a terminal window, run the following command:
    sudo apt install boinc-client boinc-manager
    #2. Set the BOINC client to automatically start after you restart your computer:
    sudo systemctl enable boinc-client
    #3. Start the BOINC client:
    sudo systemctl start boinc-client
    #4. Allow group access to client access file:
    sudo chmod g+r /var/lib/boinc-client/gui_rpc_auth.cfg
    #5. Add your Linux user to the BOINC group to allow the BOINC Manager to communicate with the BOINC client
    sudo usermod -a -G boinc $USER
    #6. Allow your terminal to pick up the privileges of the new group:
    exec su $USER
    #7. In the same terminal window, start the BOINC Manager:
    sudo boincmgr -d /var/lib/boinc-client
    
}


voice_terminal(){
    __doc__="
    https://mitchellharle.medium.com/how-to-execute-terminal-commands-with-your-voice-on-linux-eb1f6de58bff
    "
    sudo apt install portaudio19-dev swig libatlas-base-dev -y
    git clone https://github.com/synesthesiam/voice2json
    cd voice2json
    ./configure --prefix=$HOME/.local
    make -j9
    make install

    voice2json train-profile

}
