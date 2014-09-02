# Download python 2.7
mkdir ~/tmp
cd ~/tmp
wget https://www.python.org/ftp/python/2.7.6/Python-2.7.6.tgz
gunzip Python-2.7.6.tgz && tar -xvf Python-2.7.6.tar
# Make the libraries in /usr/local/lib discoverable
#cat /etc/ld.so.conf
sudo sh -c "echo '/usr/local/lib' >> /etc/ld.so.conf"
#cat /etc/ld.so.conf
# Configure, make, and altinstall python 2.7
cd ~/tmp/Python-2.7.6
./configure --prefix=/usr/local --enable-unicode=ucs4 --enable-shared LDFLAGS="-Wl,-rpath /usr/local/lib"
make -j9
sudo make altinstall
# These modules are obsolete and it is ok that they are not found
#bsddb185 dl imageop sunaudiodev 

