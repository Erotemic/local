#!/bin/sh

if [[ "$OSTYPE" == "darwin"* ]]; then
    source ~/local/bashrc_mac.sh
else
    source ~/local/bashrc_ubuntu.sh
fi

source ~/local/alias_rc.sh
source ~/local/git_helpers.sh
