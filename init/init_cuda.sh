

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
    sudo apt search nvidia-driver

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

    # Restart, ensure you have tpl-archive and then run
    #ls ~/tpl-archive/cuda
    #source ~/local/init/init_cuda.sh
    #cuda_version=10.1
    #change_cuda_version $cuda_version
    #change_cudnn_version 10.1 7.0
}
