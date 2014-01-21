# Install Correct Driver
# apt-get install nvidia-current

# Remember you have to stop the xserver before you do anything else

# stop lightdm # Unity
# stop gdm # Gnome3
# stop kdm # KDE
#/Drivers/NVIDIA-Linux-x86_64-319.32.run


#export INSTALL_NVIDIA=/home/joncrall/Drivers/NVIDIA-Linux-x86_64-319.32.run
export INSTALL_NVIDIA=/home/joncrall/Drivers/NVIDIA-Linux-x86_64-331.20.run
ls -al $NVIDIA_DRIVER_INSTALLER*
chmod +x $INSTALL_NVIDIA
$INSTALL_NVIDIA
