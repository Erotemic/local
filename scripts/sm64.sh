#!/usr/bin/env bash
__doc__='
SeeAlso:
'
ARG1=$1
if [[ "$ARG1" == "cd" ]]; then
    echo "$HOME"/code/sm64-port/build/us_pc
    cd "$HOME"/code/sm64-port/build/us_pc
    ./sm64.us
    echo "$HOME"/code/sm64-port/build/us_pc
else
    (cd "$HOME"/code/sm64-port/build/us_pc && ./sm64.us)
fi
