#!/bin/bash

install_nivida_drivers_apt(){
    __doc__="
    This function contains notes about commands related to nvidia driver
    installs and fixing issue when you run into things like where nvidia-smi
    can't find the driver.

    As of 2024, apt seems like a reasonably stable way to get nvidia drivers at
    least on 22.04 and 24.04. Previously this used to be a lot tricker, see
    legacy/init_cuda_old.sh for older versions of the tools.
    "
    #sudo add-apt-repository ppa:graphics-drivers/ppa
    #sudo apt-get update
    #sudo apt remove --purge nvidia-*
    #sudo apt install nvidia-drivers-396

    # Check what ubuntu knows about
    ubuntu-drivers devices

    # Check what is already installed
    sudo apt list --installed | grep nvidia

    # Check what is available
    apt-cache search 'nvidia-driver-' | grep '^nvidia-driver-[0-9]* ' | sort -h

    # It looks like this one works with the above PPA (maybe?)

    sudo add-apt-repository ppa:graphics-drivers -y
    sudo apt update
    #sudo apt install nvidia-drivers-396
    sudo apt install nvidia-driver-435

    apt-cache search 'nvidia-driver-' | grep '^nvidia-driver-*'
    sudo apt install nvidia-driver-525 nvidia-dkms-525
    sudo apt install nvidia-driver-525

    # Installing a newer version seems to correctly flag old versions for removal
    sudo apt remove nvidia-driver-545
    sudo apt remove libnvidia-compute-545
    sudo apt autoremove
    sudo apt list --installed | grep nvidia

    # Seems stable on Ubuntu 22.04
    sudo apt install nvidia-driver-535

    sudo apt install nvidia-driver-560  # dne

    sudo apt install nvidia-driver-545

    sudo apt install nvidia-driver-530

    sudo apt install nvidia-driver-550

    # Try out 525
    sudo apt install nvidia-driver-525

    # Restart, ensure you have tpl-archive and then run
    #ls ~/tpl-archive/cuda
    #source ~/local/init/init_cuda.sh
    #cuda_version=10.1
    #change_cuda_version $cuda_version
    #change_cudnn_version 10.1 7.0
}


install_cuda_toolkit_and_cudnn(){
    __doc__="
    https://developer.nvidia.com/cuda-downloads?target_os=Linux&target_arch=x86_64&Distribution=Debian&target_version=12&target_type=deb_local

    https://docs.nvidia.com/cuda/cuda-installation-guide-linux/#network-repo-installation-for-ubuntu

    https://developer.nvidia.com/cudnn-downloads
    "
    wget https://developer.download.nvidia.com/compute/cuda/12.6.3/local_installers/cuda-repo-debian12-12-6-local_12.6.3-560.35.05-1_amd64.deb
    sudo dpkg -i cuda-repo-debian12-12-6-local_12.6.3-560.35.05-1_amd64.deb
    sudo cp /var/cuda-repo-debian12-12-6-local/cuda-*-keyring.gpg /usr/share/keyrings/
    sudo add-apt-repository contrib
    sudo apt-get update
    sudo apt-get -y install cuda-toolkit-12-6

    sudo apt-get install zlib1g

    OS_ID="$(lsb_release --short --id)"
    if [[ "$OS_ID" == "Ubuntu" ]]; then
        VERSION=$(lsb_release -rs)
        if [[ "$VERSION" == "20.04" ]]; then
            _DISTRO="ubuntu2004"
        elif [[ "$VERSION" == "22.04" ]]; then
            _DISTRO="ubuntu2204"
        elif [[ "$VERSION" == "24.04" ]]; then
            _DISTRO="ubuntu2404"
        else
            echo "Unsupported Ubuntu version: $VERSION"
        fi
    else
        echo "Unsupported OS: $OS_ID"
    fi
    _ARCH=$(arch)
    wget https://developer.download.nvidia.com/compute/cuda/repos/"${_DISTRO}"/"${_ARCH}"/cuda-keyring_1.1-1_all.deb
    sudo dpkg -i cuda-keyring_1.1-1_all.deb

    sudo apt-get update
    sudo apt-get -y install cudnn
    sudo apt-get -y install cudnn-cuda-11
    sudo apt-get -y install cudnn-cuda-12





}
