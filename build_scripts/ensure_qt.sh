centos_purge_qt(){
    sudo yum remove -y qt4
    sudo yum remove -y qt4-devel
}

purge_pyqt4()
{
    sudo rm -rf /usr/local/lib/python2.7/site-packages/PyQt4
}

purge_sip()
{
    find /bin -name '*sip*'
    find /lib -name '*sip*'
    find /usr/local -name '*sip*'
    #export PYENV_ROOT=$WORKON_HOME/ibeis27
    #find $PYENV_ROOT -name '*sip*'
    #rm /home/jonathan/Envs/ibeis27/lib/python2.7/site-packages/sipdistutils.py
    #rm /home/jonathan/Envs/ibeis27/lib/python2.7/site-packages/libsip.a
    #rm /home/jonathan/Envs/ibeis27/lib/python2.7/site-packages/sipconfig.py
    #rm /home/jonathan/Envs/ibeis27/lib/python2.7/site-packages/sip.so
    #rm /home/jonathan/Envs/ibeis27/bin/sip
    #rm /home/jonathan/Envs/ibeis27/python2.7/sip.h
    sudo rm /usr/local/bin/sip
    sudo rm /usr/local/include/python2.7/sip.h
    sudo rm /usr/local/lib/python2.7/site-packages/sip.so
    sudo rm /usr/local/lib/python2.7/site-packages/sipdistutils.py
    sudo rm /usr/local/lib/python2.7/site-packages/sipconfig.py
    sudo rm /usr/local/lib/python2.7/site-packages/sipconfig.pyc
    sudo rm -rf /usr/local/share/sip
}


centos_prereq()
{
# CENTOS
sudo yum groupinstall 'Development Tools' -y
sudo yum install openssl-devel -y
sudo yum install libXext-devel -y
sudo yum install libXt-devel -y

#sudo apt-get install 7zip
}


#====================
# SOURCE BUILD: QT
#export QT_SOURCE_SNAPSHOT=qt-everywhere-opensource-src-4.8.6
export QT_SOURCE_SNAPSHOT=qt-everywhere-opensource-src-4.8.7

mkdir tmp
cd ~/tmp
# Download the Qt Source Code
wget http://download.qt-project.org/official_releases/qt/4.8/4.8.7/$QT_SOURCE_SNAPSHOT.tar.gz
tar xzvf $QT_SOURCE_SNAPSHOT.tar.gz
cd ~/tmp
cd $QT_SOURCE_SNAPSHOT
#make confclean
./configure \
    -prefix $PYTHON_VENV/local/qt \
    -prefix-install \
    -confirm-license -opensource \
    -release \
    -shared \
    -openssl 

    #-no-phonon \
    #-no-phonon-backend \
    #-no-webkit \
    #-no-openvg 
#LDFLAGS="-Wl,-rpath,$PYTHON_VENV/local/qt/lib"
# Make
make -j$NCPUS
# Install
make install
# make uninstall
#make install > make_install_output.out
#sudo qmake install 
#|| { echo "FAILED QT QMAKE" ; exit 1; }

ls $PYTHON_VENV/local/qt/include
ls -al /usr/include/phonon/abstractaudiooutput.h
locate phonon
make install > make_intall_output.txt
cat make_intall_output.txt | grep 3rdparty
cat make_intall_output.txt | grep phonon
grep -ER abstractaudiooutput.h * 
ls -al /usr/include/phonon/abstractaudiooutput.h
#====================


#grabzippedurl.py http://download.qt-project.org/official_releases/qt/4.8/4.8.6/$QT_SOURCE_SNAPSHOT.tar.gz
#gunzip $QT_SOURCE_SNAPSHOT.tar.gz && tar -xvf $QT_SOURCE_SNAPSHOT.tar
#cd $QT_SOURCE_SNAPSHOT
# Configure
#export QTCONFFLAGS="-prefix-install --shared -openssl -confirm-license -opensource"
#./configure --prefix=/usr/local/qt $QTCONFFLAGS LDFLAGS="-Wl,-rpath /usr/local/qt/lib" || { echo "FAILED QT CONFIGURE" ; exit 1; }
## Make
#gmake -j9 || { echo "FAILED QT QMAKE" ; exit 1; }
## Install
#sudo qmake install || { echo "FAILED QT QMAKE" ; exit 1; }


#====================
# SOURCE BUILD: SIP
export SIP_URL=http://sourceforge.net/projects/pyqt/files/sip/sip-4.16.9
export SIP_SNAPSHOT=sip-4.16.9

cd ~/tmp
wget $SIP_URL/$SIP_SNAPSHOT.tar.gz
tar xzfv $SIP_SNAPSHOT.tar.gz

cd $SIP_SNAPSHOT
python2.7 configure.py --sysroot=$VIRTUAL_ENV --incdir=$VIRTUAL_ENV/include/python2.7
make -j$NCPUS 
sudo make install
python -c "import sip; print('[test] Python can import sip')"
python -c "import sip; print('sip.__file__=%r' % (sip.__file__,))"
python -c "import sip; print('sip.SIP_VERSION=%r' % (sip.SIP_VERSION,))"
python -c "import sip; print('sip.SIP_VERSION_STR=%r' % (sip.SIP_VERSION_STR,))"
#====================

#====================
# SOURCE BUILD: PyQt4
# Use snapshot instead
# References: https://www.riverbankcomputing.com/software/pyqt/download
#export PYQT4_SNAPSHOT=PyQt-x11-gpl-4.11.tar.gz
#export PYQT4_URL=http://www.riverbankcomputing.co.uk/static/Downloads/PyQt4
#export PYQT4_SNAPSHOT=PyQt-x11-gpl-4.11.1-snapshot-e1e46b3cad30

export PYQT4_URL=http://sourceforge.net/projects/pyqt/files/PyQt4/PyQt-4.11.4
export PYQT4_SNAPSHOT=PyQt-x11-gpl-4.11.4

cd ~/tmp
wget $PYQT4_URL/$PYQT4_SNAPSHOT.tar.gz
tar xzvf $PYQT4_SNAPSHOT.tar.gz 

cd ~/tmp/$PYQT4_SNAPSHOT
python2.7 configure-ng.py --qmake=$VIRTUAL_ENV/local/qt/bin/qmake --no-designer-plugin --confirm-license --target-py-version=2.7
make -j$NCPUS 

make install
#====================


# TEST PyQt4
python2.7 -c "import PyQt4; print('[test] SUCCESS import PyQt4: %r' % PyQt4)"
python2.7 -c "from PyQt4 import QtGui; print('[test] SUCCESS import QtGui: %r' % QtGui)"
python2.7 -c "from PyQt4 import QtCore; print('[test] SUCCESS import QtCore: %r' % QtCore)"
python2.7 -c "from PyQt4.QtCore import Qt; print('[test] SUCCESS import Qt: %r' % Qt)"
