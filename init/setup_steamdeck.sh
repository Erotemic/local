#!/bin/bash
__doc__="

References:
    https://shendrick.net/Gaming/2022/05/30/sshonsteamdeck.html
"


setup_steamdeck(){
    __doc__="
    Started by manually setting up wifi and logging into steam

    First, enable ssh.

    Press the steam button, select power, then switch to desktop.

    Click the bot left button, system, and then konsole to get a terminal.

    Set a password via:

        passwd

    Then enable sshd:

        sudo systemctl start sshd

    Login to the router:

    Then we are going to set a static IP address

    Then Setup -> LAN Setup -> Add

    Find the steamdeck address and add it, note the IP Address

    Add an entry to your ssh config:

        ~/.ssh/config

    and add

        Host steamdeck
            HostName 192.168.222.20
            User deck
            IdentityFile ~/.ssh/id_erotemic_ed25519
    "
    IP_ADDR=192.168.222.20
    ssh -o PreferredAuthentications=password -o PubkeyAuthentication=no deck@$IP_ADDR

    sudo systemctl enable sshd

    IP_ADDR=192.168.222.20
    SSH_OPTS='-F /dev/null -o PreferredAuthentications=password -o PubkeyAuthentication=no' \
        ssh-copy-id -f -i ~/.ssh/id_erotemic_ed25519 deck@$IP_ADDR

    IP_ADDR=192.168.222.20
    SSH_OPTS='-F /dev/null -o PreferredAuthentications=password -o PubkeyAuthentication=no' \
        ssh-copy-id deck@$IP_ADDR

    IP_ADDR=192.168.222.20
    ssh -F /dev/null -i ~/.ssh/id_erotemic_ed25519 deck@$IP_ADDR

    # Should now be able to just login via
    ssh steamdeck

    chmod go-w "$HOME"

    # For security, now disable password login
    # add
    sudo vim /etc/ssh/sshd_config
    __new_settings__="
    PermitRootLogin no
    PubkeyAuthentication yes
    PermitEmptyPasswords no
    PasswordAuthentication no
    UsePAM no
    X11Forwarding yes
    "
    echo "$__new_settings__"
    # Reload settings
    sudo systemctl reload sshd

    # Get the dotfiles
    cd "$HOME"
    git clone https://github.com/Erotemic/local.git

    # Can use podman to get an ubuntu environment
    podman pull ubuntu

    # References:
    # https://wiki.archlinux.org/title/Pacman/Rosetta

    pacman -Ss libssl
    pacman -Ss llvm
    pacman -Ss sdl2
    pacman -Ss x11

    #sudo apt install \
    #    make build-essential libssl-dev zlib1g-dev \
    #    libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm libncurses5-dev \
    #    libncursesw5-dev xz-utils tk-dev libffi-dev liblzma-dev libgdbm-dev libc6-dev

    #sudo pacman -Sy base-devel lzlib libbz2 bzip2 readline sqlite wget curl llvm ncurses \
    #    xz gdbm python

    # See:
    # ~/code/sm64-random-assets/install_on_steamdeck.rst
}
