


install_hearthstone()
{
    #https://www.reddit.com/r/hearthstone/comments/23fwzq/tutorial_how_to_play_hearthstone_on_linux_via_wine/

    #http://www.battle.net/download/getInstallerForGame?os=win&locale=enUS&version=LIVE&gameProgram=HEARTHSTONE
    cd ~/tmp
    wget "http://www.battle.net/download/getInstallerForGame?os=win&locale=enUS&version=LIVE&gameProgram=HEARTHSTONE" -O setup_hearthstone.exe
    utget "http://www.battle.net/download/getInstallerForGame?os=win&locale=enUS&version=LIVE&gameProgram=HEARTHSTONE"

    # http://us.battle.net/hearthstone/en/forum/topic/13595239895

    sudo apt-get install playonlinux
    

    sudo add-apt-repository ppa:ubuntu-wine/ppa -y
    sudo apt-get update
    sudo apt-get install -y wine1.7
    #sudo apt-get install wine -y
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
