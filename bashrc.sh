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
export PYTHONPATH=/home/joncrall/code/utool:$PYTHONPATH
export PYTHONPATH=/home/joncrall/local/pyscripts:$PYTHONPATH


if [[ "$HOSTNAME" == "ibeis.cs.uic.edu"  ]]; then 
    export CODE_DIR=/opt/ibeis
elif [[ "$HOSTNAME" == "pachy.cs.uic.edu"  ]]; then 
    export CODE_DIR=/opt/ibeis
else
    export CODE_DIR=~/code
fi

if [ -d "~/venv" ]; then
    source ~/venv/bin/activate
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
export PATH=$PATH:/usr/local/cuda/bin
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/cuda/lib64:/usr/local/lib


# set history to not ignore leading whitespace
export HISTCONTROL=
