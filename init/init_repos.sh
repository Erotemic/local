cd ~
git clone git@github.com:Erotemic/local.git

mkdir ~/code
cd ~/code

git clone git@github.com:Erotemic/utool.git
git clone git@github.com:Erotemic/vtool.git
git clone git@github.com:Erotemic/ibeis.git
git clone git@github.com:Erotemic/flann.git
git clone git@github.com:Erotemic/guitool.git
git clone git@github.com:Erotemic/plottool.git
git clone git@github.com:Erotemic/hesaff.git
git clone git@github.com:Erotemic/opencv.git

sudo easy_install --upgrade setuptools
sudo pip install setuptools --upgrade
#sudo pip install matplotlib --upgrade
sudo easy_install pylru
#sudo pip install pylru


sudo port install py27-matplotlib +qt4
