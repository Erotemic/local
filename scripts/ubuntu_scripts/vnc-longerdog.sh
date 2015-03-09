#!/bin/sh
export REMOTE_ADDRESS=longerdog.com

# sudo apt-get install vncviewer

PORTNUM=5902
vncdisconnect()
{
    kill -9 $(lsof -i:$PORTNUM -t)
}
vncconnect()
{
#ssh -t -C -N -f -i ~/.ssh/id_rsa joncrall@$REMOTE_ADDRESS -L $PORTNUM:localhost:5900

ssh -t -C -N -f -i ~/.ssh/id_rsa joncrall@longerdog.com -L 5902:localhost:5900
}

#vncconnect
#vncviewer 127.0.0.1:$PORTNUM
#xvnc4viewer 
vncconnect

#exec 42<<'__PYSCRIPT__'
#import utool as ut
#import os
#remmina_conf_text = ut.codeblock(
#    """
#    [remmina]
#    disableclipboard=0
#    ssh_auth=0
#    clientname=
#    quality=0
#    ssh_charset=
#    ssh_privatekey=
#    console=0
#    resolution=1800x900
#    group=
#    password=supersecretpassword==
#    name=HostNameZeusCannon
#    ssh_loopback=0
#    shareprinter=0
#    ssh_username=
#    ssh_server=
#    security=
#    protocol=RDP
#    execpath=
#    sound=off
#    exec=
#    ssh_enabled=0
#    username=myusername@gmail.com
#    sharefolder=
#    domain=
#    server=192.168.13.106
#    colordepth=32
#    window_maximize=0
#    window_height=967
#    viewmode=1
#    window_width=1812
#    ~         
#    """)
#ut.write_to('remminaconf-vnc-longerdog.remmina', remmina_conf_text)
#__PYSCRIPT__
#python /dev/fd/42

remmina -c ~/local/scripts/ubuntu_scripts/remminaconf-vnc-longerdog.remmina
#vinagre --vnc-scale localhost:5902
