
install_aptgetters()
{
    # privacy
    sudo apt-get install pgpgpg
    # android phone camera reader mtpfs
    sudo apt-get install mtp-tools mtpfs
    # software center gmpt

    # Google PPA
    wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
    sudo sh -c 'echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list'
    sudo apt-get update

    sudo apt-get install google-chrome-stable
    sudo apt-get install libtiff5
    sudo apt-get install libtiff5-dev
}
make_ubuntu_symlinks()
{
    stty echo
    ln -s ~/local/scripts/ubuntu_scripts ~/scripts
    # For Hyrule
    ln -s /media/SSD_Extra ~/SSD_Extra
    ln -s /media/Store ~/Store
    ln -s /media/Store/data ~/data
}

make_python_aliases()
{
    export PYEXE=/usr/bin/python2.7
    # Command to get version
    #export PYEXE_ALT1_VERSION=$($PYTHON_BIN -c "import platform; print(platform.python_version()[0:3])")
    #export PYEXE_ALT2_VERSION=$($PYTHON_BIN -c "import platform; print(platform.python_version()[0:3]).replace('.', '')")
    #echo "PYEXE=$PYEXE"
    #echo "PYEXE_ALT1_VERSION=$PYEXE_ALT1_VERSION"
    #echo "PYEXE_ALT2_VERSION=$PYEXE_ALT2_VERSION"
    #2>&1 >/dev/null | echo | sed s/Python //g
    ## symlink for pip
    #sudo ln -s $PYEXE /usr/local/bin/python$PYEXE_ALT1_VERSION
    #sudo ln -s $PYEXE /usr/local/bin/python$PYEXE_ALT2_VERSION
    #sudo ln -s $PYEXE /usr/bin/python$PYEXE_ALT1_VERSION
    #sudo ln -s $PYEXE /usr/bin/python$PYEXE_ALT2_VERSION

    # Ubuntu tends to do things right
    sudo ln -s /usr/local/bin/pip2.7 /usr/local/bin/pip27
    sudo ln -s /usr/bin/python2.7 /usr/bin/python27
}

donot_lock_screen()
{
    gsettings set org.gnome.desktop.lockdown disable-lock-screen 'true'
}

update_locate()
{
    # Update the locate commannd
    sudo updatedb
}

install_packages()
{
    # For opencv
    sudo apt-get install openexr
    # For Lempisky Random Forsest Show
    #sudo apt-get install libgtk2.0-dev
    sudo apt-get install deluge
}

virtualbox_guest_postinstall()
{

    sudo apt-get install dkms 
    sudo apt-get update
    sudo apt-get upgrade
    # Mount VBoxGuestAdditions_4.3.8.iso and do autorun
    sudo apt-get install git -y

    git config --global user.name joncrall
    git config --global user.email crallj@rpi.edu
    git config --global push.default current

    gsettings set org.gnome.desktop.lockdown disable-lock-screen 'true'
}


install_virtualbox_additions()
{
    sudo apt-get install virtualbox-guest-additions-iso
    
    sudo apt-get update
    sudo apt-get install dkms build-essential linux-headers-generic
    
    sudo apt-get install build-essential linux-headers-$(uname -r)
    sudo apt-get install virtualbox-ose-guest-x11


    # setup virtualbox for ssh
    VBoxManage modifyvm virtual-ubuntu --natpf1 "ssh,tcp,,3022,,22"
    # To ssh to virtualserv
    #ssh -p 3022 user@127.0.0.1
    
}

virtual_init()
{
    # init on the virtual machine
    openssh-server

}

#config_clang()
#{
    ## INCOMPLETE
    ## use clang
    #sudo update-alternatives --config c++
#}

install_clang()
{
    # "update-alternatives --install" takes a link, name, path and priority.
    sudo update-alternatives --install /usr/bin/gcc gcc ~/data/clang3.3/bin/clang 50
    sudo update-alternatives --install /usr/bin/g++ g++ ~/data/clang3.3/bin/clang++ 50
    sudo update-alternatives --install /usr/bin/cpp cpp-bin /usr/bin/cpp-4.6 100
}

install_gcc()
{
    # "update-alternatives --install" takes a link, name, path and priority.
    sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-4.6 100
    sudo update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-4.6 100
    sudo update-alternatives --install /usr/bin/cpp cpp-bin /usr/bin/cpp-4.6 100
}

install_gdrive()
{
    sudo add-apt-repository ppa:alessandro-strada/ppa
    sudo apt-get update
    sudo apt-get install google-drive-ocamlfuse
}

install_dark_theme()
{
    sudo add-apt-repository ppa:noobslab/themes
    sudo apt-get update
    sudo apt-get install mediterranean-theme
}


other_fonts()
{
    # http://zevv.nl/play/code/zevv-peep/
    # NEEP
    apt-get install xfonts-jmk
    rm /etc/fonts/conf.d/70-no-bitmaps.conf
    fc-cache -f -v

    # Enable bitmap fonts
    cd /etc/fonts/conf.d/
    sudo rm /etc/fonts/conf.d/10* && sudo rm -rf 70-no-bitmaps.conf && sudo ln -s ../conf.avail/70-yes-bitmaps.conf .
    sudo dpkg-reconfigure fontconfig

    wget http://zevv.nl/play/code/zevv-peep/zevv-peep-iso8859-15-08x16.bdf
    sudo cp zevv-peep-iso8859-15-08x16.bdf /usr/share/fonts/X11/misc
    xset +fp /usr/share/fonts/X11/misc
}


make_rcfiles()
{
     sh -c 'cat >> ~/.screenrc << EOL
    def scrollback 99999
EOL'
    echo 
}
  

purge_opencv()
{
sudo rm -rf /usr/local/lib/libopencv*
sudo rm -rf /usr/local/bin/opencv*
sudo rm -rf /usr/local/include/opencv
sudo rm -rf /usr/local/include/opencv2
sudo rm -rf /usr/local/share/OpenCV
}
 
purge_pil()
{
sudo rm -rf /usr/lib/python2.7/dist-packages/PIL
sudo rm -rf /usr/lib/pyshared/python2.7/PIL
sudo rm -rf /usr/share/pyshared/PIL
sudo rm -rf /usr/lib/python2.7/dist-packages/PIL/
sudo rm -rf /usr/lib/python2.7/dist-packages/PIL
sudo rm -rf /usr/lib/python2.7/dist-packages/PIL.pth
}    

purge_sqlite3()
{
sudo find /usr/lib -iname '*sqlite3*' 
sudo find /usr/include -iname '*sqlite3*'

sudo find / -iname '*sqlite3*'


sudo ldconfig -p | grep sqlite3

ls -il /usr/local/lib/libsqlite3.so.0 && ls -il /usr/local/lib/libsqlite3.so &&
    ls -il /usr/lib/i386-linux-gnu/libsqlite3.so.0 && ls -il /usr/lib/i386-linux-gnu/libsqlite3.so


sudo mv /usr/local/lib/libsqlite3.so ~/tmp/.bad_sqlitelib
sudo rm /usr/local/include/sqlite3ext.h
sudo rm /usr/local/include/sqlite3.h
sudo rm /usr/local/bin/sqlite3
sudo rm /usr/local/lib/libsqlite3.so.0.8.6
sudo rm /usr/local/lib/libsqlite3.la
sudo rm /usr/local/lib/libsqlite3.so.0
sudo rm /usr/local/lib/libsqlite3.a

sqlite3 --version

}
