# https://www.youtube.com/watch?v=DyDEIavz0X4


install_syncthing(){
    # https://github.com/syncthing/syncthing
    # https://docs.syncthing.net/users/autostart.html#linux

    # Add the release PGP keys:
    sudo curl -o /usr/share/keyrings/syncthing-archive-keyring.gpg https://syncthing.net/release-key.gpg

    # Add the "stable" channel to your APT sources:
    echo "deb [signed-by=/usr/share/keyrings/syncthing-archive-keyring.gpg] https://apt.syncthing.net/ syncthing stable" | sudo tee /etc/apt/sources.list.d/syncthing.list

    # Add the "candidate" channel to your APT sources:
    echo "deb [signed-by=/usr/share/keyrings/syncthing-archive-keyring.gpg] https://apt.syncthing.net/ syncthing candidate" | sudo tee /etc/apt/sources.list.d/syncthing.list

    # Update and install syncthing:
    sudo apt-get update
    sudo apt-get install syncthing

    # Service files should already be installed
    systemctl --user enable syncthing.service
    systemctl --user start syncthing.service

    systemctl --user status syncthing.service
    
    
}


install_syncthing_service(){
    __doc__="
    Installing a service to run the IPFS daemon requires sudo

    Usage:
        source ~/local/init/setup_ipfs.sh
        install_ipfs_service
    "
    # https://gist.github.com/pstehlik/9efffa800bd1ddec26f48d37ce67a59f
    # https://www.maxlaumeister.com/u/run-ipfs-on-boot-ubuntu-debian/
    # https://linuxconfig.org/how-to-create-systemd-service-unit-in-linux#:~:text=There%20are%20basically%20two%20places,%2Fetc%2Fsystemd%2Fsystem%20.
    SERVICE_DPATH=/etc/systemd/system
    SERVICE_FPATH=$SERVICE_DPATH/ipfs.service
    IPFS_EXE=$(which ipfs)

    # TODO: This will depend on how you initialized IPFS
    #IPFS_PATH=/data/ipfs
    #IPFS_PATH=$HOME/.ipfs

    echo "IPFS_EXE = $IPFS_EXE"
    echo "SERVICE_FPATH = $SERVICE_FPATH"
    echo "IPFS_PATH = $IPFS_PATH"

    sudo_writeto $SERVICE_FPATH "
        [Unit]
        Description=IPFS daemon
        After=network.target
        [Service]
        Environment=\"IPFS_PATH=$IPFS_PATH\"
        User=$USER
        ExecStart=${IPFS_EXE} daemon
        [Install]
        WantedBy=multiuser.target
        "
    #sudo systemctl daemon-reload
    sudo systemctl start ipfs
    sudo systemctl status ipfs
}


install_keepassxc(){
    sudo apt install keepassxc
}


notes(){
    echo "https://www.chucknemeth.com/linux/security/keyring/keepassxc-keyring"
}
