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



# CENTOS
sudo yum groupinstall 'Development Tools' -y
sudo yum install openssl-devel -y
sudo yum install libXext-devel -y
sudo yum install libXt-devel -y


cd ~/tmp
export QT_SOURCE_SNAPSHOT=qt-everywhere-opensource-src-4.8.6
# Download the Qt Source Code
wget http://download.qt-project.org/official_releases/qt/4.8/4.8.6/$QT_SOURCE_SNAPSHOT.tar.gz

grabzippedurl.py http://download.qt-project.org/official_releases/qt/4.8/4.8.6/$QT_SOURCE_SNAPSHOT.tar.gz
gunzip $QT_SOURCE_SNAPSHOT.tar.gz && tar -xvf $QT_SOURCE_SNAPSHOT.tar
cd $QT_SOURCE_SNAPSHOT
# Configure
export QTCONFFLAGS="-prefix-install --shared -openssl -confirm-license -opensource"
./configure --prefix=/usr/local/qt $QTCONFFLAGS LDFLAGS="-Wl,-rpath /usr/local/qt/lib" || { echo "FAILED QT CONFIGURE" ; exit 1; }
# Make
gmake -j9 || { echo "FAILED QT QMAKE" ; exit 1; }
# Install
sudo qmake install || { echo "FAILED QT QMAKE" ; exit 1; }
