# Install Correct Driver
# apt-get install nvidia-current

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
mkdir ~/Drivers
mv ~/Downloads/NVIDIA-Linux* ~/Drivers
export INSTALL_NVIDIA=~/Drivers/NVIDIA-Linux-x86_64-340.32.run
ls -al ~/Drivers
chmod +x $INSTALL_NVIDIA
sudo $INSTALL_NVIDIA
