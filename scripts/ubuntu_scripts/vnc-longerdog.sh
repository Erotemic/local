#!/bin/sh

PORTNUM=5902
vncdisconnect()
{
    kill -9 $(lsof -i:$PORTNUM -t)
}
vncconnect()
{
ssh -t -C -N -f -i ~/.ssh/id_rsa joncrall@longerdog.com -L $PORTNUM:localhost:5900
}

#vncconnect
#vncviewer 127.0.0.1:$PORTNUM
#xvnc4viewer 
vncconnect
remmina
#vinagre --vnc-scale localhost:5902
