install()
{
    if [[ "$OSTYPE" == "darwin"* ]]; then
        sudo port install $1
    else
        sudo apt-get install $1
    fi
}


install cmake
