# https://wiki.qt.io/Building_Qt_5_from_Git
http://download.qt.io/official_releases/qt/5.8/5.8.0/single/qt-everywhere-opensource-src-5.8.0.tar.gz

sudo apt-get build-dep qt5-default
sudo apt-get install libxcb-xinerama0-dev 
sudo apt-get install flex bison gperf libicu-dev libxslt-dev ruby


#================================================================
cd ~/code
git clone https://code.qt.io/qt/qt5.git
#git clone https://github.com/qt/qt5.git
cd qt5
./init-repository --module-subset=default,-qtwebkit,-qtwebkit-examples,-qtwebengine 
#git checkout 5.9
#git submodule update --init
git submodule update

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
    -skip qtwebkit \
    -skip qtserialport \
    -skip qtwebkit-examples \
    -skip qtenginio \
    -developer-build

make -j9
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
export SIP_URL=http://sourceforge.net/projects/pyqt/files/sip/sip-$SIP_VERSION
export SIP_SNAPSHOT=sip-$SIP_VERSION
export INCLUDE_DIR=$(echo $VIRTUAL_ENV/include/python*)
export SITE_PACKAGES_DIR=$(python -c "import utool as ut; print(ut.get_site_packages_dir())")
echo "INCLUDE_DIR=$INCLUDE_DIR"
echo "SITE_PACKAGES_DIR=$SITE_PACKAGES_DIR"
cd ~/tmp
rm -rf $SIP_SNAPSHOT
wget $SIP_URL/$SIP_SNAPSHOT.tar.gz
tar xzfv $SIP_SNAPSHOT.tar.gz

cd ~/tmp/$SIP_SNAPSHOT
python configure.py --help
mkdir $VIRTUAL_ENV/local/share/sip
python configure.py --debug \
    --incdir=$VIRTUAL_ENV/local/include \
    --bindir=$VIRTUAL_ENV/local/bin \
    --sipdir=$VIRTUAL_ENV/local/share/sip \
    --pyidir=$SITE_PACKAGES_DIR \
    --destdir=$SITE_PACKAGES_DIR

make -j9
make install
#--sysroot=$VIRTUAL_ENV 
make -j$NCPUS 
# Need to fix virtualenv problem with a symlinked python include directory
# before this command will work.
make install
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
export PYQT_URL=http://sourceforge.net/projects/pyqt/files/PyQt5/PyQt-$PYQT_VERSION
export PYQT_SNAPSHOT=PyQt5_gpl-$PYQT_VERSION
export INCLUDE_DIR=$(echo $VIRTUAL_ENV/include/python*)
echo "INCLUDE_DIR=$INCLUDE_DIR"
echo "PYQT_VERSION=$PYQT_VERSION"
echo "PYQT_URL=$PYQT_URL"
echo "PYQT_SNAPSHOT=$PYQT_SNAPSHOT"
cd ~/tmp
wget $PYQT_URL/$PYQT_SNAPSHOT.tar.gz
tar xzvf $PYQT_SNAPSHOT.tar.gz 
cd ~/tmp/$PYQT_SNAPSHOT
#python configure.py --help 
python configure.py --confirm-license --no-designer-plugin \
    -debug \
    --qmake=$VIRTUAL_ENV/local/qt/bin/qmake \
    --sip-incdir=$VIRTUAL_ENV/local/include \
    --sip=$VIRTUAL_ENV/local/bin/sip

#--sip-incdir=$INCLUDE_DIR 
#--target-py-version=2.7
make -j$NCPUS 
make install

python -c "import PyQt5; print('[test] SUCCESS import PyQt5: %r' % PyQt5)"
python -c "from PyQt5 import QtGui; print('[test] SUCCESS import QtGui: %r' % QtGui)"
python -c "from PyQt5 import QtWidgets; print('[test] SUCCESS import QtWidgets: %r' % QtWidgets)"
python -c "from PyQt5 import QtCore; print('[test] SUCCESS import QtCore: %r' % QtCore)"
python -c "from PyQt5.QtCore import Qt; print('[test] SUCCESS import Qt: %r' % Qt)"

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

