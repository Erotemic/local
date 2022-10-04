#!/bin/bash
#https://docs.rocketpool.net/guides/node/docker.html#process-overview
# https://docs.rocketpool.net/guides/node/docker.html#downloading-the-rocket-pool-cli
# https://docs.rocketpool.net/guides/node/native.html#setting-up-the-binaries


install_rocketpool_cli(){
    ARCH=$(uname -m)
    echo "ARCH = $ARCH"
    declare -A ARCH_LUT=(
        ["x86"]="amd64"
        ["x86_64"]="amd64"
        ["aarch64"]="arm64"
    )
    ARCH="${ARCH_LUT[${ARCH}]}"
    echo "ARCH = $ARCH"

    PREFIX=$HOME/.local

    wget https://github.com/rocket-pool/smartnode-install/releases/latest/download/rocketpool-cli-linux-"${ARCH}" -O \
        "$PREFIX/bin/rocketpool"

    chmod +x "$HOME"/.local/bin/rocketpool
    rocketpool --version
}


firewall(){

    # Check ports currently in use:  sudo lsof -i -P -n | grep LISTEN
    # https://github.com/imthenachoman/How-To-Secure-A-Linux-Server#firewall-with-ufw-uncomplicated-firewall

    sudo ufw default deny incoming comment 'Deny all incoming traffic'
    sudo ufw allow "22/tcp" comment 'Allow SSH'
    sudo ufw allow 30303/tcp comment 'Execution client port, standardized by Rocket Pool'
    sudo ufw allow 30303/udp comment 'Execution client port, standardized by Rocket Pool'
    sudo ufw allow 9001/tcp comment 'Consensus client port, standardized by Rocket Pool'
    sudo ufw allow 9001/udp comment 'Consensus client port, standardized by Rocket Pool'
    sudo ufw allow 4001/tcp comment 'Public IPFS libp2p swarm port'
    sudo ufw allow from 127.0.0.1 to 127.0.0.1 port 5001 proto tcp comment 'Private IPFS API'
    sudo ufw allow from 127.0.0.1 to 127.0.0.1 port 8080 proto tcp comment 'Protected IPFS Gateway + read only API subset'


    ## Allow out rules are only needed if we are denying out trafic, which 
    ## we probably wont by default

    # allow traffic out on port 53 -- DNS
    sudo ufw allow out 53 comment 'allow DNS calls out'
    # allow traffic out on port 123 -- NTP
    sudo ufw allow out 123 comment 'allow NTP out'
    # allow traffic out for HTTP, HTTPS, or FTP
    # apt might needs these depending on which sources you're using
    sudo ufw allow out http comment 'allow HTTP traffic out'
    sudo ufw allow out https comment 'allow HTTPS traffic out'
    sudo ufw allow out ftp comment 'allow FTP traffic out'
    # allow whois
    sudo ufw allow out whois comment 'allow whois'
    # allow traffic out on port 68 -- the DHCP client
    # you only need this if you're using DHCP
    sudo ufw allow out 67 comment 'allow the DHCP client to update'
    sudo ufw allow out 68 comment 'allow the DHCP client to update'
        

    sudo ufw status
    sudo ufw enable

    # What other things need to be allowed?
    sudo ufw allow 6010/tcp comment 'boincc'
    sudo ufw allow 31416/tcp comment 'boincc'
    sudo ufw allow 631/tcp comment 'cupdsd printer'


    sudo apt install -y fail2ban
    #sudo vim /etc/fail2ban/jail.d/ssh.local

    sudo_writeto /etc/fail2ban/jail.d/ssh.local "
    [sshd]
    enabled = true
    banaction = ufw
    port = 22
    filter = sshd
    logpath = %(sshd_log)s
    maxretry = 10
    "
    sudo systemctl restart fail2ban


    #cat /etc/ssh/sshd_config | sed 'Password
    cat /etc/ssh/sshd_config | grep 'Password'
    

    sudo sed -i 's|^ChallengeResponseAuthentication|##ChallengeResponseAuthentication|g' /etc/ssh/sshd_config 
    sudo sed -i 's|^PasswordAuthentication|##PasswordAuthentication|g' /etc/ssh/sshd_config 
    sudo sed -i 's|^PermitRootLogin|##PermitRootLogin|g' /etc/ssh/sshd_config 
    sudo_appendto /etc/ssh/sshd_config  "
    ChallengeResponseAuthentication no
    PasswordAuthentication no
    PermitRootLogin prohibit-password
    "
    sudo systemctl restart sshd
    
}

unattended_upgrades(){
    sudo apt update
    sudo apt install -y unattended-upgrades update-notifier-common

    cat /etc/apt/apt.conf.d/20auto-upgrades
    
    sudo_writeto /etc/apt/apt.conf.d/20auto-upgrades '
    APT::Periodic::Update-Package-Lists "1";
    APT::Periodic::Unattended-Upgrade "1";
    APT::Periodic::AutocleanInterval "7";
    Unattended-Upgrade::Remove-Unused-Dependencies "true";
    Unattended-Upgrade::Remove-New-Unused-Dependencies "true";

    # This is the most important choice: auto-reboot.
    # This should be fine since Rocketpool auto-starts on reboot.
    Unattended-Upgrade::Automatic-Reboot "true";
    Unattended-Upgrade::Automatic-Reboot-Time "02:00";
    '
    sudo systemctl restart unattended-upgrades
    sudo systemctl status unattended-upgrades
    

}


remove_short_moduli(){
    # https://github.com/imthenachoman/How-To-Secure-A-Linux-Server#remove-short-diffie-hellman-keys
    sudo cp --archive /etc/ssh/moduli "/etc/ssh/moduli-COPY-$(date +"%Y%m%d%H%M%S")"
    sudo awk '$5 >= 3071' /etc/ssh/moduli | sudo tee /etc/ssh/moduli.tmp
    sudo mv /etc/ssh/moduli.tmp /etc/ssh/moduli
}


install_ntp(){
    __doc__="
    Network time protocol
    https://github.com/imthenachoman/How-To-Secure-A-Linux-Server#ntp-client
    "
    sudo apt install ntp -y
    sudo cp --archive /etc/ntp.conf "/etc/ntp.conf-COPY-$(date +"%Y%m%d%H%M%S")"
    
    sudo sed -i -r -e "s/^((server|pool).*)/# \1         # commented by $(whoami) on $(date +"%Y-%m-%d @ %H:%M:%S")/" /etc/ntp.conf
    echo -e "\npool pool.ntp.org iburst         # added by $(whoami) on $(date +"%Y-%m-%d @ %H:%M:%S")" | sudo tee -a /etc/ntp.conf

    sudo service ntp restart
    sudo systemctl status ntp
    sudo ntpq -p
}
