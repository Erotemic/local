#!/bin/bash


if [[ -d "$HOME/code/footswitch" ]] ; then
    git clone https://github.com/rgerganov/footswitch.git "$HOME"/code/footswitch
fi

sudo apt-get install libhidapi-dev -y


cd "$HOME"/code/footswitch

# Actually need sudo because of udev
make 
sudo make install

# https://github.com/rgerganov/footswitch
#program the first pedal to print 'a', second pedal to print 'b' and third pedal to print 'c'
footswitch -1 -k a -2 -k b -3 -k c

sudo footswitch -r
sudo footswitch -1 -k f5 -2 -k f7  -3 -m win
