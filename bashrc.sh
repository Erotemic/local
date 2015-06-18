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
export PATH=$PATH:/usr/local/cuda/bin
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/cuda/lib64:/usr/local/lib


# set history to not ignore leading whitespace
export HISTCONTROL=



# More machine specific settings
if [[ "$HOSTNAME" == "dozer"  ]]; then 
    export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/cuda-6.5/lib64:/usr/local/lib
    export PATH=$PATH:/usr/local/cuda-6.5/bin
fi

# massive hack. TODO: remove
#export PATH=$PATH:/home/joncrall/.config/ibeis_cnn/training_junction/
