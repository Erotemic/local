#!/bin/sh
export QT_ACCESSIBILITY=0
export NCPUS=$(grep -c ^processor /proc/cpuinfo)

if [[ "$OSTYPE" == "darwin"* ]]; then
    source ~/local/bashrc_mac.sh
else
    source ~/local/bashrc_ubuntu.sh
fi

export PYTHONPATH=/home/joncall/code/utool:$PYTHONPATH
export QT_API=pyqt

#export OMP_NUM_THREADS=7

source ~/local/alias_rc.sh
source ~/local/git_helpers.sh

update_pip_dists()
{
    sudo pip install pyinstaller --upgrade
}
