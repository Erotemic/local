#!/bin/sh
export QT_ACCESSIBILITY=0
export NCPUS=$(grep -c ^processor /proc/cpuinfo)

if [[ "$OSTYPE" == "darwin"* ]]; then
    source ~/local/bashrc_mac.sh
else
    source ~/local/bashrc_ubuntu.sh
fi

export QT_API=pyqt
export PYTHONPATH=/home/joncall/code/utool:$PYTHONPATH
export PYTHONPATH=/home/joncall/local/pyscripts:$PYTHONPATH


if [[ "$(hostname)" == "ibeis.cs.uic.edu"  ]]; then 
    export CODE_DIR=/opt/ibeis
else
    export CODE_DIR=~/code
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
}
export PATH=$PATH:/usr/local/cuda/bin
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/cuda/lib64:/usr/local/lib


# set history to not ignore leading whitespace
export HISTCONTROL=
