#!/bin/sh
export QT_ACCESSIBILITY=0

if [[ "$OSTYPE" == "darwin"* ]]; then
    source ~/local/bashrc_mac.sh
else
    source ~/local/bashrc_ubuntu.sh
fi

export PYTHONPATH=/home/joncall/code/utool:$PYTHONPATH

#export OMP_NUM_THREADS=7

source ~/local/alias_rc.sh
source ~/local/git_helpers.sh

alias makeinit='~/code/utool/utool/util_scripts/make_init.py'


update_pip_dists()
{
    sudo pip install pyinstaller --upgrade
}
