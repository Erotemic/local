update_locate()
{
    sudo /usr/libexec/locate.updatedb
}

enable_vnc_security()
{
    sudo /System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -activate -configure -access -on -clientopts -setvnclegacy -vnclegacy yes -clientopts -setvncpw -vncpw mypasswd -restart -agent -privs -all
}

allow_nonmac_apps()
{
    sudo spctl --add --label "HotSpotter" /Applications/HotSpotter.app
    sudo spctl --enable --label "HotSpotter"
    sudo spctl --list
}

reinstall_python()
{
    sudo port -n upgrade --force python27
}

scp_hotspotter_db()
{
    DBNAME = $1
    DST = $2
    export DBNAME = 'NAUT_DAN'
    export DST = 'joncrall@longerdog.com'
    scp -r ~/data/work/$DBNAME/images $DST:data/work/$DBNAME/images
    scp ~/data/work/_hsdb/image_table.csv $DST:data/work/_hsdb/image_table.csv
    scp ~/data/work/_hsdb/name_table.csv  $DST:data/work/_hsdb/name_table.csv
    scp ~/data/work/_hsdb/chip_table.csv  $DST:data/work/_hsdb/chip_table.csv
}

make_dirs()
{
    if [["Parham's Mac Mini Server" == $(scutil --get ComputerName)]]; then
        # Make link to Jasons data directory
        ln -s /Volumes/External/data/ ~/data
        # Move a small database
    fi
}

update_ports()
{
    sudo port selfupdate
    sudo port upgrade outdated
    # Python packages we cant get from pip
    #sudo port installed | grep python
    sudo port installed | grep gcc
    # Find nondependent ports
    #port echo leaves
}

install_gcc49()
{
    # GCC 4.9
    sudo port deactivate libgcc 
    sudo port install gcc49
    sudo port select --set gcc mp-gcc49 
}

remote_gcc()
{
    sudo port select --set gcc none
    # DEACTIVATE GCC 4.8
    sudo port deactivate gcc48
    sudo port deactivate libgcc 
    # DEACTIVATE GCC 4.9
    sudo port deactivate gcc49
    sudo port deactivate libgcc-devel
}

install_gcc48()
{
    # GCC 4.8.2
    sudo port install libgcc
    sudo port install gcc48
    sudo port select --set gcc mp-gcc48
}

revert_clang()
{
    sudo port deactivate gcc48
    sudo port -f deactivate libgcc 
}

install_gcc()
{
    # Grab the GNU ls over Mac's default BSD ls
    sudo port install coreutils +with_default_names

    sudo port install gcc_select
    sudo port select --list gcc

    # need to restart bash I guess.
    #--list gcc
    sudo port install g95
    sudo port install gcc45 +gfortran 
    sudo port install gcc46 +gfortran
    
    # Does not work on Yosemite or later
    #sudo port install apple-gcc42
    sudo port uninstall apple-gcc42

    # Reload bash to get things working more or less
    source ~/.profile
}

install_libs()
{
    sudo port install tree
    sudo port install htop
    sudo port install freetype
    sudo port install zlib
    # Libpng
    sudo port install libpng
    # Qt
    #sudo port install qt4-mac-devel
    sudo port install qt4-mac
}

port_opencv()
{
    sudo port install ffmpeg
    sudo port install opencv +python27
}

port_pyinstall()
{
    # Install the correct python
    sudo port install python27
    sudo port install python_select  
    sudo python_select python27 
    sudo port select python python27 @2.7.6

    sudo port install py27-setuptools

    sudo port install py27-pip
    port select --set pip pip27
    #sudo ln -s /opt/local/bin/pip-2.7 /opt/local/bin/pip
    #sudo port install py27-distribute Obsolete
    sudo port install py27-Pygments
    sudo port install py27-six

    sudo port install py27-openpyxl
    sudo port install py27-flake8
    sudo port install py27-pep8
    sudo port install py27-pyflakes
    sudo port install py27-pylint
    sudo port install py27-Cython

    sudo port install py27-numpy
    sudo port install py27-parsing
    sudo port install py27-dateutil
    sudo port install py27-readline

    sudo port install py27-sip
    sudo port install py27-pyqt4
    #sudo port install py27-pyqt4-devel 
    sudo port install py27-matplotlib +qt +tkinter

    sudo port install py27-zmq
    sudo port install py27-pyzmq
    sudo port install py27-Pillow  # PIL
    sudo port install py27-scipy
    sudo port install py27-ipython
    # Installs a lot of things. Install pandas last
    sudo port install py27-pandas
    #sudo port install py27-numba

    # We do need pip. 
    sudo pip install pylru
    sudo pip install pyinstaller

    sudo port select --set ipython ipython27
    port select --set cython cython27
    port select --set pyflakes py27-pyflakes
    port select --set pep8 pep827

    # Put the qt4agg backend in matploblib
    mkdir ~/.matplotlib
    echo backend      : qt4agg >> ~/.matplotlib/matplotlibrc

    #pip_install scipy
    #pip_install SIP
    #llvmpy
    #numba
    #sudo pip install matplotlib
    #sudo pip install python-qt
    #flann
    #opencv-python
    #scikit-image
    #scikit-learn
    #runsnakerun
}


clean_port_installed()
{
    # Remove ports for pip
    sudo port uninstall py27-pyqt4
    sudo port uninstall py27-sip

    sudo port uninstall py27-pyobjc-cocoa
    sudo port uninstall py27-pyobjc
    sudo port uninstall py27-py2app

    sudo port uninstall py27-scipy
    sudo port uninstall py27-tornado
    sudo port uninstall py27-ipython
    sudo port uninstall py27-tkinter

    sudo port uninstall py27-dateutil
    sudo port uninstall py27-tz

    sudo port uninstall py27-scientific
    sudo port uninstall py27-numpy
    sudo port uninstall py27-nose 

    sudo port uninstall py27-six
    sudo port uninstall py27-macholib
    sudo port uninstall py27-modulegraph
    sudo port uninstall py27-altgraph
    sudo port uninstall py27-readline
    sudo port uninstall py27-parsing
    sudo port uninstall py27-setuptools 
    sudo port uninstall ipython_select
}
