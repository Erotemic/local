hyrule_setup_sshd()
{  
    # This is Hyrule Specific
    sudo apt-get install openssh-server -y
    sudo service ssh status

    # small change to default sshd_config
    sudo sed -i 's/#Banner \/etc\/issue.net/Banner \/etc\/issue.net/' /etc/ssh/sshd_config
    sudo service ssh restart
    #sudo restart ssh
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

    # small change to default sshd_config
    # Allow authorized keys
    sudo sed -i 's/#AuthorizedKeysFile\t%h\/.ssh\/authorized_keys/AuthorizedKeysFile\t%h\/.ssh\/authorized_keys/' /etc/ssh/sshd_config
}

hyrule_setup_static_ip(){
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

    # Name of eth0 changed to eno1 in Ubuntu 16.04
    sudo sed -i 's/eth0/eno1/' /etc/network/interfaces

    sudo ip addr flush eno1
    sudo systemctl restart networking.service

    #http://www.blackmoreops.com/2013/11/25/how-to-fix-wired-network-interface-device-not-managed-error/
    #http://askubuntu.com/questions/71159/network-manager-says-device-not-managed
    sudo sed -i 's/^managed=false/managed=true/' /etc/NetworkManager/NetworkManager.conf
    sudo service network-manager restart

    # Test
    ping hyrule.cs.rpi.edu

    ssh localhost
}


hyrule_setup_fstab()
{
    # Info
    sudo fdisk -l | grep -e '^/dev/sd'
    # Write store to fstab
    sudo sh -c 'echo "/dev/sdc1                                  /media/Store      ntfs  nls=iso8859-1,uid=1000,windows_names,hide_hid_files,0  0  0" >> /etc/fstab'
    sudo ln -s /media/raid /raid  
    # For Hyrule
    ln -s /media/Store ~/Store
    ln -s /media/raid/work ~/work
}


hyrule_create_users()
{
    #List Users
    cut -d: -f1 /etc/passwd
    ls /home/

    # Delete a user
    sudo userdel kerner
    sudo rm -r /home/kerner

    # Grant sudoers
    #sudo visudo
    sudo adduser joshbeard
    sudo adduser jason
    sudo adduser git
    # Add group
    sudo groupadd ibeis
    sudo groupadd rpi
    sudo usermod -a -G sudo jason
    sudo usermod -a -G sudo joshbeard
    sudo usermod -a -G ibeis jason
    sudo usermod -a -G ibeis joncrall
    sudo usermod -a -G rpi joshbeard
    sudo usermod -a -G rpi joncrall
    sudo usermod -a -G rpi jason

    sudo usermod -a -G noaa jon.crall
    sudo usermod -a -G noaa jonathan.owens
    # Delete user
    #sudo deluser --remove-home newuser
    #sudo chown -R joncrall:rpi *
    #umask 002 work
    #chgrp rpi work
    #chmod g+s work

    sudo usermod -a -G rpi hendrik
    sudo usermod -a -G rpi zack
    sudo usermod -a -G rpi guest
    sudo adduser hendrik
    sudo adduser guest
    
    #  New users
    sudo adduser chuck
    sudo usermod -a -G rpi chuck

    sudo adduser andrea
    sudo usermod -a -G rpi andrea

    Plains0Grevys0Zebras0
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
    sudo adduser git
    # Set git user password
    sudo passwd git
    # Become git
    sudo su git
    cd ~git
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

reinstate_gitserver_backup()
{
    # Copy over backup of home folder
    sudo cp -TRv /media/joncrall/Store/homeback/git/ ~git

    # Inspection
    sudo ls -al ~git/.ssh
    sudo ls -al ~git
    
    # Fix permissions
    sudo chmod 700 ~git/.ssh
    sudo chmod 600 ~git/.ssh/authorized_keys
    sudo chown -R git:git ~git/*
    sudo chown -R git:git ~git/.bash*
    sudo chown -R git:git ~git/.cache*

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

fix_monitor_positions()
{
    # References:
    #https://bugs.launchpad.net/ubuntu/+source/xorg/+bug/1311399
    #http://askubuntu.com/questions/450767/multi-display-issue-with-ubuntu-gnome-14-04
    #http://bernaerts.dyndns.org/linux/74-ubuntu/309-ubuntu-dual-display-monitor-position-lost

    sudo wget -O /usr/local/sbin/update-monitor-position https://raw.githubusercontent.com/NicolasBernaerts/ubuntu-scripts/master/ubuntugnome/update-monitor-position
    sudo chmod +x /usr/local/sbin/update-monitor-position
    sudo wget -O /usr/share/applications/update-monitor-position.desktop https://raw.githubusercontent.com/NicolasBernaerts/ubuntu-scripts/master/ubuntugnome/update-monitor-position.desktop
    sudo chmod +x /usr/share/applications/update-monitor-position.desktop

    mkdir -p $HOME/.config/autostart
    wget -O $HOME/.config/autostart/update-monitor-position.desktop https://raw.githubusercontent.com/NicolasBernaerts/ubuntu-scripts/master/ubuntugnome/update-monitor-position.desktop
    sed -i -e 's/^Exec=.*$/Exec=update-monitor-position 5/' $HOME/.config/autostart/update-monitor-position.desktop
    chmod +x $HOME/.config/autostart/update-monitor-position.desktop
        

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
    #sudo apt-get install y-ppa-manager
    ##for printer
    #sudo apt-key adv --recv-key --keyserver keyserver.ubuntu.com 24CBF5474CFD1E2F

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
# hit add printer, select network, and then find XeroxPhaser63000DN

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



add_ipynb_mimetypes(){
    # https://termueske.wordpress.com/2015/03/16/a-hack-for-ipython-notebook/

    python -m utool.util_ubuntu --exec-add_new_mimetype_association \
        --mime-name=ipynb+json \
        --ext=.ipynb --exe-fpath=jupyter-notebook --force
}

two_gpus(){
    # http://nvidia.custhelp.com/app/answers/detail/a_id/3029/~/using-cuda-and-x
    echo "foo"

    # Determine PCI-IDS of graphics cards
    #lspci
    #nvidia-smi -a
    nvidia-xconfig --query-gpu-info

    # Had to swap device order

    #Section "Device"
        #Identifier     "Device0"
        #Driver         "nvidia"
        #VendorName     "NVIDIA Corporation"
        #BoardName      "GeForce GTX 670"
        #BusID          "PCI:1:0:0"
    #EndSection


    #Section "Device"
        #Identifier     "Device1"
        #Driver         "nvidia"
        #VendorName     "NVIDIA Corporation"
        #BoardName      "GeForce GTX 660"
        #BusID          "PCI:2:0:0"
    #EndSection


    #Section "Screen"
        #Identifier     "Screen0"
        #Device         "Device1"
        #Monitor        "Monitor0"
        #DefaultDepth    24
        #SubSection     "Display"
            #Depth       24
        #EndSubSection
    #EndSection


    #https://devtalk.nvidia.com/default/topic/769851/multi-nvidia-gpus-and-xorg-conf-how-to-account-for-pci-bus-busid-change-/

}


freshtart_ubuntu_entry_point()
{
    #ln -s ~/local/homelinks/.ctags ~/.ctags
    #ln -s ~/local/bashrc.sh ~/.bashrc
    #ln -s ~/local/profile.sh ~/.profile 
    #ln -s ~/local/config/.pypirc ~/.pypirc 
    #ln -s ~/local/config/.theanorc ~/.theanorc 
    #ln -s ~/local/config/.theanorc ~/.theanorc 
    #mkdir -p ~/.config/terminator
    #ln -s ~/local/config/terminator_config ~/.config/terminator/config
    #

    #export PYTHON_VENV="$HOME/venv"
    #mkdir -p $PYTHON_VENV
    #virtualenv -p /usr/bin/python2.7 $PYTHON_VENV
    #virtualenv -p /usr/bin/python2.7 $HOME/abs_venv --always-copy
    #source $PYTHON_VENV/bin/activate

    # FIX ISSUE WITH SIP
    #virtualenv --relocatable venv
    #virtualenv --relocatable $HOME/abs_venv
    #ls venv/include
    #ls abs_venv/include
    # //

    # Python3 VENV
    #sudo pip3 install virtualenv
    #sudo pip3 install virtualenv -U
    #export PYTHON3_VENV="$HOME/venv3"
    #mkdir -p $PYTHON3_VENV
    #virtualenv -p /usr/bin/python3 $PYTHON3_VENV
    # source $PYTHON3_VENV/bin/activate

    # FIX ISSUE WITH SIP
    #virtualenv --relocatable venv
    #virtualenv --relocatable $HOME/abs_venv
    #ls venv/include
}
    #ls abs_venv/include


virtualenv_numpy_16()
{
    # disable current venv
    deactivate

    # setup virtual env
    export PYTHON_VENV="$HOME/_venv_numpy_1.6"
    mkdir -p $PYTHON_VENV
    virtualenv -p /usr/bin/python2.7 $PYTHON_VENV
    source $PYTHON_VENV/bin/activate

    pip install setuptools -U
    pip install numpy

    sudo pip install pillow
    # Virtual Environment 
    cd
    mkdir -p venv
    sudo pip2.7 install virtualenv
    #python2.7 -m virtualenv -p /usr/bin/python2.7 venv
    python2.7 -m virtualenv -p /usr/bin/python2.7 venv --system-site-packages
    source ~/venv/bin/activate
    pip install numpy==1.6.1
    pip install Cython==0.23.4
    pip install scipy==0.9.0

    python -c "import numpy; print(numpy.__version__)"
    cd ~/code/scikit-learn-old-numpy
    python setup develop
}


