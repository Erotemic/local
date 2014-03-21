cd ~
git clone git@github.com:Erotemic/local.git

mkdir ~/code
cd ~/code
git clone git@github.com:Erotemic/ibeis.git
git clone git@github.com:Erotemic/hotspotter.git
git clone git@github.com:Erotemic/flann.git
git clone git@github.com:Erotemic/hesaff.git
git clone git@github.com:Erotemic/opencv.git

sudo easy_install --upgrade setuptools
sudo pip install setuptools --upgrade
#sudo pip install matplotlib --upgrade
sudo easy_install pylru
#sudo pip install pylru


sudo port install py27-matplotlib +qt4
