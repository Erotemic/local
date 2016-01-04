#!/bin/sh
export QT_ACCESSIBILITY=0

if [[ "$OSTYPE" == "darwin"* ]]; then
    export NCPUS=$(sysctl -n hw.ncpu)
    source ~/local/bashrc_mac.sh
else
    export NCPUS=$(grep -c ^processor /proc/cpuinfo)
    source ~/local/bashrc_ubuntu.sh
fi

export QT_API=pyqt


# My standard environment variables
if [[ "$HOSTNAME" == "ibeis.cs.uic.edu"  ]]; then 
    export CODE_DIR=/opt/ibeis
elif [[ "$HOSTNAME" == "pachy.cs.uic.edu"  ]]; then 
    export CODE_DIR=/opt/ibeis
else
    export CODE_DIR=~/code
fi

export PYTHONPATH=$CODE_DIR/utool:$PYTHONPATH
export PYTHONPATH=$HOME/local/pyscripts:$PYTHONPATH

export PYTHON_VENV="$HOME/venv"

setup_venv(){
    mkdir $PYTHON_VENV
    virtualenv -p /usr/bin/python2.7 $PYTHON_VENV
}

#echo $PYTHON_VENV

if [ -d "$PYTHON_VENV" ]; then
    source $PYTHON_VENV/bin/activate
fi


#export OMP_NUM_THREADS=7

source ~/local/alias_rc.sh
source ~/local/git_helpers.sh

update_pip_dists()
{
    sudo pip install pyinstaller --upgrade
}
 
permit_erotemic_gitrepo()
{ 
    #permit_gitrepo -i
    sed -i 's/https:\/\/github.com\/Erotemic/git@github.com:Erotemic/' .git/config
    sed -i 's/https:\/\/github.com\/bluemellophone/git@github.com:bluemellophone/' .git/config
}


# set history to not ignore leading whitespace
export HISTCONTROL=


export LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH

# If IBM CPLEX is installed
export CPLEX_PREFIX=/opt/ibm/ILOG/CPLEX_Studio_Community1263
export PATH=$PATH:$CPLEX_PREFIX/cplex/bin/x86-64_linux/
export PATH=$PATH:$CPLEX_PREFIX/opl/oplide/
export PATH=$PATH:$CPLEX_PREFIX/cplex/include/
export PATH=$PATH:$CPLEX_PREFIX/opl/include/
export PATH=$PATH:$CPLEX_PREFIX/opl/

export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$CPLEX_PREFIX/cplex/lib/x86-64_linux/static_pic
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$CPLEX_PREFIX/cplex/bin/x86-64_linux/
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$CPLEX_PREFIX/opl/bin/x86-64_linux
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$CPLEX_PREFIX/opl/lib/x86-64_linux/static_pic

# Other program environment variables
if [[ "$HOSTNAME" == "hyrule"  ]]; then 
    export PATH=$PATH:/usr/local/cuda/bin
    #export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/cuda/lib64:/usr/local/lib
    export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/cuda-7.5/targets/x86_64-linux/lib:/usr/local/cuda/lib64:/usr/local/lib
    #export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/cuda-7.5/targets/x86_64-linux/lib:/usr/local/lib
    
    #export JAVA_HOME=/usr/lib/jvm/java-7-openjdk-amd64
    # hacky
    #export TOMCAT_DIR=$CODE_DIR/Wildbook/tmp/apache-tomcat-8.0.24
    #export TOMCAT_HOME=$TOMCAT_DIR
    #export CATALINA_HOME=$TOMCAT_DIR

    export PATH=$PATH
    export PATH=/usr/local/texlive/2015/bin/x86_64-linux:$PATH
elif [[ "$HOSTNAME" == "dozer"  ]]; then 
    export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/cuda-6.5/lib64:/usr/local/lib
    export PATH=$PATH:/usr/local/cuda-6.5/bin
elif [[ "$HOSTNAME" == "Ooo"  ]]; then 
    #export UTOOL_NO_PYRF=True
    export UTOOL_NO_PYRF=False
    export UTOOL_NO_CNN=False
    export THEANO_FLAGS="device=cpu"

    export PATH=$PATH:/opt/gurobi650/linux64/bin
    export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/opt/gurobi650/linux64/lib
else
    # These paths are likely to be true on other machines as weel
    #export PATH=$PATH:/usr/local/cuda/bin
    #export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/cuda/lib64:/usr/local/lib
    #export JAVA_HOME=/usr/lib/jvm/java-7-openjdk-amd64
    export PATH=$PATH
fi

alias rpivpn='sudo openconnect -b vpn.net.rpi.edu -uyour_school_username -ucrallj'

export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$VIRTUAL_ENV/lib
