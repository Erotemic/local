
wine_1_9()
{
    # http://ubuntuhandbook.org/index.php/2020/01/install-wine-5-0-stable-ubuntu-18-04-19-10/

    sudo dpkg --add-architecture i386

    wget https://dl.winehq.org/wine-builds/Release.key
    sudo apt-key add Release.key

    wget -qO - https://dl.winehq.org/wine-builds/winehq.key | sudo apt-key add -

    wget -nc https://dl.winehq.org/wine-builds/winehq.key
    sudo apt-key add winehq.key


    # For pre 19.10
    sudo add-apt-repository ppa:cybermax-dexter/sdl2-backport -y
    sudo apt-add-repository "deb https://dl.winehq.org/wine-builds/ubuntu $(lsb_release -cs) main" -y
    sudo apt update && sudo apt install --install-recommends winehq-stable -y


    #sudo apt update -y
    #sudo apt-add-repository 'https://dl.winehq.org/wine-builds/ubuntu/'

    #sudo add-apt-repository ppa:wine/wine-builds -y
    #sudo apt-get update -y
    #sudo apt-get install --install-recommends wine-staging -y
    #sudo apt-get install wine-staging -y
    ##sudo apt-get install winehq-staging
    #sudo apt-get install winehq-devel
    #sudo apt-get install wine-devel

    #sudo apt-get remove winehq-staging
    #sudo apt-get remove winehq-staging
    #sudo add-apt-repository --remove ppa:wine/wine-builds
}

cleanup_sources_list(){
    sudo apt install python3-apt
    sudo python3 -m pip install git+https://github.com/Erotemic/aptsources-cleanup.git
    #https://askubuntu.com/questions/760896/how-can-i-fix-apt-error-w-target-packages-is-configured-multiple-times
}

starcraft2_2020(){
    __heredoc__ = """
    https://www.reddit.com/r/starcraft/comments/9ugzrz/definitive_linux_sc2_guide/
    https://lutris.net/games/starcraft-ii/
    """
    #sudo apt-get install libvulkan1 libvulkan1:i386
    ##sudo apt-get install mesa-vulkan-drivers mesa-vulkan-drivers:i386

    # Install lutris
    sudo add-apt-repository ppa:lutris-team/lutris -y
    sudo apt-get update -y
    sudo apt-get install lutris -y

    # Change preferences so games are downloaded to /data/lutris or wherever
    # you have space

    # See https://github.com/lutris/lutris/wiki/Installing-drivers#installing-vulkan
    # for 18.04 (needs update for 19.04 / 20.04)
    #sudo add-apt-repository ppa:kisak/kisak-mesa -y
    ##sudo add-apt-repository --remove ppa:kisak/kisak-mesa
    #sudo apt install ppa-purge
    #sudo ppa-purge ppa:kisak/kisak-mesa

    manual_steps="
    navigate here: https://lutris.net/games/starcraft-ii/
    click install
    "

    sudo dpkg --add-architecture i386
    sudo apt update && sudo apt upgrade -y
}

starcraft2_2023_did_not_work(){
    __heredoc__ = """
    https://www.reddit.com/r/starcraft/comments/9ugzrz/definitive_linux_sc2_guide/
    https://lutris.net/games/starcraft-ii/
    """
    #sudo apt-get install libvulkan1 libvulkan1:i386
    ##sudo apt-get install mesa-vulkan-drivers mesa-vulkan-drivers:i386

    # Remove old lutris
    #sudo apt-get remove lutris -y
    #sudo add-apt-repository --remove ppa:lutris-team/lutris -y
    #sudo apt-get update
    #sudo apt-get update -y

    #sudo add-apt-repository --remove ppa:lutris-team/lutris-staging -y
    #sudo apt-get update
    #sudo apt-get update -y
    #sudo apt-get install lutris -y
    #sudo apt-get remove lutris -y

    #git clone https://github.com/lutris/lutris.git $HOME/code/lutris
    #cd $HOME/code/lutris

    #sudo apt install python3-yaml python3-requests python3-pil python3-gi python3-gi-cairo \
    #  gir1.2-gtk-3.0 gir1.2-gnomedesktop-3.0 gir1.2-webkit2-4.0 \
    #  gir1.2-notify-0.7 psmisc cabextract unzip p7zip curl fluid-soundfont-gs \
    #  x11-xserver-utils python3-evdev libc6-i386  libgirepository1.0-dev \
    #  python3-setproctitle python3-distro

    #lib32gcc1

    #virtualenv --system-site-packages $HOME/code/lutris/venv-lutris
    #source $HOME/code/lutris/venv-lutris/bin/activate
    #cd $HOME/code/lutris
    #python3 setup.py install
    #
    flatpak install flathub com.github.tchx84.Flatseal
    flatpak run com.github.tchx84.Flatseal



    flatpak install flathub net.lutris.Lutris
    sudo flatpak override net.lutris.Lutris --filesystem=host
    flatpak run net.lutris.Lutris
    # user, -y


    # Change preferences so games are downloaded to /data/lutris or wherever
    # you have space

    # See https://github.com/lutris/lutris/wiki/Installing-drivers#installing-vulkan
    # for 18.04 (needs update for 19.04 / 20.04)
    #sudo add-apt-repository ppa:kisak/kisak-mesa -y
    ##sudo add-apt-repository --remove ppa:kisak/kisak-mesa
    #sudo apt install ppa-purge
    #sudo ppa-purge ppa:kisak/kisak-mesa

    manual_steps="
    navigate here: https://lutris.net/games/starcraft-ii/
    click install
    "

    sudo dpkg --add-architecture i386
    sudo apt update && sudo apt upgrade -y

    export DXVK_FILTER_DEVICE_NAME="GeForce RTX 3090"
    #DXVK_FILTER_DEVICE_NAME="GeForce RTX 3090" lutris
    DXVK_FILTER_DEVICE_NAME="GeForce RTX 3090" lutris -d
}

starcraft2_OLD(){
    # https://askubuntu.com/questions/846651/installing-starcraft-2-playonlinux
    # https://gaming.stackexchange.com/questions/341111/is-there-a-painless-way-to-run-starcraft-2-on-linux
    # https://www.reddit.com/r/starcraft/comments/5w0wyv/how_to_play_sc2_on_linux_a_full_walk_through/
    sudo apt install ttf-mscorefonts-installer -y

    cd ~/Downloads
    # broken link
    wget -O Battle.net-Setup.exe "https://www.battle.net/download/getInstallerForGame?os=win&locale=enUS&version=LIVE&gameProgram=BATTLENET_APP"

    # /home/joncrall/Downloads/StarCraft-II-Setup.exe

    # DOUBLE CLICKED .EXE AND DID MANUAL SETUP



    sudo add-apt-repository ppa:alexlarsson/flatpak -y
    sudo apt-get update -y
    sudo apt install --install-recommends flatpak
    flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
    flatpak remote-add --if-not-exists winepak https://dl.winepak.org/repo/winepak.flatpakrepo
    flatpak install winepak com.blizzard.StarCraft2


    # winecfg
    # Graphics -> Emulate a virtual desktop @ 1920x1080

    sudo apt-get install winetricks winbind
    sudo apt-get purge winetricks
    winetricks corefonts vcrun2005 vcrun2008 vcrun2015
}

get_latest_winetricks(){
    # Install Winetricks
    # https://github.com/Winetricks/winetricks/issues/500
    cd ~/tmp
    rm winetricks
    wget https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks
    chmod +x ~/tmp/winetricks
    ~/tmp/winetricks update-self
    sudo cp -v winetricks /usr/local/bin
    # http://superuser.com/questions/739498/how-to-add-dll-override-to-wine-config-from-command-lin
}

reinstall_hearthstone(){
    # https://www.reddit.com/r/hearthstone/comments/4uspc8/are_other_linux_users_having_problems_with/
    export WINEPREFIX="$HOME/.wine"
    WINEPREFIX="$HOME/.wine"
    wineboot -u

    wintricks vcrun2015

    # DOWNLOAD Installer
    # http://www.battle.net/download/getInstallerForGame?os=win&locale=enUS&version=LIVE&gameProgram=HEARTHSTONE
    wine ~/Downloads/Hearthstone-Setup.exe

    # Overrides
    #export WINEDLLOVERRIDES="api-ms-win-crt-runtime-l1-1-0.dll,api-ms-win-crt-stdio-l1-1-0.dll,ucrtbase,vcruntime140"
    #w_override_dlls disabled "api-ms-win-crt-runtime-l1-1-0.dll,api-ms-win-crt-stdio-l1-1-0.dll,ucrtbase,vcruntime140"
#    cat > temp-override-dll.reg <<_EOF_
#REGEDIT4

#[HKEY_CURRENT_USER\Software\Wine\DllOverrides]
#"api-ms-win-crt-runtime-l1-1-0.dll"=disabled
#"api-ms-win-crt-stdio-l1-1-0.dll"=disabled
#"ucrtbase"=disabled
#"vcruntime140"=disabled
#_EOF_
#    #wine cmd /c regedit /S temp-override-dll.reg
#    wine cmd /c regedit temp-override-dll.reg
    #winepreopts=(env PULSE_LATENCY_MSEC=60 WINEPREFIX="${wineprefixprefolder}/wine" WINEDLLOVERRIDES="msvcp100=n,b;api-ms-win-crt-runtime-l1-1-0=n,b;api-ms-win-crt-heap-l1-1-0=n,b;api-ms-win-crt-locale-l1-1-0=n,b;api-ms-win-crt-stdio-l1-1-0=n,b;ucrtbase=n,b;vcruntime140=n,b;api-ms-win-crt-convert-l1-1-0=n,b;api-ms-win-crt-time-l1-1-0=n,b;")
    #winepostopts=(-opengl)
    #"${winepreopts[@]}" wine start 'C:\users\Public\Desktop\StarCraft II.lnk' "${winepostopts[@]}" 2&>>/dev/null &


}

new_wine32_install(){
    # References:
    # https://forum.winehq.org/viewtopic.php?f=8&t=24145
    # http://ubuntuforums.org/showthread.php?t=2300076
    # https://www.bountysource.com/issues/27630898-dotnet30-fails-to-install-on-32-bit-prefix-ubuntu
    # http://askubuntu.com/questions/783211/cant-install-dotnet45-with-winetricks-on-ubuntu-14-04

    #rm -rf ~/cache/winetricks

    # Start fresh with a new wine directory
    rm -rf $HOME/.wine32-dotnet45

    # Make new WINEPREFIX
    export WINEPREFIX="$HOME/.wine32-dotnet45"
    export WINEARCH=win32
    WINEPREFIX="$HOME/.wine32-dotnet45"
    WINEARCH=win32

    echo "WINEARCH=$WINEARCH"
    echo "WINEPREFIX=$WINEPREFIX"

    echo 0 | sudo tee /proc/sys/kernel/yama/ptrace_scope

    # Initial configuration of new wine prefix
    wineboot -u
    # Run and exit
    #winecfg
    ~/tmp/winetricks -q dotnet45 corefonts

    ~/tmp/winetricks -q --unattended windowscodecs msxml3 mfc42
    ~/tmp/winetricks -q --unattended corefonts
    ~/tmp/winetricks -q --unattended dotnet45


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

    ~/tmp/winetricks -q dotnet45

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
    #export WINEPREFIX="$HOME/.wine32-dotnet45"
    #export WINEARCH=win32
    #WINEPREFIX="$HOME/.wine32-dotnet45"
    #WINEARCH=win32
    #export WINEPREFIX="$HOME/.wine32-dotnet45"
    #export WINEARCH=win32
    #WINEPREFIX="$HOME/.wine32-dotnet45"
    #WINEARCH=win32
    export WINEPREFIX="$HOME/.wine"
    WINEPREFIX="$HOME/.wine"
    # https://www.reddit.com/r/hearthstone/comments/23fwzq/tutorial_how_to_play_hearthstone_on_linux_via_wine/

    # rm -rf .wine
    # wineboot -u

    cd ~/tmp
    rm winetricks
    wget https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks
    chmod +x ~/tmp/winetricks

    # http://www.battle.net/download/getInstallerForGame?os=win&locale=enUS&version=LIVE&gameProgram=HEARTHSTONE
    #utget "http://www.battle.net/download/getInstallerForGame?os=win&locale=enUS&version=LIVE&gameProgram=HEARTHSTONE"
    cd ~/tmp
    wget "http://www.battle.net/download/getInstallerForGame?os=win&locale=enUS&version=LIVE&gameProgram=HEARTHSTONE" -O setup_hearthstone.exe
    chmod +x setup_hearthstone.exe

    wine ~/Downloads/Hearthstone-Setup.exe
    wine ~/Downloads/Hearthstone-Setup.exe

    # http://us.battle.net/hearthstone/en/forum/topic/13595239895

    # Get .Net
    #https://github.com/Epix37/Hearthstone-Deck-Tracker/issues/1164
    #bash winetricks dotnet452

    cd "/home/joncrall/.wine/drive_c/Program Files (x86)/Hearthstone"
    ./Hearthstone.exe
    # Unhandled exception: unimplemented function api-ms-win-crt-time-l1-1-0.dll._W_Gettnames called in 32-bit code
    cd "/home/joncrall/.wine/drive_c/Program Files (x86)/Battle.net"
    ./Battle.net.exe
    wine "/home/joncrall/.wine/drive_c/Program Files (x86)/Battle.net/Battle.net Launcher.exe"

    #sudo apt-get install mono-complete
    #sudo apt-get install mono-vbnc

    # Hearthstone arena helper
    # https://github.com/rembound/Arena-Helper#how-to-install

    #wget https://github.com/rembound/Arena-Helper/releases/download/0.8.0/ArenaHelper.v0.8.0.zip
    #wget https://github.com/HearthSim/Hearthstone-Deck-Tracker/releases/download/v0.15.3/Hearthstone.Deck.Tracker-v0.15.3.zip
    #rm -rf ~/tmp/Hearthstone\ Deck\ Tracker
    #7z x Hearthstone.Deck.Tracker-v0.15.3.zip
    #chmod +x ~/tmp/Hearthstone\ Deck\ Tracker/Hearthstone\ Deck\ Tracker.exe
    #wine ~/tmp/Hearthstone\ Deck\ Tracker/Hearthstone\ Deck\ Tracker.exe
    ##wget https://github.com/Epix37/Hearthstone-Deck-Tracker/releases/download/v0.13.17/Hearthstone.Deck.Tracker-v0.13.17.zip

    # Autobuild arena tracker
    cd ~/code/Arena-Tracker
    git pull --rebase
    qmake ArenaTracker.pro -r -spec linux-g++
    cd ~/code/build-ArenaTracker-Desktop_Qt_5_6_1_GCC_64bit-Release
    make -j9



    #cd ~/tmp
    #wget https://github.com/rembound/Arena-Helper/releases
    #wget https://github.com/rembound/Arena-Helper/releases/download/0.6.8/ArenaHelper.v0.6.8.zip
    #7z x Hearthstone.Deck.Tracker-v*.zip
    #ls ./Hearthstone\ Deck\ Tracker/
    #chmod +x ./Hearthstone\ Deck\ Tracker/*.exe
    #mono ./Hearthstone\ Deck\ Tracker/Hearthstone\ Deck\ Tracker.exe
    #"Hearthstone Deck Tracker"

    #https://github.com/Winetricks/winetricks/issues/575
    #~/tmp/winetricks -q vcrun2015
}


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
    sudo apt-get install python-wxversion
    sudo apt-get install python-wxpython

    python -c "import wxversion"
    python2.6 -c "import wxversion"
    python3 -c "import wxversion"

    sudo pip install --upgrade --trusted-host wxpython.org --pre -f http://wxpython.org/Phoenix/snapshot-builds/ wxPython_Phoenix
    sudo -H pip install --upgrade --pre -f http://wxpython.org/Phoenix/snapshot-builds/ --trusted-host wxpython.org wxPython_Phoenix


    python -c "import wx; print(wx.VERSION_STRING)"


    sudo apt-get install playonlinux
    sudo apt-get remove playonlinux

    sudo add-apt-repository ppa:ubuntu-wine/ppa -y
    sudo apt-get update
    #sudo apt-get install -y wine1.7
    sudo apt-get install -y wine1.8
    #sudo apt-get install wine -y

    # Prevents
    # p11-kit: couldn't load module: /usr/lib/i386-linux-gnu/pkcs11/p11-kit-trust.so:
    # /usr/lib/i386-linux-gnu/pkcs11/p11-kit-trust.so: cannot open shared object file: No such file or directory
    sudo apt-get install libp11-kit-gnome-keyring:i386
    sudo apt-get install winbind


    # Turn on trace debugging
    ls -al  /etc/sysctl.d/10-ptrace.conf
    cat /etc/sysctl.d/10-ptrace.conf
    # Change value from 1 to 0
    #kernel.yama.ptrace_scope
    sudo gvim /etc/sysctl.d/10-ptrace.conf
}

linux_arena_tracker(){
    # https://github.com/supertriodo/Arena-Tracker
    cd ~/tmp
    https://github.com/Itseez/opencv/archive/2.4.13.zip
    7z x opencv-2.4.13.zip
    mv opencv-2.4.13 ~/code/Arena-Tracker/

    # Build old opencv for arena tracker
    cd ~/code/Arena-Tracker/opencv-2.4.13
    mkdir -p build
    cd build
    cmake .. -DCMAKE_INSTALL_PREFIX=/home/joncrall/code/Arena-Tracker/opencv_install
    make -j9
    make install

    mkdir "/home/joncrall/.wine/drive_c/Program Files (x86)/Hearthstone/Logs"
    touch "/home/joncrall/.wine/drive_c/Program Files (x86)/Hearthstone/Logs/log.config"

    wine "/home/joncrall/.wine/drive_c/Program Files (x86)/Hearthstone/Hearthstone.exe"
    wine "/home/joncrall/.wine/drive_c/Program Files (x86)/Battle.net/Battle.net.exe"


    # Hearthstone log dir
    ~/.wine/drive_c/users/joncrall/Local\ Settings/Application\ Data/Blizzard/Hearthstone/Logs
    touch ~/.wine/drive_c/users/joncrall/Local\ Settings/Application\ Data/Blizzard/Hearthstone/Logs/log.config

    # Can edit build Settings to Release mode in project settings
    # in the qt creator when in the arenatracker project

    chmod +x /home/joncrall/code/build-ArenaTracker-Desktop_Qt_5_6_1_GCC_64bit-Debug/ArenVaTracker
    cd ~/code/Arena-Tracker/opencv_install/lib
    cp -r ~/code/Arena-Tracker/opencv_install/lib/* ~/code/build-ArenaTracker-Desktop_Qt_5_6_1_GCC_64bit-Debug
    cp -r ~/code/Arena-Tracker/opencv_install/lib/* ~/code/build-ArenaTracker-Desktop_Qt_5_6_1_GCC_64bit-Release
    gvim '~/.config/Arena Tracker/Arena Tracker.conf'
    ~/code/build-ArenaTracker-Desktop_Qt_5_6_1_GCC_64bit-Debug/ArenaTracker

    #[General]
    #autoSize=true
    #cardHeight=35
    #createGoldenCards=false
    #draftLearningMode=false
    #drawDisappear=5
    #logConfig=/home/joncrall/.wine/drive_c/users/joncrall/Local Settings/Application Data/Blizzard/Hearthstone/Logs/log.config
    #logConfig=/home/joncrall/.wine/drive_c/Program Files (x86)/Hearthstone/Logs/log.config
    #logsDirPath=/home/joncrall/.wine/drive_c/users/joncrall/Local Settings/Application Data/Blizzard/Hearthstone/Logs
    #maxGamesLog=15
    #numWindows=2
    #password=
    #playerEmail=
    #pos=@Point(0 0)
    #pos2=@Point(0 0)
    #showClassColor=true
    #showDraftOverlay=true
    #showSpellColor=true
    #size=@Size(255 600)
    #size2=@Size(222 600)
    #splitWindow=false
    #theme=1
    #tooltipScale=10
    #transparent=1



}


remove_wine_stuff(){
    sudo apt-get remove wine-mono4.5.4
    sudo apt-get remove playonlinux wine*
    sudo apt-get remove winbind
}


install_cockatrice()
{
    # https://www.reddit.com/r/Cockatrice/comments/2prlnx/can_anyone_eli5_how_to_install_on_linux/
    co
    sudo apt-get install build-essential clang libqt4-dev -y
    sudo apt-get install libprotobuf-dev qtmobility-dev -y
    sudo apt-get install protobuf-compiler -y

    sudo apt install libqt5websockets5 libqt5multimedia5 -y

    # https://github.com/Cockatrice/Cockatrice/wiki/Compiling-Cockatrice-(Linux)#ubuntu-linux
    sudo apt update
    sudo apt install git build-essential g++ cmake -y
    sudo apt install libprotobuf-dev protobuf-compiler -y
    sudo apt install qt5-default qttools5-dev qttools5-dev-tools -y
    sudo apt install qtmultimedia5-dev libqt5multimedia5-plugins libqt5svg5-dev libqt5sql5-mysql -y
    sudo apt install -y libgcrypt11-dev


    apt-file search Qt5MultimediaConfig.cmake
    apt-file search Qt5SvgConfig.cmake

    sudo apt install qtbase5-dev qtmultimedia5-dev libqt5svg5-dev libqt5websockets5-dev -y

    fix_mesa_libEGL(){
        # NEED TO FIX MESA LIBGL SYMLINK REFERENCED BY Qt5::Gui
        # https://askubuntu.com/questions/616065/the-imported-target-qt5gui-references-the-file-usr-lib-x86-64-linux-gnu-li

        # CHECK IF BROKEN
        ls -al /usr/lib/x86_64-linux-gnu/libEGL.so

        # Find existing places
        locate libEGL.so

        # ON MY 16.04 system, the first of these was broken, but the second and third were not, so fix it.
        /usr/lib/x86_64-linux-gnu/libEGL.so
        # It pointed to
        # /usr/lib/x86_64-linux-gnu/libEGL.so -> mesa-egl/libEGL.so
        # But mesa-egl/libEGL.so did not exist

        # REMOVE IT
        sudo unlink /usr/lib/x86_64-linux-gnu/libEGL.so

        # FIND WHICH ONES DO EXIST
        ls /usr/lib/x86_64-linux-gnu/libEGL*
        # Not sure if option (a) or (b) is right
        # (a) ln -s /usr/lib/x86_64-linux-gnu/libEGL.so.1 /usr/lib/x86_64-linux-gnu/libEGL.so
        # (b) ln -s /usr/lib/x86_64-linux-gnu/libEGL_nvidia.so.0 /usr/lib/x86_64-linux-gnu/libEGL.so
        sudo ln -s /usr/lib/x86_64-linux-gnu/libEGL_nvidia.so.0 /usr/lib/x86_64-linux-gnu/libEGL.so
    }

    deactivate_venv

    cd ~/code
    git clone https://github.com/Cockatrice/Cockatrice
    cd ~/code/Cockatrice
    mkdir -p ~/code/Cockatrice/build
    cd ~/code/Cockatrice/build
    cmake .. -DCMAKE_INSTALL_PREFIX=$HOME/.local
    make -j9
    make install

    #cmake .. -DWITH_QT4=1 -DWITH_SERVER=0 -DWITH_CLIENT=1 -DWITH_ORACLE=1 -DCMAKE_INSTALL_PREFIX=$HOME/.local
    #make -j9
    #make install
}


shandalar(){
    # This sort of works, but crashes with visual glitches when I try to start a new game
    cd /home/joncrall/Documents/mtg/Manalink_1.3.2/Manalink1.3.2_20010711
    wine Magic/Program/Magic.exe
}

install_dolphin(){

}
