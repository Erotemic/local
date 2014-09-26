# Install Correct Driver
# apt-get install nvidia-current

# Try this aptget repo
sudo add-apt-repository ppa:xorg-edgers/ppa -y
sudo apt-get update
#sudo apt-get install nvidia-343
#sudo apt-get remove nvidia-343
sudo apt-get install nvidia-340



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

install_cuda_prereq()
{
	sudo apt-get install -y libprotobuf-dev
    sudo apt-get install -y libleveldb-dev 
    sudo apt-get install -y libsnappy-dev 
    sudo apt-get install -y libopencv-dev 
    sudo apt-get install -y libboost-all-dev 
    sudo apt-get install -y libhdf5-serial-dev
    sudo apt-get install -y libgflags-dev
    sudo apt-get install -y libgoogle-glog-dev
    sudo apt-get install -y liblmdb-dev
    sudo apt-get install -y protobuf-compiler 

    sudo apt-get install -y libfreeimage-dev

    #sudo apt-get install -y gcc-4.6 
    #sudo apt-get install -y g++-4.6 
    #sudo apt-get install -y gcc-4.6-multilib
    #sudo apt-get install -y g++-4.6-multilib 
    #sudo apt-get install -y libjpeg62

    sudo apt-get install -y gfortran
    sudo apt-get install -y libatlas-base-dev 

    sudo apt-get install -y python-dev
    sudo apt-get install -y python-pip
    sudo apt-get install -y python-numpy
    sudo apt-get install -y python-pillow
}

# Get the cuda 6.5 deb file
mkdir ~/installers
cd ~/installers
wget http://developer.download.nvidia.com/compute/cuda/repos/ubuntu1404/x86_64/cuda-repo-ubuntu1404_6.5-14_amd64.deb
sudo dpkg -i cuda-repo-*
# Carefull this removes 343 drivers and puts in 340 drivers
sudo apt-get update
sudo apt-get install cuda

#sudo apt-get install nvidia-cuda-toolkit
