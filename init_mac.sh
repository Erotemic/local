update_locate()
{
    sudo /usr/libexec/locate.updatedb
}

enable_vnc_security()
{
    sudo /System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -activate -configure -access -on -clientopts -setvnclegacy -vnclegacy yes -clientopts -setvncpw -vncpw mypasswd -restart -agent -privs -all
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

if [["Parham's Mac Mini Server" == $(scutil --get ComputerName)]]; then
    # Make link to Jasons data directory
    ln -s /Volumes/External/data/ ~/data
    # Move a small database
fi

enable_vnc_security

# Grab the GNU ls over Mac's default BSD ls
sudo port install coreutils +with_default_names
sudo port install g95
sudo port install gcc45 +gfortran 
sudo port install gcc46 +gfortran
sudo port install apple-gcc42

sudo port install tree

sudo port install freetype
sudo port install zlib

# Libpng
sudo port install libpng

sudo port install python27
sudo port select python python27 @2.7.6
sudo port install python_select  
python_select python27 

#sudo port install qt4-mac-devel
sudo port install qt4-mac
#sudo port install py27-pyqt4

# Python packages we cant get from pip
sudo port install py27-ipython
sudo port select --set ipython ipython27

sudo pip install pandas
sudo pip install scipy --upgrade


sudo port installed | grep python

reinstall()
{
    sudo port uninstall -f $1
    sudo port install $1
}
reinstall py27-pip

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


fix_pip()
{
    sudo port uninstall py27-pip
    sudo port uninstall py27-numpy
    sudo port uninstall py27-scipy
    sudo port uninstall py27-nose
    sudo port uninstall py27-modulegraph
    sudo port uninstall py27-pyobjc
    sudo port uninstall py27-setuptools
    sudo port install py27-pip
}

pip_install()
{
    sudo pip install $1 --upgrade
    #sudo pip uninstall $1
}

pip_Unstall()
{
    sudo pip uninstall $1 -y
}


purge_pip()
{
    pip_Unstall Pygments
    pip_Unstall argparse
    pip_Unstall openpyxl
    pip_Unstall parse
    pip_Unstall psutil
    pip_Unstall pyglet
    pip_Unstall pyparsing
    pip_Unstall pyreadline
    pip_Unstall Cython
    pip_Unstall line-profiler
    pip_Unstall flake8
    pip_Unstall pep8
    pip_Unstall pyflakes
    pip_Unstall pylint
    pip_Unstall pylru
    pip_Unstall pyinstaller
    pip_Unstall multiprocessing

    pip_Unstall pandas
    pip_Unstall pyzmq
    pip_Unstall Pillow  # PIL
    pip_Unstall ipython
}


port_pyinstall()
{
    sudo port install py27-$1
}

# Find nondependent ports
port echo leaves

port_pyinstall()
{
    sudo port install py27-setuptools
    sudo port install py27-pip
    port select --set pip pip27
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

    port select --set cython cython27
    port select --set pyflakes py27-pyflakes
    port select --set pep8 pep827
    

    # ports does not have
    #port_pyinstall line-profiler
    #port_pyinstall argparse
    #port_pyinstall psutil
    #port_pyinstall pyglet
    #port_pyinstall pyparsing
    #port_pyinstall pylru
    #port_pyinstall pyinstaller
    #port_pyinstall multiprocessing
    #port_pyinstall parse
}


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
# quaremap


sudo port selfupdate
sudo port upgrade outdated
