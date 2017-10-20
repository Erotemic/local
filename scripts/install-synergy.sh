cd ~/tmp
# Checkout synergy
svn checkout http://svn.synergy-foss.org/trunk/ synergy
cd synergy
# Unzip Crypto
cd tools
mkdir cryptopp562
cd cryptopp562 && cp ../cryptopp562.zip .
unzip cryptopp562.zip && rm cryptopp562.zip
cd ../..
# Do Cmake Things
mkdir build
cd build
cmake -G "Unix Makefiles" -DCMAKE_BUILD_TYPE=Release .. -DCONF_CPACK=True
make -j9
sudo make install


sudo dpkg -i synergy-1.4.12-Linux-i686.deb
sudo dpkg -i synergy-1.4.12-Linux-x86_64.deb


# Had to remove encryption and put in desktop mode
# had to use 32 bit on windows (also in desktop mode)


#wget http://synergy.googlecode.com/files/synergy-1.4.12-Source.tar.gz
#tar -zxvf synergy-1.4.12-Source.tar.gz
#cd synergy-1.4.12-Source

#sudo apt-get install libxtst-dev
#sudo apt-get install libcrypto++-dev libcrypto++-doc libcrypto++-utils

#cd ../..
#./configure
#make
#make-install
