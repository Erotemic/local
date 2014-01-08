if [[ "$OSTYPE" == "darwin"* ]]; then
    install()
    {
        sudo port install $1
    }
else
    install()
    {
        sudo apt-get install $1
    }
fi

install cmake

