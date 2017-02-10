common_paths()
{
    cat ~/local/init/ensure_vim_plugins.py
}


install_core()
{
    sudo apt-get update -y 
    sudo apt-get upgrade -y
    # Git
    sudo apt-get install -y git

    # latest git
    sudo add-apt-repository ppa:git-core/ppa -y
    sudo apt-get update
    sudo apt-get install git -y
    git --version
    

    # Vim / Gvim
    #sudo apt-get install -y vim
    #sudo apt-get install -y vim-gtk
    #sudo apt-get install -y vim-gtk-py2
    #sudo apt-get remove -y vim
    #sudo apt-get remove -y vim-gnome
    #sudo apt-get remove -y vim-gtk-py2
    # Make python2 work with vim on ubuntu 16.04 for a bit longer
    # WE WILL SWITH TO PYTHON 3!
    sudo apt-get install -y vim-gnome-py2
    sudo update-alternatives --set vim /usr/bin/vim.gnome-py2
    sudo update-alternatives --set gvim /usr/bin/gvim.gtk-py2

    sudo apt-get install -y exuberant-ctags 

    # Trash put
    #sudo apt-get install -y trash-cli
    sudo apt-get install -y gvfs-bin
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
    sudo apt-get install -y wmctrl xsel xdotool xclip
    sudo apt-get install -y xclip
    sudo apt-get install -y gparted htop tree
    sudo apt-get install -y tmux astyle
    sudo apt-get install -y synaptic okular
    sudo apt-get install -y openssh-server

    sudo apt-get install p7zip-full -y
    sudo apt-get install graphviz -y
    sudo apt-get install imagemagick -y

    #sudo apt_get install libhighgui2.4
    #sudo apt_get install libcv2.4
    #sudo apt_get install libcvaux-dev
    #sudo apt_get install opencv-doc

    # sqlite db  editor
    #sudo apt-get install sqliteman
    sudo apt-get install -y sqlitebrowser 
    #References: http://stackoverflow.com/questions/7454796/taglist-exuberant-ctags-not-found-in-path
    sudo apt-get install -y hdfview

    # for editing desktop sidebar icons
    sudo apt-get install alacarte

    # anti-virus 
    # https://www.upcloud.com/support/scanning-ubuntu-14-04-server-for-malware/
    sudo apt-get install clamav clamav-daemon
    sudo freshclam
    sudo clamscan -r /home

    sudo apt-get install rkhunter
}

truely_ergonomic_keyboard_setup()
{
    sudo apt-get install lm-sensors
    sudo apt-get install hardinfo
    # TEK truely ergonomic keyboard setup
    # Link for TEK 229 Need to switch for 209
    # https://trulyergonomic.com/store/layout-designer--configurator--reprogrammable--truly-ergonomic-mechanical-keyboard/#KTo7PD0+P0BBQkNERUw5394rNR4fICEi4yMkJSYnLS4xOBQaCBUXTBwYDBITLzDhBBYHCQorCw0ODzPl4B0bBhkFKhEQNjc05OfiSktOTSwoLFBSUU/mRQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAX2BhAAAAAAAAAAAAAAAAXF1eVlcAAAAAAAAAAABZWltVAAAAAAAAAAAAYgBjVAAAAAAAAAAAWCsAAAAAAACTAQAMAiMBAAwBigEADAIhAQAMAZQBAAwBkgEADAGDAQAMALYBAAwAzQEADAC1AQAMAOIBAAwA6gEADADpAQAMALhJAEYAAAAAAEitR64AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACk6Ozw9Pj9AQUJDREVMOd/eKzUeHyAhImQjJCUmJy4qLzAUGggVF0wcGAwSEzQx4wQWBwkKLQsNDg8z5+EdGwYZBSoREDY3OOXg4kpLTk0sKCxQUlFP5uQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAF9gYQAAAAAAAAAAAAAAAFxdXlZXAAAAAAAAAAAAWVpbVQAAAAAAAAAAAGIAY1QAAAAAAAAAAFgrAAAAAAAAkwEADAIjAQAMAYoBAAwCIQEADAGUAQAMAZIBAAwBgwEADAC2AQAMAM0BAAwAtQEADADiAQAMAOoBAAwA6QEADAC4SQBGAAAAAABIrUeuAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=
    cd ~/tmp
    utzget http://www.trulyergonomic.com/Truly_Ergonomic_Firmware_Upgrade_Linux_v2_0_0.tar.gz
    cd tex-linux
    #sudo apt-get remove libwxbase3.0-0 libwxgtk3.0-0 libwxgtk-webview3.0-0
    #In Ubuntu before 15.04 vivid (or derivatives like Linux Mint 17.2) you have to:
    #1. add the ubuntu-toolchain-r/test ppa to get libstdc++6-4.9
    sudo add-apt-repository ppa:ubuntu-toolchain-r/test 
    sudo apt-get update
    sudo apt-get install libstdc++6
    wget http://security.ubuntu.com/ubuntu/pool/universe/w/wxwidgets3.0/libwxbase3.0-0_3.0.2-1_amd64.deb
    wget http://security.ubuntu.com/ubuntu/pool/universe/w/wxwidgets3.0/libwxgtk3.0-0_3.0.2-1_amd64.deb
    wget http://security.ubuntu.com/ubuntu/pool/universe/w/wxwidgets3.0/libwxgtk-webview3.0-0_3.0.2-1_amd64.deb
    sudo dpkg -i libwx*.deb
    sudo ./tek
    # Now 
}

install_dropbox()
{
    # Dropbox 
    #cd ~/tmp
    #cd ~/tmp && wget -O - "https://www.dropbox.com/download?plat=lnx.x86_64" | tar xzf -
    #.dropbox-dist/dropboxd
    sudo apt-get -y install nautilus-dropbox
}

install_zotero()
{
    # Find the most recent release URL
    export ZOTERO_URL=$(python -c "
    from bs4 import BeautifulSoup
    import requests
    url = 'https://www.zotero.org/download/'
    html = requests.get(url).content
    soup = BeautifulSoup(html, 'html.parser')
    tags = [h for h in soup.find_all('a') if 'Download' in h.text and 'Linux 64-bit' in h.text]
    href = tags[0].get('href')
    print(href)
    ")
    echo "ZOTERO_URL=$ZOTERO_URL"
    #https://download.zotero.org/standalone/4.0.29.10/Zotero-4.0.29.10_linux-x86_64.tar.bz2
    cd ~/tmp
    wget $ZOTERO_URL
    utarbz2 Zotero-*_linux-x86_64.tar.bz2
    sudo cp -r Zotero_linux-x86_64 /opt/zotero
    # Change permissions so zotero can automatically update itself
    sudo chown -R root:$USER /opt/zotero
    sudo chmod -R g+w /opt/zotero
    sudo chmod -R u+w /opt/zotero

    python -m utool.util_ubuntu --exec-make_application_icon --exe=/opt/zotero/zotero --icon=/opt/zotero/chrome/icons/default/main-window.ico -w

    # Need to do tools->Add-Ons->(setting icon)->Add from file
    # view citation key
    https://github.com/ZotPlus/zotero-better-bibtex
    https://github.com/ZotPlus/zotero-better-bibtex/releases/download/1.6.30/zotero-better-bibtex-1.6.30.xpi
    # others...
    http://www.rtwilson.com/academic/autozotbib
    http://www.rtwilson.com/academic/autozotbib.xpi
    https://addons.mozilla.org/en-US/firefox/addon/zotero-scholar-citations/
}

install_core_extras()
{
    # Not commonly used but frequently forgotten
    sudo apt-get install -y valgrind
    #sudo apt-get install -y screen
    sudo apt-get install -y synaptic
    sudo apt-get install -y gitg
    sudo apt-get install -y sysstat
    sudo apt-get install -y vlc
    sudo apt-get install -y subversion
    sudo apt-get install -y remmina 
    sudo apt-get install expect -y


    sudo apt-get install -y filezilla

    sudo apt-get install python-pydot -y

    sudo apt-get install dia-gnome -y

    # flux
    sudo add-apt-repository ppa:kilian/f.lux
    sudo apt-get update
    sudo apt-get install fluxgui -y

    # 7zip

    # Make vlc default app
    # http://askubuntu.com/questions/91701/how-to-set-vlc-as-default-video-player
    cat /usr/share/applications/defaults.list | grep video
    cat /usr/share/applications/defaults.list | grep totem.desktop
    cat ~/.local/share/applications/mimeapps.list
    sudo sed -i 's/\(^.*\)video\(.*\)=totem.desktop/\1video\2=vlc.desktop/' /usr/share/applications/defaults.list
    sudo sed -i 's/\(^.*\)audio\(.*\)=totem.desktop/\audio\2=vlc.desktop/' /usr/share/applications/defaults.list


    # ssh file system
    sudo apt-get install sshfs -y
    mkdir ~/ami    
    sshfs -o idmap=user ibeis-hackathon:/home/ubuntu ~/ami
    sshfs -o idmap=user lev:/ ~/lev


    # To allow to get the flash package from software center
    #http://askubuntu.com/questions/576562/apt-way-to-get-adobe-flash-player-latest-version-for-linux-not-working
    #http://blog.cacoo.com/2012/08/07/troubleshooting-chrome-flash/
    sudo add-apt-repository universe
    sudo apt-get install pepperflashplugin-nonfree
    sudo update-pepperflashplugin-nonfree --status
    sudo update-pepperflashplugin-nonfree --install 

    sudo add-apt-repository ppa:nilarimogard/webupd8
    sudo apt-get update
    sudo apt-get install freshplayerplugin


    #http://superuser.com/questions/403664/how-can-i-copy-and-paste-text-out-of-a-remote-vim-to-a-local-vim
    # 
}


install_skype()
{
    # References: https://help.ubuntu.com/community/Skype
    #sudo dpkg --add-architecture i386
    sudo add-apt-repository "deb http://archive.canonical.com/ $(lsb_release -sc) partner"
    sudo apt-get update 
    sudo apt-get install skype -y
    #sudo apt-get install -y skype
}

install_evaluating()
{
    #sudo apt-get install inkscape -y
    #References: https://github.com/kayhayen/Nuitka#use-case-3-package-compilation
    sudo apt-get install nuitka
    nuitka --module ibeis --recurse-directory=ibeis
    nuitka --recurse-all main.py
}

install_ubuntu_tweak()
{
    # To clean up old kernels
    # References: http://askubuntu.com/questions/2793/how-do-i-remove-or-hide-old-kernel-versions-to-clean-up-the-boot-menu
    sudo add-apt-repository ppa:tualatrix/ppa
    sudo apt-get update
    sudo apt-get install -y ubuntu-tweak
}

install_chrome()
{
    # Google PPA
    wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
    sudo sh -c 'echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list'
    sudo apt-get update
    # Google Chrome
    sudo apt-get install -y google-chrome-stable 
}
 
install_spotify()
{
    #cat /etc/apt/sources.list
    sudo sh -c 'echo "deb http://repository.spotify.com stable non-free" >> /etc/apt/sources.list'
    sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 94558F59
    sudo apt-get update
    sudo apt-get install -y spotify-client --force-yes
    # https://community.spotify.com/t5/Help-Desktop-Linux-Windows-Web/Linux-users-important-update/td-p/1157534
    sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys D2C19886
}

install_vpn()
{

    # 
    http://dotcio.rpi.edu/services/network-remote-access/vpn-connection-and-installation/using-vpnc-open-source-client

    # replaces cisco anyconnect
    sudo apt-get install network-manager-openconnect-gnome -y

    # gateway: vpn.net.rpi.edu

    #https://www.reddit.com/r/RPI/comments/2c3fd9/rpi_vpn_from_ubuntu/

    sudo openconnect -b vpn.net.rpi.edu -uyour_school_username -ucrallj
    alias rpivpn='sudo openconnect -b vpn.net.rpi.edu -uyour_school_username -ucrallj'
    
}

 
install_latex()
{
    echo 'latex'
    # Latex (ubuntu uses texlive 2013, use something more recent)
    sudo apt-get purge texlive
    sudo apt-get purge texlive-base
    sudo apt-get purge pgf

    #texlive 2015
    # https://www.tug.org/texlive/acquire-netinstall.html
    cd ~/tmp
    wget http://mirror.ctan.org/systems/texlive/tlnet/install-tl-unx.tar.gz
    tar xzvf install-tl-unx.tar.gz
    cd install-tl-*
    #export TEXLIVE_INSTALL_PREFIX=/opt/texlive
    #export TEXDIR=/opt/texlive
    chmod +x install-tl
    sudo ./install-tl
    # cd /usr/local/texlive/2015/bin/x86_64-linux
    # Installed to /usr/local/texlive/2015/
    # Need to add /usr/local/texlive/2015/bin/x86_64-linux to the PATH
    #python -m utool.util_cplat --exec-get-path-dirs:0

    sudo apt-get install latexmk
}


install_python()
{
    # Python
    sudo apt-get install python-qt4
    sudo apt-get install python-pip
    sudo apt-get install -y python-tk
    sudo pip install virtualenv
    sudo pip install jedi
    sudo pip install pep8
    sudo pip install autopep8
    sudo pip install flake8
    sudo pip install pylint
    sudo pip install line_profiler
    #sudo pip install Xlib
    sudo pip install requests
    sudo pip install objgraph
    sudo pip install memory_profiler
    sudo pip install guppy

    #https://github.com/rogerbinns/apsw/releases/download/3.8.6-r1/apsw-3.8.6-r1.win32-py2.7.exe
    sudo apt-get install -y libsqlite3-dev 
    sudo apt-get install -y sqlite3
    sudo apt-get install -y libsqlite3
    sudo apt-get install -y python-apsw
    #sudo pip install apsw


    sudo apt-get install libgeos-dev -y
    pip install shapely
}

install_hdf5()
{
    #sudo apt-get install -y libhdf5-serial-dev
    #The following extra packages will be installed:
    #  libhdf5-openmpi-7
    #Suggested packages:
    #  libhdf5-doc
    #The following packages will be REMOVED:
    #  libhdf5-7 libhdf5-dev libhdf5-serial-dev
    #The following NEW packages will be installed:
    #  libhdf5-openmpi-7 libhdf5-openmpi-dev
    sudo apt-get install -y libhdf5-serial-dev
    sudo apt-get install -y libhdf5-openmpi-dev
    #h5cc -showconfig
    sudo apt-get install hdf5-tools
}

install_cuda_prereq()
{
    sudo apt-get install -y libprotobuf-dev
    sudo apt-get install -y libleveldb-dev 
    sudo apt-get install -y libsnappy-dev 
    sudo apt-get install -y libboost-all-dev 
    sudo apt-get install -y libopencv-dev 

    install_hdf5

    sudo apt-get install -y libgflags-dev
    sudo apt-get install -y libgoogle-glog-dev
    sudo apt-get install -y liblmdb-dev
    sudo apt-get install -y protobuf-compiler 

    #sudo apt-get install -y gcc-4.6 
    #sudo apt-get install -y g++-4.6 
    #sudo apt-get install -y gcc-4.6-multilib
    #sudo apt-get install -y g++-4.6-multilib 
    sudo apt-get install libpthread-stubs0-dev

    sudo apt-get install -y gfortran
    sudo apt-get install -y libjpeg62
    sudo apt-get install -y libfreeimage-dev
    sudo apt-get install -y libatlas-base-dev 

    sudo apt-get install -y python-dev
    #sudo apt-get install -y python-pip
    #sudo apt-get install -y python-numpy
    #sudo apt-get install -y python-pillow
}


install_xlib()
{
    # for gnome-shell-grid
    sudo pip install svn+https://python-xlib.svn.sourceforge.net/svnroot/python-xlib/trunk/
    sudo apt-get install -y python-wnck 
    sudo apt-get install -y wmctrl 
    sudo apt-get install -y xdotool
}

install_virtualbox()
{
    # References: https://www.virtualbox.org/wiki/Linux_Downloads
    # Add oracle keys
    #wget -q https://www.virtualbox.org/download/oracle_vbox.asc -O- | sudo apt-key add -
    #sudo apt-get update
    #sudo apt-get install virtualbox-4.3
    sudo apt-get install virtualbox 
    sudo apt-get install dkms
    # download addons and mount on guest machine
    #http://download.virtualbox.org/virtualbox/4.1.12/
    utget 'http://download.virtualbox.org/virtualbox/4.1.12/VBoxGuestAdditions_4.1.12.iso'
    utget 'http://mirror.solarvps.com/centos/7.0.1406/isos/x86_64/CentOS-7.0-1406-x86_64-DVD.iso'
    python -c 'import utool; print(utool.grab_file_url("http://download.virtualbox.org/virtualbox/4.1.12/VBoxGuestAdditions_4.1.12.iso"))'
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
    sudo apt-get install capnproto
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
    sudo apt-get install clang-3.5
    sudo apt-get install libstdc++-4.8-dev

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
    sudo apt-get install zlib1g zlib1g-dev 
    sudo apt-get install libedit-dev
    sudo apt-get install llvm-3.5 llvm-3.5-dev llvm-dev
    sudo apt-get install llvm-3.6 llvm-3.6-dev llvm-dev
    pip install enum34 funcsigs

    sudo apt-get install libedit-dev -y
    sudo pip install enum34 -U
    sudo -H pip install pip --upgrade
    sudo -H pip install llvmlite
    sudo -H pip install funcsig
    which llvm-config-3.5
    sudo ln -s llvm-config-3.5 /usr/bin/llvm-config
    sudo apt-get install libedit-dev -y
    export LLVM_CONFIG=/usr/bin/llvm-config-3.5

    sudo LLVM_CONFIG=/usr/bin/llvm-config-3.6 pip install llvmlite -U
    sudo LLVM_CONFIG=/usr/bin/llvm-config-3.6 pip install numba -U

    sudo -H pip install llvmlite
    python -c "import numba; print(numba.__version__)"
    python -c "import llvmlite; print(llvmlite.__version__)"
}

# Cleanup
#sudo apt-get remove jasper -y

install_hpn()
{
    # References: https://spoutcraft.org/threads/blazing-fast-sftp-ssh-transfer.7682/
    ssh -V

    sudo apt-get install python-software-properties
    sudo add-apt-repository ppa:w-rouesnel/openssh-hpn
    sudo apt-get update -y
    sudo apt-get install openssh-server


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
    #sudo apt-get install recordmydesktop gtk-recordmydesktop
    sudo add-apt-repository ppa:obsproject/obs-studio
    sudo apt-get update && sudo apt-get install obs-studio
}


encryprtion()
{
    cd ~/tmp
    utzget https://coderslagoon.com/download.php?file=trupax8A_linux64.zip
    cd TruPax8A
    chmod +x install.sh
    sudo ./install.sh

    trupaxgui

    # https://coderslagoon.com/home.php
    cryptkeeper()
    {
        sudo apt-get install cryptkeeper
        #http://superuser.com/questions/179150/reading-an-encfs-volume-from-windows
        #http://alternativeto.net/software/aescrypt/
        #http://www.getsafe.org/about#linuxversion
    }

    # Try OTFE
    sudo apt-get install cryptmount

    sudo add-apt-repository ppa:stefansundin/truecrypt
    sudo apt-get update
    sudo apt-get install truecrypt
}


install_xrdp_remote_desktop()
{
    # http://scarygliders.net/2011/11/17/x11rdp-ubuntu-11-10-gnome-3-xrdp-customization-new-hotness/
    # http://askubuntu.com/questions/445485/ubuntu-14-server-and-xrdp
    # http://askubuntu.com/questions/499088/ubuntu-14-x-with-xfce4-session-desktop-terminates-abruptly/499180#499180
    # http://askubuntu.com/questions/449785/ubuntu-14-04-xrdp-grey 
    sudo apt-get install xrdp -y
    sudo /etc/init.d/xrdp start
    sudo /etc/init.d/xrdp stop

    # try to fix 14.10 issues
    #sudo apt-add-repository ppa:ubuntu-mate-dev/ppa
    #sudo apt-add-repository ppa:ubuntu-mate-dev/trusty-mate
    #sudo add-apt-repository --remove ppa:ubuntu-mate-dev/ppa
    #sudo add-apt-repository --remove ppa:ubuntu-mate-dev/trusty-mate
    #sudo apt-get update 
    #sudo apt-get upgrade
    #sudo apt-get install ubuntu-mate-core ubuntu-mate-desktop
    #echo mate-session >~/.xsession
    #sudo service xrdp restart

    # http://askubuntu.com/questions/247501/i-get-failed-to-load-session-ubuntu-2d-when-using-xrdp

    sudo apt-get install gnome-session-fallback
    cat ~/.xsession 
    echo gnome-session --session=gnome-fallback > ~/.xsession

    # http://c-nergy.be/blog/?p=5305
    sudo apt-get update
    sudo apt-get install xfce4
 
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
    sudo apt-get install x11vnc -y
    sudo apt-get install vinagre -y

    cd ~/tmp
    utzget http://www.karlrunge.com/x11vnc/etv/ssvnc_unix_only-1.0.20.tar.gz
#sudo apt-get install remmina
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
    sudo apt-get install gconf-editor 
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
    sudo apt-get update
    sudo apt-get install xbacklight
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

make_sshkey(){
    ssh-keygen -t rsa -b 4096 -C "your_email@example.com"
    ssh-keygen -t rsa -b 4096 
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
    sudo apt-get --purge remove linux-sound-base alsa-base alsa-utils
    sudo apt-get install linux-sound-base alsa-base alsa-utils
    sudo apt-get install gdm ubuntu-desktop

    # http://www.linuxquestions.org/questions/ubuntu-63/how-to-set-default-sound-card-in-ubuntu-4175480799/
    cat /proc/asound/modules 


    lspci | grep Audio
    #00:1b.0 Audio device: Intel Corporation 7 Series/C210 Series Chipset Family High Definition Audio Controller (rev 04)
    #01:00.1 Audio device: NVIDIA Corporation GK106 HDMI Audio Controller (rev a1)
    #02:00.1 Audio device: NVIDIA Corporation GK104 HDMI Audio Controller (rev a1)


    #https://bbs.archlinux.org/viewtopic.php?id=115277


    # https://help.ubuntu.com/community/OpenSound
    sudo apt-get purge pulseaudio gstreamer0.10-pulseaudio
    sudo dpkg-reconfigure linux-sound-base


    # http://askubuntu.com/questions/629634/after-reinstall-alsa-and-pulse-audio-system-setting-missing
    sudo apt-get remove --purge alsa-base pulseaudio
    sudo apt-get install alsa-base* pulseaudio* pulseaudio-module-bluetooth* pulseaudio-module-x11* 
    unity-control-center* unity-control-center-signon* webaccounts-extension-common* xul-ext-webaccounts*
    indicator-sound* libcanberra-pulse* osspd* osspd-pulseaudio*
    # http://techgage.com/news/disabling_nvidias_hdmi_audio_under_linux/
    kerneldirs=$(echo /usr/src/linux-headers-*)
    echo $kerneldirs
    cd ${kerneldirs[-1]}
    sudo make menuconfig
    D S 
}

setup_ssh_server()
{
    # See hyrule specific version
    sudo apt-get install -y openssh-server

    sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.factory-defaults
    sudo chmod a-w /etc/ssh/sshd_config.factory-defaults

    # Make changes
    sudo gvim /etc/ssh/sshd_config

    msudo restart ssh || sudo systemctl restart ssh
}
