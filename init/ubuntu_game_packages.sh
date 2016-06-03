
ubuntu_wine_prereqs(){

    sudo apt-get install dpkg-dev
    sudo apt-get install libwebkitgtk-dev -y
    sudo apt-get install libtiff-dev libjpeg-dev
    sudo apt-get install libgtk2.0-dev
    sudo apt-get install libgtk2.0-dev -y
    sudo apt-get install libsdl1.2-dev -y
    sudo apt-get install libgstreamer-plugins-base0.10-dev -y
    sudo apt-get install libnotify-dev
    sudo apt-get install freeglut3
    sudo apt-get install freeglut3-dev

    sudo apt-get install python-wxgtk2.8
    python -c "import wxversion"
    python2.6 -c "import wxversion"
    python3 -c "import wxversion"

    sudo pip install --upgrade --trusted-host wxpython.org --pre -f http://wxpython.org/Phoenix/snapshot-builds/ wxPython_Phoenix 

    python -c "import wx; print(wx.VERSION_STRING)"
    

    sudo apt-get install playonlinux

    sudo add-apt-repository ppa:ubuntu-wine/ppa -y
    sudo apt-get update
    sudo apt-get install -y wine1.7
    #sudo apt-get install wine -y

    # Prevents
    # p11-kit: couldn't load module: /usr/lib/i386-linux-gnu/pkcs11/p11-kit-trust.so: 
    # /usr/lib/i386-linux-gnu/pkcs11/p11-kit-trust.so: cannot open shared object file: No such file or directory
    sudo apt-get install libp11-kit-gnome-keyring:i386
    sudo apt-get install winbind


    # Turn on trace debugging
    ls -al  /etc/sysctl.d/10-ptrace.conf
    # Change value from 1 to 0
    #kernel.yama.ptrace_scope
    sudo gvim /etc/sysctl.d/10-ptrace.conf
}

get_latest_winetricks(){
    # Install Winetricks
    # https://github.com/Winetricks/winetricks/issues/500
    cd ~/tmp
    rm winetricks
    wget https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks
    chmod +x ~/tmp/winetricks
}


new_wine32_install(){
    # Remove old wine directory
    #rm -rf ~/cache/winetricks
    rm -rf $HOME/.wine32-dotnet45

    # Make new WINEPREFIX 
    export WINEPREFIX="$HOME/.wine32-dotnet45" 
    export WINEARCH=win32
    WINEPREFIX="$HOME/.wine32-dotnet45" 
    WINEARCH=win32

    wineboot -u
    # Run and exit
    #winecfg

    # https://www.bountysource.com/issues/27630898-dotnet30-fails-to-install-on-32-bit-prefix-ubuntu
    winetricks -q --unattended windowscodecs msxml3 mfc42 dotnet45 corefonts
    
    #bash winetricks -q dotnet30 
    # Had to do a manual download in this process
    ~/tmp/winetricks -q corefonts
    ~/tmp/winetricks -q dotnet452
    ~/tmp/winetricks -q dotnet40
    ~/tmp/winetricks -q dotnet45 corefonts

    winecfg
    # Enable virtual desktop under graphics
    mkdir -p ~/.cache/winetricks/msxml3

    # Download
    # http://download.cnet.com/Microsoft-XML-Parser-MSXML-3-0-Service-Pack-7-SP7/3000-7241_4-10731613.html
    cp ~/Downloads/msxml3.msi ~/.cache/winetricks/msxml3

    #wine --exec ~/.cache/winetricks/msxml3


    winetricks dotnet45

    bash winetricks dotnet45 corefonts
}


dotnet_winetricks(){
    # dotnet 4.5 with wine tricsks
    # https://appdb.winehq.org/objectManager.php?sClass=version&iId=25478
    cd ~/tmp
    wget https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks
    bash winetricks dotnet45 corefonts

}


install_hearthstone()
{
    #https://www.reddit.com/r/hearthstone/comments/23fwzq/tutorial_how_to_play_hearthstone_on_linux_via_wine/

    #http://www.battle.net/download/getInstallerForGame?os=win&locale=enUS&version=LIVE&gameProgram=HEARTHSTONE
    cd ~/tmp
    wget "http://www.battle.net/download/getInstallerForGame?os=win&locale=enUS&version=LIVE&gameProgram=HEARTHSTONE" -O setup_hearthstone.exe
    utget "http://www.battle.net/download/getInstallerForGame?os=win&locale=enUS&version=LIVE&gameProgram=HEARTHSTONE"

    # http://us.battle.net/hearthstone/en/forum/topic/13595239895

    # Get .Net
    #https://github.com/Epix37/Hearthstone-Deck-Tracker/issues/1164
    wget http://winetricks.googlecode.com/svn/trunk/src/winetricks
    bash winetricks dotnet45

    #sudo apt-get install mono-complete
    sudo apt-get install mono-vbnc

    # Hearthstone arena helper
    # https://github.com/rembound/Arena-Helper#how-to-install

    wget https://github.com/Epix37/Hearthstone-Deck-Tracker/releases/download/v0.13.17/Hearthstone.Deck.Tracker-v0.13.17.zip


    cd ~/tmp
    wget https://github.com/rembound/Arena-Helper/releases
    wget https://github.com/rembound/Arena-Helper/releases/download/0.6.8/ArenaHelper.v0.6.8.zip
    7z x Hearthstone.Deck.Tracker-v*.zip
    ls ./Hearthstone\ Deck\ Tracker/
    chmod +x ./Hearthstone\ Deck\ Tracker/*.exe
    mono ./Hearthstone\ Deck\ Tracker/Hearthstone\ Deck\ Tracker.exe
    "Hearthstone Deck Tracker"


}


install_cockatrice()
{
    # https://www.reddit.com/r/Cockatrice/comments/2prlnx/can_anyone_eli5_how_to_install_on_linux/
    code
    sudo apt-get install build-essential clang libqt4-dev -y
    sudo apt-get install libprotobuf-dev qtmobility-dev -y
    sudo apt-get install protobuf-compiler -y
    git clone https://github.com/Cockatrice/Cockatrice
    cd ~/code/Cockatrice
    mkdir -p build
    cd build
    cmake .. -DWITH_QT4=1 -DWITH_SERVER=0 -DWITH_CLIENT=1 -DWITH_ORACLE=1 -DCMAKE_INSTALL_PREFIX=~
    make -j9
    make install
}
