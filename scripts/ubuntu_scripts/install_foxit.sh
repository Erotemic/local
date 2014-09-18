#cd ~/Downloads
#sudo dpkg -i --force-architecture FoxitReader_1.1.0_i386.deb
#rm FoxitReader_1.1.0_i386.deb

#https://help.ubuntu.com/community/Foxit

 #Download the tar.bz2 from
#http://www.foxitsoftware.com/downloads/index.php
sudo apt-get install libgtk2.0-0 -y
sudo apt-get install libgtk2.0-0:i386 -y
sudo apt-get install lib32stdc++6 -y
sudo apt-get install libcanberra-gtk-module:i386 -y
sudo apt-get install gtk2-engines-pixbuf:i386 -y



cd ~/Downloads
tar xvfj FoxitReader-1.1.0.tar.bz2
mv 1.1-release foxit
sudo mv ~/Downloads/foxit /opt
sudo ln -s /opt/foxit/FoxitReader /usr/bin/foxit
