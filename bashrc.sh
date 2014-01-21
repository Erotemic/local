#!/bin/sh

if [[ "$OSTYPE" == "darwin"* ]]; then
    source ~/local/bashrc_mac.sh
else
    source ~/local/bashrc_ubuntu.sh
fi

source alias_rc.sh
