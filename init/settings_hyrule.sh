hyrule_setup_sshd()
{  
    # This is Hyrule Specific

    # small change to default sshd_config
    sudo sed -i 's/#Banner \/etc\/issue.net/Banner \/etc\/issue.net/' /etc/ssh/sshd_config
    sudo restart ssh
    cat /etc/issue.net 
    sudo sh -c 'cat >> /etc/issue.net << EOL
    
           #  
          ###  
         #####  
        #######  
       #       #  
      ###     ###  
     #####   #####  
    ####### #######  
EOL'
    # Cheeck to see if its running
    ps -A | grep sshd

    cat /etc/network/interfaces
    sudo sh -c 'cat >> /etc/network/interfaces << EOL
auto eth0
iface eth0 inet static 
    address 128.213.17.14
    network 128.213.17.0
    netmask 255.255.255.0
    gateway 128.213.17.1
    broadcast 128.213.17.255
    dns-nameservers 128.113.26.77 128.113.28.67
    dns-search cs.rpi.edu
EOL'
    cat /etc/network/interfaces
}


hyrule_setup_fstab()
{
    # Info
    sudo fdisk -l | grep -e '^/dev/sd'
    # Write store to fstab
    sudo sh -c 'echo "/dev/sdc1                                  /media/Store      ntfs  nls=iso8859-1,uid=1000,windows_names,hide_hid_files,0  0  0" >> /etc/fstab'
    sudo ln -s /media/raid /raid  
    ln -s ~/local/scripts/ubuntu_scripts ~/scripts
    # For Hyrule
    ln -s /media/Store ~/Store
    ln -s /media/raid/work ~/work
}


hyrule_create_users()
{
    # Grant sudoers
    #sudo visudo
    sudo adduser jason
    sudo adduser hendrik
    sudo adduser zack
    sudo adduser git
    # Add group
    sudo groupadd rpi
    sudo usermod -a -G rpi jason
    sudo usermod -a -G rpi joncrall
    sudo usermod -a -G rpi hendrik
    sudo usermod -a -G rpi zack
    # Delete user
    #sudo deluser --remove-home newuser
    #sudo chown -R joncrall:rpi *
    #umask 002 work
    #chgrp rpi work
    #chmod g+s work
}



recover_backup()
{
    export BACKUPLOCAL="/media/joncrall/HADES/local"
    cd "$BACKUPLOCAL"
    export BACKUPHOME="/media/joncrall/SeagateBackup/sep14bak/home"
    cd "$BACKUPHOME/joncrall/.ssh"
    # Recover ssh keys
    mkdir ~/.ssh
    cp -r * ~/.ssh
    cd ~/.ssh
    #cd ~/.ssh
    #cp -r "$BACKUPHOME/.ssh" .
    #mv .ssh/* .
    #rm -rf  ~/.ssh/.ssh
    #
    # Restore user home directories
    export BACKUPHOME="/media/joncrall/SeagateBackup/sep14bak/home"
    cd $BACKUPHOME/hendrik
    sudo cp -r * "/home/hendrik/" 
    #
    # Restore fstab
    export BACKUPETC="/media/joncrall/SeagateBackup/sep14bak/etc"
    cd "$BACKUPETC"

    # Restore some repos
    export BACKUPHOME="/media/joncrall/SeagateBackup/sep14bak/home"
    cd "$BACKUPHOME/joncrall"
    cp -rv $BACKUPHOME/joncrall/code/hotspotter ~/code/hotspotter
    cp -rv $BACKUPHOME/joncrall/latex ~/latex
    cp -rv $BACKUPHOME/joncrall/Pictures ~/Pictures
    cp -rv $BACKUPHOME/joncrall/Documents ~/Documents
}


fix_monitor_positions()
{
    mkdir ~/.config/autostart
sh -c 'cat >> ~/.config/autostart/fixmonitor.desktop << EOL
[Desktop Entry]
Type=Application
Name=FixMonitor
Comment=Hyrule monitor fix
Exec=xrandr --output DVI-D-0 --pos 1920x0 --rotate left --output DVI-I-0 --pos 0x0
NoDisplay=false
#X-GNOME-Autostart-Delay=1
'
    #echo "xrandr --output DVI-D-0 --pos 1920x0 --rotate left --output DVI-I-0 --pos 0x0" >> ~/.config/autostart/
}
