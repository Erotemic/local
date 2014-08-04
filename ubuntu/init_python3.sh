sudo apt-get install libreadline-dev 
sudo apt-get install libssl-dev
sudo apt-get install libsqlite3-dev

export NCPUS=$(grep -c ^processor /proc/cpuinfo)

# What python 2.7 installed with 
#python2.7-config --cflags
-I/usr/include/python2.7 -I/usr/include/python2.7 
-fno-strict-aliasing -DNDEBUG -g -fwrapv -O2 -Wall -Wstrict-prototypes -g -fstack-protector 
--param=ssp-buffer-size=4 -Wformat -Wformat-security -Werror=format-security
#
#python2.7-config --libs
-lpthread -ldl -lutil -lm -lpython2.7
#joncrall@Hyrule:~/code/ibeis$ python2.7-config --ldflags
-L/usr/lib/python2.7/config -lpthread -ldl -lutil -lm -lpython2.7 -Xlinker -export-dynamic -Wl,-O1 -Wl,-Bsymbolic-functions

# What python 3.2 installed with 
python3.2-config --cflags
-I/usr/include/python3.2mu -I/usr/include/python3.2mu
-DNDEBUG-g -fwrapv -O2 -Wall
-Wstrict-prototypes -g -fstack-protector
--param=ssp-buffer-size=4 -Wformat -Wformat-security
-Werror=format-security


# What I had with default 3.4
joncrall@Hyrule:~/code/cpython/Modules/_ctypes$ python3.4m-config --cflags
-I/usr/local/include/python3.4m -I/usr/local/include/python3.4m
-Wno-unused-result -Werror=declaration-after-statement  -DNDEBUG -g -fwrapv 
-O3 -Wall -Wstrict-prototypes


# What is python*m? 
#http://stackoverflow.com/questions/16675865/difference-between-python3-and-python3m-executibles
#via PEP 3149.
#Regarding the m flag specifically, this is what Pymalloc is:
#Pymalloc, a specialized object allocator written by Vladimir Marangozov, was a feature added to Python 2.1. Pymalloc is intended to be faster than the system malloc() and to have less memory overhead for allocation patterns typical of Python programs. The allocator uses C's malloc() function to get large pools of memory and then fulfills smaller memory requests from these pools.

# TODO: Purge python 3.2, and python 3.4 from system and reinstall

sudo updatedb
locate --existing --basename --regexp \\bpython3.2\\b$
locate --existing --regexp \\bpython3.2\\b$
locate --existing --basename --regexp \\bpython3 | grep .git


#=====================
# SOURCE: BUILD PYTHON
cd ~/code
git clone https://github.com/python/cpython.git
cd ~/code/cpython
git checkout 3.4
# Configure cflags
export CFLAGS="-fno-strict-aliasing -fstack-protector --param=ssp-buffer-size=4 -Wformat -Wformat-security -Werror=format-security -O2"
./configure --prefix=/usr/local --enable-shared LDFLAGS="-Wl,-rpath /usr/local/lib"

make -j$NCPUS
make test
sudo make altinstall

virtualenv -p /usr/local/bin/python3.4 ~/py3env
source ~/py3env/bin/activate


pip install setuptools
pip install Pygments
pip install Sphinx
pip install six
pip install dateutils
pip install pyreadline
pip install pyparsing
pip install requests
pip install colorama
pip install psutil
pip install ipython
pip install Cython
pip install numpy
pip install scipy
pip install Pillow
pip install tornado
pip install scikit-learn
pip install matplotlib


mkdir ~/srcdistro
mkdir ~/tmp


#====================
# SOURCE BUILD: QT
#sudo yum install -y qt4
#sudo yum install -y qt4-devel
# FIXME: The rest of this logic is in that file you forgot to commit
export QT_URL=http://download.qt-project.org/official_releases/qt/5.3/5.3.1/single/
export QT_SNAPSHOT=qt-everywhere-opensource-src-5.3.1
cd ~/tmp
wget $QT_URL/$QT_SNAPSHOT.tar.gz
gunzip $QT_SNAPSHOT.tar.gz && tar -xvf $QT_SNAPSHOT.tar
mv $QT_SNAPSHOT ~/srcdistro
cd ~/srcdistro/$QT_SNAPSHOT
#gmake confclean
sudo apt-get install libxcb1-dev
./configure -openssl -confirm-license -opensource -shared -qt-xcb 
# --prefix=/usr/local/qt -prefix-install
gmake -j$NCPUS
sudo gmake install
# symlink qmake to bin
sudo ln -s /usr/local/qt/bin/qmake /usr/bin/qmake
sudo sh -c "echo '/usr/local/qt/lib' >> /etc/ld.so.conf"
#====================


#====================
# SOURCE BUILD: SIP
export SIP_URL=http://sourceforge.net/projects/pyqt/files/sip/sip-4.16
export SIP_SNAPSHOT=sip-4.16
cd ~/tmp
wget $SIP_URL/$SIP_SNAPSHOT.tar.gz
gunzip $SIP_SNAPSHOT.tar.gz && tar -xvf $SIP_SNAPSHOT.tar
mv $SIP_SNAPSHOT ~/srcdistro
cd ~/srcdistro/$SIP_SNAPSHOT
# This is ok if virtualenv is on
python configure.py
make -j$NCPUS && sudo make install
python -c "import sip; print('[test] Python can import sip')"
#====================


#====================
# SOURCE BUILD: PyQt5
cd ~/tmp
# Use snapshot instead
#export PYQT5_SNAPSHOT=PyQt-x11-gpl-4.11.tar.gz
export PYQT5_URL=http://www.riverbankcomputing.co.uk/static/Downloads/PyQt5/
export PYQT5_SNAPSHOT=PyQt-gpl-5.3.2-snapshot-6f28c7ec4a3a
wget $PYQT5_URL/$PYQT5_SNAPSHOT.tar.gz
gunzip $PYQT5_SNAPSHOT.tar.gz && tar -xvf $PYQT5_SNAPSHOT.tar
mv $PYQT5_SNAPSHOT ~/srcdistro
cd ~/srcdistro/$PYQT5_SNAPSHOT
#python configure-ng.py --qmake=/usr/local/qt/bin/qmake --no-designer-plugin --confirm-license --target-py-version=3.4
python configure.py --qmake=/usr/local/Qt-5.3.1/bin/qmake --no-designer-plugin --confirm-license 
make -j$NCPUS && sudo make install
python -c "import PyQt5; print('[test] SUCCESS import PyQt5: %r' % PyQt5)"
python -c "from PyQt5 import QtGui; print('[test] SUCCESS import QtGui: %r' % QtGui)"
python -c "from PyQt5 import QtCore; print('[test] SUCCESS import QtCore: %r' % QtCore)"
python -c "from PyQt5.QtCore import Qt; print('[test] SUCCESS import Qt: %r' % Qt)"
#====================


#====================
# SOURCE BUILD: PyQt4
cd ~/tmp
# Use snapshot instead
export PYQT4_URL=http://www.riverbankcomputing.co.uk/static/Downloads/PyQt4/
export PYQT4_SNAPSHOT=PyQt-x11-gpl-4.11.2-snapshot-2c3f3d227e9b
wget $PYQT4_URL/$PYQT4_SNAPSHOT.tar.gz
gunzip $PYQT4_SNAPSHOT.tar.gz && tar -xvf $PYQT4_SNAPSHOT.tar
mv $PYQT4_SNAPSHOT ~/srcdistro
cd ~/srcdistro/$PYQT4_SNAPSHOT
python configure-ng.py --qmake=/usr/bin/qmake --no-designer-plugin --confirm-license
make -j$NCPUS && sudo make install
python -c "import PyQt4; print('[test] SUCCESS import PyQt4: %r' % PyQt4)"
python -c "from PyQt4 import QtGui; print('[test] SUCCESS import QtGui: %r' % QtGui)"
python -c "from PyQt4 import QtCore; print('[test] SUCCESS import QtCore: %r' % QtCore)"
python -c "from PyQt4.QtCore import Qt; print('[test] SUCCESS import Qt: %r' % Qt)"
#====================



pip install pyqt5
pip install sip --allow-external sip --allow-unverified sip
pip install sip
pip install functools32

#pip install package-name

#deactivate


# Shit I forgot opencv
python -c "import utool"
python -c "import vtool"
python -c "import plottool"
python -c "import guitool"

python setup.py
