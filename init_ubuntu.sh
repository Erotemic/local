
make_ubuntu_symlinks()
{
    ln -s ~/local/scripts/ubuntu_scripts ~/scripts
    # For Hyrule
    ln -s /media/SSD_Extra ~/SSD_Extra
    ln -s /media/Store ~/Store
    ln -s /media/Store/data ~/data
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


install_python()
{
    sudo pip install pillow
}

install_gdrive()
{
    sudo add-apt-repository ppa:alessandro-strada/ppa
    sudo apt-get update
    sudo apt-get install google-drive-ocamlfuse
}
