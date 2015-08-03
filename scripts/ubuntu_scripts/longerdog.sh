#!/bin/sh
# Change terminal title
echo -en "\033]0;SSH longerdog\a"
ssh joncrall@longerdog.com -i ~/.ssh/id_rsa
ssh joncrall@longerdog.com -X

vnc_longerdog()
{
    ssh -L 5902:localhost:5900 joncrall@longerdog.com
    vinagre works well


    xtightvncviewer localhost::5902 
    xtightvncviewer localhost::5902 -geometry 600x400

    xtightvncviewer localhost:5901
    xtightvncviewer localhost:5901
    echo "password" >> ~/tmp/longerdog_vnc_passwordfile
    xtightvncviewer localhost::5901 --passwd ~/tmp/longerdog_vnc_passwordfile
    remmina
    https://apps.ubuntu.com/cat/applications/natty/ssvnc/

    ssvnc -
    #ssh joncrall@longerdog.com -L 5901:localhost:5900 "x11vnc -display :0 -noxdamage"


    ibeis@197.248.81.250
    #http://ubuntuforums.org/showthread.php?t=772395
    ssh -L 5901:localhost:5900 ibeis@197.248.81.250
    xtightvncviewer localhost::5901
}

