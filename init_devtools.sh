install()
{
    if [[ "$OSTYPE" == "darwin"* ]]; then
        sudo port install $1
    else
        sudo apt-get install $1
    fi
}

install cmake

# Macports stuff
if [[ "$OSTYPE" == "darwin"* ]]; then
install py27-ipython
sudo port select --set ipython ipython27
fi
