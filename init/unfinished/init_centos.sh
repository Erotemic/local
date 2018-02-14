# Install virtualbox addons
# http://download.virtualbox.org/virtualbox/4.1.12/
# Mount the .iso on the guest machine
sudo mount /dev/cdrom /mnt/
cd /mnt
./VBoxLinuxAdditions.run

useradd joncrall
passwd joncrall

# Add user to suoders file
visudo
echo "joncrall ALL=(ALL) ALL" >> /etc/sudoers

# Init Dynamic IP
vi /etc/sysconfig/network-scripts/ifcfg-eth0
# Ensure the following variables
DEVICE=eth0
BOOTPROTO=dhcp
ONBOOT=yes
NM_CONTROLLED=no

# These commands will ensure that
export GLOBAL_ifcfg_eth0=/etc/sysconfig/network-scripts/ifcfg-eth0
echo $GLOBAL_ifcfg_eth0.backup
cat $GLOBAL_ifcfg_eth0
cat $GLOBAL_ifcfg_eth0 > ifcfg-eth0.backup
sudo sed -i s/ONBOOT=no/ONBOOT=yes/ $GLOBAL_ifcfg_eth0 
sudo sed -i s/NM_CONTROLLED=yes/NM_CONTROLLED=no/ $GLOBAL_ifcfg_eth0

sudo yum install vim
sudo yum install gvim


sudo yum install git
if [ ! -f ~/local ]; then
mkdir ~/tmp
fi
if [ ! -f ~/code ]; then
mkdir ~/code
fi
cd ~
if [ ! -f ~/local ]; then
    git clone https://github.com/Erotemic/local.git
fi
# TODO UTOOL
mv ~/.bashrc ~/.bashrc.orig
mv ~/.profile ~/.profile.orig
ln -s ~/local/bashrc.sh ~/.bashrc
ln -s ~/local/profile.sh ~/.profile 
source ~/.bashrc
git config --global user.name joncrall
git config --global user.email crallj@rpi.edu
git config --global push.default current

sudo yum install bash-completion

# OR do this if bash-completion doesnt install through yum
mkdir ~/tmp
cd tmp
wget http://pkgs.repoforge.org/bash-completion/bash-completion-20060301-1.el6.rf.noarch.rpm
rpm -ivh bash-completion-20060301-1.el6.rf.noarch.rpm
 bash-completion-20060301-1.noarch.rpm
. /etc/bash_completion



# Virtual environment
#sudo pip2.7 install virtualenv
#usr/local/lib/python2.7/site-packages/virtualenv/
#sudo /usr/local/lib/python2.7/site-packages/virtualenv.py

cd
mkdir venv
sudo pip2.7 install virtualenv
python2.7 -m virtualenv -p /usr/bin/python2.7 venv ----system-site-packages
source ~/venv/bin/activate 
