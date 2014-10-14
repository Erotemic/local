# Remember you have to stop the xserver before you do anything else

# ctrl+alt+f1
# stop lightdm # Unity
# stop gdm # Gnome3
# stop kdm # KDE
#/Drivers/NVIDIA-Linux-x86_64-319.32.run

#http://www.nvidia.com/download/driverResults.aspx/77525/en-us

# Add drivers repo from edgers
sudo add-apt-repository ppa:xorg-edgers/ppa -y
sudo apt-get update

# Install Correct Driver for Geforce 670 GTX
# Use 340 for cuda compadability
sudo apt-get install nvidia-340
#sudo apt-get install nvidia-343
#sudo apt-get remove nvidia-343

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

install_cuda_prereq

# Get the cuda 6.5 deb file
mkdir ~/tmp
cd ~/tmp
wget http://developer.download.nvidia.com/compute/cuda/repos/ubuntu1404/x86_64/cuda-repo-ubuntu1404_6.5-14_amd64.deb
sudo dpkg -i cuda-repo-*
# Carefull this removes 343 drivers and puts in 340 drivers
sudo apt-get update
sudo apt-get install cuda

#REBOOT

echo 'export PATH=$PATH:/usr/local/cuda/bin' >> ~/.bashrc
echo 'export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/cuda/lib64:/usr/local/lib' >> ~/.bashrc
source ~/.bashrc


#TEST 

nvcc --version
nvidia-smi


# INFO
apt-cache depends cuda
apt-cache depends nvidia-340-dev
apt-cache depends nvidia-340-uvm


# OTHER 

reinstall_nvidia()
{
    sudo apt-get remove nvidia-340-dev
    sudo apt-get remove nvidia-340
    sudo apt-get remove cuda
    sudo apt-get remove libcuda1-340
    sudo apt-get remove nvidia-libopencl1-340
    sudo apt-get remove nvidia-libopencl-icd-340
    sudo apt-get remove nvidia-settings
}

# OLD
# apt-get install nvidia-current
# Use: "nvcc --version" for CUDA version [Ex: V6.5.X]
# Use: "nvidia-smi" for driver version [Ex: 34X.XX]
#sudo apt-get install nvidia-cuda-toolkit


#export INSTALL_NVIDIA=/home/joncrall/Drivers/NVIDIA-Linux-x86_64-319.32.run
#export INSTALL_NVIDIA=/home/joncrall/Drivers/NVIDIA-Linux-x86_64-331.20.run
#manual_nvidia_install(){
#    # USE APT-GET 340
#    mkdir ~/Drivers
#    mv ~/Downloads/NVIDIA-Linux* ~/Drivers
#    ls -al ~/Drivers

#    export INSTALL_NVIDIA=~/Drivers/NVIDIA-Linux-x86_64-340.32.run
#    chmod +x $INSTALL_NVIDIA
#    sudo stop gdm
#}
# Doesnt actually seem echo correctly
#sudo cat /etc/modprobe.d/blacklist.conf
#sudo echo "blacklist nouveau" >> /etc/modprobe.d/blacklist.conf
#sudo $INSTALL_NVIDIA
