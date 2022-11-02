#!/bin/bash
#https://docs.rocketpool.net/guides/node/docker.html#process-overview
# https://docs.rocketpool.net/guides/node/docker.html#downloading-the-rocket-pool-cli
# https://docs.rocketpool.net/guides/node/native.html#setting-up-the-binaries



nuc_notes(){
    __doc__='
    # https://www.intel.com/content/www/us/en/support/articles/000031273/intel-nuc.html
    # https://www.intel.com/content/www/us/en/support/articles/000031273.html
    # https://www.intel.com/content/www/us/en/support/articles/000060119/intel-nuc.html

    K - slim
    F - 

    BXNUC10I5 F N HN 1

    NUC 10 i5 - barebones - NUC10i5FNK - 255.00 + 22.90 - https://www.ebay.com/itm/374307531147
    299.99 + 29.99 = BOX NUC 8 i5 BEH1 - https://www.ebay.com/itm/314198708699?

    Retail (2022-10-23)
    ------
    NUC  7 i5 - barebones - NUC7i5BNK       - Amazon 246.50

    NUC  8 i5 - barebones - NUC8i5BEH       - Amazon 348.58
                Beelink   - NUC8i5          - Amazon 327.00

    NUC 10 i3 - barebones - NUC10i3FNHN     - Amazon 318.99

    NUC 10 i5 -           - BXNUC10i5FNH1   - NewEgg 509.00
    NUC 11 i5 - barebones - BNUC11TNHi50Z01 - NewEgg 439.99

    '
}


install_rocketpool_cli(){
    __doc__="
    Downloads and installs rocketpool via the docker interface.

    Follows the tutorial in:
        * https://docs.rocketpool.net/guides/node/docker.html#downloading-the-rocket-pool-cli
        * https://docs.rocketpool.net/guides/node/config-docker.html#configuring-via-the-wizard

    Rocketpool via docker is a collection of 6 services:

        * rocketpool_api - The Smartnode API that the CLI interacts with
        * rocketpool_node - Checks and claims RPL rewards after a reward checkpoint and is responsible for actually staking new validators when you create a minipool.
        * rocketpool_watchtower - This is used by Oracle Nodes to perform oracle-related duties. For regular node operators, this will simply stay idle.

        * rocketpool_eth1 - The Execution client.
            - Possible Client Backends: Geth, Erigon, Besu, Nethermind, ...

        * rocketpool_eth2 - The Consensus beacon node client.
            - Possible Client Backends: Nimbus, Prysm, Lighthous, Teku

        * rocketpool_validator - The Validator client, which is responsible for your validator duties (such as attesting to blocks or proposing new blocks).

    Information about backend eth1 and eth2 clients:
        * https://docs.rocketpool.net/guides/node/eth-clients.html#consensus-clients
    "
    ARCH=$(uname -m)
    declare -A ARCH_LUT=(
        ["x86"]="amd64"
        ["x86_64"]="amd64"
        ["aarch64"]="arm64"
    )
    ARCH="${ARCH_LUT[${ARCH}]}"
    echo "ARCH = $ARCH"

    PREFIX=$HOME/.local

    mkdir -p "$PREFIX/bin"
    wget https://github.com/rocket-pool/smartnode-install/releases/latest/download/rocketpool-cli-linux-"${ARCH}" -O \
        "$PREFIX/bin/rocketpool"

    chmod +x "$HOME"/.local/bin/rocketpool
    rocketpool --version


    ## Via docker:
    # run and choose options
    rocketpool service install


    ## Check status:
    rocketpool service status
    rocketpool service version

    ## Check status in docker
    
    docker ps
    rocketpool service logs eth1
    rocketpool service logs eth2
    rocketpool service logs validator
    rocketpool service logs api
    rocketpool service logs node
    rocketpool service logs watchtower

    # Run the Configuration Wizard (opens settings manager if already configured)
    rocketpool service config

    # To change execution clients:
    # https://docs.rocketpool.net/guides/node/change-clients.html#change-your-selected-execution-client
    # Note: this will take down your entire node while you resync

    # Verify everything looks ok
    rocketpool service logs eth1

    # To change concensus clients
    # https://docs.rocketpool.net/guides/node/change-clients.html#changing-consensus-clients
    rocketpool service config 
    # Manual Interaction, simply change it
    # And verify it looks ok
    rocketpool service logs eth2


    # Sycing blockchain state: 
    # https://docs.rocketpool.net/guides/node/starting-rp.html#waiting-for-your-eth-clients-to-sync
    # Note: This can take DAYS to finish!
    rocketpool node sync


    ### LOADING A WALLET FOR THE TEST NETWORK ###
    # https://docs.rocketpool.net/guides/node/starting-rp.html#setting-up-a-wallet

    # Load test_wallets.txt secret data

    # This will create a new wallet just for this machine, which is a good
    # idea, but make sure you save them.
    rocketpool wallet init

    # Print the node wallet public keys
    rocketpool wallet status

    # Save the new wallet address securely

    

    # Service Commands:
    # https://docs.rocketpool.net/guides/node/cli-intro.html#service-commands
    rocketpool service status
    rocketpool service stats

    # Note Commands:
    # https://docs.rocketpool.net/guides/node/cli-intro.html#node-commands
    rocketpool node status


    # Minipool commands:
    # https://docs.rocketpool.net/guides/node/cli-intro.html#minipool-commands

    ### Check minipool validator public keys
    rocketpool minipool status



    ######
    # This doesn't seem to be 100% necessary, but can help to configure your
    # router to forward ports 30303 and 9001 to the validator node ip address.
    # https://medium.com/rocket-pool/rocket-pool-node-quickstart-guide-d40bc3d0de6d#:~:text=Forwarding%20Peer%20Discovery%20Ports,more%20nodes%20on%20the%20network.



    #########
    ### AFTER YOUR WALLET HAS FUNDS (16 + 1.6 ETH)


    # https://docs.rocketpool.net/guides/node/prepare-node.html#registering-your-node-with-the-network
    rocketpool node register


    # Monitoring performance:
    # https://docs.rocketpool.net/guides/node/performance.html#monitoring-your-node-s-performance

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
    sudo systemctl status fail2ban


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


check_network(){
    sudo apt install vnstat
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
