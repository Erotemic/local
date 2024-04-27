#!/usr/bin/env bash
__doc__="
A graveyard for old bash scripts related to old versions of software that
probably don't matter anymore.
"


setup_venv3(){
    __doc__="
    CommandLine:
        source ~/local/init/freshstart_ubuntu.sh && setup_venv3
    "
    # Ensure PIP, setuptools, and virtual are on the SYSTEM
    if [ "$(has_pymodule python3 pip)" == "False" ]; then
    #if [ "$(which pip3)" == "" ]; then
        ensure_curl
        mkdir -p ~/tmp
        curl https://bootstrap.pypa.io/get-pip.py > ~/tmp/get-pip.py

        # Test if we have distutils; if not, install it.
        python3 -c "from distutils import sysconfig as distutils_sysconfig"
        if [ "$?" != "0" ]; then
            sudo apt install python3-distutils -y
        fi

        python3 ~/tmp/get-pip.py --user
    fi
    python3 -m pip install pip setuptools virtualenv -U --user

    #python3 -c "import sys; print(sys.version)"
    #PYVERSUFF=$(python3 -c "import sys; print('.'.join(map(str, sys.version_info[0:3])))")
    #PYVERSUFF=$(python3 -c "import sysconfig; print(sysconfig.get_config_var('LDVERSION'))")
    PYEXE=$(python3 -c "import sys; print(sys.executable)")
    PYVERSUFF=$(python3 -c "import sysconfig; print(sysconfig.get_config_var('VERSION'))")
    PYTHON3_VERSION_VENV="$HOME/venv$PYVERSUFF"
    mkdir -p "$PYTHON3_VERSION_VENV"
    python3 -m virtualenv -p "$PYEXE" "$PYTHON3_VERSION_VENV"
    python3 -m virtualenv --relocatable "$PYTHON3_VERSION_VENV"

    PYTHON3_VENV="$HOME/venv3"
    # symlink to the real env
    ln -s "$PYTHON3_VERSION_VENV" "$PYTHON3_VENV"

    #python3 -m virtualenv -p /usr/bin/python3 $PYTHON3_VENV
    # source $PYTHON3_VENV/bin/activate

    # Now ensure the correct pip is installed locally
    #pip3 --version
    # should be for 3.x
}

dev_fix_venv_mismatched_version(){
    __doc__="
    This might fix the cmath import issue?
    "
    # Check if the virtualenv and system python are on the same patch version
    # IF THEY HAVE DIFFERENT MAJOR/MINOR VERSONS DO NOTHING HERE!
    "$VIRTUAL_ENV"/bin/python --version
    /usr/bin/python3 --version

    # overwrite the virtualenv python with a fresh copy of the system python
    cp "$VIRTUAL_ENV"/bin/python "$VIRTUAL_ENV"/bin/python.bakup
    sha1sum  "$VIRTUAL_ENV"/bin/python.bakup
    sha1sum  "$VIRTUAL_ENV"/bin/python
    sha1sum  /usr/bin/python3

    lsof  "$VIRTUAL_ENV"/bin/python

    cp /usr/bin/python3 "$VIRTUAL_ENV"/bin/python
}


setup_poetry_env(){

    mkdir -p ~/tmp
    cd ~/tmp
    URL=https://raw.githubusercontent.com/python-poetry/poetry/1.1.5/get-poetry.py
    EXPECT_SHA256=e973b3badb95a916bfe250c22eeb7253130fd87312afa326eb02b8bdcea8f4a7
    curl -sSL $URL > get-poetry.py
    GOT_SHA256=$(sha256sum get-poetry.py | cut -d' ' -f1)
    # For security, it is important to verify the hash
    if [[ "$GOT_SHA256" != "$EXPECT_SHA256" ]]; then
        echo "Downloaded file does not match hash! DO NOT CONTINUE!"
        exit 1;
    fi
    python get-poetry.py

    #$HOME/.poetry/bin/poetry self update
    #$HOME/.poetry/bin/poetry env info

    PYENV_PREFIX=$(pyenv prefix)
    VENV_PREFIX=$PYENV_PREFIX/envs
    mkdir -p "$VENV_PREFIX"

    python -m venv "$VENV_PREFIX"/py38
    source "$VENV_PREFIX"/py38/bin/activate

}


pyenv_packages(){
    pip install pip -U
    pip install numpy
    pip install torch torchvision
    pip install scipy networkx scikit-learn scikit-image
    pip install psutil networkx Pillow scikit-image sympy
    pip install numpy scipy matplotlib pandas seaborn
    pip install pyqt5
    pip install pyyaml ipython
    pip install line_profiler
    pip install six pep8 autopep8 flake8 pylint
    pip install pygtrie
    pip install dvc[all]
    pip install pytest
    pip install parse
    pip install jedi
    pip install scikit-build cmake ninja
    pip install tensorboard

    pip install opencv-python-headless

    pip install tensorflow

    # Try installing gdal without conda
    sudo add-apt-repository ppa:ubuntugis/ppa -y
    sudo apt-get update -y
    sudo apt-get install gdal-bin libgdal-dev -y

    GDAL_PREFIX=$(gdal-config --prefix)
    CFLAGS=$(gdal-config --cflags)
    GDAL_VERSION=$(gdal-config --version)
    echo "GDAL_PREFIX = $GDAL_PREFIX"
    echo "GDAL_VERSION = $GDAL_VERSION"
    CFLAGS=$CFLAGS pip install GDAL=="$GDAL_VERSION"
    #CFLAGS=$CFLAGS CPLUS_INCLUDE_PATH=$GDAL_PREFIX/include/gdal C_INCLUDE_PATH=$GDAL_PREFIX/gdal pip install GDAL==$GDAL_VERSION
    python -c "import osgeo"
    python -c "from osgeo import gdal; print(gdal.Open)"
    # python -c "import osr"
}



setup_conda_env(){

    # Miniconda3-latest-Linux-ppc64le.sh
    # Miniconda3-latest-Linux-x86_64.sh
    # Miniconda3-latest-MacOSX-x86_64.pkg
    # Miniconda3-latest-MacOSX-x86_64.sh
    # Miniconda3-latest-Windows-x86.exe
    # Miniconda3-latest-Windows-x86_64.exe
    mkdir -p ~/tmp/setup-conda
    cd ~/tmp/setup-conda
    #https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
    # See https://docs.conda.io/en/latest/miniconda_hashes.html for updating
    # to newer versions

    # To update to a newer version see:
    # https://docs.conda.io/en/latest/miniconda_hashes.html for updating
    # https://docs.conda.io/en/latest/miniconda.html#linux-installers
    CONDA_VERSION=4.10.3
    CONDA_PY_VERSION=py38
    #ARCH="$(dpkg --print-architecture)"  # different convention
    ARCH="$(arch)"
    OS=Linux
    CONDA_KEY="${CONDA_PY_VERSION}_${CONDA_VERSION}-${OS}-${ARCH}"
    echo "CONDA_KEY = $CONDA_KEY"
    CONDA_INSTALL_SCRIPT="Miniconda3-${CONDA_KEY}.sh"
    CONDA_URL="https://repo.anaconda.com/miniconda/${CONDA_INSTALL_SCRIPT}"

    declare -A CONDA_KNOWN_HASHES=(
        ["py38_4.10.3-Linux-x86_64-sha256"]="935d72deb16e42739d69644977290395561b7a6db059b316958d97939e9bdf3d"
        ["py38_4.10.3-Linux-aarch64-sha256"]="19584b4fb5c0656e0cf9de72aaa0b0a7991fbd6f1254d12e2119048c9a47e5cc"
    )
    CONDA_EXPECTED_SHA256="${CONDA_KNOWN_HASHES[${CONDA_KEY}-sha256]}"
    echo "CONDA_EXPECTED_SHA256 = $CONDA_EXPECTED_SHA256"

    curl "$CONDA_URL" > "$CONDA_INSTALL_SCRIPT"

    # For security, it is important to verify the hash
    echo "${CONDA_EXPECTED_SHA256}  ${CONDA_INSTALL_SCRIPT}" > conda_expected_hash.sha256
    if ! sha256sum --status -c conda_expected_hash.sha256; then
        GOT_HASH=$(sha256sum "$CONDA_INSTALL_SCRIPT")
        echo "GOT_HASH      = $GOT_HASH"
        echo "EXPECTED_HASH = $CONDA_EXPECTED_SHA256"
        echo "Downloaded file does not match hash! DO NOT CONTINUE!"
    else
        echo "Hash verified, continue with install"
        chmod +x "$CONDA_INSTALL_SCRIPT "
        # Install miniconda to user local directory
        _CONDA_ROOT=$HOME/.local/conda
        sh "$CONDA_INSTALL_SCRIPT" -b -p "$_CONDA_ROOT"
        # Activate the basic conda environment
        source "$_CONDA_ROOT/etc/profile.d/conda.sh"
        # Update the base
        conda update --name base conda --yes

        #conda update -y -n base conda
        conda create -y -n conda38 python=3.8 --override-channels --channel conda-forge
        #conda activate conda38
    fi

    #conda create -y -n conda39 python=3.9
    #conda create -y -n py37 python=3.7
    #conda create -y -n py36 python=3.6
    #conda remove --name py36 --all
}

setup_conda_other(){

    conda create -y -n py39 python=3.9
    conda create -y -n py38 python=3.8
    conda create -y -n py37 python=3.7
    conda create -y -n py36 python=3.6
    conda create -y -n py35 python=3.5
    conda create -y -n py27 python=2.7
    conda create -y -n py26 python=2.6
    conda activate py36
}

setup_conda_test(){
    conda remove --name py37_test --all
    conda create -y -n py37_test python=3.7
    conda activate py37_test
}


setup_conda27_env(){
    conda update -y -n base conda
    conda create -y -n py27 python=2.7
    conda activate py27
}

install_conda_basics(){

    pip install pip -U
    pip install -e ~/code/xdoctest
    pip install -e ~/code/ubelt
    pip install -e ~/code/utool
    pip install -e ~/code/vtool

    pip install -r ~/code/ubelt/optional-requirements.txt
    pip install pytest

    pip install six
    pip install jedi
    pip install ipython
    pip install pep8 autopep8 flake8 pylint line_profiler

    pip install psutil networkx Pillow scikit-image sympy

    pip install numpy scipy matplotlib
    pip install opencv-python
    pip install pyqt5

    pip install pyyaml
    pip install pygtrie pyqtree

    pip install tensorboard tensorflow

    pip install -e ~/local/vim/vimfiles/bundle/vimtk

    #conda install -y -c dsdale24 pyqt5
    #conda install -y -c conda-forge opencv
    #conda install -c pytorch pytorch

    #conda uninstall pytorch

    # CHECK which cuda you have
    cat ~/.local/cuda/version.txt

    conda install -y -c pytorch pytorch

    pyblock "import torch; print(torch.cuda.is_available())"

    # conda install -y -c pytorch magma-cuda80
    # conda install -y -c pytorch magma-cuda90

    #git clone --recursive https://github.com/pytorch/pytorch $HOME/code/pytorch-conda
    #cd $HOME/code/pytorch-conda
    #python setup.py clean && python setup.py install

    # TRY TO WORK WITH GXX_LINUX-64
    #conda install numpy pyyaml mkl mkl-include setuptools cmake cffi typing
    #export CMAKE_PREFIX_PATH="$(dirname $(which conda))/../"

    #CC="cc" CPP="gcc" CXX="c++" python setup.py install
}


setup_venv2(){
    __doc__="
    CommandLine:
        source ~/local/init/freshstart_ubuntu.sh && setup_venv2
    "
    # Ensure PIP, setuptools, and virtual are on the SYSTEM
    if [ "$(has_pymodule python2 pip)" == "False" ]; then
    #if [ "$(which pip2)" == "" ]; then
        ensure_curl
        mkdir -p ~/tmp
        curl https://bootstrap.pypa.io/get-pip.py > ~/tmp/get-pip.py
        python2 ~/tmp/get-pip.py --user
    fi
    python2 -m pip install pip setuptools virtualenv -U --user

    PYEXE=$(python2 -c "import sys; print(sys.executable)")
    PYVERSUFF=$(python2 -c "import sysconfig; print(sysconfig.get_config_var('VERSION'))")
    PYTHON2_VERSION_VENV="$HOME/venv$PYVERSUFF"
    mkdir -p "$PYTHON2_VERSION_VENV"
    python2 -m virtualenv -p "$PYEXE" "$PYTHON2_VERSION_VENV"
    python2 -m virtualenv --relocatable "$PYTHON2_VERSION_VENV"

    PYTHON2_VENV="$HOME/venv2"
    # symlink to the real env
    ln -s "$PYTHON2_VERSION_VENV" "$PYTHON2_VENV"
}


#setup_venv2(){
#    echo "
#    CommandLine:
#        source ~/local/init/freshstart_ubuntu.sh && setup_venv2
#    " > /dev/null
#    # ENSURE SYSTEM PIP IS SAME AS SYSTEM PYTHON
#    # sudo update-alternatives --set pip /usr/local/bin/pip2.7
#    # sudo rm /usr/local/bin/pip
#    # sudo ln -s /usr/local/bin/pip2.7 /usr/local/bin/pip
#    echo "setup venv2"

#    if [ "$(has_pymodule python2 pip)" == "False" ]; then
#    #if [ "$(which pip2)" == "" ]; then
#        ensure_curl
#        curl https://bootstrap.pypa.io/get-pip.py > ~/tmp/get-pip.py
#        python2 ~/tmp/get-pip.py --user
#    fi
#    PYTHON2_VENV="$HOME/venv2"
#    mkdir -p $PYTHON2_VENV
#    python2.7 -m pip install pip setuptools virtualenv -U --user
#    python2.7 -m virtualenv -p $(which python2.7) $PYTHON2_VENV
#    #python2 -m virtualenv -p /usr/bin/python2.7 $PYTHON2_VENV
#    #python2 -m virtualenv --relocatable $PYTHON2_VENV
#}


patch_venv_with_shared_libs(){
    __doc__="
    References:
        https://github.com/pypa/virtualenv/pull/1045/files
    "

    pyblock "
        import shutil
        import os
        import sys
        from os.path import join

        def is_relative_lib():
            # Check if the python was compiled with LDFLAGS -rpath and $ORIGIN
            import distutils
            ldflags_var = distutils.sysconfig.get_config_var('LDFLAGS')
            if ldflags_var is None:
                return False
            ldflags = ldflags_var.split(',')
            n_flags = len(ldflags)
            idx = 0
            while idx < n_flags - 1:
                flag = ldflags[idx]
                if flag == '-rpath':
                    # rpath can contain multiple entries:
                    rpaths = ldflags[idx+1].split(os.pathsep)
                    for rpath in rpaths:
                        rpath = rpath.strip()
                        if rpath.startswith(''$'ORIGIN'):
                            return True
                    idx += 1
                idx += 1
            return False

        def copyfile(src, dest, symlink=True):
            if not os.path.exists(src):
                # Some bad symlink in the src
                print('Cannot find file %s (bad symlink)' % src)
                return
            if os.path.exists(dest):
                print('File %s already exists' % dest)
                return
            if not os.path.exists(os.path.dirname(dest)):
                print('Creating parent directories for %s' % os.path.dirname(dest))
                os.makedirs(os.path.dirname(dest))
            if not os.path.islink(src):
                srcpath = os.path.abspath(src)
            else:
                srcpath = os.readlink(src)
            if symlink and hasattr(os, 'symlink') and not is_win:
                print('Symlinking %s' % dest)
                try:
                    os.symlink(srcpath, dest)
                except (OSError, NotImplementedError):
                    print('Symlinking failed, copying to %s' % dest)
                    copyfileordir(src, dest, symlink)
            else:
                print('Copying to %s' % dest)
                copyfileordir(src, dest, symlink)

        def copyfileordir(src, dest, symlink=True):
            if os.path.isdir(src):
                shutil.copytree(src, dest, symlink)
            else:
                shutil.copy2(src, dest)

        def install_shared(bin_dir, symlink=True):
            # copy (symlink by default) the python shared library to the target
            print('Installing shared lib...')

            sys.real_prefix
            real_executable = join(sys.real_prefix, os.path.relpath(sys.executable, sys.prefix))

            current_shared = os.path.realpath(join(os.path.dirname(real_executable), '..', 'lib'))

            target_shared = os.path.normpath(join(bin_dir, '..', 'lib'))

            import glob

            lib_subdirs = ['', 'x86_64-linux-gnu', 'i386-linux-gnu']
            for subdir in lib_subdirs:
                major = sys.version_info.major
                minor = sys.version_info.minor
                libfiles = list(glob.glob(join(current_shared, subdir, 'libpython*{}.{}*'.format(major, minor))))
                if libfiles:
                    break

            assert len(libfiles) > 0, 'no python libs found'

            for libpython in libfiles:
                target_file = join(target_shared, os.path.basename(libpython))

                copyfile(libpython, target_file)

            print('done.')

        bin_dir = join(os.environ['VIRTUAL_ENV'], 'bin')  # hack
        install_shared(bin_dir, symlink=True)
    "
}

patch_venv_with_ld_library(){
    __doc__="
    CommandLine:
        source ~/local/init/freshstart_ubuntu.sh && patch_venv_with_ld_library

    References:
        https://github.com/pypa/virtualenv/pull/1045
        https://github.com/bastibe/lunatic-python/issues/35

    Ignore:
        # FIXME:
        ln -s /usr/lib/python2.7/config-x86_64-linux-gnu ~/venv2/lib
        ln -s /usr/lib/python2.7/config-x86_64-linux-gnu_d ~/venv2/lib
    "
    ACTIVATE_SCRIPT=$VIRTUAL_ENV/bin/activate

    # apply the patch
    pyblock "
        import textwrap
        from os.path import exists
        new_path = '$ACTIVATE_SCRIPT'
        old_path = '$ACTIVATE_SCRIPT.old'
        if not exists(old_path):
            import shutil
            shutil.copy(new_path, old_path)

        text = open(old_path, 'r').read()
        lines = text.splitlines(True)

        def absindent(text, prefix=''):
            text = textwrap.dedent(text).lstrip()
            text = prefix + prefix.join(text.splitlines(True))
            return text.splitlines(True)

        if len(lines) != 78:
            # hacky way of preventing extra patches
            print('length of file {} is unexpected'.format(new_path))
        else:
            print('patching {}'.format(new_path))
            new_lines = []
            for old_lineno, line in enumerate(lines, start=1):
                new_lines.append(line)
                if old_lineno == 10:
                    new_lines.extend(absindent('
                            C_INCLUDE_PATH=\"\$_OLD_C_INCLUDE_PATH\"
                            LD_LIBRARY_PATH=\"\$_OLD_VIRTUAL_LD_LIBRARY_PATH\"

                        ', ' ' * 8))
                elif old_lineno == 11:
                    new_lines.extend(absindent('
                            export C_INCLUDE_PATH
                            export LD_LIBRARY_PATH

                            unset _OLD_C_INCLUDE_PATH
                            unset _OLD_VIRTUAL_LD_LIBRARY_PATH
                        ', ' ' * 8))
                elif old_lineno == 46:
                    new_lines.extend(absindent('
                            _OLD_C_INCLUDE_PATH=\"\$C_INCLUDE_PATH\"
                            _OLD_VIRTUAL_LD_LIBRARY_PATH=\"\$LD_LIBRARY_PATH\"

                        '))
                elif old_lineno == 47:
                    new_lines.extend(absindent('
                            C_INCLUDE_PATH=\"\$VIRTUAL_ENV/include:\$C_INCLUDE_PATH\"
                            LD_LIBRARY_PATH=\"\$VIRTUAL_ENV/lib:\$LD_LIBRARY_PATH\"

                        '))
                elif old_lineno == 48:
                    new_lines.extend(absindent('
                            export C_INCLUDE_PATH
                            export LD_LIBRARY_PATH
                        '))
            new_text = ''.join(new_lines)
            open(new_path, 'w').write(new_text)
    "
    #diff -u $VIRTUAL_ENV/bin/activate.old $VIRTUAL_ENV/bin/activate
}

setup_venv37(){
    echo "setup venv37"
    # Make sure you install 3.7 to ~/.local from source
    PYTHON3_VENV="$HOME/venv3_7"
    mkdir -p "$PYTHON3_VENV"
    ~/.local/bin/python3 -m venv "$PYTHON3_VENV"
    ln -s "$PYTHON3_VENV" ~/venv3

}

setup_venvpypy(){
    echo "setup venvpypy"

    PYPY_VENV="$HOME/venvpypy"
    mkdir -p "$PYPY_VENV"

    #sudo apt install pypy pypy-pip

    #pypy -m pip install pip
    #pip -m install virtualenv --user
    #pip install virtualenv
    pypy -m ensurepip
    virtualenv -p /usr/bin/pypy "$PYPY_VENV"

    pypy -m ensurepip
    sudo apt install pypy-pip
    sudo apt install pypy3

    sudo add-apt-repository ppa:pypy/ppa
    sudo apt update
    sudo apt install pypy3

}

install_chrome()
{
    # Google PPA
    wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
    sudo sh -c 'echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list'
    sudo apt update
    # Google Chrome
    sudo apt install -y google-chrome-stable
}

reinstall_chrome(){
    sudo apt-get purge google-chrome-stable -y
    rm ~/.config/google-chrome/ -rf
}


setup_ibeis()
{
    mkdir -p ~/code
    cd ~/code
    if [ ! -f ~/ibeis ]; then
        git clone https://github.com/Erotemic/ibeis.git
    fi
    cd ~/code/ibeis
    git pull
    git checkout next
    ./_scripts/bootstrap.py
    ./_scripts/__install_prereqs__.sh
    ./super_setup.py --build --develop
    ./super_setup.py --checkout next
    ./super_setup.py --build --develop

    # Options
    ./_scripts/bootstrap.py --no-syspkg --nosudo

    cd
    IBEIS_WORK_DIR="$(python -c 'import ibeis; print(ibeis.get_workdir())')"
    echo "$IBEIS_WORK_DIR"
    ln -s "$IBEIS_WORK_DIR"  work
}


setup_development_environment(){
    __doc__="
    CommandLine:
        source ~/local/init/freshstart_ubuntu.sh
        setup_development_environment
    "

    pip install bs4
    pip install pyperclip

    python ~/local/init/ensure_vim_plugins.py
    python ~/local/init/ensure_repos.py

    # Install utool
    cd ~/code
    if [ ! -f ~/utool ]; then
        git clone git@github.com:Erotemic/utool.git
        cd utool
        pip install -e .
    fi

    # Get latex docs
    cd ~/latex
    if [ ! -f ~/latex ]; then
        mkdir -p ~/latex
        git clone git@hyrule.cs.rpi.edu.com:crall-candidacy-2015.git
    fi

    # Install machine specific things

    if [[ "$HOSTNAME" == "hyrule"  ]]; then
        echo "SETUP HYRULE STUFF"
        customize_sudoers
        source settings_hyrule.sh
        hyrule_setup_sshd
        hyrule_setup_fstab
        hyrule_create_users
    elif [[ "$HOSTNAME" == "Ooo"  ]]; then
        echo "SETUP Ooo STUFF"
        install_dropbox
        customize_sudoers
        nautilus_settings
        gnome_settings
        install_chrome
        # Make sure dropbox has been initialized first
        install_fonts

        #
        install_spotify
    else
        echo "UNKNOWN HOSTNAME"
    fi

    # Extended development environment
    sudo apt install -y pkg-config
    sudo apt install -y libtk-img-dev
    sudo apt install -y libav-tools libgeos-dev
    sudo apt install -y libfftw3-dev libfreetype6-dev
    sudo apt install -y libatlas-base-dev liblcms1-dev zlib1g-dev
    sudo apt install -y libjpeg-dev libopenjpeg-dev libpng12-dev libtiff5-dev

    # Commonly used and frequently forgotten
    sudo apt install -y wmctrl xsel xdotool xclip
    sudo apt install -y gparted htop tree
    sudo apt install -y fd-find
    sudo apt install -y tmux astyle
    sudo apt install -y synaptic okular
    sudo apt install -y openssh-server
    sudo apt install -y valgrind synaptic gitg expect
    sudo apt install -y sshfs

    pip install numpy
    pip install scipy
    pip install Cython
    pip install pandas
    pip install statsmodels
    pip install scikit-learn

    pip install matplotlib

    pip install functools32
    pip install psutil
    pip install six
    pip install dateutils
    pip install pyreadline
    #pip install pyparsing
    pip install parse

    pip install networkx
    pip install Pygments
    pip install colorama

    pip install requests
    pip install simplejson
    pip install flask
    pip install flask-cors

    pip install lockfile
    pip install lru-dict
    pip install shapely

    # pydot is currently broken
    #http://stackoverflow.com/questions/15951748/pydot-and-graphviz-error-couldnt-import-dot-parser-loading-of-dot-files-will
    #pip uninstall pydot
    pip uninstall pyparsing
    pip install -Iv 'https://pypi.python.org/packages/source/p/pyparsing/pyparsing-1.5.7.tar.gz#md5=9be0fcdcc595199c646ab317c1d9a709'
    pip install pydot
    python -c "import pydot"

    pip install bs4

    if [ "$(which cmake)" == "" ]; then
        python ~/local/build_scripts/init_cmake_latest.py
    fi
}


local_apt(){
    #--------
    # apt-get without root permissions
    PKG_NAME=tmux
    apt download $PKG_NAME
    PKG_DEB=$(echo $PKG_NAME*.deb)
    # Cant get this to work
    dpkg -i "$PKG_DEB" --force-not-root --root="$HOME"
    #--------
}


big_apt_install(){


    sudo apt install -y astyle automake autotools-dev build-essential curl expect exuberant-ctags g++ gcc gfortran gitg gparted graphviz hardinfo hdfview htop imagemagick libatlas-base-dev libatlas-base-dev libblas-dev libboost-all-dev libevent-dev libfftw3-dev libfreeimage-dev libfreetype6-dev libgeos-dev libgflags-dev libgoogle-glog-dev libjpeg-dev libjpeg62 liblapack-dev libleveldb-dev liblmdb-dev libncurses5-dev libopencv-dev libprotobuf-dev libpthread-stubs0-dev libsnappy-dev libtiff5-dev libtk-img-dev lm-sensors mdadm okular openssh-server p7zip-full patchutils pkg-config postgresql protobuf-compiler python-dev python3-dev python3-tk remmina rsync sqlitebrowser sshfs symlinks synaptic terminator tmux tree valgrind vim-gnome wmctrl xclip xdotool xsel zlib1g-dev initramfs-tools gdisk openssh-server libhdf5-serial-dev libhdf5-openmpi-dev xbacklight hdf5-tools libsqlite3-dev sqlite3 sysstat gitk

    sudo apt-get install git-lfs


    libav-tools
    libopenjpeg-dev libpng12-dev

    sudo apt-get install network-manager-openvpn-gnome -y

    sudo apt install remmina remmina-plugin-rdp libfreerdp-plugins-standard -y
    # Add self to fuse group
    sudo groupadd fuse
    sudo usermod -aG fuse "$USER"
    sudo chmod g+rw /dev/fuse
    sudo chgrp fuse /dev/fuse

    sudo add-apt-repository ppa:obsproject/obs-studio -y
    sudo apt update && sudo apt install obs-studio -y


    sudo apt install kdenlive


    # SeeAlso ~/local/build_scripts/build_obs.sh

    sudo apt -y install nautilus-dropbox

    # Google Chrome
    wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
    sudo sh -c 'echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list'
    sudo apt update -y
    sudo apt install -y google-chrome-stable

    sudo add-apt-repository ppa:unit193/encryption -y
    sudo apt update
    sudo apt install veracrypt -y


    sudo add-apt-repository ppa:linrunner/tlp -y
    sudo apt update -y
    sudo apt install tlp tlp-rdw -y
}


resetup_ooo_after_os_reinstall()
{
    # https://ubuntuforums.org/showthread.php?t=2002217
    # if you reinstalled your OS you just need to tell the system about the
    # raid to get things working again
    sudo apt-get install gdisk mdadm rsync -y
    # Simply scan for your preconfigured raid
    sudo mdadm --assemble --scan
    cat /proc/mdstat
    sudo update-initramfs -u

    sudo mdadm --examine "$RAID_PARTS"
    sudo mdadm --detail /dev/md0


    # Mount the RAID (temporary. modify fstab to automount)
    sudo mkdir -p /media/joncrall/raid
    sudo mount /dev/md0 /media/joncrall/raid
    # Modify fstab so RAID auto-mounts at startup
    sudo sh -c "echo '# appended to fstab by by install scripts' >> /etc/fstab"
    sudo sh -c "echo 'UUID=4bf557b1-cbf7-414c-abde-a09a25e351a6  /media/joncrall/raid              ext4    defaults        0 0' >> /etc/fstab"

    sudo ln -s /media/joncrall/raid /raid


    # small change to default sshd_config
    # Allow authorized keys
    COMP_BUBBLE=$(python -c "import utool as ut; print(ut.bubbletext(ut.get_computer_name()))")
    sudo sh -c "echo \"$COMP_BUBBLE\" >> /etc/issue.net"
    cat /etc/issue.net
    sudo sed -i 's/#AuthorizedKeysFile\t%h\/.ssh\/authorized_keys/AuthorizedKeysFile\t%h\/.ssh\/authorized_keys/' /etc/ssh/sshd_config


    # be sure to do fix_monitor_positions in ubuntu_core_packages.sh
}

specific_18_04_freshinstall(){
    sudo apt install gnome-shell-extensions -y
    sudo apt install chrome-gnome-shell -y
    sudo apt-get install gir1.2-cogl-1.0 gir1.2-gtop-2.0 gir1.2-networkmanager-1.0 -y
}


install_transcrypt(){
    __doc__="
    References:

        https://embeddedartistry.com/blog/2018/3/15/safely-storing-secrets-in-git
        https://github.com/AGWA/git-crypt
        https://github.com/elasticdog/transcrypt
    "
    cd ~/code
    #git clone git@github.com:Erotemic/transcrypt.git ~/code/transcrypt
    #git clone https://github.com/elasticdog/transcrypt.git
    git clone https://github.com/Erotemic/transcrypt.git ~/code/transcrypt
    cd ~/code/transcrypt

    source "$HOME"/local/init/utils.sh
    safe_symlink "$HOME"/code/transcrypt/transcrypt "$HOME"/.local/bin/transcrypt

    #git clone https://github.com/Erotemic/roaming.git
    git clone https://gitlab.com/Erotemic/erotemic.git
    cd "$HOME"/code/erotemic

    # new roaming
    #mkdir -p $HOME/code/roaming
    #cd $HOME/code/roaming

    # TODO: fixme to use GCM
    __doc__="
    # How to init a new encrypted repo

    #git init
    transcrypt --cipher=aes-256-cbc
    transcrypt --display
    echo '*  filter=crypt diff=crypt' >> .gitattributes
    echo 'secret plans' >> dummy_secrets

    # Copy and paste the following command to initialize a cloned repository:
    transcrypt -c aes-256-cbc
    transcrypt -c aes-256-cbc -p 'pass1'
    transcrypt --cipher=aes256-GCM
    "
    #git clone https://gitlab.com/Erotemic/erotemic.git

    # The user must supply a password here
    transcrypt -c aes-256-cbc
}


fix_ubuntu_permissions_cmd_not_found(){
    sudo chmod ugo+r /var/lib/command-not-found/commands.db
}

setup_deep_learn_env(){
    source ~/local/init/init_cuda.sh
    change_cudnn_version 7.0

    cd ~/code
    git clone https://github.com/pytorch/pytorch.git
    cd ~/code/pytorch
    git pull
    git submodpull
    pip install pyyaml
    python setup.py install

    pip install h5py matplotlib Pillow torchvision
    pip install tensorflow
    pip install scikit-image

    git clone https://github.com/TeamHG-Memex/tensorboard_logger.git ~/code/tensorboard_logger
    pip install -e ~/code/tensorboard_logger
}

simple_setup_auto(){
    __doc__="
    Does setup on machines without root access
    "
    # Just in case
    deactivate

    mkdir -p ~/tmp
    mkdir -p ~/code
    cd ~

    if [ ! -d ~/.ssh ]; then
        mkdir -p ~/.ssh
        #ssh-copy-id username@remote
    fi

    source ~/local/init/freshstart_ubuntu.sh
    source ~/local/init/ensure_symlinks.sh
    ensure_config_symlinks

    source ~/.bashrc

    set_global_git_config

    source ~/local/init/freshstart_ubuntu.sh
    setup_venv3
    source ~/venv3/bin/activate

    pip install setuptools --upgrade
    pip install six
    pip install jedi
    pip install pep8 autopep8 flake8 pylint
    pip install line_profiler

    pip install Cython
    pip install ipython

    pip install numpy scipy
    pip install pyqt5
    pip install opencv-python

    mkdir -p ~/local/vim/vimfiles/bundle
    source ~/local/vim/init_vim.sh
    echo "source ~/local/vim/portable_vimrc" > ~/.vimrc
    python ~/local/init/ensure_vim_plugins.py

    source ~/local/init/freshstart_ubuntu.sh
    # Install utool
    echo "Installing utool"
    if [ ! -d ~/code/utool ]; then
        git clone -b next http://github.com/Erotemic/utool.git ~/code/utool
    fi
    if [ "$(has_pymodule ubelt)" == "False" ]; then
        pip install -e ~/code/utool
    fi

    echo "Installing xdoctest"
    if [ ! -d ~/code/xdoctest ]; then
        git clone http://github.com/Erotemic/xdoctest.git ~/code/xdoctest
    fi
    if [ "$(has_pymodule xdoctest)" == "False" ]; then
        pip install -e ~/code/xdoctest
    fi

    echo "Installing ubelt"
    if [ ! -d ~/code/ubelt ]; then
        git clone http://github.com/Erotemic/ubelt.git ~/code/ubelt
    fi
    if [ "$(has_pymodule ubelt)" == "False" ]; then
        pip install -e ~/code/ubelt
    fi

    echo "Installing vtool"
    if [ ! -d ~/code/vtool ]; then
        git clone http://github.com/Erotemic/vtool.git ~/code/vtool
    fi
    if [ "$(has_pymodule vtool)" == "False" ]; then
        pip install -e ~/code/vtool
    fi

    echo "Installing guitool"
    if [ ! -d ~/code/guitool ]; then
        git clone http://github.com/Erotemic/guitool.git ~/code/guitool
    fi
    if [ "$(has_pymodule guitool)" == "False" ]; then
        pip install -e ~/code/guitool
    fi

    echo "Installing plottool"
    if [ ! -d ~/code/plottool ]; then
        git clone http://github.com/Erotemic/plottool.git ~/code/plottool
    fi
    if [ "$(has_pymodule plottool)" == "False" ]; then
        pip install -e ~/code/plottool
    fi

    #git clone http://github.com/Erotemic/networkx.git ~/code/networkx
    #pip install -e ~/code/networkx
    pip install networkx tqdm

    python ~/local/init/init_ipython_config.py

    #deactivate
    #setup_venv2
    #source ~/venv2/bin/activate
    #pip install setuptools --upgrade
    #pip install six
    #pip install jedi
    #pip install pep8 autopep8 flake8 pylint
    #pip install line_profiler

    #pip install Cython
    #pip install ipython

    #pip install numpy scipy pandas
    #pip install opencv-python

    #source ~/.bashrc

    #we-py3
}




basic_apt_install(){
    # High priority
    sudo apt install htop git tmux tree curl gcc g++ gfortran build-essential p7zip-full curl -y

    # Mid priority
    sudo apt install sshfs pgpgpg sensors lm-sensors -y

    # Mid priority
    sudo apt install expect exuberant-ctags graphviz imagemagick gitk wmctrl xclip xdotool xsel valgrind -y

    # Other
    sudo apt install yamllint
}


simple_setup_manual()
{
    sudo apt install git -y
    # If local does not exist
    if [ ! -d "$HOME"/local ]; then
        git clone https://github.com/Erotemic/local.git "$HOME/local"
    fi
    if [ ! -d "$HOME"/misc ]; then
        git clone https://github.com/Erotemic/misc.git "$HOME/misc"
    fi
    source ~/local/init/freshstart_ubuntu.sh

    source ~/local/init/ensure_symlinks.sh
    ensure_config_symlinks
    simple_setup_auto

    if [ ! -d "$HOME/internal" ]; then
        # Requires correct SSH keys
        git clone git@kwgitlab.kitware.com:jon.crall/internal.git "$HOME/internal"
    fi
}
