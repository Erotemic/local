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
}

install_core_extras()
{
    # Not commonly used but frequently forgotten
    sudo apt-get install -y okular
    sudo apt-get install -y subversion
    sudo apt-get install -y filezilla
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
 
install_spotify()
{
    #cat /etc/apt/sources.list
    sudo sh -c 'echo "deb http://repository.spotify.com stable non-free" >> /etc/apt/sources.list'
    sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 94558F59
    sudo apt-get update
    sudo apt-get install -y spotify-client
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


# Cleanup
#sudo apt-get remove jasper -y

