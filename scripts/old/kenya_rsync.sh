#!/usr/bin/env bash
echo -en "\033]0;RSync Kenya\a"
#export SERVER_ADDRESS=ibeis.cs.uic.edu
#export SERVER_ADDRESS=131.193.42.63
#export SERVER_ADDRESS=41.215.76.14
export SERVER_ADDRESS=ibeis.cs.uic.edu
echo "rsync into $SERVER_ADDRESS"

export SERVER_DIR=/data/ibeis/PZ_RoseMary_ONLY
export SRC=jonathan@$SERVER_ADDRESS:$SERVER_DIR
export DST=/raid/raw_rsync

rsync -rzP --exclude='_ibeis_cache' --exclude='chips' $SRC $DST
