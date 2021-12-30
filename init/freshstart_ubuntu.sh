source $HOME/local/init/utils.sh

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
    if [ ! -d $HOME/local ]; then
        git clone https://github.com/Erotemic/local.git $HOME/local
    fi
    if [ ! -d $HOME/misc ]; then
        git clone https://github.com/Erotemic/misc.git $HOME/misc
    fi
    source ~/local/init/freshstart_ubuntu.sh 

    source ~/local/init/ensure_symlinks.sh 
    ensure_config_symlinks
    simple_setup_auto

    if [ ! -d $HOME/internal ]; then
        # Requires correct SSH keys
        git clone git@kwgitlab.kitware.com:jon.crall/internal.git $HOME/internal
    fi
}

local_remote_presetup(){
    "
    Run this script on the local computer to setup the remote with data that
    must be pushed to it (i.e. we cannot pull these files)
    "
    REMOTE=somemachine.com
    REMOTE_USER=jon.crall
    ssh-copy-id $REMOTE_USER@$REMOTE
    #In event of slowdown: sshpass -f <(printf '%s\n' kwpass=yourpass) ssh-copy-id $REMOTE_USER@$REMOTE
    rsync -avzupR ~/./tpl-archive/ $REMOTE_USER@$REMOTE:. 
}

set_global_git_config(){

    #git config --global user.email crallj@rpi.edu
    git config --global user.name $USER
    #git config --global user.email erotemic@gmail.com
    git config --global user.email jon.crall@kitware.com
    git config --global push.default current

    git config --global core.editor "vim"
    git config --global rerere.enabled false
    git config --global core.fileMode false
    git config --global alias.co checkout
    git config --global alias.submodpull 'submodule update --init --recursive'
    #git config --global merge.conflictstyle diff3
    git config --global merge.conflictstyle merge

    git config --global core.autocrlf false
}

setup_single_use_ssh_keys(){
    # References: https://security.stackexchange.com/questions/50878/ecdsa-vs-ecdh-vs-ed25519-vs-curve25519
    mkdir -p ~/.ssh
    cd ~/.ssh

    # WHERES MY POST-QUANTUM CRYPTO AT?!  
    # Unfortunately I think ED25519 cant be PQ-resistant because its fixed at 256 bits :(
    # Note: add a passphrase in -N for extra secure
    echo "USER = $USER"
    echo "HOSTNAME = $HOSTNAME"
    EMAIL=erotemic@gmail.com
    EMAIL=jon.crall@kitware.com
    FPATH="$HOME/.ssh/id_${HOSTNAME}_${USER}_ed25519"
    ssh-keygen -t ed25519 -b 256 -C "${EMAIL}" -f $FPATH -N ""

    chmod 700 ~/.ssh
    chmod 400 ~/.ssh/id_*
    chmod 644 ~/.ssh/id_*.pub

    eval "$(ssh-agent -s)"
    ssh-add ~/.ssh/id_${HOSTNAME}_${USER}_ed25519
    
    echo "TODO: Register public key with appropriate services"
    echo " https://github.com/profile/keys "
    echo " https://gitlab.com/profile/keys "
    cat ~/.ssh/id_${HOSTNAME}_${USER}_ed25519.pub

    # Note: RSA with longer keys will be post-quantum resistant for longer
    # The NSA recommends a minimum 3072 key length, probably should go longer than that
    # ssh-keygen -t rsa -b 8192 -C "erotemic@gmail.com" -f id_${HOSTNAME}_${USER}_rsa -N ""

    # See: https://github.com/open-quantum-safe/liboqs

}

setup_remote_ssh_keys(){
    # DO THIS ONCE, THEN MOVE THESE KEY AROUND TO REMOTE MACHINES. ROTATE REGULARLY
    # IDEALLY MAKE ONE PER MACHINE: see setup_single_use_ssh_keys.
    mkdir -p ~/.ssh
    cd ~/.ssh
    ssh-keygen -t rsa -b 8192 -C "erotemic@gmail.com" -f id_myname_rsa -N ""

    # setup local machine with a special public / private key pair
    ssh-add id_myname_rsa

    # Add this public key to remote authorized_keys so they recognize you.  
    # You may have to type in your password for each of these, but it will be
    # the last time.
    REMOTE_USER=jon.crall
    REMOTE_HOST=remote_machine
    # ENSURE YOU HAVE ALL COMPUTERS UPDATED IN YOUR SSH CONFIG
    REMOTES=( remote1 remote2 remote3 remote4 remote5 )

    ssh-copy-id $REMOTE_USER@$REMOTE_HOST

    for remote in "${REMOTES[@]}"
    do
        echo "UPDATING remote = $remote"
        # move .ssh config to other computers
        rsync ~/.ssh/./config $remote:.ssh/./
    done

    ###
    # ALTERNATE
    # Copy from a remote to local computer
    REMOTE_USER=jon.crall
    REMOTE_HOST=hocus-pocus
    rsync $REMOTE_USER@$REMOTE_HOST:.ssh/./id_* $HOME/.ssh/
    rsync $REMOTE_USER@$REMOTE_HOST:.ssh/./config $HOME/.ssh/

    REMOTE_ALIAS=
    rsync -avprPRL $HOME/.ssh/./id_*  $REMOTE_ALIAS:.ssh/
    rsync -avprPRL $HOME/.ssh/./config $REMOTE_ALIAS:.ssh/
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


new_setup_ssh_keys(){
    mkdir -p ~/.ssh
    cd ~/.ssh
    ssh-keygen -t rsa -b 4096 -C "jon.crall@kitware.com"
    # Add new key to ssh agent if it is already running

    ssh-add
    # Manual Step:
    # Add public key to github https://github.com/settings/keys
    # Add public key to other places

    fix_ssh_permissions
}

fix_ssh_permissions(){
    # Fix ssh keys if you have them
    echo "
    CommandLine:
        source ~/local/init/freshstart_ubuntu.sh && fix_ssh_permissions
    " > /dev/null
    ls -al ~/.ssh
    chmod 700 ~/.ssh
    chmod 600 ~/.ssh/authorized_keys
    chmod 600 ~/.ssh/known_hosts
    chmod 600 ~/.ssh/config
    chmod 400 ~/.ssh/id_*
    ls -al ~/.ssh
}


entry_prereq_git_and_local()
{
    # This is usually done manually
    sudo apt install git -y
    cd ~

    # sudo usermod -l newUsername oldUsername
    # usermod -d /home/newHomeDir -m newUsername

    # If on a new computer, then make a new ssh key
    
    if [[ "$HOSTNAME" == "calculex"  ]]; then 
        new_setup_ssh_keys
    fi

    fix_ssh_permissions

    # Fix ssh keys if you have them
    ls -al ~/.ssh
    chmod 700 ~/.ssh
    chmod 600 ~/.ssh/authorized_keys
    chmod 600 ~/.ssh/known_hosts
    chmod 600 ~/.ssh/config
    chmod 400 ~/.ssh/id_rsa*
    chmod 400 ~/.ssh/id_ed*

    # If local does not exist
    if [ ! -f ~/local ]; then
        git clone https://github.com/Erotemic/local.git
        cd local/init 
    fi
}

freshtart_ubuntu_script()
{ 
    __doc__="
    CommandLine:
        source ~/local/init/freshstart_ubuntu.sh
        freshtart_ubuntu_script
    "
    mkdir -p ~/tmp
    mkdir -p ~/code
    cd ~
    if [ ! -d ~/local ]; then
        git clone https://github.com/Erotemic/local.git
    fi

    sudo apt install symlinks -y

    source ~/local/init/freshstart_ubuntu.sh
    source ~/local/init/ensure_symlinks.sh 
    ensure_config_symlinks

    source ~/.bashrc

    set_global_git_config

    source ~/local/init/freshstart_ubuntu.sh
    #make_sshkey

    #sudo apt install trash-cli
    sudo apt install -y exuberant-ctags 

    # Vim
    #sudo apt install -y vim
    #sudo apt install -y vim-gtk
    sudo apt install -y vim-gnome

    # Terminal settings
    #sudo apt install terminator -y

    if [ "$(which terminator)" == "" ]; then
        # Dont use buggy gtk2 version 
        # https://bugs.launchpad.net/ubuntu/+source/terminator/+bug/1568132

        #sudo add-apt-repository ppa:gnome-terminator
        #sudo apt update
        #sudo apt install terminator -y
        #cat /etc/apt/sources.list
        #sudo apt remove terminator
        #sudo add-apt-repository --remove ppa:gnome-terminator

        sudo add-apt-repository ppa:gnome-terminator/nightly-gtk3
        sudo apt update
        sudo apt install terminator -y
    fi

    # Development Environment
    sudo apt install gcc g++ gfortran build-essential -y
    sudo apt install -y python3-dev python3-tk
    sudo apt install -y python3-tk

    #sudo update-alternatives --install /usr/bin/python python /usr/bin/python2.7 10

    # Python 
    setup_venv3
    source ~/venv3/bin/activate

    pip install setuptools --upgrade
    pip install six
    pip install jedi
    pip install ipython
    pip install pep8 autopep8 flake8 pylint line_profiler

    mkdir -p ~/local/vim/vimfiles/bundle
    source ~/local/vim/init_vim.sh
    #mkdir ~/.vim_tmp
    echo "source ~/local/vim/portable_vimrc" > ~/.vimrc
    python ~/local/init/ensure_vim_plugins.py

    source ~/local/init/ubuntu_core_packages.sh

    # Get latex docs
    #cd ~/latex
    #if [ ! -f ~/latex ]; then
    #    mkdir -p ~/latex
    #    git clone git@hyrule.cs.rpi.edu.com:crall-candidacy-2015.git
    #fi

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
    sudo apt install -y libblas-dev liblapack-dev
    sudo apt install -y libav-tools libgeos-dev 
    sudo apt install -y libfftw3-dev libfreetype6-dev 
    sudo apt install -y libatlas-base-dev liblcms1-dev zlib1g-dev
    sudo apt install -y libjpeg-dev libopenjpeg-dev libpng12-dev libtiff5-dev

    pip install numpy
    pip install scipy
    pip install Cython
    pip install pandas
    pip install requests

    pip install six
    pip install parse
    pip install Pygments
    pip install colorama

    pip install matplotlib

    pip install statsmodels
    pip install scikit-learn

    #pip install functools32
    #pip install psutil
    #pip install dateutils
    #pip install pyreadline
    #pip install pyparsing
    
    #pip install networkx

    #pip install simplejson
    #pip install flask
    #pip install flask-cors

    #pip install lockfile
    #pip install lru-dict
    #pip install shapely

    # pydot is currently broken
    #http://stackoverflow.com/questions/15951748/pydot-and-graphviz-error-couldnt-import-dot-parser-loading-of-dot-files-will
    #pip uninstall pydot
    pip uninstall pyparsing
    pip install -Iv 'https://pypi.python.org/packages/source/p/pyparsing/pyparsing-1.5.7.tar.gz#md5=9be0fcdcc595199c646ab317c1d9a709'
    pip install pydot
    python -c "import pydot"

    # Ubuntu hack for pyqt4
    # http://stackoverflow.com/questions/15608236/eclipse-and-google-app-engine-importerror-no-module-named-sysconfigdata-nd-u
    #sudo apt install python-qt4-dev
    #sudo apt remove python-qt4-dev
    #sudo apt remove python-qt4
    #sudo ln -s /usr/lib/python2.7/plat-*/_sysconfigdata_nd.py /usr/lib/python2.7/
    #python -c "import PyQt4"
    # TODO: install from source this is weird it doesnt work
    # sudo apt autoremove

    # Install utool
    if [ ! -d ~/code/utool ]; then
        git clone git@github.com:Erotemic/utool.git ~/code/utool
        pip install -e ~/code/utool
    fi

    if [ ! -d ~/code/ubelt ]; then
        git clone git@github.com:Erotemic/ubelt.git ~/code/ubelt
        pip install -e ~/code/ubelt
    fi

    git clone git@github.com:Erotemic/networkx.git ~/code/networkx
    pip install -e ~/code/networkx

    python ~/local/init/init_ipython_config.py
}

ensure_curl(){
    HAVE_SUDO=$(have_sudo)
    if [ "$(which curl)" == "" ]; then
        echo "Need to install curl"
        if [ "$HAVE_SUDO" == "True" ]; then
            sudo apt install curl -y
        else
            echo "Cannot install curl without sudo"
        fi
    fi
}

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
        if [ "$(echo $?)" != "0" ]; then
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
    mkdir -p $PYTHON3_VERSION_VENV
    python3 -m virtualenv -p $PYEXE $PYTHON3_VERSION_VENV 
    python3 -m virtualenv --relocatable $PYTHON3_VERSION_VENV 

    PYTHON3_VENV="$HOME/venv3"
    # symlink to the real env
    ln -s $PYTHON3_VERSION_VENV $PYTHON3_VENV

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
    $VIRTUAL_ENV/bin/python --version
    /usr/bin/python3 --version

    # overwrite the virtualenv python with a fresh copy of the system python
    cp $VIRTUAL_ENV/bin/python $VIRTUAL_ENV/bin/python.bakup
    sha1sum  $VIRTUAL_ENV/bin/python.bakup
    sha1sum  $VIRTUAL_ENV/bin/python
    sha1sum  /usr/bin/python3

    lsof  $VIRTUAL_ENV/bin/python

    cp /usr/bin/python3 $VIRTUAL_ENV/bin/python
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
    mkdir -p $VENV_PREFIX

    python -m venv $VENV_PREFIX/py38
    source $VENV_PREFIX/py38/bin/activate
    
}

setup_pyenv(){
    # See Also: 
    # ~/local/tools/pyenv_ext/pyenv_ext_commands.sh

    # Install requirements for building Python
    sudo apt-get install -y \
        make build-essential libssl-dev zlib1g-dev \
        libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm libncurses5-dev \
        libncursesw5-dev xz-utils tk-dev libffi-dev liblzma-dev python-openssl

    # Download pyenv
    export PYENV_ROOT="$HOME/.pyenv"
    if [[ ! -d "$PYENV_ROOT" ]]; then
        git clone https://github.com/pyenv/pyenv.git $PYENV_ROOT
        (cd $PYENV_ROOT && src/configure && make -C src)
    fi

    # We will need to add something similar in your bashrc
    if [ -d "$PYENV_ROOT" ]; then
        export PATH="$PYENV_ROOT/bin:$PATH"
        eval "$($PYENV_ROOT/bin/pyenv init -)"
        source $PYENV_ROOT/completions/pyenv.bash
    fi

    # About Optimizations
    # https://github.com/docker-library/python/issues/160#issuecomment-509426916
    # https://gist.github.com/nszceta/ec6efc9b5e54df70deeec7bceead0a1d
    # https://clearlinux.org/news-blogs/boosting-python-profile-guided-platform-specific-optimizations
    #CHOSEN_PYTHON_VERSION=2.7.18
    CHOSEN_PYTHON_VERSION=3.8.5

    PROFILE_TASK="-m test.regrtest 
        --pgo test_array test_base64 test_binascii test_binhex test_binop
        test_c_locale_coercion test_csv test_json test_hashlib test_unicode
        test_codecs test_traceback test_decimal test_math test_compile
        test_threading test_time test_fstring test_re test_float test_class
        test_cmath test_complex test_iter test_struct test_slice test_set
        test_dict test_long test_bytes test_memoryview test_io test_pickle"

    PYTHON_CONFIGURE_OPTS="
        --enable-shared 
        --enable-optimizations 
        --with-computed-gotos
        --with-lto"

    #PYTHON_CFLAGS="-march=native -O2 -pipe" 
    PYTHON_CFLAGS="-march=native -O3 -pipe" 

    #PROFILE_TASK=$PROFILE_TASK \
    PYTHON_CFLAGS="$PYTHON_CFLAGS" \
    PYTHON_CONFIGURE_OPTS="$PYTHON_CONFIGURE_OPTS" \
    pyenv install $CHOSEN_PYTHON_VERSION --verbose

    # Set your global pyenv version, so your prefix maps correctly.
    pyenv shell $CHOSEN_PYTHON_VERSION
    pyenv global $CHOSEN_PYTHON_VERSION

    if [[ $CHOSEN_PYTHON_VERSION == 2.7.* ]]; then
        echo "2.7"
        pip install virtualenv
        PYENV_PREFIX=$(pyenv prefix)
        python -m virtualenv $PYENV_PREFIX/envs/pyenv$CHOSEN_PYTHON_VERSION
    else
        echo "3.x"
        # Create the virtual environment
        PYENV_PREFIX=$(pyenv prefix)
        python -m venv $PYENV_PREFIX/envs/pyenv$CHOSEN_PYTHON_VERSION
    fi

    # Add this to your bashrc so you start in a virtual environment

    #### START BASHRC PART ###
    echo "#### ADD THIS TO YOUR BASH RC ####"
    BASHRC_CONTENTS=$(codeblock '
    CHOSEN_PYTHON_VERSION=3.8.5
    # Add the pyenv command to our environment if it exists
    export PYENV_ROOT="$HOME/.pyenv"
    if [ -d "$PYENV_ROOT" ]; then
        export PATH="$PYENV_ROOT/bin:$PATH"
        eval "$($PYENV_ROOT/bin/pyenv init -)"
        source $PYENV_ROOT/completions/pyenv.bash
        export PYENV_PREFIX=$(pyenv prefix)
    fi
    
    if [ -d "$PYENV_PREFIX/envs/pyenv$CHOSEN_PYTHON_VERSION" ]; then
        source $PYENV_PREFIX/envs/pyenv$CHOSEN_PYTHON_VERSION/bin/activate
    fi
    ')
    echo "#### ADD THE ABOVE TO YOUR BASH RC ####"
    echo $BASHRC_CONTENTS
    #### END BASHRC PART ####
}


build_vim_for_pyenv(){
    if [[ ! -d "$HOME/code/vim" ]]; then 
        git clone https://github.com/vim/vim.git ~/code/vim
    else 
        cd $HOME/code/vim
        git pull
    fi

    source $HOME/local/init/utils.sh
    apt_ensure build-essential libtinfo-dev libncurses-dev gnome-devel libgtk-3-dev libxt-dev

    #./configure --help
    #./configure --help | grep python
    cd $HOME/code/vim

    # https://github.com/vim/vim/issues/6457
    #git checkout v8.1.2424
    git checkout v8.2.3113

    # Build in virtualenv?
    # deactivate
    deactivate_venv

    BUILD_IN_VIRTUALENV=0
    if [[ "$BUILD_IN_VIRTUALENV" == "1" ]]; then
        #PREFIX=$VIRTUAL_ENV
        # I Think the config has to point to the actual python install and not
        # the virtualenv
        PREFIX=$(pyenv prefix)
        EXEC_PREFIX=$VIRTUAL_ENV
        CONFIG_DIR=$($(pyenv prefix)/bin/python-config --configdir)
        #CONFIG_DIR=$($VIRTUAL_ENV/bin/python-config --configdir)
        PYTHON_CMD=$(which python)
    else
        # Seems like this doesnt always work
        PREFIX=$(pyenv prefix)
        EXEC_PREFIX="$PREFIX"
        CONFIG_DIR=$($(pyenv prefix)/bin/python-config --configdir)
        PYTHON_CMD=$(pyenv which python)
    fi

    #PREFIX=${VIRTUAL_ENV:=$HOME/.local}
    #CONFIG_DIR=$(python-config --configdir)

    #https://github.com/ycm-core/YouCompleteMe/issues/3760
    #PREFIX=$(pyenv prefix)
    #CONFIG_DIR=$($(pyenv prefix)/bin/python-config --configdir)
    echo "PREFIX = $PREFIX"
    echo "EXEC_PREFIX = $EXEC_PREFIX"
    echo "CONFIG_DIR = $CONFIG_DIR"

    # THIS WORKS! 
    export LDFLAGS="-rdynamic"
    make distclean
    ./configure \
        --prefix=$PREFIX \
        --exec-prefix=$EXEC_PREFIX \
        --enable-pythoninterp=no \
        --enable-python3interp=yes \
        --with-python3-command=$PYTHON_CMD \
        --with-python3-config-dir=$CONFIG_DIR \
        --enable-gui=gtk3
    cat src/auto/config.mk 

    # Ensure the version of python matches (there are cases due to system
    # configs where it might not)
    cat src/auto/config.mk | grep 'PYTHON3\|prefix'

    make -j$(nproc)
    #./src/vim -u NONE --cmd "source test.vim"
    make install

    if [[ -d "$HOME/code/vimtk" ]]; then
        unlink_or_backup $HOME/.vim/bundle/vimtk
        ln -s $HOME/code/vimtk $HOME/.vim/bundle/vimtk
    fi

    pip install ubelt pyperclip
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
    CFLAGS=$CFLAGS pip install GDAL==$GDAL_VERSION
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
    mkdir -p ~/tmp
    cd ~/tmp
    #https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
    # See https://docs.conda.io/en/latest/miniconda_hashes.html for updating
    # to newer versions

    # To update to a newer version see:
    # https://docs.conda.io/en/latest/miniconda_hashes.html for updating
    CONDA_INSTALL_SCRIPT=Miniconda3-py38_4.9.2-Linux-x86_64.sh
    curl https://repo.anaconda.com/miniconda/$CONDA_INSTALL_SCRIPT > $CONDA_INSTALL_SCRIPT

    # For security, it is important to verify the hash
    CONDA_EXPECTED_SHA256=1314b90489f154602fd794accfc90446111514a5a72fe1f71ab83e07de9504a7
    echo "${CONDA_EXPECTED_SHA256}  ${CONDA_INSTALL_SCRIPT}" > conda_expected_hash.sha256 
    if ! sha256sum --status -c conda_expected_hash.sha256; then
        echo "Downloaded file does not match hash! DO NOT CONTINUE!"
    else
        echo "Hash verified, continue with install"
        chmod +x $CONDA_INSTALL_SCRIPT 
        # Install miniconda to user local directory
        _CONDA_ROOT=$HOME/.local/conda
        sh $CONDA_INSTALL_SCRIPT -b -p $_CONDA_ROOT
        # Activate the basic conda environment
        source $_CONDA_ROOT/etc/profile.d/conda.sh
        # Update the base 
        conda update --name base conda --yes 

        #conda update -y -n base conda 
        conda create -y -n conda38 python=3.8 --override-channels --channel conda-forge
        conda activate conda38
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
    mkdir -p $PYTHON2_VERSION_VENV
    python2 -m virtualenv -p $PYEXE $PYTHON2_VERSION_VENV 
    python2 -m virtualenv --relocatable $PYTHON2_VERSION_VENV 

    PYTHON2_VENV="$HOME/venv2"
    # symlink to the real env
    ln -s $PYTHON2_VERSION_VENV $PYTHON2_VENV
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
    mkdir -p $PYTHON3_VENV
    ~/.local/bin/python3 -m venv $PYTHON3_VENV
    ln -s $PYTHON3_VENV ~/venv3 

}

setup_venvpypy(){
    echo "setup venvpypy"

    PYPY_VENV="$HOME/venvpypy"
    mkdir -p $PYPY_VENV

    #sudo apt install pypy pypy-pip

    #pypy -m pip install pip
    #pip -m install virtualenv --user
    #pip install virtualenv
    pypy -m ensurepip
    virtualenv -p /usr/bin/pypy $PYPY_VENV 

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

install_fonts()
{
    # Download fonts
    #sudo apt -y install nautilus-dropbox

    mkdir -p ~/tmp 
    cd ~/tmp
    wget https://github.com/antijingoist/open-dyslexic/archive/master.zip
    7z x master.zip

    wget https://downloads.sourceforge.net/project/cm-unicode/cm-unicode/0.7.0/cm-unicode-0.7.0-ttf.tar.xz
    7z x cm-unicode-0.7.0-ttf.tar.xz && 7z x cm-unicode-0.7.0-ttf.tar && rm cm-unicode-0.7.0-ttf.tar

    _SUDO ""
    #_SUDO sudo
    #FONT_DIR=/usr/share/fonts
    FONT_DIR=$HOME/.fonts
    TTF_FONT_DIR=$FONT_DIR/truetype
    OTF_FONT_DIR=$FONT_DIR/truetype
    mkdir -p $TTF_FONT_DIR
    mkdir -p $OTF_FONT_DIR

    cp $HOME/code/erotemic/safe/assets/DyslexicBundle.zip $HOME/tmp
    mkdir -p $HOME/tmp/DyslexicBundle
    rm -rf $HOME/tmp/DyslexicBundle
    mkdir -p $HOME/tmp/DyslexicBundle
    unzip $HOME/code/erotemic/safe/assets/DyslexicBundle.zip -d $HOME/tmp/DyslexicBundle
    ls $HOME/tmp/DyslexicBundle
    $_SUDO cp -v $HOME/tmp/DyslexicBundle/*.ttf $TTF_FONT_DIR/
    $_SUDO cp -v $HOME/tmp/DyslexicBundle/*.otf $OTF_FONT_DIR/

    ls ~/Dropbox/Fonts/
    cd ~/Dropbox/Fonts/
    $_SUDO cp -v ~/Dropbox/Fonts/*.ttf $TTF_FONT_DIR/
    $_SUDO cp -v ~/Dropbox/Fonts/*.otf $OTF_FONT_DIR/
    $_SUDO cp -v ~/tmp/open-dyslexic-master/otf/*.otf $OTF_FONT_DIR/
    $_SUDO cp -v ~/tmp/cm-unicode-0.7.0/*.ttf $TTF_FONT_DIR/

    $_SUDO fc-cache -f -v

    # Delete matplotlib cache if you install new fonts
    rm ~/.cache/matplotlib/fontList*
}


install_dropbox_fonts2(){
    # DEPENDS: Linked Dropbox
    mkdir -p $HOME/.fonts/truetype
    cp -v ~/Dropbox/Fonts/*.ttf $HOME/.fonts/truetype
    cp -v ~/Dropbox/Fonts/*.otf $HOME/.fonts/truetype
    fc-cache -f -v
}

virtualbox_ubuntu_init()
{
    sudo apt install dkms 
    sudo apt update
    sudo apt upgrade
    # Press Ctrl+D to automatically install virtualbox addons do this
    sudo apt install virtualbox-guest-additions-iso
    sudo apt install dkms build-essential linux-headers-generic
    sudo apt install build-essential linux-headers-$(uname -r)
    sudo apt install virtualbox-ose-guest-x11
    # setup virtualbox for ssh
    VBoxManage modifyvm virtual-ubuntu --natpf1 "ssh,tcp,,3022,,22"
}

nopassword_on_sudo()
{ 
    # DEPRICATE: we dont do this anymore
    # CAREFUL. THIS IS HUGE SECURITY RISK
    # References: http://askubuntu.com/questions/147241/execute-sudo-without-password
    sudo cat /etc/sudoers > ~/tmp/sudoers.next  
    echo "$USERNAME ALL=(ALL) NOPASSWD: ALL" >> ~/tmp/sudoers.next  
    # Copy over the new sudoers file
    visudo -c -f ~/tmp/sudoers.next
    if [ "$?" -eq "0" ]; then
        sudo cp ~/tmp/sudoers.next /etc/sudoers
    fi 
    rm ~/tmp/sudoers.next
} 

 
nautilus_hide_unwanted_sidebar_items()
{
    __doc__="
    CommandLine:
        source ~/local/init/freshstart_ubuntu.sh && nautilus_hide_unwanted_sidebar_items

    Refernces:
        https://askubuntu.com/questions/762591/how-to-remove-unwanted-default-bookmarks-in-nautilus
        https://askubuntu.com/questions/79150/how-to-remove-bookmarks-from-the-nautilus-sidebar/1042059#1042059
    "

    echo "Removing unwanted nautilus sidebar items"

    if [ "1" == "0" ]; then
        # Sidebar items are governed by files in $HOME and /etc
        ls ~/.config/user-dirs*
        ls /etc/xdg/user-dirs*

        cat ~/.config/user-dirs.dirs 
        cat ~/.config/user-dirs.locale

        cat /etc/xdg/user-dirs.conf 
        cat /etc/xdg/user-dirs.defaults 

        #cat ~/.config/user-dirs.conf 
    fi

    ### --------------------------------------
    ### modify local config files in $HOME/.config
    ### --------------------------------------
    
    chmod u+w ~/.config/user-dirs.dirs
    #sed -i 's/XDG_DOCUMENTS_DIR/#XDG_DOCUMENTS_DIR/' ~/.config/user-dirs.dirs
    sed -i 's/XDG_TEMPLATES_DIR/#XDG_TEMPLATES_DIR/' ~/.config/user-dirs.dirs 
    sed -i 's/XDG_PUBLICSHARE_DIR/#XDG_PUBLICSHARE_DIR/' ~/.config/user-dirs.dirs
    sed -i 's/XDG_MUSIC_DIR/#XDG_MUSIC_DIR/' ~/.config/user-dirs.dirs
    sed -i 's/XDG_PICTURES_DIR/#XDG_PICTURES_DIR/' ~/.config/user-dirs.dirs
    sed -i 's/XDG_VIDEOS_DIR/#XDG_VIDEOS_DIR/' ~/.config/user-dirs.dirs
    ###
    echo "enabled=true" >> ~/.config/user-dirs.conf
    chmod u-w ~/.config/user-dirs.dirs

    ### --------------------------------------
    ### Modify global config files in /etc/xdg
    ### --------------------------------------

    #sudo sed -i 's/DOCUMENTS/#DOCUMENTS/'     /etc/xdg/user-dirs.defaults 
    sudo sed -i 's/TEMPLATES/#TEMPLATES/'     /etc/xdg/user-dirs.defaults 
    sudo sed -i 's/PUBLICSHARE/#PUBLICSHARE/' /etc/xdg/user-dirs.defaults 
    sudo sed -i 's/MUSIC/#MUSIC/'             /etc/xdg/user-dirs.defaults 
    sudo sed -i 's/PICTURES/#PICTURES/'       /etc/xdg/user-dirs.defaults 
    sudo sed -i 's/VIDEOS/#VIDEOS/'           /etc/xdg/user-dirs.defaults 
    ###
    sudo sed -i "s/enabled=true/enabled=false/" /etc/xdg/user-dirs.conf
    sudo echo "enabled=false" >> /etc/xdg/user-dirs.conf
    sudo sed -i "s/enabled=true/enabled=false/" /etc/xdg/user-dirs.conf

    # Trigger an update
    xdg-user-dirs-gtk-update

    echo "
    NOTE:
        After restarting nautilus the unwanted items will be demoted to regular
        bookmarks. You can now removed them via the right click context menu.
    "
}


nautilus_settings()
{
    #echo "Get Open In Terminal in context menu"
    #sudo apt install nautilus-open-terminal -y

    # Tree view for nautilus
    gsettings set org.gnome.nautilus.window-state side-pane-view "tree"

    #http://askubuntu.com/questions/411430/open-the-parent-folder-of-a-symbolic-link-via-right-click
    mkdir -p ~/.gnome2/nautilus-scripts
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
    echo $IBEIS_WORK_DIR
    ln -s $IBEIS_WORK_DIR  work
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
    sudo apt install -y tmux astyle
    sudo apt install -y synaptic okular
    sudo apt install -y openssh-server

    sudo apt install -y valgrind synaptic gitg expect
    sudo apt install sshfs -y

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
    ./
    

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
    dpkg -i $PKG_DEB --force-not-root --root=$HOME 
    #--------
}


customize_sudoers()
{ 
    # References: http://askubuntu.com/questions/147241/execute-sudo-without-password
    # Make timeout for sudoers a bit longer
    sudo cat /etc/sudoers > ~/tmp/sudoers.next  
    sed -i 's/^Defaults.*env_reset/Defaults    env_reset, timestamp_timeout=480/' ~/tmp/sudoers.next 
    # Copy over the new sudoers file
    sudo visudo -c -f ~/tmp/sudoers.next
    if [ "$?" -eq "0" ]; then
        sudo cp ~/tmp/sudoers.next /etc/sudoers
    fi 
    rm ~/tmp/sudoers.next
    #cat ~/tmp/sudoers.next  
    #sudo cat /etc/sudoers 
} 


gnome_settings()
{
    # NOTE: mouse scroll wheel behavior was fixed by unplugging and replugging
    # the mouse. Odd. 

    #gconftool-2 --all-dirs "/"
    #gconftool-2 --all-dirs "/desktop/url-handlers"
    #gconftool-2 -a "/desktop/url-handlers"
    #gconftool-2 -a "/desktop/applications"
    #gconftool-2 --all-dirs "/schemas/desktop"
    #gconftool-2 --all-dirs "/apps"
    #gconftool-2 -R /desktop
    #gconftool-2 -R /
    #gconftool-2 --get /apps/nautilus/preferences/desktop_font
    #gconftool-2 --get /desktop/gnome/interface/monospace_font_name

    #gconftool-2 -a "/apps/gnome-terminal/profiles/Default" 
    #gsettings set org.gnome.desktop.lockdown disable-lock-screen 'true'
    #sudo -u gdm gconftool-2 --type=bool --set /desktop/gnome/sound/event_sounds false
    #sudo apt install -y gnome-tweak-tool

    gconftool-2 --set "/apps/gnome-terminal/profiles/Default/background_color" --type string "#1111111"
    gconftool-2 --set "/apps/gnome-terminal/profiles/Default/foreground_color" --type string "#FFFF6999BBBB"
    gconftool-2 --set /apps/gnome-screensaver/lock_enabled --type bool false
    gconftool-2 --set /desktop/gnome/sound/event_sounds --type=bool false

    # try and disable password after screensaver lock
    gsettings set org.gnome.desktop.lockdown disable-lock-screen 'true'
    gsettings set org.gnome.desktop.screensaver lock-enabled false

    # need to enable to super+L works
    # gsettings set org.gnome.desktop.lockdown disable-lock-screen 'false'


    # Fix search in nautilus (remove recurison)
    # http://askubuntu.com/questions/275883/traditional-search-as-you-type-on-newer-nautilus-versions
    gsettings set org.gnome.nautilus.preferences enable-interactive-search true
    #gsettings set org.gnome.nautilus.preferences enable-interactive-search false

    gconftool-2 --get /apps/gnome-screensaver/lock_enabled 
    gconftool-2 --get /desktop/gnome/sound/event_sounds

    #sudo apt install nautilus-open-terminal
}


jupyter_mime_association(){
    python -m utool.util_ubuntu --exec-add_new_mimetype_association --mime-name=ipynb+json --ext=.ipynb --exe-fpath=/usr/local/bin/ipynb
    python -m utool.util_ubuntu --exec-add_new_mimetype_association --mime-name=ipynb+json --ext=.ipynb --exe-fpath=jupyter-notebook --force
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
    sudo usermod -aG fuse $USER
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


retro_console(){
    # https://github.com/Swordfish90/cool-retro-term 
    wget https://github.com/Swordfish90/cool-retro-term/releases/download/1.1.1/Cool-Retro-Term-1.1.1-x86_64.AppImage
    chmod a+x Cool-Retro-Term-1.1.1-x86_64.AppImage
    ./Cool-Retro-Term-1.1.1-x86_64.AppImage
}

brio_webcam(){
    # https://www.kurokesu.com/main/2016/01/16/manual-usb-camera-settings-in-linux/
    sudo apt-get install v4l-utils
    v4l2-ctl --list-devices

    v4l2-ctl -d /dev/video1 --list-ctrls

    v4l2-ctl -d /dev/video0 --list-ctrls
    v4l2-ctl -d /dev/video1 --list-ctrls

    v4l2-ctl -d /dev/video0 --set-ctrl=focus_auto=1
    v4l2-ctl -d /dev/video0 --set-ctrl=exposure_auto_priority=1
    v4l2-ctl -d /dev/video0 --set-ctrl=backlight_compensation=0
    v4l2-ctl -d /dev/video0 --set-ctrl=focus_absolute=10
    v4l2-ctl -d /dev/video0 --set-ctrl=zoom_absolute=100
    
    #v4l2-ctl -d /dev/video0 --set-ctrl=focus_auto=0
    #v4l2-ctl -d /dev/video0 --set-ctrl=focus_absolute=255
    #v4l2-ctl -d /dev/video0 --set-ctrl=focus_absolute=0
    #v4l2-ctl -d /dev/video0 --set-ctrl=zoom_absolute=100
    v4l2-ctl -d /dev/video0 --set-ctrl=zoom_absolute=150
    v4l2-ctl -d /dev/video0 --set-ctrl=zoom_absolute=180

}

fix_dns_issue(){
    # Reference: https://bugs.launchpad.net/ubuntu/+source/dnsmasq/+bug/1639776
    # Reference: https://askubuntu.com/questions/233222/how-can-i-disable-the-dns-that-network-manager-uses
    #There is a workaround for the openvpn issue on ubuntu
    #16.04. After connecting to the vpn, run:
    sudo pkill dnsmasq
    sudo sed -i 's/^\(dns=dnsmasq\)/#\1/g' /etc/NetworkManager/NetworkManager.conf 
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
    
    sudo mdadm --examine $RAID_PARTS
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

gnome_extensions(){
    https://extensions.gnome.org/extension/352/middle-click-to-close-in-overview/
    https://extensions.gnome.org/extension/15/alternatetab/

    https://extensions.gnome.org/extension/120/system-monitor/
    https://extensions.gnome.org/extension/9/systemmonitor/
}

install_travis_cmdline_tool(){
    sudo apt install ruby ruby-dev -y
    sudo gem install travis
}

disable_screen_lock(){
    # References: https://askubuntu.com/questions/1041230/how-to-disable-screen-locking-in-ubuntu-18-04-gnome-shell
    gsettings set org.gnome.desktop.screensaver lock-enabled false
    # also can do it via settings -> privacy -> screen lock
}


install_basic_extras(){
    # Vera Crypt
    sudo add-apt-repository ppa:unit193/encryption -y
    sudo apt update
    sudo apt install veracrypt -y

    # Dropbox
    #sudo apt -y install nautilus-dropbox
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

    source $HOME/local/init/utils.sh
    safe_symlink $HOME/code/transcrypt/transcrypt $HOME/.local/bin/transcrypt

    #git clone https://github.com/Erotemic/roaming.git
    git clone https://gitlab.com/Erotemic/erotemic.git
    cd $HOME/code/erotemic

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


stop_evolution_cpu_hogging(){
    # STOP USING MY CPU. EVOLUTION!
    sudo chmod -x /usr/lib/evolution/evolution-calendar-factory
    sudo chmod -x /usr/lib/evolution/evolution-*
}


fix_ubuntu_18_04_sound_pop_issue(){
    __doc__="
    Script that fixes a popping sound due to a power saving feature

    References:
        https://superuser.com/questions/1493096/linux-ubuntu-speakers-popping-every-few-seconds
        https://www.youtube.com/watch?v=Pdmy8dMWitg
    "
    sudo echo "obtaining sudo"
    # First, there are two system files that need modification
    # Changing the values here should fix the issue in your current session. 
    cat /sys/module/snd_hda_intel/parameters/power_save
    cat /sys/module/snd_hda_intel/parameters/power_save_controller
    # Flip the 1 to a 0
    sudo sh -c "echo 0 > /sys/module/snd_hda_intel/parameters/power_save"
    # Flip the Y to a N
    sudo sh -c "echo N > /sys/module/snd_hda_intel/parameters/power_save_controller"

    # To make this change persistant we must modify a config file
    if [ -f "/etc/default/tlp" ]; then
        # Some systems (usually laptops) have this controlled via TLP 
        sudo sed -i 's/SOUND_POWER_SAVE_ON_BAT=1/SOUND_POWER_SAVE_ON_BAT=0/' /etc/default/tlp
        sudo sed -i 's/SOUND_POER_SAVE_CONTROLLER=Y/SOUND_POER_SAVE_CONTROLLER=N/' /etc/default/tlp
    elif [ -f "/etc/modprobe.d/alsa-base.conf" ]; then
        # Append this line to the end of the file
        text="options snd-hda-intel power_save=0 power_save_controller=N"
        fpath="/etc/modprobe.d/alsa-base.conf"
        # Apppend the text only if it doesn't exist
        found="$(grep -F "$text" "$fpath")"
        if [ "$found" == "" ]; then
            sudo sh -c "echo \"$text\" >> $fpath"
        fi
        cat "$fpath"
    else
        echo "Error!, unknown system audio configuration" 1>&2
        exit 1
    fi
}

test_lan_speed(){
    # https://askubuntu.com/questions/7976/how-do-you-test-the-network-speed-between-two-boxes
    sudo apt install iperf
}

latest_clickclose_gnome(){
    # Also: Try this first -> enable quick close
    sudo apt install gnome-tweaks
    # https://github.com/p91paul/middleclickclose

    mkdir -p $HOME/tmp/prep_middleclickclose
    cd $HOME/tmp/prep_middleclickclose
    source $HOME/local/init/utils.sh
    curl_verify_hash https://codeload.github.com/p91paul/middleclickclose/zip/7c1653bf00da0bc28296ce921cc79ccf4d91e6d4 middleclickclose.zip f0890d8ad6d967844

    #curl https://codeload.github.com/p91paul/middleclickclose/zip/7c1653bf00da0bc28296ce921cc79ccf4d91e6d4 -o middleclickclose.zip 
    7z x -y middleclickclose.zip 

    mkdir -p $HOME/.local/share/gnome-shell/extensions
    cp -r middleclickclose-7c1653bf00da0bc28296ce921cc79ccf4d91e6d4/middleclickclose@paolo.tranquilli.gmail.com $HOME/.local/share/gnome-shell/extensions/
    glib-compile-schemas $HOME/.local/share/gnome-shell/extensions/middleclickclose@paolo.tranquilli.gmail.com/schemas

    # reload gnome shell (alternative to alt-f2 + r)
    killall -3 gnome-shell
    
}


htop_like_resource_monitors(){

    # Core: Also
    nvtop
    htop

    # Disk monitor
    sudo apt install iotop

    # nmon shows usage per disk (and others info)
    sudo apt install nmon

    # Network monitor tools
    # bmon shows usage network interface
    sudo apt install bmon

    # Requires sudo shows usge per program
    sudo apt install nethogs

    # requires sudo, not obvious what it does
    sudo apt install iftop

    # https://itsfoss.com/linux-system-monitoring-tools/

    # https://www.reddit.com/r/linux/comments/na637t/diskgraph_for_if_youre_wondering_what_your_disk/

    #sudo apt install bashtop
    bashtop
    pip install bpytop 

    #sudo add-apt-repository ppa:bashtop-monitor/bashtop
    #sudo apt update
    #sudo apt install bashtop
}



check_hdd_health(){
    # https://superuser.com/questions/171195/how-to-check-the-health-of-a-hard-drive
    sudo smartctl -a /dev/sda | less
    
    sudo apt-get install gsmartcontrol
}

fix_ubuntu_permissions_cmd_not_found(){
    sudo chmod ugo+r /var/lib/command-not-found/commands.db
}

benchmark()
{
    # https://linuxconfig.org/how-to-benchmark-your-linux-system

    sudo apt install sysbench

    sysbench cpu run

    sysbench cpu run --threads=1 --cpu-max-prime=10000
    sysbench cpu run --threads=1 --cpu-max-prime=100000
    sysbench cpu run --threads=4 --cpu-max-prime=400000
    sysbench cpu run --threads=8 --cpu-max-prime=8000000

    sysbench memory run

    sysbench fileio --file-test-mode=seqwr run

    #time (python -m pip install xdoctest && python -m xdoctest xdoctest)


    # https://hewlettpackard.github.io/dlcookbook-dlbs/#/
    git clone https://github.com/HewlettPackard/dlcookbook-dlbs.git ./dlbs   # Install benchmarking suite
    cd ./dlbs  
    source ./scripts/environment.sh                                          # Initialize host environment
    python ./python/dlbs/experimenter.py help --frameworks                   # List supported DL frameworks
    docker pull nvcr.io/nvidia/pytorch:18.06-py3                             # Pull PyTorch docker image from NGC
    docker pull nvcr.io/nvidia/pytorch:18.06-py3

    export BENCH_ROOT="."
    . ./scripts/environment.sh
    # MASSIVE HACK:
    # fixes dlbs scripts that use the old "nvida-docker" to use "docker <arg1> --runtime=nvidia <arg-rest>"
    mkdir -p hack_bin
    codeblock()
    {
        __doc__="helper to deindent text in bash scripts"
        PYEXE=python
        echo "$1" | $PYEXE -c "import sys; from textwrap import dedent; print(dedent(sys.stdin.read()).strip('\n'))"
    }
    echo "$(codeblock '
    FIRST=$1
    shift
    nvidia-docker $FIRST --runtime=nvidia $@
    ')" > ./hack_bin/nvidia-docker
    chmod +x ./hack_bin/nvidia-docker
    PATH="$PWD/hack_bin:$PATH"

    rm -rf ./pytorch ./logs
    python $DLBS_ROOT/python/dlbs/experimenter.py run \
        --log-level="debug" \
        -Pexp.framework='"pytorch"' \
        -Vexp.gpus='"1"' \
        -Vexp.rerun='"always"' \
        -Ppytorch.cudnn_benchmark=false \
        -Ppytorch.cudnn_fastest=true \
        -Ppytorch.num_loader_threads=4 \
        -Pexp.device_type='"gpu"' \
        -Pexp.dtype='"float32"' \
        -Pexp.num_batches='2' \
        -Pexp.phase='"inference"' \
        -Vexp.model='"resnet50"' \
        -Pexp.docker=true \
        -Pexp.log_file='"${BENCH_ROOT}/pytorch/${exp.model}_${exp.effective_batch}_${exp.num_gpus}.log"' \
        -Pexp.docker_args='"--rm --shm-size=1g --ulimit memlock=-1 --ulimit stack=67108864"'

    params="exp.status,exp.framework_title,exp.effective_batch,results.time,results.throughput,exp.model_title,exp.docker_image"

    python $logparser ./pytorch/logs/*.log --output_file './results.json' 

    python $reporter --summary_file '${HOME}/dlbs/results.json'\             # Parse summary file and build
                     --type 'weak-scaling'\                                  #     weak scaling report
                     --target_variable 'results.time'                        #     using batch time as performance metric


    python $DLBS_ROOT/python/dlbs/bench_data.py parse ./pytorch/*.log  --output results.json

    python $DLBS_ROOT/python/dlbs/bench_data.py summary  results.json 

    python $DLBS_ROOT/python/dlbs/bench_data.py report  results.json --report strong
    python $DLBS_ROOT/python/dlbs/bench_data.py report  results.json --report regular
    python $DLBS_ROOT/python/dlbs/bench_data.py report  results.json --report '{"inputs": ["exp.status","exp.framework_title","exp.effective_batch","results.time","results.throughput","exp.model_title","exp.docker_image"], "output": "exp.num_gpus", "report_efficiency": true}'
    echo "params = $params"


    python $DLBS_ROOT/python/dlbs/bench_data.py summary results.json --report weak
    python $DLBS_ROOT/python/dlbs/bench_data.py summary results.json --report string
    --output_params ${params}                           
    
    
    docker run -ti nvcr.io/nvidia/tensorflow:18.07-py3 /bin/bash
    nvidia-docker run -ti nvcr.io/nvidia/tensorflow:18.07-py3 /bin/bash
    
}
