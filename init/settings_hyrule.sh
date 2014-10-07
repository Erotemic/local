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
#Static IP Address
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

    #http://www.blackmoreops.com/2013/11/25/how-to-fix-wired-network-interface-device-not-managed-error/
    #http://askubuntu.com/questions/71159/network-manager-says-device-not-managed
    sudo sed -i 's/^managed=false/managed=true/' /etc/NetworkManager/NetworkManager.conf
    sudo service network-manager restart
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

setup_gitserver()
{
    # Set git user password
    sudo passwd git
    # Become git
    su git
    cd
    # Make .ssh dir
    mkdir .ssh
    # add authorized keys
    cat ~joncrall/.ssh/id_rsa.pub >> ~git/.ssh/authorized_keys
    # Permissions
    chmod -R go= ~git/.ssh
    # Change shell so nasty things can't happen on the relatively open git server
    sudo chsh -s /bin/rbash git
    sudo chown -R git:git ~git/*
    sudo chown -R git:git ~git/.ssh
}


make_newrepo()
{
    sudo /home/joncrall/scripts//new_repo.sh crall-cvpr-15
    lt
    git clone git@hyrule.cs.rpi.edu:crall-cvpr-15.git

    ####
    #cp .gitignore ../crall-cvpr-15/
    #cp ~/Dropbox/CVPR\ Paper/*.tex .
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
    cp -rv $BACKUPHOME/joncrall/Pictures/* ~/Pictures
    cp -rv $BACKUPHOME/joncrall/Documents/* ~/Documents
    
    export BACKUPHOME="/media/joncrall/SeagateBackup/sep14bak/home"
    sudo cp -rv $BACKUPHOME/git/* ~git
    sudo cp -rv $BACKUPHOME/joncrall/code/gnome-shell-grid ~joncrall/code/
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


printer(){
#http://www.cs.rpi.edu/twiki/view/LabstaffWeb/PublicPrinters
#http://www.rpi.edu/dept/arc/web/printing/printertype.html
128.213.17.40
sudo cat /etc/cups/printers.conf
sudo gvim /etc/cups/printers.conf
sudo lpstat -s

# This by itself doesnt seem to work 

sudo sh -c 'cat >> /etc/cups/printers.conf << EOL
<DefaultPrinter Xerox-Phaser-6300DN>
UUID urn:uuid:fa12f4f5-4401-3be7-7c43-e1583d40f019
Info Xerox Phaser 6300DN
Location 128.213.17.40
DeviceURI socket://128.213.17.40:9100
PPDTimeStamp *
State Idle
StateTime 1409678168
Type 8433684
Accepting Yes
Shared Yes
ColorManaged Yes
JobSheets none none
QuotaPeriod 0
PageLimit 0
KLimit 0
OpPolicy default
ErrorPolicy retry-job
Attribute marker-colors \#00FFFF,#FF00FF,#FFFF00,#000000,none,none,none,none,none,none,none
Attribute marker-levels 24,33,41,32,0,63,88,88,88,88,0
Attribute marker-names Cyan Toner Cartridge, Phaser 6300/6350, PN 106R01073,Magenta Toner Cartridge, Phaser 6300/6350, PN 106R01074,Yellow Toner Cartridge, Phaser 6300/6350, PN 106R01075,Black Toner Cartridge, Phaser 6300/6350, PN 106R01076,Imaging Unit, Phaser 6300/6350, PN 108R00645,Fuser, Phaser 6300/6350, PN 115R00035 (110 V)/115R00036 (220 V),Cyan Developer Unit,Magenta Developer Unit,Yellow Developer Unit,Black Developer Unit,Transfer Roller, Phaser 6300/6350, PN 108R000646
Attribute marker-types toner,toner,toner,toner,opc,fuser,opc,opc,opc,opc,transferUnit
Attribute marker-change-time 1409678168
</Printer>
'

sudo restart cups
}
