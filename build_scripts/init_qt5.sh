# Three step process
# 1) Build and install Qt5
# 2) Build and install sip
# 3) Build and install PyQt5

# https://wiki.qt.io/Building_Qt_5_from_Git
# http://download.qt.io/official_releases/qt/5.8/5.8.0/single/qt-everywhere-opensource-src-5.8.0.tar.gz
# Build Qt5 by itself

sudo apt-get build-dep qt5-default -y
sudo apt-get install libxcb-xinerama0-dev  -y
sudo apt-get install flex bison gperf libicu-dev libxslt-dev ruby -y
sudo apt-get install libssl-dev -y

python -m pip install bs4

#================================================================
cd ~/code
git clone https://code.qt.io/qt/qt5.git
#git clone https://github.com/qt/qt5.git
cd ~/code/qt5
./init-repository --module-subset=default,-qtwebkit,-qtwebkit-examples,-qtwebengine 
#git checkout 5.9
#git submodule update --init
git submodule update

./configure --help

./configure -prefix $VIRTUAL_ENV/local/qt \
    -debug \
    -confirm-license -opensource \
    -platform linux-g++ \
    -nomake tests \
    -nomake tools \
    -nomake examples \
    -skip qttools \
    -skip qttranslations \
    -skip qtconnectivity \
    -skip qtserialport \
    -skip qtenginio \
    -developer-build
    #-skip qtwebkit \
    #-skip qtwebkit-examples \

make -j5
make install

ls $VIRTUAL_ENV/local/qt
ls $VIRTUAL_ENV/local/qt/lib


#================================================================
# Still no github for sip

export SIP_VERSION=$(python -c "
import bs4
import requests
resp = requests.get('https://sourceforge.net/projects/pyqt/files/sip/')
soup = bs4.BeautifulSoup(resp.content, 'html.parser')
for a in soup.find_all('a'):
    href = a.get('href')
    prefix = '/projects/pyqt/files/sip/sip-'
    if href.startswith(prefix):
        print(href[len(prefix):-1])
        break
")
export SOABI=$(python -c "from distutils import sysconfig; print(sysconfig.get_config_vars().get('SOABI', 'py2'))")
export SIP_URL=http://sourceforge.net/projects/pyqt/files/sip/sip-$SIP_VERSION
export SIP_SNAPSHOT=sip-$SIP_VERSION
export INCLUDE_DIR=$(echo $VIRTUAL_ENV/include/python*)
export SITE_PACKAGES_DIR=$(python -c "import utool as ut; print(ut.get_site_packages_dir())")
export NCPUS=$(grep -c ^processor /proc/cpuinfo)
echo "
    SOABI             = $SOABI
    SIP_SNAPSHOT      = $SIP_SNAPSHOT
    SIP_URL           = $SIP_URL
    INCLUDE_DIR       = $INCLUDE_DIR
    SITE_PACKAGES_DIR = $SITE_PACKAGES_DIR
"

# make a directory for this specific build version
mkdir -p ~/tmp/sip-$SOABI
cd ~/tmp/sip-$SOABI
#rm -rf $SIP_SNAPSHOT
wget $SIP_URL/$SIP_SNAPSHOT.tar.gz
tar xzfv $SIP_SNAPSHOT.tar.gz

cd ~/tmp/sip-$SOABI/$SIP_SNAPSHOT
#python configure.py --help
mkdir $VIRTUAL_ENV/local/share/sip
python configure.py --debug \
    --incdir=$VIRTUAL_ENV/local/include \
    --bindir=$VIRTUAL_ENV/local/bin \
    --sipdir=$VIRTUAL_ENV/local/share/sip \
    --pyidir=$SITE_PACKAGES_DIR \
    --destdir=$SITE_PACKAGES_DIR

make -j$NCPUS 
make install
#--sysroot=$VIRTUAL_ENV 
# Need to fix virtualenv problem with a symlinked python include directory
# before this command will work.
#make install
python -c "import sip; print('[test] Python can import sip')"
python -c "import sip; print('sip.__file__=%r' % (sip.__file__,))"
python -c "import sip; print('sip.SIP_VERSION=%r' % (sip.SIP_VERSION,))"
python -c "import sip; print('sip.SIP_VERSION_STR=%r' % (sip.SIP_VERSION_STR,))"


#================================================================
# PyQt5 unofficial repo
#git clone https://github.com/baoboa/pyqt5
export PYQT_VERSION=$(python -c "
import bs4
import requests
resp = requests.get('https://sourceforge.net/projects/pyqt/files/PyQt5/')
soup = bs4.BeautifulSoup(resp.content, 'html.parser')
for a in soup.find_all('a'):
    href = a.get('href')
    prefix = '/projects/pyqt/files/PyQt5/PyQt-'
    if href is not None and href.startswith(prefix):
        print(href[len(prefix):-1])
        break
")
export SOABI=$(python -c "from distutils import sysconfig; print(sysconfig.get_config_vars().get('SOABI', 'py2'))")
export PYQT_URL=http://sourceforge.net/projects/pyqt/files/PyQt5/PyQt-$PYQT_VERSION
export PYQT_SNAPSHOT=PyQt5_gpl-$PYQT_VERSION
export INCLUDE_DIR=$(echo $VIRTUAL_ENV/include/python*)
export NCPUS=$(grep -c ^processor /proc/cpuinfo)
echo "
    SOABI         = $SOABI
    INCLUDE_DIR   = $INCLUDE_DIR
    PYQT_VERSION  = $PYQT_VERSION
    PYQT_URL      = $PYQT_URL
    PYQT_SNAPSHOT = $PYQT_SNAPSHOT
"

# make a directory for this specific build version
mkdir -p ~/tmp/pyqt-$SOABI
cd ~/tmp/pyqt-$SOABI
wget $PYQT_URL/$PYQT_SNAPSHOT.tar.gz
tar xzvf $PYQT_SNAPSHOT.tar.gz 
cd ~/tmp/pyqt-$SOABI/$PYQT_SNAPSHOT

python configure.py --help 

ls $VIRTUAL_ENV/local/qt/bin

#QtWebSockets, QtWebChannel,
#These PyQt5 modules will be built: QtCore, QtGui, QtMultimedia,
#QtMultimediaWidgets, QtNetwork, QtOpenGL, QtPrintSupport, QtQml, QtQuick,
#QtSql, QtSvg, QtTest, QtWidgets, QtXml, QtXmlPatterns, QtDBus,
#_QOpenGLFunctions_2_0, _QOpenGLFunctions_2_1, _QOpenGLFunctions_4_1_Core,
#QtSensors, QtX11Extras, QtPositioning, QtQuickWidgets, QtWebSockets,
#QtWebChannel, QtLocation.


python configure.py --confirm-license --no-designer-plugin --debug \
    --qmake=$VIRTUAL_ENV/local/qt/bin/qmake \
    --sip-incdir=$VIRTUAL_ENV/local/include \
    --sip=$VIRTUAL_ENV/local/bin/sip \
    --disable=QtWebChannel \
    --disable=QtWebSockets \
    --disable=QtNetwork 


#--sip-incdir=$INCLUDE_DIR 
#--target-py-version=2.7
make -j$NCPUS 
make install

ls ~/venv3/lib/python3.5/site-packages/PyQt5

python -c "import PyQt5; print('[test] SUCCESS import PyQt5: %r' % PyQt5)"
python -c "from PyQt5 import QtGui; print('[test] SUCCESS import QtGui: %r' % QtGui)"
python -c "from PyQt5 import QtWidgets; print('[test] SUCCESS import QtWidgets: %r' % QtWidgets)"
python -c "from PyQt5 import QtCore; print('[test] SUCCESS import QtCore: %r' % QtCore)"
python -c "from PyQt5.QtCore import Qt; print('[test] SUCCESS import Qt: %r' % Qt)"

test_tools()
{
    python -c "import guitool"
    python -m plottool

}

remove_sip()
{

    # Make did this
    #cp -f sip /home/joncrall/venv3/local/bin/sip
    #cp -f sip.so /home/joncrall/venv3/lib/python3.5/site-packages/sip.so
    #cp -f /home/joncrall/tmp/sip-4.19.1/siplib/sip.h /home/joncrall/venv3/local/include/sip.h
    #cp -f /home/joncrall/tmp/sip-4.19.1/sip.pyi /home/joncrall/venv3/lib/python3.5/site-packages/sip.pyi
    #cp -f sipconfig.py /home/joncrall/venv3/lib/python3.5/site-packages/sipconfig.py
    #cp -f /home/joncrall/tmp/sip-4.19.1/sipdistutils.py /home/joncrall/venv3/lib/python3.5/site-packages/sipdistutils.py
    rm $VIRTUAL_ENV/bin/sip
    ls -al $VIRTUAL_ENV/bin/sip*
    ls -al $VIRTUAL_ENV/local/bin/sip*
}

