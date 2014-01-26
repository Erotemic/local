#cd ~/Downloads
#sudo dpkg -i --force-architecture FoxitReader_1.1.0_i386.deb
#rm FoxitReader_1.1.0_i386.deb

#https://help.ubuntu.com/community/Foxit

 #Download the tar.bz2 from
#http://www.foxitsoftware.com/downloads/index.php

tar xvfj FoxitReader-1.1.0.tar.bz2
mv 1.1-release foxit
sudo mv ~/Downloads/foxit /opt
sudo ln -s /opt/foxit/FoxitReader /usr/bin/foxit
