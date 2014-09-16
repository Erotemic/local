# Install Correct Driver
# apt-get install nvidia-current

# Try this aptget repo
sudo add-apt-repository ppa:xorg-edgers/ppa -y
sudo apt-get update
sudo apt-get install nvidia-343


# Remember you have to stop the xserver before you do anything else

# ctrl+alt+f1
# stop lightdm # Unity
# stop gdm # Gnome3
# stop kdm # KDE
#/Drivers/NVIDIA-Linux-x86_64-319.32.run

#http://www.nvidia.com/download/driverResults.aspx/77525/en-us
#Geforce 670 GTX


#export INSTALL_NVIDIA=/home/joncrall/Drivers/NVIDIA-Linux-x86_64-319.32.run
#export INSTALL_NVIDIA=/home/joncrall/Drivers/NVIDIA-Linux-x86_64-331.20.run
manual_nvidia_install(){
mkdir ~/Drivers
mv ~/Downloads/NVIDIA-Linux* ~/Drivers
ls -al ~/Drivers

export INSTALL_NVIDIA=~/Drivers/NVIDIA-Linux-x86_64-340.32.run
chmod +x $INSTALL_NVIDIA
sudo stop gdm
}
# Doesnt actually seem echo correctly
#sudo cat /etc/modprobe.d/blacklist.conf
#sudo echo "blacklist nouveau" >> /etc/modprobe.d/blacklist.conf
#sudo $INSTALL_NVIDIA
