#http://sn0v.wordpress.com/2012/12/07/installing-cuda-5-on-ubuntu-12-04/

#http://docs.nvidia.com/cuda/cuda-getting-started-guide-for-linux/index.html#package-manager-installation


init_cuda_with_deb_pkg(){
    # First download the deb from https://developer.nvidia.com/cuda-downloads
    sudo dpkg -i ~/Downloads/cuda-repo-ubuntu1604-8-0-local-ga2_8.0.61-1_amd64.deb
    sudo apt-get update
    sudo apt-get install cuda
}


init_local_cuda(){
    # Download the correct version packages from nvidia
    # https://developer.nvidia.com/cuda-downloads

    # Sync between machines
    rsync -avp ~/cuda-archive/ jon.crall@arisia.kitware.com:cuda-archive
    rsync -avp ~/cuda-archive/ jon.crall@aretha.kitware.com:cuda-archive

    CUDA_INSTALL=$(python -c "$(codeblock "
    from os.path import join, exists, expanduser

    # SET TO CURRENT VERSION YOU WANT
    cuda = '8.0'
    osname = 'linux'
    type = 'run'

    # (cuda_version, os, installer-type)
    ver = {}
    ver[('8.0', 'linux', 'run')] = 'cudnn-8.0-linux-x64-v7.tgz'

    fname = ver[(cuda, osname, type)]
    fpath = join(expanduser('~/cuda-archive'), fname)
    assert exists(fpath)
    print(fpath)
    ")")
}


init_local_cudnn(){
    # Download the correct version packages from nvidia
    # https://developer.nvidia.com/rdp/cudnn-download

    # Sync between machines
    rsync -avp ~/cuda-archive/ jon.crall@arisia.kitware.com:cuda-archive
    rsync -avp ~/cuda-archive/ jon.crall@aretha.kitware.com:cuda-archive

    CUDNN_TGZ=$(python -c "$(codeblock "
    from os.path import join, exists, expanduser

    # SET TO CURRENT VERSION YOU WANT
    cuda = '8.0'
    cudnn = '7.0'
    osname = 'linux'

    # (cuda_version, cudnn_version, os)
    ver = {}
    ver[('8.0', '7.0', 'linux')] = 'cudnn-8.0-linux-x64-v7.tgz'
    ver[('9.0', '7.0', 'linux')] = 'cudnn-9.0-linux-x64-v7.tgz'

    fname = ver[(cuda, cudnn, osname)]
    fpath = join(expanduser('~/cuda-archive'), fname)
    assert exists(fpath)
    print(fpath)
    ")")
    echo "CUDNN_TGZ = $CUDNN_TGZ"

    mkdir -p ~/.local
    # Navigate to <cudnnpath> and unzip cudnn
    CUDNNPATH="$HOME/tmp"
    cd $CUDNNPATH
    tar -xzvf $CUDNN_TGZ

    # Then copy the files into your cudadir
    CUDADIR=$HOME/.local/cuda
    mkdir -p $CUDADIR
    mkdir -p $CUDADIR/include
    mkdir -p $CUDADIR/lib64
    cp cuda/include/cudnn.h $CUDADIR/include
    cp cuda/lib64/libcudnn* $CUDADIR/lib64
    chmod a+r $CUDADIR/include/cudnn.h
}


init_cudnn(){
    # Download the DEB packages from nvidia
    # https://developer.nvidia.com/rdp/cudnn-download

    # runtime
    sudo dpkg -i ~/Downloads/libcudnn6_6.0.21-1+cuda8.0_amd64.deb
    # dev
    sudo dpkg -i ~/Downloads/libcudnn6-dev_6.0.21-1+cuda8.0_amd64.deb
    # doc
    sudo dpkg -i ~/Downloads/libcudnn6-doc_6.0.21-1+cuda8.0_amd64.deb

    sudo apt-get update

    #cd ~/tmp
    #tar -xvzf ~/Downloads/cudnn-8.0-linux-x64-v6.0.tgz
}


oldcudastuff(){
    sudo apt-get install libxi-dev libxmu-dev freeglut3-dev build-essential binutils-gold

    # GeForce 600 Series GTX 670 Linux 64-bit

    # EVGA 04G-P4-2673-KR GeForce GTX 670 Superclocked+ w/Backplate 4GB 256-bit GDDR5 PCI Express 3.0 x16 HDCP Ready SLI Support ...

    #sudo gvim /etc/modprobe.d/blacklist.conf


    # Verify supported linux
    uname -m && cat /etc/*release

    # Verify NVIDIA Card
    lspci | grep -i nvidia

    sudo /usr/bin/nvidia-uninstall

    # ARMv7 cross development
    sudo apt-get install g++-4.6-arm-linux-gnueabihf


    # Dont use the DEB
    cd tmp
    wget http://developer.download.nvidia.com/compute/cuda/6_0/rel/installers/cuda_6.0.37_linux_64.run

    # Stop X
    Ctrl+Alt+F1
    sudo service lightdm stop

    chmod +x cuda_6.0.37_linux_64.run
    ./cuda_6.0.37_linux_64.run


    # Downloading the CUDA toolkit deb
    # Install the deb file
    http://developer.download.nvidia.com/compute/cuda/repos/ubuntu1204/x86_64/cuda-repo-ubuntu1204_6.0-37_amd64.deb
    # This line did bad things
    #sudo sh -c \ 'echo "foreign-architecture armhf" >> /etc/dpkg/dpkg.cfg.d/multiarch'
    sudo apt-get update
    sudo apt-get install cuda

    export PATH=/usr/local/cuda-6.0/bin:$PATH
    export LD_LIBRARY_PATH=/usr/local/cuda-6.0/lib64:$LD_LIBRARY_PATH
}

#==========================

# Download
cd ~/tmp
http://developer.download.nvidia.com/compute/cuda/6_5/rel/installers/cuda_6.5.14_linux_64.run
chmod +x cuda_*
#wget http://developer.download.nvidia.com/compute/cuda/4_2/rel/toolkit/cudatoolkit_4.2.9_linux_64_ubuntu11.04.run
#wget http://developer.download.nvidia.com/compute/cuda/4_2/rel/sdk/gpucomputingsdk_4.2.9_linux.run

# Install 
cd ~/Downloads
chmod +x cudatoolkit_4.2.9_linux_*
sudo ./cudatoolkit_4.2.9_linux_*

export PATH=$PATH:/opt/cuda/bin
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/opt/cuda/lib:/opt/cuda/lib64
echo 'export PATH=$PATH:/opt/cuda/bin' >> ~/.bash_profile
echo 'export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/opt/cuda/lib:/opt/cuda/lib64' >> ~/.bash_profile

# compile
cd ~/NVIDIA_GPU_Computing_SDK/C
LINKFLAGS=-L/usr/lib/nvidia-current/ make cuda-install=/opt/cuda


test()
{
~/NVIDIA_GPU_Computing_SDK/C/bin/linux/release/./fluidsGL
optirun ~/NVIDIA_GPU_Computing_SDK/C/bin/linux/release/./fluidsGL
}

cleanup()
{
    cd ~/Desktop
    rm cudatoolkit_4.2.9_linux_*
    rm gpucomputingsdk_4.2.9_linux.run
}

remove_cuda()
{
    rm -r ~/NVIDIA_GPU_Computing_SDK
    sudo rm -r /opt/cuda
}

makecudarc()
{
python -c 'import theano; print theano.config'

THEANO_FLAGS='floatX=float32,device=gpu0,nvcc.fastmath=True'


echo "____________"
THEANO_FLAGS='device=cpu' python gpu.py
echo "____________"
THEANO_FLAGS='device=gpu' python gpu.py
echo "____________"

sh -c 'cat > ~/.theanorc << EOF
[cuda]
root = /usr/local/cuda
[global]
device = gpu
floatX = float32
EOF'

#http://deeplearning.net/software/theano/library/config.html
cat ~/.theanorc



sh -c 'cat > ~/.theanorc << EOF
[cuda]
root = /usr/local/cuda
[global]
device = gpu
floatX = float64
force_device=True
allow_gc=False
print_active_device=True
EOF'

}
