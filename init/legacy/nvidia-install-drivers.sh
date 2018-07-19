# See init_cuda.sh instead

# References
# http://askubuntu.com/questions/206283/how-can-i-uninstall-a-nvidia-driver-completely
# https://github.com/Theano/libgpuarray/issues/19

# Verify nvidia card model
lspci | grep -i nvidia
# Verify linux version
uname -m && cat /etc/*release

install_via_18_04_apt(){
    ubuntu-drivers devices
    sudo ubuntu-drivers autoinstall

    # https://askubuntu.com/questions/1028830/how-do-i-install-cuda-on-ubuntu-18-04

    # cuda currently needs gcc 6
    sudo apt-get install gcc-6 g++-6

    sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-6 10
    sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-7 20

    sudo update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-6 10
    sudo update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-7 20

    sudo update-alternatives --install /usr/bin/cc cc /usr/bin/gcc 30
    sudo update-alternatives --set cc /usr/bin/gcc

    sudo update-alternatives --install /usr/bin/c++ c++ /usr/bin/g++ 30
    sudo update-alternatives --set c++ /usr/bin/g++

    sudo update-alternatives --config gcc
    sudo update-alternatives --config g++


    sudo apt install nvidia-cuda-toolkit

    # can torch see cuda?
    pip install torch
    python -c "import torch; print(torch.cuda.is_available())"
}


install_nvidia_driver()
{
    # Add drivers repo from edgers
    sudo add-apt-repository ppa:xorg-edgers/ppa -y
    sudo apt update

    # Hyrule has Geforce 670 GTX
    # Will this work for the GTX 285 as well?
    # Install Correct Driver for Geforce 670 GTX
    # Use 340 for cuda compadability
    sudo apt install nvidia-340
    #sudo apt install nvidia-343
    #sudo apt remove nvidia-343
}


install_cuda_prereq()
{
	sudo apt install -y libprotobuf-dev
    sudo apt install -y libleveldb-dev 
    sudo apt install -y libsnappy-dev 
    sudo apt install -y libopencv-dev 
    sudo apt install -y libboost-all-dev 
    sudo apt install -y libhdf5-serial-dev
    sudo apt install -y libgflags-dev
    sudo apt install -y libgoogle-glog-dev
    sudo apt install -y liblmdb-dev
    sudo apt install -y protobuf-compiler 

    sudo apt install -y libfreeimage-dev

    #sudo apt install -y gcc-4.6 
    #sudo apt install -y g++-4.6 
    #sudo apt install -y gcc-4.6-multilib
    #sudo apt install -y g++-4.6-multilib 
    #sudo apt install -y libjpeg62

    sudo apt install -y gfortran
    sudo apt install -y libatlas-base-dev 

    sudo apt install -y python-dev
    sudo apt install -y python-pip
    #sudo apt install -y python-numpy
    #sudo apt install -y python-pillow
}

install_cuda_via_tpl(){

    # Prereqs
    sudo apt-get install freeglut3-dev build-essential libx11-dev libxmu-dev libxi-dev libgl1-mesa-glx libglu1-mesa libglu1-mesa-dev

    # nvidia drivers
    # For now assume these exist
    #sudo sh ~/tpl-archive/cuda/NVIDIA-Linux-x86_64-390.42.run

    # cuda drivers
    sudo sh ~/tpl-archive/cuda/cuda_9.1.85_387.26_linux.run -toolkit -silent -override
    #sudo sh ~/tpl-archive/cuda/cuda_9.1.85_387.26_linux.run
    # accept and select yes and defaults for everything
    # (maybe not the samples though)

    # A REBOOT MAY BE REQUIRED
}



install_cuda()
{
    # SEE init_cuda.sh

    # Get the cuda 6.5 deb file
    mkdir -p ~/tmp
    cd ~/tmp

    # Go to https://developer.nvidia.com/cuda-downloads
    # to get this link
    wget http://developer.download.nvidia.com/compute/cuda/7.5/Prod/local_installers/cuda-repo-ubuntu1404-7-5-local_7.5-18_amd64.deb
    sudo dpkg -i cuda-repo-ubuntu1404-7-5-local_7.5-18_amd64.deb
    sudo apt install cuda

    #wget http://developer.download.nvidia.com/compute/cuda/repos/ubuntu1404/x86_64/cuda-repo-ubuntu1404_6.5-14_amd64.deb
    #sudo dpkg -i cuda-repo-*

    sudo apt install nvidia-cuda-toolkit

    # Carefull this removes 343 drivers and puts in 340 drivers
    #sudo apt update
    #sudo apt install cuda

    #REBOOT

    echo 'export PATH=$PATH:/usr/local/cuda/bin' >> ~/.bashrc
    echo 'export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/cuda/lib64:/usr/local/lib' >> ~/.bashrc
    source ~/.bashrc

    # update ldconfig cache
    sudo ldconfig /usr/local/cuda/lib64
}

install_nvidia_driver
install_cuda_prereq
install_cuda

# Need to reboot here
#TEST 

test_nvidia()
{
    nvcc --version
    nvidia-smi

    python -c "import theano"
    python -c "import theano; print(theano.__file__)"
    python -c "import cv2; print(cv2.__file__)"
    python -m ibeis_cnn
    python -m ibeis_cnn._plugin --test-generate-species-background:0 --show

    # May need to recompile theano and pylearn2 
    # git rm -rf * in the code dir 
    # then sudo python setup.py develop
}


fix_permission_issues()
{

    sudo pip install PyYAML --upgrade

    sudo python -m ibeis_cnn
    sudo python -m ibeis
    python -m ibeis_cnn

    sudo chown -R joncrall:joncrall ~/.theano/*

    rm -rf ~/.theano/*

    python -m ibeis_cnn
    python -m ibeis_cnn._plugin --test-generate-species-background:0 --show
    #python -m ibeis_cnn._plugin --exec-detect_annot_zebra_background_mask --show
}

# INFO
apt-cache depends cuda
apt-cache depends nvidia-340-dev
apt-cache depends nvidia-340-uvm
apt-cache depends nvidia-340
apt-cache depends nvidia-settings


# OTHER 

purge_nvidia_drivers_and_cuda()
{

    # Part for removing what was there
    #sudo apt remove cuda
    #sudo apt remove libcuda1-340

    #sudo apt remove nvidia-340-dev
    #sudo apt remove nvidia-340
    #sudo apt remove nvidia-libopencl1-340
    #sudo apt remove nvidia-libopencl-icd-340
    #sudo apt remove nvidia-opencl-icd-340
    #sudo apt remove nvidia-settings

    sudo apt remove --purge nvidia-*
    sudo apt remove --purge libcuda1-3*
    sudo apt remove --purge cuda*
    sudo apt autoremove

    sudo apt update

    # List what nvidia packages are still installed
    dpkg -l | grep -i nvidia
    dpkg -l | grep -i nvcc

    # Remove cuda parts
    sudo apt remove nvidia-cuda-toolkit
    #sudo apt autoremove  # optional

    sudo rm -rf /usr/local/cuda*

    locate nvidia | grep -v joncrall
}

purge_docker()
{
    # maybe remove docker if you are also removing nvidia
    dpkg -l | grep -i docker

    sudo apt remove --purge docker-ce
    sudo apt remove --purge docker
    sudo apt remove --purge docker.io
    sudo apt remove --purge nvidia-docker2

    sudo rm -rf /var/lib/nvidia-docker
    sudo rm -rf /var/lib/docker
    sudo rm -rf /etc/docker

    sudo updatedb

    locate docker | grep -v joncrall

    sudo rm -rf /etc/apparmor.d/docker
    sudo rm -rf /etc/apparmor.d/cache/docker
}

purge_virtualbox(){
    # it seems virtualbox may also cause problems
    # https://askubuntu.com/questions/703746/how-to-completely-remove-virtualbox


    __heredoc__ " 
    When I was messing with acidialias boot issues I used
    ` systemctl status `
    and saw my system was degraded so I then did
    
    ` systemctl --failed `
    and saw that virtualbox failed to load
    "

    dpkg -l | grep -i virtual
    dpkg -l | grep -i vagrant

    sudo apt-get remove --purge virtualbox 
    sudo apt-get remove --purge vagrant
    sudo apt-get remove --purge virtualbox-dkms
    sudo apt-get remove --purge unity-scope-virtualbox
    
}


ooo_nvidia_gtx_285()
{
    cd ~/tmp
    #probably should just use apt
    #http://www.nvidia.com/download/driverResults.aspx/95165/en-us
    #wget http://www.nvidia.com/content/DriverDownload-March2009/confirmation.php?url=/XFree86/Linux-x86_64/340.96/NVIDIA-Linux-x86_64-340.96.run
    #export INSTALL_NVIDIA=~/Drivers/NVIDIA-Linux-x86_64-340.32.run
    #chmod +x $INSTALL_NVIDIA
    #sudo stop gdm
}

# OLD
# Remember you have to stop the xserver before you do anything else

# ctrl+alt+f1
# stop lightdm # Unity
# stop gdm # Gnome3
# stop kdm # KDE
#/Drivers/NVIDIA-Linux-x86_64-319.32.run

#http://www.nvidia.com/download/driverResults.aspx/77525/en-us
# apt install nvidia-current
# Use: "nvcc --version" for CUDA version [Ex: V6.5.X]
# Use: "nvidia-smi" for driver version [Ex: 34X.XX]
#sudo apt install nvidia-cuda-toolkit


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


#remove_upgraded_nvidia_drivers(){
#    # Ubuntu upgraded my drivers, and that broke cuda
#    echo 'foo'
#    # This is my attemp to remove them. 
#    # apt-cache depends nvidia-340-dev reports
#    #  Depends: nvidia-340
#    #  Conflicts: nvidia-340-dev:i386

#    #sudo apt remove nvidia-340-dev:i386
#    #sudo apt remove nvidia-340-uvm:i386

#    # Actually, I'm just going to try reinstalling
#}
