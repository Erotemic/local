#!/usr/bin/env bash
__doc__="
Getting the OS on the SD card requires a few steps, but its not that bad.

The [SDM]_ tool might be a good alternative. Need to look into it.

References:
    https://raspberrypi.stackexchange.com/questions/111722/rpi-4-running-ubuntu-server-20-04-cant-connect-to-wifi
    https://www.cyberciti.biz/faq/ubuntu-change-hostname-command/
    .. [SDM] https://github.com/gitbls/sdm
"

setup_pi_sd_card_on_host_system(){
    # On the host system install the rpi-imager software
    sudo apt install rpi-imager

    rpi-imager \


    __manual_instructions__="
    * Insert the SD card to the host system.
    * Start the GUI
    * Select Operating System:
       - Other General Purpose OS ->
       - Ubuntu ->
       - Ubuntu Server (22.04 LTS / latest) 64 bit
    * Selet Storage: the SD card
    * Optional: click advanced usage to modify defaults like WIFI / username
    * Click Write
    * Wait for the OS to download, install, and verify (10-20 minutes)
    "

    # After completion, we make modifications so the Pi can headlessly connect
    # to the wifi (on server ubuntu ssh is enabled by default) It is important
    # that this is done correctly, because these settings will only be applied
    # on the first boot. Not sure if it is possible to  reset without
    # reinstalling the OS.
    load_secrets

    # This is where the SD card auto-mounted for me
    export SYSTEM_BOOT_DPATH="/media/$USER/system-boot"
    ls "$SYSTEM_BOOT_DPATH"

    # Check the original config to make sure we dont loose anything important
    echo "---"
    sed '/#.*/d' "$SYSTEM_BOOT_DPATH/user-data"  | sed '/^ *$/d'
    echo "---"
    sed '/#.*/d' "$SYSTEM_BOOT_DPATH/network-config"  | sed '/^ *$/d'
    echo "---"

    source "$HOME/local/init/utils.sh"

    # Note: this is not exactly YAML, so we cant do anything fancy
    codeblock "
    version: 2
    renderer: networkd
    ethernets:
      eth0:
        dhcp4: true
        optional: true
    wifis:
      wlan0:
        dhcp4: true
        dhcp6: true
        optional: true
        access-points:
          \"${HOME_WIFI_NAME}\":
            password: \"${HOME_WIFI_PASS}\"
    " > "$SYSTEM_BOOT_DPATH/network-config"
    chmod 611 "$SYSTEM_BOOT_DPATH/network-config"  # -rw-r--r--

    ## TODO: generalized way of getting the user public ssh key
    #SSH_PUBLIC_KEY=$(cat /home/joncrall/.ssh/id_erotemic_ed25519.pub)
    # Dont think I got this right, but network config seemed to work, so lets
    # try with that and defaults here
    ## Append this to the end of user-data
    #codeblock "
    ## This is the user-data configuration file for cloud-init.
    ## The cloud-init documentation has more details:
    ##
    ## https://cloudinit.readthedocs.io/
    ##
    ## Please note that the YAML format employed by this file is sensitive to
    ## differences in whitespace

    ## On first boot, set the user's password and
    ## expire user passwords
    #chpasswd:
    #  expire: true
    #  list:
    #    - ${USERNAME}:rework

    ## Enable password authentication with the SSH daemon
    #ssh_pwauth: true

    #users:
    #  - name: ${USERNAME}
    #    lock_passwd: false
    #    sudo: [ \"ALL=(ALL) NOPASSWD:ALL\" ]
    #    shell: /bin/bash
    #    groups: [adm, audio, cdrom, dialout, floppy, video, plugdev, dip, netdev, sudo]
    #    ssh-authorized-keys:
    #      - ${SSH_PUBLIC_KEY}

    ## Reboot after cloud-init completes
    #power_state:
    #  mode: reboot
    #" > "$SYSTEM_BOOT_DPATH/user-data"
    #chmod 611 "$SYSTEM_BOOT_DPATH/user-data"  # -rw-r--r--

    __manual_instructions__="
    Eject the SD Card, insert it in the Pi and plug it in
    Next ssh into the machine and execute the main body of the script

    ssh-keygen -f ~/.ssh/known_hosts -R 192.168.222.29
    ssh ubuntu@192.168.222.29

    # Default settings will require you to change password here and relogin
    ssh ubuntu@192.168.222.29


    New notes:

    To ssh with a forced password use
    ssh -o PubkeyAuthentication=no -o PreferredAuthentications=password joncrall@192.168.222.17

    "
}

export PI_HOSTNAME="mojo"
export PI_USERNAME="joncrall"

# Change the name of the computer
sudo hostnamectl set-hostname $PI_HOSTNAME


# This has some user interaction with passwords / full names / etc
# TODO: non interactive
sudo adduser "$PI_USERNAME"
sudo usermod -a -G adm,dialout,cdrom,floppy,sudo,audio,dip,video,plugdev,netdev,lxd "$PI_USERNAME"

sudo usermod -a -G docker "$USER"

__onhost__="
    exit

    ssh-copy-id joncrall@192.168.222.17
    ssh joncrall@192.168.222.17
"

quick_local_setup(){
    git clone https://github.com/Erotemic/local.git
    source "$HOME/local/init/utils.sh"

    source "$HOME/local/init/ensure_symlinks.sh"
    ensure_config_symlinks
}
quick_local_setup
source "$HOME/local/init/utils.sh"


setup_basic(){
    sudo apt install git curl jq expect htop tmux tree sshfs p7zip-full pgpgpg lm-sensors rsync symlinks net-tools -y
    sudo apt install -y network-manager -y
    sudo apt install ntfs-3g -y

    # https://forums.raspberrypi.com/viewtopic.php?t=362047
    # See Also: /etc/netplan/50-cloud-init.yaml
}

setup_display_manager(){
    # https://phoenixnap.com/kb/how-to-install-a-gui-on-ubuntu
    sudo apt update
    sudo apt install gnome-session gdm3 ubuntu-desktop
}


do_system_updates(){
    sudo apt update -y
    sudo apt upgrade -y
    apt_ensure git gcc g++ build-essential gfortran curl jq expect htop tmux tree sshfs p7zip-full pgpgpg lm-sensors rsync symlinks net-tools
    apt_ensure btop

    source "$HOME/local/init/utils.sh"
    source "$HOME/local/tools/pyenv_ext/pyenv_ext_commands.sh"
    UPGRADE=1 install_pyenv
    pyenv_create_virtualenv 3.9.9 full
    pip install -e ~/local/rob
}

apt_ensure curl htop tmux tree sshfs pgpgpg lm-sensors rsync symlinks net-tools


install_go(){
    ARCH="$(dpkg --print-architecture)"
    echo "ARCH = $ARCH"
    GO_VERSION="1.17.5"
    GO_KEY=go${GO_VERSION}.linux-${ARCH}
    URL="https://go.dev/dl/${GO_KEY}.tar.gz"

    declare -A GO_KNOWN_HASHES=(
        ["go1.17.5.linux-amd64-sha256"]="bd78114b0d441b029c8fe0341f4910370925a4d270a6a590668840675b0c653e"
        ["go1.17.5.linux-arm64-sha256"]="6f95ce3da40d9ce1355e48f31f4eb6508382415ca4d7413b1e7a3314e6430e7e"
    )
    EXPECTED_HASH="${GO_KNOWN_HASHES[${GO_KEY}-sha256]}"
    echo "EXPECTED_HASH = $EXPECTED_HASH"
    #URL="https://go.dev/dl/go1.17.5.linux-amd64.tar.gz"

    # Hack:
    # ensure a baseline python exists
    sudo ln -s /usr/bin/python3 /usr/bin/python
    source ~/local/init/utils.sh
    BASENAME=$(basename "$URL")
    curl_verify_hash "$URL" "$BASENAME" "$EXPECTED_HASH" sha256sum "-L"

    mkdir -p "$HOME/.local"
    tar -C "$HOME/.local" -xzf "$BASENAME"
    mkdir -p "$HOME/.local/bin"
    # Add $HOME/.local/go to your path or make symlinks
    ln -s "$HOME/.local/go/bin/go" "$HOME/.local/bin/go"
    ln -s "$HOME/.local/go/bin/gofmt" "$HOME/.local/bin/gofmt"
}


install_ipfs(){
    if [[ "$(which go)" == "" ]]; then
        install_go
    fi

    # IPFS itself
    source ~/local/init/utils.sh
    mkdir -p "$HOME/temp/setup-ipfs"
    cd "$HOME/temp/setup-ipfs"
    #URL="https://dist.ipfs.io/go-ipfs/v0.9.0/go-ipfs_v0.9.0_linux-amd64.tar.gz"
    #URL=https://dist.ipfs.io/go-ipfs/v0.11.0/go-ipfs_v0.11.0_linux-amd64.tar.gz

    ARCH="$(dpkg --print-architecture)"
    echo "ARCH = $ARCH"
    IPFS_VERSION="v0.12.0-rc1"
    IPFS_KEY=go-ipfs_${IPFS_VERSION}_linux-${ARCH}
    URL="https://dist.ipfs.io/go-ipfs/${IPFS_VERSION}/${IPFS_KEY}.tar.gz"
    declare -A IPFS_KNOWN_HASHES=(
        ["go-ipfs_v0.12.0-rc1_linux-arm64-sha512"]="730c9d7c31f5e10f91ac44e6aa3aff7c3e57ec3b2b571e398342a62d92a0179031c49fc041cd063403147377207e372d005992fee826cd4c4bba9b23df5c4e0c"
        ["go-ipfs_v0.12.0-rc1_linux-amd64-sha512"]="b0f913f88c515eee75f6dbf8b41aedd876d12ef5af22762e04c3d823964207d1bf314cbc4e39a12cf47faad9ca8bbbbc87f3935940795e891b72c4ff940f0d46"
    )
    EXPECTED_HASH="${IPFS_KNOWN_HASHES[${IPFS_KEY}-sha512]}"
    #HASH_URL="${URL}.sha512"
    #EXPECTED_HASH=$(curl "$HASH_URL" | sed "s/ .*//g")
    BASENAME=$(basename "$URL")
    curl_verify_hash "$URL" "$BASENAME" "$EXPECTED_HASH" sha512sum

    echo "BASENAME = $BASENAME"
    tar -xvzf "$BASENAME"
    cp go-ipfs/ipfs "$HOME/.local/bin"

    # That should install IPFS now, lets set it up
    #mkdir -p "$HOME/data/ipfs"
    #cd "$HOME/data/ipfs"

    # https://github.com/lucas-clemente/quic-go/wiki/UDP-Receive-Buffer-Size
    # Increase max buffer size to 2.5MB
    sudo sysctl -w net.core.rmem_max=2500000

    # Maybe server is not the best profile?
    # https://docs.ipfs.io/how-to/command-line-quick-start/#prerequisites
    #ipfs init --profile server
    #ipfs init --profile badgerds
    ipfs init --profile lowpower

    # https://www.maxlaumeister.com/u/run-ipfs-on-boot-ubuntu-debian/
    mkdir -p "$USER_SYSTEMD_DPATH"
    #cat $USER_SYSTEMD_DPATH/ipfs.service

    #SYSTEMD_DPATH=$HOME/.config/systemd/user  # is this right?
    #mkdir -p $SYSTEMD_DPATH
    SYSTEMD_DPATH=/etc/systemd/system  # is this right?
    sudo mkdir -p $SYSTEMD_DPATH

    SERVICE_FPATH=$SYSTEMD_DPATH/ipfs.service
    echo "SERVICE_FPATH = $SERVICE_FPATH"

    # FIXME
    sudo_writeto $SERVICE_FPATH "
        [Unit]
        Description=IPFS daemon
        After=network.target

        [Service]
        ### Uncomment the following line for custom ipfs datastore location
        # Environment=IPFS_PATH=/path/to/your/ipfs/datastore
        ExecStart=$HOME/.local/bin/ipfs daemon
        Restart=on-failure

        [Install]
        WantedBy=default.target
        "
    sudo systemctl start ipfs   # make it run now
    sudo systemctl enable ipfs  # make it run on boot
    sudo systemctl status ipfs

    # If the above fails we can do a poor mans tmux daemon
    tmux new-session -d -s "ipfs_daemon" "ipfs daemon"

    ipfs swarm peers

    # Quicker test
    ipfs pin add QmWhKBAQ765YH2LKMQapWp7mULkQxExrjQKeRAWNu5mfBK

    # Pin my shit
    tmux new-session -d -s "ipfs_pin" "ipfs pin add QmNj2MbeL183GtPoGkFv569vMY8nupUVGEVvvvqhjoAATG --progress"
    ipfs pin add QmNj2MbeL183GtPoGkFv569vMY8nupUVGEVvvvqhjoAATG --progress

    # The root CID
    ipfs pin add QmNj2MbeL183GtPoGkFv569vMY8nupUVGEVvvvqhjoAATG --progress

    # High level analysis subdir
    ipfs ls QmbvEN1Ky3MGGBVDwyMBZvdUCFi1WvfdzkTzgtE7sAvW9B

    # Should be possible to viz a single image without too much DL time
    ipfs get QmWpFhhLfXhWhnYdCJP6pE8E8obFceYTa7XZyc2Dkk9AaZ -o scat_scatterplot.png && eog scat_scatterplot.png
    ipfs get QmVnDcQdcB59yt8e6ky49MnNCCuMNbSjyFkwRBM4bDysBq -o viz_align_process.png  && eog viz_align_process.png
}


install_boinc()
{
    # Probably want to install a desktop
    sudo apt install ubuntu-desktop -y  # TODO: make non-interactive, might require reboot

    sudo apt install boinc-client boinc-manager -y

    sudo apt-get install boinc-client

    sudo usermod -a -G boinc "$USER"

    #sudo apt-get remove boinc-client

    # Add main computer as a host that is allowed to control this device
    printf "\n192.168.222.16\n" >> remote_hosts.cfg

    #boinc --daemon --allow_remote_gui_rpc
    boinc
    # Start boinc, then look at /var/lib/boinc/gui_rpc_auth.cfg for the password
    sudo cat /var/lib/boinc/gui_rpc_auth.cfg

    # Start the client as a service
    sudo /etc/init.d/boinc-client start
    sudo /etc/init.d/boinc-client stop

    systemctl status boinc-client.service

    # Attach boinc to WCD account
    _on_host_="
    load_secrets
    echo "export BOINC_WCG_ACCOUNT_KEY=$BOINC_WCG_ACCOUNT_KEY"
    export BOINC_WCG_ACCOUNT_KEY=...
    "

    sudo chmod 664 /etc/boinc-client/gui_rpc_auth.cfg
    #boinc --no_gui_rpc --attach_project http://www.worldcommunitygrid.org "$BOINC_WCG_ACCOUNT_KEY"
    #boinc --attach_project http://www.worldcommunitygrid.org "$BOINC_WCG_ACCOUNT_KEY"
    boinc
    #/var/lib/boinc/gui_rpc_auth.cfg
}

setup_wireless(){
    # https://askubuntu.com/questions/406166/how-can-i-configure-my-headless-server-to-connect-to-a-wireless-network-automati

    # List wireless card devices
    iwconfig

    # Set this environ to the right wireless device
    DEVICE_NAME=wlan0

    # List status
    iwlist "$DEVICE_NAME" s

    # List available network names
    iwlist "$DEVICE_NAME" s | grep ESSID

    # https://linuxconfig.org/ubuntu-22-04-connect-to-wifi-from-command-line

    # Seems like our setup may have configured the right files for us.
    nmcli dev wifi list
    nmcli dev status

    sudo nmcli --ask dev wifi connect "WhoWhatWhenWhereWifi-5G"

    #DEVICE_NAME=wlan0
    #nmcli "$DEVICE_NAME" wifi on
    # https://askubuntu.com/questions/882806/ethernet-device-not-managed

    sudo nmcli dev set wlan0 managed yes

    sudo systemctl restart NetworkManager

    nmcli connection up id wlan0


    ###
    ## Something with
    cat /etc/netplan/50-cloud-init.yaml
    sudo netplan apply
}


debug_broken_ethernet(){
    # https://www.mendrugory.com/post/no-ethernet-ubuntu/
    # https://askubuntu.com/questions/1416493/how-to-enable-ethernet-interface-ubuntu-22-04
    # https://ubuntuforums.org/showthread.php?t=1490833
    # https://www.freshblurbs.com/blog/2022/08/07/fix-eth0-rpi-ubuntu.html
    sudo lshw -C network
    sudo lshw -class network

    sudo apt install -y network-manager -y
    sudo systemctl restart NetworkManager

    sudo ifconfig eth0 up

    sudo journalctl -b | grep -E "dhcpcd|wlan0|eth0|wpa"
    sudo dhclient -v

    sudo EDITOR=vim crontab -e
    # Add Line:
    # @reboot dhclient -v
    # https://stackoverflow.com/questions/610839/how-can-i-programmatically-create-a-new-cron-job

    # Workaround to run above command on every reboot
    # (Doesn work because not root?)
    #(crontab -l ; echo "@reboot dhclient -v") 2>&1 | grep -v "no crontab" | sort | uniq | crontab -

    sudo systemctl enable systemd-networkd
    sudo systemctl status networking.service

    sudo systemctl enable NetworkManager
    sudo systemctl status NetworkManager

    nmcli device show


}


retroarch_for_pi(){
    # export DEBIAN_FRONTEND=noninteractive
    sudo add-apt-repository ppa:libretro/stable -y
    sudo apt-get update && sudo apt-get install retroarch
    sudo apt-get install libretro-snes9x libretro-genesisplusgx libretro-mupen64plus
    sudo apt-get install retroarch libretro-snes9x libretro-mupen64plus libretro-genesisplusgx libretro-bsnes-mercury-performance libretro-core-info libretro-gambatte


    # x86 only :(
    # curl https://buildbot.libretro.com/nightly/linux/x86_64/RetroArch_Qt.7z -o RetroArch_Qt.7z
    # 7z x RetroArch_Qt.7z

    mkdir -p "$HOME"/code
    git clone https://github.com/libretro/RetroArch.git "$HOME"/code/retroarch

    # Depending on your configuration you may need to uncomment the deb-src
    # repositories in /etc/apt/sources.list,
    # /etc/apt/sources.list.d/libretro-ubuntu-testing-$version.list and then
    # run apt-get update before running apt-get build-dep

    sudo sed -i '/^#\s*deb-src /s/^#\s*//' /etc/apt/sources.list

    sudo apt-get install git build-essential cmake
    sudo apt-get update

    sudo apt-get build-dep retroarch

    #sudo apt-get install libopenvg-dev
    sudo apt install libgl1-mesa-dev
    sudo apt-get -y install build-essential libxkbcommon-dev zlib1g-dev libfreetype6-dev libegl1-mesa-dev libgles2-mesa-dev libgbm-dev libavcodec-dev libsdl2-dev libsdl-image1.2-dev libxml2-dev yasm
    sudo apt-get install libraspberrypi-dev

    cd ~/code/retroarch
    # ./configure
    ./configure --disable-videocore
    make clean
    make -j3

    ls ~/.config/retroarch/cores

    sed -i 's/^menu_show_core_updater = "false"/menu_show_core_updater = "true"/' ~/.config/retroarch/retroarch.cfg


    # References:
    # https://forums.raspberrypi.com/viewtopic.php?t=334692
    # https://docs.libretro.com/development/retroarch/compilation/ubuntu/
    # https://buildbot.libretro.com/
    #
    #
    curl https://le.builds.lakka.tv/RPi4.aarch64/Lakka-RPi4.aarch64-5.0.img.gz -O Lakka-RPi4.aarch64-5.0.img.gz

    # Desktop Icon
    #
    mkdir -p ~/.local/share/icons/
    curl https://avatars.githubusercontent.com/u/1812827 -o ~/.local/share/icons/retroarch.png

    echo "
[Desktop Entry]
Name=RetroArch
Comment=Libretro Frontend for Emulators
Exec=~/code/retroarch/retroarch
Icon=retroarch
Terminal=false
Type=Application
Categories=Game;Emulator;
StartupWMClass=retroarch
" > ~/.local/share/applications/retroarch.desktop
    chmod +x ~/.local/share/applications/retroarch.desktop
    gio set ~/.local/share/applications/retroarch.desktop "metadata::trusted" true
    update-desktop-database ~/.local/share/applications
    gnome-shell --replace & disown




    # Superbuild stuff
    apt-get install ccache
    export PATH=/usr/lib/ccache/bin/:$PATH
    git clone https://github.com/libretro/libretro-super.git ~/code/libretro-super
    cd ~/code/libretro-super
    ./libretro-fetch.sh snes9x
    ./libretro-fetch.sh genesis_plus_gx
    ./libretro-fetch.sh nestopia

    # Mario 64 Decomp
    cd ~/code
    sudo apt install python3-pip
    curl -LsSf https://astral.sh/uv/install.sh | sh

    git clone https://github.com/Erotemic/sm64-random-assets.git

    ~/.local/bin/uv venv .venv --seed
    source .venv/bin/activate
    python -m pip install uv
    python -m uv pip install -e .[headless]
    ./build


    #### Fallback
    sudo apt install fceux snes9x gambatte

    # Maybe use?
    # https://emulationstation.org/gettingstarted.html#install_rpi_standalone


    # Need to convert v64 to z64 format?
    sudo apt install n64tools



}
