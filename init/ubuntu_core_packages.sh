
index_opencv_with_ctags()
{
    #References:
    #    http://sourceforge.net/p/ctags/mailman/message/20916991/
    ctags -R -ICVAPI --c++-kinds=+p --fields=+iaS --extra=+q --language-force=c++ /usr/include/opencv/
}
clean_for_upgrade()
{
    # msg: Please free at least an additional 68,3 M of disk space on '/boot'. Empty your trash and remove temporary packages of former installations using 'sudo apt-get clean'.
    # References: http://askubuntu.com/questions/495941/software-updater-needs-more-disk-space
    ubuntu-tweak
}

setup_ibeis()
{
    source ~/local/init/freshstart_ubuntu.sh
    setup_ibeis
}

ypackin()
{
    sudo pip install $*
}
packin()
{
    sudo apt-get install -y $*
}


install_core()
{
    sudo apt-get update -y 
    sudo apt-get upgrade -y
    # Git
    sudo apt-get install -y git

    # Vim
    sudo apt-get install -y vim
    sudo apt-get install -y vim-gtk

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
    sudo apt-get install -y screen
    sudo apt-get install -y synaptic
    sudo apt-get install -y astyle

    # 
    sudo apt_get install libhighgui2.4
    sudo apt_get install libcv2.4
    sudo apt_get install libcvaux-dev
    sudo apt_get install opencv-doc


    # sqlite db  editor
    #sudo apt-get install sqliteman
    sudo apt-get install -y sqlitebrowser 
    #References: http://stackoverflow.com/questions/7454796/taglist-exuberant-ctags-not-found-in-path
    sudo apt-get install -y exuberant-ctags 
    
}

install_synergy()
{
    sudo apt-get install synergy -y

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
    # Zotero
    sudo add-apt-repository ppa:smathot/cogscinl
    sudo apt-get update
    sudo apt-get install -y zotero-standalone 
}

install_core_extras()
{
    # Not commonly used but frequently forgotten
    sudo apt-get install -y okular
    sudo apt-get install -y subversion
    sudo apt-get install -y filezilla
    sudo apt-get install -y gitg
    sudo apt-get install -y sysstat

    # References: https://help.ubuntu.com/community/Skype
    #sudo dpkg --add-architecture i386
    sudo add-apt-repository "deb http://archive.canonical.com/ $(lsb_release -sc) partner"
    sudo apt-get update 
    sudo apt-get install skype -y
    #sudo apt-get install -y skype


    sudo apt-get install graphviz -y
    sudo apt-get install python-pydot -y
    sudo apt-get install imagemagick -y

    sudo apt-get install dia-gnome -y
    sudo apt-get install inkscape -y
}

install_evaluating()
{
    #References: https://github.com/kayhayen/Nuitka#use-case-3-package-compilation
    sudo apt-get install nuitka
    nuitka --module ibeis --recurse-directory=ibeis
    nuitka --recurse-all main.py
    
}

install_ppa_extras()
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
    sudo apt-get install -y spotify-client
}


svn_repos()
{
    # https://code.google.com/p/groupsac/source/checkout 
    svn checkout http://groupsac.googlecode.com/svn/trunk/ groupsac-read-only
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

    sudo apt-get install -y remmina 

    #sudo apt-get remove texlive-generic-extra
    #sudo apt-get install texlive-bibtex-extra -y
    #sudo apt-get install texlive-full -y
}


install_python()
{
    # Python
    sudo apt-get install -y python-tk
    sudo pip install jedi
    sudo pip install pep8
    sudo pip install autopep8
    sudo pip install flake8
    sudo pip install pylint
    sudo pip install line_profiler
    #sudo pip install Xlib
    sudo pip install virtualenv
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

install_cuda_prereq()
{
	sudo apt-get install -y libprotobuf-dev
    sudo apt-get install -y libleveldb-dev 
    sudo apt-get install -y libsnappy-dev 
    sudo apt-get install -y libopencv-dev 
    sudo apt-get install -y libboost-all-dev 
    sudo apt-get install -y libhdf5-serial-dev
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
    sudo apt-get install -y python-pip
    sudo apt-get install -y python-numpy
    sudo apt-get install -y python-pillow
}


install_xlib()
{
    # for gnome-shell-grid
    sudo pip install svn+https://python-xlib.svn.sourceforge.net/svnroot/python-xlib/trunk/
    sudo apt-get install -y python-wnck 
    sudo apt-get install -y wmctrl 
    packin xdotool
}

pip_upgrade()
{
     sudo pip install numpy --upgrade
     sudo pip install Cython --upgrade
     sudo pip install scipy --upgrade
     sudo pip install pyzmq --upgrade
     sudo pip install matplotlib --upgrade
     sudo pip install scikit-learn --upgrade
     sudo pip install ipython --upgrade
     
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
}

install_cmake_latest()
{
    # http://www.cmake.org/download/
    python -c "http://www.cmake.org/files/v3.0/cmake-3.0.2-Linux-i386.tar.gz"
    # +==================================================
    # SIMPLE WAY OF EXECUTING MULTILINE PYTHON FROM BASH
    # +--------------------------------------------------
    # Creates custom file descriptor that runs the script
    # References: http://superuser.com/questions/607367/raw-multiline-string-in-bash
    sudo apt-get remove cmake
    exec 42<<'__PYSCRIPT__'
import utool as ut
from os.path import join
cmake_zipped_url = 'http://www.cmake.org/files/v3.0/cmake-3.0.2-Linux-i386.tar.gz'
cmake_unzipped_fpath = ut.grab_zipped_url(cmake_zipped_url)
ut.vd(cmake_unzipped_fpath)
install_prefix = ut.unixpath('~')
for dname in ['bin', 'doc', 'man', 'share']:
    install_dst = join(install_prefix, dname)
    install_src = join(cmake_unzipped_fpath, dname)
    ut.copy(install_src, install_dst)
print(cmake_unzipped_fpath)
__PYSCRIPT__
python /dev/fd/42 $@


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


install_lyx{
    # Useless because it can't convert .tex to .lyx well
    sudo add-apt-repository ppa:lyx-devel/release
    sudo apt-get update
    sudo apt-get install lyx -y
}
