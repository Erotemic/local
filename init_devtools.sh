install_mac()
{
    sudo port install $1
}

install()
{
    install_mac $@
}

install cmake

