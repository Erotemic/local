
#index_opencv_with_ctags()
#{
#    #References:
#    #    http://sourceforge.net/p/ctags/mailman/message/20916991/
#    ctags -R -ICVAPI --c++-kinds=+p --fields=+iaS --extra=+q --language-force=c++ /usr/include/opencv/
#}
#clean_for_upgrade()
#{
#    # msg: Please free at least an additional 68,3 M of disk space on '/boot'. Empty your trash and remove temporary packages of former installations using 'sudo apt-get clean'.
#    # References: http://askubuntu.com/questions/495941/software-updater-needs-more-disk-space
#    ubuntu-tweak
#}

#setup_ibeis()
#{
#    source ~/local/init/freshstart_ubuntu.sh
#}

#ypackin()
#{
#    sudo pip install $*
#}
#packin()
#{
#    sudo apt-get install -y $*
#}


install_core()
{
    sudo apt-get update -y 
    sudo apt-get upgrade -y
    # Git
    sudo apt-get install -y git

    # Vim
    sudo apt-get install -y vim
    sudo apt-get install -y vim-gtk
    sudo apt-get install -y exuberant-ctags 

    # Trash put
    sudo apt-get install -y trash-cli
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
    sudo apt-get install -y gparted
    sudo apt-get install -y htop
    sudo apt-get install -y tree
    sudo apt-get install -y openssh-server
    sudo apt-get install -y tmux
    sudo apt-get install -y synaptic
    sudo apt-get install -y astyle
    sudo apt-get install -y valgrind
    #sudo apt-get install -y screen

    # 
    sudo apt_get install libhighgui2.4
    sudo apt_get install libcv2.4
    sudo apt_get install libcvaux-dev
    sudo apt_get install opencv-doc


    # sqlite db  editor
    #sudo apt-get install sqliteman
    sudo apt-get install -y sqlitebrowser 
    #References: http://stackoverflow.com/questions/7454796/taglist-exuberant-ctags-not-found-in-path
    sudo apt-get install -y hdfview
    
}

#install_synergy()
#{
#    sudo apt-get install synergy -y
#}


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
    # Zotero
    #sudo add-apt-repository ppa:smathot/cogscinl
    #sudo apt-get update
    #sudo apt-get install -y zotero-standalone 
    #python -c "import ssl; print ssl.OPENSSL_VERSION"

    #python3 -c "import utool; print(utool.grab_file_url(\"$@\", spoof=True))"
    #python3 -c "import utool; print(utool.grab_file_url(\"https://download.zotero.org/standalone/4.0.26.3/Zotero-4.0.26.3_linux-x86_64.tar.bz2\", spoof=True))"
    

    #utget "https://download.zotero.org/standalone/4.0.26.3/Zotero-4.0.26.3_linux-x86_64.tar.bz2"
    cd ~/Downloads
    utarbz2 Zotero-4.0.26.3_linux-x86_64.tar.bz2
    cd Zotero_linux-x86_64/
    cd /opt
    cd ~/Downloads
    sudo cp -r Zotero_linux-x86_64 /opt/zotero
    # Change permissions so zotero can automatically update itself
    sudo chown -R root:joncrall /opt/zotero
    sudo chmod -R g+w /opt/zotero
    sudo chmod -R u+w /opt/zotero

    http://www.rtwilson.com/academic/autozotbib
    http://www.rtwilson.com/academic/autozotbib.xpi
    https://addons.mozilla.org/en-US/firefox/addon/zotero-scholar-citations/


}

install_core_extras()
{
    # Not commonly used but frequently forgotten
    sudo apt-get install -y okular
    sudo apt-get install -y synaptic
    sudo apt-get install -y gitg
    sudo apt-get install -y sysstat
    sudo apt-get install -y vlc
    sudo apt-get install -y subversion

    #sudo apt-get install -y filezilla


    sudo apt-get install graphviz -y
    sudo apt-get install imagemagick -y
    sudo apt-get install python-pydot -y

    sudo apt-get install dia-gnome -y

    # flux
    sudo add-apt-repository ppa:kilian/f.lux
    sudo apt-get update
    sudo apt-get install fluxgui -y

    # 7zip
    sudo apt-get install p7zip-full

    # Make vlc default app
    # http://askubuntu.com/questions/91701/how-to-set-vlc-as-default-video-player
    cat /usr/share/applications/defaults.list | grep video
    cat /usr/share/applications/defaults.list | grep totem.desktop
    cat ~/.local/share/applications/mimeapps.list
    sudo sed -i 's/\(^.*\)video\(.*\)=totem.desktop/\1video\2=vlc.desktop/' /usr/share/applications/defaults.list
    sudo sed -i 's/\(^.*\)audio\(.*\)=totem.desktop/\audio\2=vlc.desktop/' /usr/share/applications/defaults.list
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
    # Latex
    sudo apt-get install -y texlive
    sudo apt-get install -y texlive
    sudo apt-get install -y texlive-base 
    sudo apt-get install -y texlive-extra-utils
    sudo apt-get install -y texlive-binaries
    sudo apt-get install -y texlive-latex-base
    sudo apt-get install -y texlive-latex-extra
    sudo apt-get install -y texlive-latex-recommended
    sudo apt-get install -y texlive-math-extra
    sudo apt-get install -y texlive-science
    sudo apt-get install -y texlive-bibtex-extra
    sudo apt-get install -y texlive-fonts-extra
    sudo apt-get install -y texlive-generic-recommended

    sudo apt-get install -y xindy

    #sudo apt-get install -y remmina 
    #sudo apt-get remove texlive-generic-extra
    #sudo apt-get install texlive-bibtex-extra -y
    #sudo apt-get install texlive-full -y

    # references
    # http://askubuntu.com/questions/207442/how-to-add-open-terminal-here-to-nautilus-context-menu
    #sudo apt-get install nautilus-open-terminal

    #texlive 2015
    # https://www.tug.org/texlive/acquire-netinstall.html
    cd ~/tmp
    wget http://mirror.ctan.org/systems/texlive/tlnet/install-tl-unx.tar.gz
    7z x install-tl-unx.tar.gz
    7z x install-tl-unx.tar
    #rm install-tl-unx.tar
    #cd ~/tmp/install-tl-20150902/
    cd install-tl-*
    #export TEXLIVE_INSTALL_PREFIX=/opt/texlive
    #export TEXDIR=/opt/texlive
    chmod +x install-tl
    sudo ./install-tl
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
    sudo apt-get install libsqlite3-dev 
    sudo apt-get install sqlite3
    sudo apt-get install libsqlite3
    sudo apt-get install python-apsw
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

#pip_upgrade()
#{
#     sudo pip install numpy --upgrade
#     sudo pip install Cython --upgrade
#     sudo pip install scipy --upgrade
#     sudo pip install pyzmq --upgrade
#     sudo pip install matplotlib --upgrade
#     sudo pip install scikit-learn --upgrade
#     sudo pip install ipython --upgrade
#}

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
}

install_cmake_latest()
{
    # Download latest by parsing webpage
    exec 42<<'__PYSCRIPT__'
import utool as ut
from six.moves import urllib
import urllib2
headers = { 'User-Agent' : 'Mozilla/5.0' }
req = urllib2.Request(r'https://cmake.org/download/', None, headers)
page = urllib2.urlopen(req)
page_str = page.read()

next = False
lines = page_str.split('\n')
for index, x in enumerate(lines):
    if next:
        print(x)
        import parse
        url_suffix = parse.parse('{foo}href="{href}"{other}', x)['href']
        url = r'https://cmake.org' + url_suffix
        break
    if 'Linux x86_64' in x:
        next = True
url = url.replace('.sh', '.tar.gz')
cmake_unzipped_fpath = ut.grab_zipped_url(url)
from os.path import join
install_prefix = ut.unixpath('~')
for dname in ['bin', 'doc', 'man', 'share']:
    install_dst = join(install_prefix, dname)
    install_src = join(cmake_unzipped_fpath, dname)
    ut.copy(install_src, install_dst)
print(cmake_unzipped_fpath)
__PYSCRIPT__
python /dev/fd/42 $@

    
    # http://www.cmake.org/download/
    #python -c "http://www.cmake.org/files/v3.0/cmake-3.0.2-Linux-i386.tar.gz"
    # +==================================================
    # SIMPLE WAY OF EXECUTING MULTILINE PYTHON FROM BASH
    # +--------------------------------------------------
    # Creates custom file descriptor that runs the script
    # References: http://superuser.com/questions/607367/raw-multiline-string-in-bash
    # http://stackoverflow.com/questions/2043453/executing-python-multi-line-statements-in-the-one-line-command-line
#    sudo apt-get remove cmake
#    exec 42<<'__PYSCRIPT__'
#import utool as ut
#from os.path import join
#cmake_zipped_url = 'http://www.cmake.org/files/v3.0/cmake-3.0.2-Linux-i386.tar.gz'
#cmake_unzipped_fpath = ut.grab_zipped_url(cmake_zipped_url)
#ut.vd(cmake_unzipped_fpath)
#install_prefix = ut.unixpath('~')
#for dname in ['bin', 'doc', 'man', 'share']:
#    install_dst = join(install_prefix, dname)
#    install_src = join(cmake_unzipped_fpath, dname)
#    ut.copy(install_src, install_dst)
#print(cmake_unzipped_fpath)
#__PYSCRIPT__
#python /dev/fd/42 $@


    # L_________________________________________________

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


install_workrave()
{
    # DOENT BUILD RIGHT
    sudo apt-get install libxtst-dev -y
    sudo apt-get install libxss-dev -y
    sudo apt-get install python-cheetah -y
    sudo apt-get install gnome-core-devel -y
    exec 42<<'__PYSCRIPT__'
import utool as ut
import os
from os.path import join
zipped_url = 'http://sourceforge.net/projects/workrave/files/workrave/1.10/workrave-1.10.tar.gz'
unzipped_fpath = ut.grab_zipped_url(zipped_url)
ut.vd(unzipped_fpath)
os.chdir(unzipped_fpath)
ut.cmd('./configure')
ut.cmd('make')

install_prefix = ut.unixpath('~')
for dname in ['bin', 'doc', 'man', 'share']:
    install_dst = join(install_prefix, dname)
    install_src = join(unzipped_fpath, dname)
    ut.copy(install_src, install_dst)
print(unzipped_fpath)
__PYSCRIPT__
python /dev/fd/42 $@

}

install_numba()
{
    # References: http://askubuntu.com/questions/588688/importerror-no-module-named-llvmlite-binding
    # References: http://askubuntu.com/questions/576510/error-while-trying-to-install-llvmlite-on-ubuntu-14-04
    sudo apt-get install libedit-dev -y
    sudo pip install enum34
    sudo -H pip install pip --upgrade
    sudo -H pip install llvmlite
    sudo -H pip install funcsig
    which llvm-config-3.5
    sudo ln -s llvm-config-3.5 /usr/bin/llvm-config
    sudo apt-get install libedit-dev -y
    export LLVM_CONFIG=/usr/bin/llvm-config-3.5
    sudo -H pip install llvmlite
    python -c "import numba"
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


#install_lyx()
#{
#    # Useless because it can't convert .tex to .lyx well
#    sudo add-apt-repository ppa:lyx-devel/release
#    sudo apt-get update
#    sudo apt-get install lyx -y
#}


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
}


setup_python3()
{
    sudo apt-get install python3-dev 
    sudo apt-get install python3-pip 

    sudo easy_install3 pip
    sudo pip3 install lockfile
    sudo pip3 install flask
    sudo pip3 install numpy
    sudo pip3 install scipy
    sudo pip3 install Pillow
    sudo pip3 install matplotlib
    sudo pip3 install statsmodels
    ut
    sudo python3 setup.py develop
    vt
    sudo python3 setup.py develop
    pt
    sudo python3 setup.py develop
    gt
    sudo python3 setup.py develop
    dt
    sudo python3 setup.py develop
    # setup pyflann3
    hes
    sudo python3 setup.py develop

    sudo pip install git+https://github.com/pwaller/pyfiglet

    python3 -c "import vtool"

    # set pip to python2.7
    sudo -H pip2.7 install pip -U --force-reinstall
    #ls -al /usr/local/bin/pip
    
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


install_pydio(){
    gvim   /etc/apt/sources.list
sudo sh -c 'cat >>  /etc/apt/sources.list  << EOL

# pydio manual stuff
deb http://dl.ajaxplorer.info/repos/apt stable main
deb-src http://dl.ajaxplorer.info/repos/apt stable main
EOL'
wget -O - http://dl.ajaxplorer.info/repos/charles@ajaxplorer.info.gpg.key | sudo apt-key add -

sudo apt-get update
sudo apt-get install pydio


cd ~/tmp
wget http://downloads.sourceforge.net/project/ajaxplorer/pydio-sync/java/0.8.4/PydioSync-0.8.4-Linux-x86_64-Jars.zip
7z x PydioSync-0.8.4-Linux-x86_64-Jars.zip

cd ~/tmp
wget https://pyd.io/resources/pydio6/data/public/pydiosync-linux-1-0-2-targz?dl=true\&file=/1e481dfadf/PydioSync-Linux-v1.0.2.tar.gz
cp pydiosync-linux-1-0-2-targz\?dl\=true\&file\=%2F1e481dfadf%2FPydioSync-Linux-v1.0.2.tar.gz PydioSync-Linux-v1.0.2.tar.gz
7z xz pydiosync-linux-1-0-2-targz\?dl\=true\&file\=%2F1e481dfadf%2FPydioSync-Linux-v1.0.2.tar.gz
7z xzvf PydioSync-Linux-v1.0.2.tar.gz
7z x PydioSync-Linux-v1.0.2.tar -o Pydio
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
