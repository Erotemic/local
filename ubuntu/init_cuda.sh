sudo apt-get install libxi-dev libxmu-dev freeglut3-dev build-essential binutils-gold


# Download
cd ~/Desktop
wget http://developer.download.nvidia.com/compute/cuda/4_2/rel/toolkit/cudatoolkit_4.2.9_linux_64_ubuntu11.04.run
wget http://developer.download.nvidia.com/compute/cuda/4_2/rel/sdk/gpucomputingsdk_4.2.9_linux.run

# Install 
cd ~/Desktop
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

