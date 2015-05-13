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
    sudo adduser kerner
    sudo adduser guest
    # Add group
    sudo groupadd rpi
    sudo usermod -a -G rpi jason
    sudo usermod -a -G rpi joncrall
    sudo usermod -a -G rpi hendrik
    sudo usermod -a -G rpi zack
    sudo usermod -a -G rpi kerner
    # Delete user
    #sudo deluser --remove-home newuser
    #sudo chown -R joncrall:rpi *
    #umask 002 work
    #chgrp rpi work
    #chmod g+s work
    #  New users
    sudo adduser chuck
    sudo usermod -a -G rpi chuck
}

create_bare_repos()
{
    # References:
    # http://www.saintsjd.com/2011/01/what-is-a-bare-git-repository/
    # http://stackoverflow.com/questions/2888029/how-to-push-a-local-git-repository-to-another-computer
    sudo git clone --bare ~joncrall/code/ibeis ~git/ibeis.git
    sudo git clone --bare ~joncrall/code/utool ~git/utool.git
    sudo chown -R git:git ~git/ibeis.git
    sudo chown -R git:git ~git/utool.git
    
    #
    git remote add hyrule git@hyrule.cs.rpi.edu:ibeis.git
    git remote add hyrule git@hyrule.cs.rpi.edu:utool.git
    
}

hyrule_setup_groups()
{
    sudo chown -R joncrall:rpi /raid
    sudo chown -R joncrall:rpi ~/code/caffe

    # fix for hendrik
    sudo chown -R hendrik:hendrik /home/hendrik/Desktop
    sudo chown -R hendrik:hendrik /home/hendrik/Downloads
    sudo chown -R hendrik:hendrik /home/hendrik/ibeis
    sudo chown -R hendrik:hendrik /home/hendrik/project

    chgrp -R rpi /raid

    # give group write access to raid
    sudo chmod -R g+rw /raid
    sudo chmod -R g+rw /raid/work
    sudo chmod -R g+rw /raid/work/GIRM_MUGU_20

    sudo chown -R joncrall:rpi /raid/work/
    sudo chown -R joncrall:rpi /raid/work/GIRM_MUGU_20

    sudo chgrp -R rpi /raid/*
    
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



    echo '
Section "Monitor"
    Identifier     "Monitor0"
    VendorName     "Unknown"
    ModelName      "Samsung SMS24A450/460"
    HorizSync       30.0 - 81.0
    VertRefresh     56.0 - 75.0
    Option         "DPMS"
	# HorizSync source: edid, VertRefresh source: edid
EndSection

Section "Monitor"
    Identifier     "Monitor1"
    VendorName     "Unknown"
    ModelName      "Samsung SyncMaster"
    HorizSync       30.0 - 81.0
    VertRefresh     56.0 - 60.0
EndSection

Section "Screen"
    Identifier     "Screen0"
    Device         "Device0"
    Monitor        "Monitor0"
    DefaultDepth    24
    Option         "NoLogo" "True"
    Option         "Stereo" "0"
    Option         "nvidiaXineramaInfoOrder" "DFP-0"
    Option         "metamodes" "DFP-0: nvidia-auto-select +0+0, DFP-3: nvidia-auto-select @1920x1920 +1920+0"
    Option         "AddARGBGLXVisuals" "true"
    Option         "AllowGLXWithComposite" "true"
    SubSection     "Display"
        Depth       24
    EndSubSection
EndSection

Section "Screen"
    Identifier     "Screen1"
    Device         "Device1"
    Monitor        "Monitor1"
    DefaultDepth    24
    Option         "Stereo" "0"
    Option         "metamodes" "DFP-3: nvidia-auto-select @1920x1920 +0+0"
    Option         "AddARGBGLXVisuals" "true"
    SubSection     "Display"
        Depth       24
    EndSubSection
EndSection

Section "InputClass"
    Identifier "Marble Mouse"
    Driver "evdev"
    MatchProduct "Logitech USB Trackball"
    MatchDevicePath "/dev/input/event*"
    MatchIsPointer "yes"
    Option "ButtonMapping" "1 9 3 4 5 6 7 2 8"
    Option "EmulateWheel" "true"
    Option "EmulateWheelButton" "3"
    Option "ZAxisMapping" "4 5"
    Option "XAxisMapping" "6 7"
    Option "Emulate3Buttons" "false"
EndSection
'
    # Reconfigure x
    reconfigx(){
        sudo stop gdm
        sudo sudo dpkg-reconfigure xserver-xorg
        sudo sudo nvidia-xconfig 
    }

    
    #echo "xrandr --output DVI-D-0 --pos 1920x0 --rotate left --output DVI-I-0 --pos 0x0" >> ~/.config/autostart/

    #grep DVI | tree -f -L 1 -i --noreport
    #sudo grep -rRl --include="*" "DVI-D-0" .

    # Regenen /etc/X11/xorg.conf
    #sudo nvidia-xconfig
    
}


printer(){
    # References
    #http://www.cs.rpi.edu/twiki/view/LabstaffWeb/PublicPrinters
    #http://www.rpi.edu/dept/arc/web/printing/printertype.html
    # http://askubuntu.com/questions/153672/how-to-add-a-printer-in-gnome-shell
128.213.17.40
sudo cat /etc/cups/printers.conf
sudo gvim /etc/cups/printers.conf
sudo lpstat -s

sudo apt-get install hplip

#sudo apt-get install y-ppa-manager

# USE THE SYSTEM PRINTER INSTEAD
system-config-printer
# or use the CPUS web interface at
http://localhost:631

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
#sudo apt-key adv --recv-key --keyserver keyserver.ubuntu.com 24CBF5474CFD1E2F
}
