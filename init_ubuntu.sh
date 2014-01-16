# Update the locate commannd
sudo updatedb

# For opencv
sudo apt-get install openexr

# use clang
sudo update-alternatives --config c++

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
