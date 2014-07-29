#!/bin/sh
# Change terminal title
echo -en "\033]0;SSH server\a"
#export SERVER_ADDRESS=ibeis.cs.uic.edu
#export SERVER_ADDRESS=131.193.42.63
export SERVER_ADDRESS=41.215.76.14
ssh jonathan@$SERVER_ADDRESS

#-i ~/.ssh/id_rsa

# ssh -X jonathan@131.193.42.63
