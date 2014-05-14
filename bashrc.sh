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


update_pip_dists()
{
    sudo pip install pyinstaller --upgrade
}

update_pyrepos()
{
    sudo python ~/code/utool/setup.py install sdist
    sudo python ~/code/vtool/setup.py install sdist
    sudo python ~/code/hesaff/setup.py install sdist
    #cd ~/code/vtool
    #sudo setup.py install
}

alias uppy=update_pyrepos
