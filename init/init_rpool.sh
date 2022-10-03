#!/bin/bash
#https://docs.rocketpool.net/guides/node/docker.html#process-overview
# https://docs.rocketpool.net/guides/node/docker.html#downloading-the-rocket-pool-cli
# https://docs.rocketpool.net/guides/node/native.html#setting-up-the-binaries
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


firewall(){

    sudo ufw default deny incoming comment 'Deny all incoming traffic'
    sudo ufw allow "22/tcp" comment 'Allow SSH'
    sudo ufw allow 30303/tcp comment 'Execution client port, standardized by Rocket Pool'
    sudo ufw allow 30303/udp comment 'Execution client port, standardized by Rocket Pool'
    sudo ufw allow 9001/tcp comment 'Consensus client port, standardized by Rocket Pool'
    sudo ufw allow 9001/udp comment 'Consensus client port, standardized by Rocket Pool'
    sudo ufw status
    sudo ufw enable

    # What other things need to be allowed?
    sudo ufw allow 6010/tcp comment 'boincc'
    sudo ufw allow 31416/tcp comment 'boincc'
    sudo ufw allow 631/tcp comment 'cupdsd printer'


    sudo apt install -y fail2ban

    sudo vim /etc/fail2ban/jail.d/ssh.local

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
    
    
    
    
}
