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

    # https://stackoverflow.com/questions/39379792/install-cuda-without-root

    # Sync between machines
    cd
    rsync -avuzpR tpl-archive/ jon.crall@arisia.kitware.com
    rsync -avzupR tpl-archive/ jon.crall@aretha.kitware.com:

    rsync -avzup tpl-archive/cuda/ jon.crall@arisia.kitware.com:tpl-archive/cuda
    rsync -avzup tpl-archive/cuda/ jon.crall@aretha.kitware.com:tpl-archive/cuda

    tar -xf cuda_cluster_pkgs_9.1.85_ubuntu1604.tar.gz
    mv cuda_cluster_pkgs_ubuntu1604 ~/tmp
    cd ~/tmp/cuda_cluster_pkgs_ubuntu1604

    CUDA_INSTALL=$(python -c "$(codeblock "
    from os.path import join, exists, expanduser

    # SET TO CURRENT VERSION YOU WANT
    cuda = '8.0'
    osname = 'linux'
    type = 'run'

    # (cuda_version, os, installer-type) = (run, patch)
    ver = {}
    ver[('8.0', 'linux', 'run')] = ('cuda_8.0.61_375.26_linux.run', cuda_8.0.61.2_linux.run)

    fname = ver[(cuda, osname, type)]
    fpath = join(expanduser('~/tpl-archive/cuda'), fname)
    assert exists(fpath)
    print(fpath)
    ")")
}


current_cudnn_info()
{
    "
        source ~/local/init/init_cuda.sh
        current_cudnn_info
    "
    CUDNN_INCLUDE_PATH="$HOME/.local/cuda/include"
    CUDNN_LIB_PATH="$HOME/.local/cuda/lib64"
    echo ""
    echo "--- CUDNN INFO ---"
    echo "Relevant ENV Vars"
    echo " * CUDNN_LIBRARIES = $CUDNN_LIBRARIES"
    echo " * CUDNN_LIB_DIR = $CUDNN_LIB_DIR"
    echo " * CUDNN_INCLUDE_DIR = $CUDNN_INCLUDE_DIR"
    echo ""
    echo "Relevant Paths"
    echo "$CUDNN_INCLUDE_PATH"
    echo ""
    ls -al $CUDNN_INCLUDE_PATH
    echo ""
    echo "$CUDNN_LIB_PATH"
    echo ""
    ls -al $CUDNN_LIB_PATH
    echo "------"
    echo ""
}

uninstall_local_cuda()
{
    "
        source ~/local/init/init_cuda.sh
        uninstall_local_cuda
    "
    # Uninstall old local cuda via manifest
    python -c "$(codeblock "
    import os
    import ubelt as ub

    def subfiles(dpath):
        for dirpath, dirnames, filenames in os.walk(dpath):
            for fname in filenames:
                yield os.path.join(dirpath, fname)

    manifest_fpath = ub.truepath('$HOME/.local/cuda/manifest_cuda.txt')
    if os.path.exists(manifest_fpath):
        lines = list(open(manifest_fpath, 'r').readlines())
        print(len(lines))
        for line in lines:
            if line.startswith('#'):
                continue
            mode, *rest = line.strip().split(':')
            path = ':'.join(rest)

            # remove hash
            if mode in ['link', 'file']:
                *parts, hash = path.split(':')
                path = ':'.join(parts)

            elif os.path.exists(path) or os.path.islink(path):
                if mode == 'link' and os.path.islink(path): 
                    print('UNLINK ' + path)
                    os.unlink(path)
                elif mode == 'file':
                    print('REMOVE ' + path)
                    #ub.delete(path)
                    os.remove(path)
                elif mode == 'dir':
                    children = list(subfiles(path))
                    if len(children) > 0:
                        #print('NOT REMOVING ({} children) {}'.format(len(children), path))
                        #print(children)
                        pass
                    elif len(children) == 0:
                        print('RMDIR ' + path)
                        #ub.delete(path)
                        os.rmdir(path)
                else:
                    raise Exception(mode)
    ")"
}


change_cuda_version()
{

    # Install desired cuda version
    uninstall_local_cuda

    # version 8
    #sh ~/tpl-archive/cuda/cuda-linux64-rel-8.0.61-21551265.run -prefix=$HOME/.local/cuda -noprompt -manifest $HOME/.local/cuda/manifest_cuda.txt -nosymlink 

    # version 9
    sh ~/tpl-archive/cuda/cuda-linux.9.1.85-23083092.run -prefix=$HOME/.local/cuda -noprompt -manifest $HOME/.local/cuda/manifest_cuda.txt -nosymlink 

    # IS there any way to get these to work locally?
    sh ~/tpl-archive/cuda/NVIDIA-Linux-x86_64-387.26.run --help
    sh ~/tpl-archive/cuda/NVIDIA-Linux-x86_64-387.26.run -a
    sh ~/tpl-archive/cuda/NVIDIA-Linux-x86_64-387.26.run -a -x 
    sh ~/tpl-archive/cuda/NVIDIA-Linux-x86_64-387.26.run --info
}

prep_cuda_runfile(){
    # Extract the actual cuda installer to the tpl-dir
    sh ~/tpl-archive/cuda/cuda_8.0.61_375.26_linux.run --silent --toolkitpath=$HOME/.local/cuda/ --no-opengl-libs --verbose --extract=$HOME/tpl-archive/cuda
    # only keep the toolkit, remove the driver and samples
    rm $HOME/tpl-archive/cuda/NVIDIA-Linux-x86_64-375.26.run
    rm $HOME/tpl-archive/cuda/cuda-samples-linux-8.0.61-21551265.run

    
    sh ~/tpl-archive/cuda/cuda_9.1.85_387.26_linux.run --silent --toolkitpath=$HOME/.local/cuda/ --no-opengl-libs --verbose --extract=$HOME/tpl-archive/cuda
    #rm $HOME/tpl-archive/cuda/NVIDIA-Linux-x86_64-387.26.run
    rm $HOME/tpl-archive/cuda/cuda-samples.9.1.85-23083092-linux.run
}



change_cudnn_version(){
    "
        source ~/local/init/init_cuda.sh
        change_cudnn_version 7.0
        change_cudnn_version 6.0
        change_cudnn_version 5.1

        current_cudnn_info
    "
    python -c "$(codeblock "
        from os.path import join, exists, expanduser, splitext, relpath
        import ubelt as ub

        # SET TO CURRENT VERSION YOU WANT
        cuda = '8.0'
        #cudnn = '7.0'
        cudnn = '$1'
        osname = 'linux'

        # (cuda_version, cudnn_version, os)
        ver = {}
        ver[('9.1', '7.0', 'linux')] = 'cudnn-9.1-linux-x64-v7.tgz'
        ver[('9.0', '7.0', 'linux')] = 'cudnn-9.0-linux-x64-v7.tgz'
        ver[('8.0', '7.0', 'linux')] = 'cudnn-8.0-linux-x64-v7.tgz'
        ver[('8.0', '6.0', 'linux')] = 'cudnn-8.0-linux-x64-v6.0.tgz'
        ver[('8.0', '5.1', 'linux')] = 'cudnn-8.0-linux-x64-v5.1.tgz'

        print('Unpacking cudnn {} for cuda {} on {}'.format(cudnn, cuda, osname))

        home = expanduser('~')
        cudnn_tgz_fname = ver[(cuda, cudnn, osname)]
        cudnn_tgz_fpath = join(home, 'tpl-archive', 'cuda', cudnn_tgz_fname)
        assert exists(cudnn_tgz_fpath)

        suffix = splitext(cudnn_tgz_fname)[0].replace('cudnn-', '')

        # Navigate to <cudnnpath> and unzip cudnn
        cudnn_dir = ub.ensuredir(((home, 'tmp', 'cudnn', suffix)))
        import os
        os.chdir(cudnn_dir)
        ub.cmd('tar -xzvf ' + cudnn_tgz_fpath, verbose=2)

        # Setup the local install paths for cudnn
        install_prefix = ub.ensuredir((home, '.local'))
        cuda_dpath = ub.ensuredir((install_prefix, 'cuda'))
        include_dpath = ub.ensuredir((cuda_dpath, 'include'))
        lib_dpath = ub.ensuredir((cuda_dpath, 'lib64'))

        # Finally copy the files into your cudadir
        import shutil
        import glob

        srcdir = join(cudnn_dir, 'cuda')
        dstdir = join(install_prefix, 'cuda')

        print('Removing old CUDNN')
        iters = [
            glob.iglob(dstdir + '/lib64/libcudnn.so*'),
            glob.iglob(dstdir + '/lib64/libcudnn_static.a*'),
            glob.iglob(dstdir + '/include/cudnn.h'),
        ]
        import itertools as it
        for path in it.chain.from_iterable(iters):
            ub.delete(path, verbose=True)

        print('Install new CUDNN')
        for src in glob.iglob(srcdir + '/*/*', recursive=True):
            name = relpath(src, srcdir)
            dst = join(dstdir, name)
            print('copying {} -> {}'.format(src, dst))
            # use cp -P to preserve the relative symlinks
            ub.cmd(('cp', '-P', src, dst), verbout=1, verbose=2)
            #shutil.copy2(src, dst)

        src = join(cudnn_dir, 'cuda', 'include')

        ub.cmd('chmod a+r ' + dstdir + '/include/cudnn.h', verbose=2)
        ")"
}


init_local_cudnn(){
    # Download the correct version packages from nvidia
    # https://developer.nvidia.com/rdp/cudnn-download

    # Sync between machines
    mkdir -p ~/tpl-archive/cuda
    #~/tpl-archive/cuda
    #rsync -avpR ~/tpl-archive/ arisia:tpl-archive
    #rsync -avpR ~/tpl-archive/ aretha:tpl-archive
    rsync -avuzpR tpl-archive/ jon.crall@arisia.kitware.com
    rsync -avzupR tpl-archive/ jon.crall@aretha.kitware.com:

    # check for user cuda
    ls ~/.local/cuda/lib64/libcudnn*
    ls ~/.local/cuda/include/cudnn*
    # check for system cuda
    ls /usr/local/cuda/lib64/libcudnn*
    ls /usr/local/cuda/lib64/
    ls /usr/local/cuda/include/cudnn*

    change_cudnn_version 6.0

    tree /home/joncrall/.local/cuda/
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


main_cuda(){

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

}


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
