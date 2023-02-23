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


install_keepassxc(){
    sudo apt install keepassxc
}


notes(){
    echo "https://www.chucknemeth.com/linux/security/keyring/keepassxc-keyring"
}
