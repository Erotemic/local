#!/bin/sh
# Change terminal title
echo -en "\033]0;SSH server\a"
#export SERVER_ADDRESS=ibeis.cs.uic.edu
#export SERVER_ADDRESS=131.193.42.63
#export SERVER_ADDRESS=41.215.76.14
#export SERVER_ADDRESS=ibeis.cs.uic.edu
export SERVER_ADDRESS=41.203.223.178
#export SERVER_PORT=22
export SERVER_PORT=1022
echo "sshing into $SERVER_ADDRESS at port $SERVER_PORT"
ssh -X -p $SERVER_PORT jonathan@$SERVER_ADDRESS

#-i ~/.ssh/id_rsa

# ssh -X jonathan@131.193.42.63
