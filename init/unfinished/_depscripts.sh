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



ipython_notebook_server()
{
    # References: http://www.akadia.com/services/ssh_test_certificate.html
    #openssl genrsa -des3 -out server.key 1024
    #openssl req -new -key server.key -out server.csr
    #cp server.key server.key.org
    #openssl rsa -in server.key.org -out server.key
    #openssl x509 -req -days 365 -in server.csr -signkey server.key -out server.crt
    #jupyter-notebook --no-browser --certfile=server.crt

    # References: https://ipython.org/ipython-doc/1/interactive/public_server.html
    #openssl req -x509 -nodes -days 365 -newkey rsa:1024 -keyout mycert.pem -out mycert.pem
    #jupyter-notebook --no-browser --certfile=mycert.pem

    # References: http://jupyter-notebook.readthedocs.org/en/latest/public_server.html
#    openssl req -x509 -nodes -days 365 -newkey rsa:1024 -keyout mycert.key -out mycert.pem

#    jupyter-notebook --generate-config --help
#    jupyter-notebook --config

#    sh -c 'cat > nbserver_config.py << EOL
## Notebook configuration for public notebook server
#c = get_config()

## Set options for certfile, ip, password, and toggle off browser auto-opening
##c.NotebookApp.certfile = "mycert.pem"
## Set ip to "*" to bind on all interfaces (ips) for the public server
#c.NotebookApp.ip = "*"
#c.NotebookApp.open_browser = False

## It is a good idea to set a known, fixed port for server access
#c.NotebookApp.port = 9999
#EOL'
    #jupyter-notebook --config nbserver_config.py --certfile=mycert.pem
    #jupyter-notebook --config nbserver_config.py 
    jupyter-notebook --ip="*" --no-browser
}


ubuntu_will_not_boot_unless_recovery_mode()
{
    #https://ubuntuforums.org/showthread.php?t=2268327
    echo
}


fix_sound()
{
    # http://askubuntu.com/questions/824481/constant-high-frequency-beep-on-startup-no-other-sound 
    # https://help.ubuntu.com/community/SoundTroubleshootingProcedure

    # https://bbs.archlinux.org/viewtopic.php?id=198618
    
    echo options snd_hda_intel index=1 >> /etc/modprobe.d/alsa-base.conf
    modprobe -rv snd_hda_intel
    modprobe -v snd_hda-intel

    # Ubuntu 14.04 always plays a constant high frequency sound

#I'm on Ubuntu 14.04.5 LTS and having a very odd issue. Whenever I boot my computer (about when X starts up) my speakers emit a constant high frequency sound. No other sound plays from any application. This happens on both speaker and headphones. This also happens regardless of if the computer's sound is muted or not. This happens in both the front microphone jack and the back line-out jack. Every so often there is also a buzzing sound. The system did not do this previously. This all started when I installed a second graphics card. All I did to the computer was install an Nvidia GeForce GTX 660 along side my existing GeForce GTX 670. Going back to the original configuration did not change anything.  I've had this problem for almost a month now and I have found no solutions. 

#Other things I have noticed:
#    * the system seems to recognize when I plug/unplug my headphones by chaning the audio output device in the system sound settings. 
#    * pavucontrol does not seem to know about the intel sound card that I want to play sound from. It only shows the NVIDIA HDMI options. However, the system sound panel does show both the NVIDIA HDMI and the normal intel jacks. 

# I followed many of the steps in https://help.ubuntu.com/community/SoundTroubleshootingProcedure and was unable to solve the problem. Here is the output of step 3. I greatly appreciate any help. 


# http://askubuntu.com/questions/687062/usb-audio-interface-not-showing-device-in-list-for-pulseaudio

#(venv2) joncrall@hyrule:~$ aplay -l | grep card
#card 0: PCH [HDA Intel PCH], device 0: ALC892 Analog [ALC892 Analog]
#card 0: PCH [HDA Intel PCH], device 1: ALC892 Digital [ALC892 Digital]
#card 0: PCH [HDA Intel PCH], device 3: HDMI 0 [HDMI 0]
#card 0: PCH [HDA Intel PCH], device 7: HDMI 1 [HDMI 1]
#card 1: NVidia [HDA NVidia], device 3: HDMI 0 [HDMI 0]
#card 1: NVidia [HDA NVidia], device 7: HDMI 1 [HDMI 1]
#card 1: NVidia [HDA NVidia], device 8: HDMI 2 [HDMI 2]
#card 1: NVidia [HDA NVidia], device 9: HDMI 3 [HDMI 3]
#card 2: NVidia_1 [HDA NVidia], device 3: HDMI 0 [HDMI 0]
#card 2: NVidia_1 [HDA NVidia], device 7: HDMI 1 [HDMI 1]
#card 2: NVidia_1 [HDA NVidia], device 8: HDMI 2 [HDMI 2]
#card 2: NVidia_1 [HDA NVidia], device 9: HDMI 3 [HDMI 3]
#(venv2) joncrall@hyrule:~$ ^C
#(venv2) joncrall@hyrule:~$ gksu gedit /etc/pulse/default.pa

#>>> load-module module-alsa-sink device=hw:0
    
    

}


extrafix()
{
    chmod og-w ~/.python-eggs
}

dosetup_virtual()
{
    customize_sudoers
    source ~/local/init/ubuntu_core_packages.sh
    gnome_settings
    nautilus_settings
}
#index_opencv_with_ctags()
#{
#    #References:
#    #    http://sourceforge.net/p/ctags/mailman/message/20916991/
#    ctags -R -ICVAPI --c++-kinds=+p --fields=+iaS --extra=+q --language-force=c++ /usr/include/opencv/
#}
#clean_for_upgrade()
#{
#    # msg: Please free at least an additional 68,3 M of disk space on '/boot'. Empty your trash and remove temporary packages of former installations using 'sudo apt-get clean'.
#    # References: http://askubuntu.com/questions/495941/software-updater-needs-more-disk-space
#    ubuntu-tweak
#}

#setup_ibeis()
#{
#    source ~/local/init/freshstart_ubuntu.sh
#}

#ypackin()
#{
#    sudo pip install $*
#}
#packin()
#{
#    sudo apt-get install -y $*
#}
#install_synergy()
#{
#    sudo apt-get install synergy -y
#}


#pip_upgrade()
#{
#     sudo pip install numpy --upgrade
#     sudo pip install Cython --upgrade
#     sudo pip install scipy --upgrade
#     sudo pip install pyzmq --upgrade
#     sudo pip install matplotlib --upgrade
#     sudo pip install scikit-learn --upgrade
#     sudo pip install ipython --upgrade
#}

install_workrave()
{
    # DOENT BUILD RIGHT
    sudo apt-get install libxtst-dev -y
    sudo apt-get install libxss-dev -y
    sudo apt-get install python-cheetah -y
    sudo apt-get install gnome-core-devel -y
    exec 42<<'__PYSCRIPT__'
import utool as ut
import os
from os.path import join
zipped_url = 'http://sourceforge.net/projects/workrave/files/workrave/1.10/workrave-1.10.tar.gz'
unzipped_fpath = ut.grab_zipped_url(zipped_url)
ut.vd(unzipped_fpath)
os.chdir(unzipped_fpath)
ut.cmd('./configure')
ut.cmd('make')

install_prefix = ut.unixpath('~')
for dname in ['bin', 'doc', 'man', 'share']:
    install_dst = join(install_prefix, dname)
    install_src = join(unzipped_fpath, dname)
    ut.copy(install_src, install_dst)
print(unzipped_fpath)
__PYSCRIPT__
python /dev/fd/42 $@

}

#install_lyx()
#{
#    # Useless because it can't convert .tex to .lyx well
#    sudo add-apt-repository ppa:lyx-devel/release
#    sudo apt-get update
#    sudo apt-get install lyx -y
#}


install_pydio(){
    gvim   /etc/apt/sources.list
sudo sh -c 'cat >>  /etc/apt/sources.list  << EOL

# pydio manual stuff
deb http://dl.ajaxplorer.info/repos/apt stable main
deb-src http://dl.ajaxplorer.info/repos/apt stable main
EOL'
wget -O - http://dl.ajaxplorer.info/repos/charles@ajaxplorer.info.gpg.key | sudo apt-key add -

sudo apt-get update
sudo apt-get install pydio


cd ~/tmp
wget http://downloads.sourceforge.net/project/ajaxplorer/pydio-sync/java/0.8.4/PydioSync-0.8.4-Linux-x86_64-Jars.zip
7z x PydioSync-0.8.4-Linux-x86_64-Jars.zip

cd ~/tmp
wget https://pyd.io/resources/pydio6/data/public/pydiosync-linux-1-0-2-targz?dl=true\&file=/1e481dfadf/PydioSync-Linux-v1.0.2.tar.gz
cp pydiosync-linux-1-0-2-targz\?dl\=true\&file\=%2F1e481dfadf%2FPydioSync-Linux-v1.0.2.tar.gz PydioSync-Linux-v1.0.2.tar.gz
7z xz pydiosync-linux-1-0-2-targz\?dl\=true\&file\=%2F1e481dfadf%2FPydioSync-Linux-v1.0.2.tar.gz
7z xzvf PydioSync-Linux-v1.0.2.tar.gz
7z x PydioSync-Linux-v1.0.2.tar -o Pydio
}




fix_upgrade_1404_to_1604(){
    # Something was wrong with gcc and I eneded to download this
    wget http://security.ubuntu.com/ubuntu/pool/main/g/gcc-5/libstdc++6_5.3.1-14ubuntu2.1_i386.deb
    # Then install it to get gcc libs working well enough
    sudo dkpg -i libstdc++6_5.3.1-14ubuntu2.1_i386.deb

    # Also need to fix my virtual env
    # https://www.guyrutenberg.com/2012/05/30/fixing-virtualenv-after-upgrading-your-distributionpython/
    virtualenv ~/venv
    virtualenv --system-site-packages ~/venv
}

latest_vim(){
    co
    git clone https://github.com/vim/vim.git
    mkdir tmpinstall
    ./configure --enable-gui=gtk2 --enable-pythoninterp=yes \
        --with-vim-name=vim-8 \
        --with-ex-name=ex-8 \
        --with-view-name=view-8 
    #--prefix=/home/joncrall/code/vim/tmpinstall
    make -j9
    sudo make install
    ls tmpinstall/bin/
}



beyond_compare(){
    wget http://www.scootersoftware.com/bcompare-4.1.9.21719_amd64.deb
    sudo apt-get update
    sudo apt-get install gdebi-core
    sudo gdebi bcompare-4.1.9.21719_amd64.deb
}

install_banish404(){
    #http://askubuntu.com/questions/65911/how-can-i-fix-a-404-error-when-using-a-ppa-or-updating-my-package-lists
    # Get rid of failing packages when running apt-get update
    #sudo add-apt-repository ppa:fossfreedom/packagefixes
    #sudo apt-get update
    #sudo apt-get install banish404

    cd ~/tmp
    wget https://launchpad.net/~fossfreedom/+archive/packagefixes/+files/banish404_0.1-4_all.deb
    sudo dpkg -i banish404_0.1-4_all.deb

    sudo add-apt-repository --remove http://ppa.launchpad.net/boost-latest/ppa/ubuntu
    sudo add-apt-repository --remove http://ppa.launchpad.net/fossfreedom/packagefixes/ubuntu
    sudo add-apt-repository --remove http://ppa.launchpad.net/tualatrix/ppa/ubuntu
}
