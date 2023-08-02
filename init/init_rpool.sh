#!/bin/bash
__docs__="

SeeAlso:
    ~/local/tools/get_validator_duties.py


References:
    https://docs.rocketpool.net/guides/node/docker.html#process-overview
    https://docs.rocketpool.net/guides/node/docker.html#downloading-the-rocket-pool-cli
    https://docs.rocketpool.net/guides/node/native.html#setting-up-the-binaries

rETH to ETH
    https://coinmarketcap.com/currencies/rocket-pool-eth/reth/eth/

rETH ratio to peg
    https://dune.com/drworm/rocketpool

RPL to ETH:
    https://www.coingecko.com/en/coins/rocket-pool/eth
"



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


upgrade_rocketpool_cli()
{
    # Download the new stuff.
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
    wget https://github.com/rocket-pool/smartnode-install/releases/latest/download/rocketpool-cli-linux-"${ARCH}" -O ./rocketpool
    wget https://github.com/rocket-pool/smartnode-install/releases/latest/download/rocketpool-cli-linux-"${ARCH}".sig -O ./rocketpool.sig

    if ! test -f ./smartnode-signing-key-v3.asc; then
        wget https://github.com/rocket-pool/smartnode-install/releases/latest/download/smartnode-signing-key-v3.asc -O ./smartnode-signing-key-v3.asc
        # Sign key belongs to:
        # https://github.com/jclapis
        gpg --import ./smartnode-signing-key-v3.asc

        # Optional
        python3 ~/local/scripts/xgpg.py edit_trust D17FBE7E12E2C9DC21CE2BC3E00CDCDC74B1E3F5 ultimate
    fi

    gpg --verify rocketpool.sig rocketpool

    # Stop the existing node
    rocketpool service stop
    rocketpool --version

    # Move the new cli into place
    mv ./rocketpool "$PREFIX/bin/rocketpool"
    chmod +x "$HOME"/.local/bin/rocketpool
    rocketpool --version

    #### TO UPGRADE FROM EXISTING INSTALL
    # https://docs.rocketpool.net/guides/node/updates.html#updating-the-smartnode-stack
    rocketpool service install -d

    # Check the changes that were made
    rocketpool service config

    # Typically let reconfigure restart the service
    # You might need to try several times is docker wants to be weird
    #rocketpool service start

    ## Check status:
    rocketpool service status
    rocketpool service version

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
    wget https://github.com/rocket-pool/smartnode-install/releases/latest/download/rocketpool-cli-linux-"${ARCH}" -O ./rocketpool
    wget https://github.com/rocket-pool/smartnode-install/releases/latest/download/rocketpool-cli-linux-"${ARCH}".sig -O ./rocketpool.sig
    wget https://github.com/rocket-pool/smartnode-install/releases/latest/download/smartnode-signing-key-v3.asc -O ./smartnode-signing-key-v3.asc

    # Sign key belongs to:
    # https://github.com/jclapis
    gpg --import ./smartnode-signing-key-v3.asc
    gpg --verify rocketpool.sig rocketpool

    mv ./rocketpool "$PREFIX/bin/rocketpool"
    chmod +x "$HOME"/.local/bin/rocketpool
    rocketpool --version

    #### FIRST TIME INSTALL
    ## Via docker:
    # run and choose options
    rocketpool service install

    #### TO UPGRADE FROM EXISTING INSTALL
    # https://docs.rocketpool.net/guides/node/updates.html#updating-the-smartnode-stack
    #rocketpool service install -d

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
    # (This actually is important)
    # https://medium.com/rocket-pool/rocket-pool-node-quickstart-guide-d40bc3d0de6d#:~:text=Forwarding%20Peer%20Discovery%20Ports,more%20nodes%20on%20the%20network.

    # To put funds in your node wallet, transfer 16 ETH however you want.



    #########
    ### AFTER YOUR WALLET HAS FUNDS (16 + 1.6 ETH)

    # https://docs.rocketpool.net/guides/node/prepare-node.html#registering-your-node-with-the-network
    # This just uses a small smartcontract to add your node to the blockchain,
    # you don't need the total funds on your node to register it.
    rocketpool node register

    #########
    ### STAKING

    # Set the withdrawal address (cold wallet)
    rocketpool node set-withdrawal-address 0xa219b5ba2007e15dc057dc3a151c3f168a1ca019 --force

    # Set voting delegate address (hot wallet)
    rocketpool node set-voting-delegate 0xa219b5ba2007e15dc057dc3a151c3f168a1ca019

    # To start staking

    # Stake at least 1.6 ETH of RPL
    rocketpool node stake-rpl

    # Stake at least 1.6 ETH of RPL
    rocketpool node deposit

    ## Setup an alias
    codeblock "
    alias rp=rocketpool
    " > "$HOME/.bashrc-local"
}


update_smartstack(){

    ### DOWNLOAD NEW STUF FIRST
    ### Download and instll the new latest CLI version
    DOWNLOAD_DIR="$HOME/tmp"
    INSTALL_PREFIX="$HOME/.local"

    # Download the new CLI version
    mkdir -p "$DOWNLOAD_DIR"
    # Determine your machine CPU architecture (usually amd64 for normal machines)
    ARCH=$(uname -m)
    declare -A ARCH_LUT=(
        ["x86"]="amd64"
        ["x86_64"]="amd64"
        ["aarch64"]="arm64"
    )
    ARCH="${ARCH_LUT[${ARCH}]}"

    # Download the latest binary.
    wget https://github.com/rocket-pool/smartnode-install/releases/latest/download/rocketpool-cli-linux-"${ARCH}" -O "$DOWNLOAD_DIR/rocketpool"

    # Optional, download the latest signature and signing key to verify the binary before installing.
    wget https://github.com/rocket-pool/smartnode-install/releases/latest/download/rocketpool-cli-linux-"${ARCH}".sig -O "$DOWNLOAD_DIR/rocketpool.sig"
    wget https://github.com/rocket-pool/smartnode-install/releases/latest/download/smartnode-signing-key-v3.asc -O "$DOWNLOAD_DIR/smartnode-signing-key-v3.asc"
    # Sign key belongs to:
    # https://github.com/jclapis
    gpg --import "$DOWNLOAD_DIR/smartnode-signing-key-v3.asc"
    gpg --verify "$DOWNLOAD_DIR/rocketpool.sig" "$DOWNLOAD_DIR/rocketpool"

    # COPY STUFF BEFORE
    # https://docs.rocketpool.net/guides/node/updates.html#updating-the-smartnode-stack
    rocketpool service stop

    # If everything looks good install the new binary by copying it into your
    # binary directory (this will overwrite the previous binary)
    mkdir -p "$INSTALL_PREFIX/bin"
    cp "$DOWNLOAD_DIR/rocketpool" "$INSTALL_PREFIX/bin/rocketpool"

    # Add executable persmission
    chmod +x "$INSTALL_PREFIX/bin/rocketpool"
    rocketpool --version


    #### Run the install upgrade
    rocketpool service install -d

    # Check configuration (make sure nothing is new)
    rocketpool service config

    # Restart the service
    rocketpool service start

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



verify_checkpoint_sync(){

    # List of public checkpoints
    # https://eth-clients.github.io/checkpoint-sync-endpoints/

    # https://docs.prylabs.network/docs/prysm-usage/checkpoint-sync
    # https://nimbus.guide/trusted-node-sync.html#verify-you-synced-the-correct-chain

    sudo ufw allow from 127.0.0.1 to 127.0.0.1 port 5052 proto tcp comment 'Local Nimbus REST API'

    curl -X GET http://testing.mainnet.beacon-api.nimbus.team/eth/v1/beacon/blocks/head/root

    #sudo ufw allow from "${LOCAL_IP_PREFIX}.0/24" proto tcp to any port 3500 comment 'Allow checkpoint HEAD network'
    #curl -s http://YOUR_NODE_IP:YOUR_NODE_PORT/eth/v1/beacon/headers/finalized
    curl http://localhost:3500/eth/v1/beacon/headers/finalized  | jq .'data.header.message'

    curl http://localhost:5052/eth/v1/beacon/headers/finalized
    curl http://localhost:5052/eth/v1/node/syncing

    # Does seem to need export HTTP port enabled
    curl http://localhost:5052/eth/v1/beacon/blocks/head/root
    curl http://pewter:5052/eth/v1/beacon/blocks/head/root



    curl https://sync-mainnet.beaconcha.in/eth/v1/beacon/blocks/head/root
    curl https://sync-mainnet.beaconcha.in/eth/v1/beacon/headers/finalized

    curl -s http://localhost:5052/eth/v1/beacon/headers/finalized | jq .'data.header.message'
    curl -s https://sync-mainnet.beaconcha.in:5052/eth/v1/beacon/headers/finalized | jq .'data.header.message'

}


cleanup_firewall(){

    # Find the rules that dont apply
    sudo ufw status numbered

    # NOTE: delete only handles one index at a time, need to relist numbers
    # after we delete one at a time
    sudo ufw status numbered | grep boinc | python3 -c "import sys; print(chr(10).join([line.split(' ')[0][1:-1] for line in sys.stdin.read().split(chr(10))]))"

    sudo ufw status numbered | grep cupdsd | python3 -c "import sys; print(chr(10).join([line.split(' ')[0][1:-1] for line in sys.stdin.read().split(chr(10))]))"

    # And delete them
    sudo ufw delete 17

}

cancel_transaction(){
    WALLET_ADDRESS=0x402d4Df6E2e147cCF1edEd8B0F697cFa3c55E6F1
    https://goerli.etherscan.io/address/0x402d4Df6E2e147cCF1edEd8B0F697cFa3c55E6F1

    0x85bc12e229200035baca224d07d957a05beb6464902040e717e6f9215c7b02fc
}

throttle_cpu(){
    # If things are getting too hot, limit the CPU usage
    sudo apt install cpulimit

    #NETHERMIND_PID=$(ps -axl | grep "nethermind\/Nethermind.Runner" | awk '{print $3}')
    NETHERMIND_PID=$(pgrep ".*Nethermind")
    echo "NETHERMIND_PID = $NETHERMIND_PID"

    # cpulimit -l takes a number between 1 and 100*num_cores.
    # This command gets that number as a fraction of all CPUs
    CPU_LIMIT=$(python3 -c "import multiprocessing as mp; print(int(0.5 * mp.cpu_count() * 100))")
    sudo cpulimit -p "$NETHERMIND_PID" -l "$CPU_LIMIT"
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

    rocketpool service install-update-tracker

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

# Dont need to do this, docker will restart IFF it was running
#install_rocketpool_startup_service(){
#    source ~/local/init/init_rpool.sh
#    SERVICE_NAME=rocketpool_startup
#    SERVICE_EXE="$HOME/.local/bin/rocketpool"
#    SERVICE_ARGS="service start"
#    SERVICE_ENV=""
#    SERVICE_DESC="Rocketpool startup"
#    install_service rocketpool_startup "$HOME/.local/bin/rocketpool" "service start" "" "Rocketpool startup"
#}


#install_service(){
#    __doc__='
#    Installing a service managed by systemctl

#    IPFS_EXE=$(which ipfs)

#    wip_install_service ipfs $IPFS_EXE "daemon" "IPFS_PATH=$IPFS_PATH" "IPFS daemon"
#    wip_install_service rocketpool_startup $HOME/.local/bin/rocketpool "service start" "" "Rocketpool startup"

#    '
#    # https://gist.github.com/pstehlik/9efffa800bd1ddec26f48d37ce67a59f
#    # https://www.maxlaumeister.com/u/run-ipfs-on-boot-ubuntu-debian/
#    # https://linuxconfig.org/how-to-create-systemd-service-unit-in-linux#:~:text=There%20are%20basically%20two%20places,%2Fetc%2Fsystemd%2Fsystem%20.
#    SERVICE_NAME=$1
#    SERVICE_EXE=$2
#    SERVICE_ARGS=$2
#    SERVICE_ENV=$4
#    SERVICE_DESC=$5

#    echo "
#    SERVICE_NAME = $SERVICE_NAME
#    SERVICE_EXE = $SERVICE_EXE
#    SERVICE_ARGS = $SERVICE_ARGS
#    SERVICE_ENV = $SERVICE_ENV
#    SERVICE_DESC = $SERVICE_DESC
#    "

#    SERVICE_DPATH=/etc/systemd/system
#    SERVICE_FPATH=$SERVICE_DPATH/${SERVICE_NAME}.service

#    echo "SERVICE_EXE = $SERVICE_EXE"
#    echo "SERVICE_FPATH = $SERVICE_FPATH"

#    sudo_writeto "$SERVICE_FPATH" "
#        [Unit]
#        Description=${SERVICE_DESC}
#        After=network.target
#        [Service]
#        Environment=\"${SERVICE_ENV}\"
#        User=$USER
#        ExecStart=${SERVICE_EXE} ${SERVICE_ARGS}
#        [Install]
#        WantedBy=multiuser.target
#        "
#    #sudo systemctl daemon-reload
#    sudo systemctl start "$SERVICE_NAME"
#    sudo systemctl status "$SERVICE_NAME"
#}


migrate_to_mainnet(){
    # https://docs.rocketpool.net/guides/testnet/mainnet.html#smartnode-operation-on-mainnet
    rocketpool minipool exit


    # I had an issue where I started my eth2 sync from scratch, and
    # reconfiguring to use checkpoint-sync didn't seem to work. it continued to
    # sync from scratch.  To force a resync with a checkpoint-url, set it via
    # `rocketpool service configure` and run:
    rocketpool s resync-eth2
}



voting_on_proposals(){
    __doc__="
    Link your delegate wallet to https://vote.rocketpool.net

    Or

    via CLI:
    https://docs.rocketpool.net/guides/odao/proposals.html#making-a-proposal
    "
}


checking_attestation_schedule(){
    _=""
    # https://ethereum.github.io/beacon-APIs/#/
    # https://gist.github.com/pietjepuk2/eb021db978ad20bfd94dce485be63150
}


configure_metric_monitoring_server(){
    __doc__="
    Rocket pool eth to reth
    https://coinmarketcap.com/currencies/rocket-pool-eth/reth/eth/

    # Ratio to the peg
    https://dune.com/drworm/rocketpool

    # https://docs.rocketpool.net/guides/node/grafana.html#enabling-the-metrics-server
    "

    # https://docs.rocketpool.net/guides/node/grafana.html#enabling-the-metrics-server
    SUBNET_CIDR_IP=$(docker inspect rocketpool_monitor-net | grep -Po "(?<=\"Subnet\": \")[0-9./]+")
    echo "SUBNET_CIDR_IP = $SUBNET_CIDR_IP"
    # Allow docker subnet
    sudo ufw allow from "$SUBNET_CIDR_IP" to any port 9103 comment "Allow prometheus access to node-exporter"

    LOCAL_IP=$(ifconfig eno1 | grep -Po "(?<=inet )[0-9./]+")
    LOCAL_IP_PREFIX=$(echo "${LOCAL_IP}" | cut -d "." -f1-3)
    echo "LOCAL_IP = $LOCAL_IP"
    echo "LOCAL_IP_PREFIX = $LOCAL_IP_PREFIX"

    # Allow machines in the local network
    sudo ufw allow from "${LOCAL_IP_PREFIX}.0/24" proto tcp to any port 3100 comment 'Allow grafana from local network'

    echo "Now naviate on your machine to: $LOCAL_IP:3100"

    # Reset the admin password for grafana (if you forgot your original password)
    docker exec -it rocketpool_grafana grafana-cli admin reset-admin-password admin

    # Follow instructions on the browser for:
    # https://docs.rocketpool.net/guides/node/grafana.html#importing-the-rocket-pool-dashboard

}


configure_grafana_dashboard(){
    __doc__="

    Manual Steps
    ------------
    First, import the latest dashboard as described in
    https://docs.rocketpool.net/guides/node/grafana.html#enabling-the-metrics-server

    That is, click Dashboards (the 4 squares icon) -> +import

    The current dashboard id (2023-07-30) is 18391

    Then go to share -> export it, and now we can programatically modify the file.

    "
    FPATH="$HOME/Downloads/Rocket Pool Dashboard v1.3.0-1684781005746.json"
    echo "FPATH = $FPATH"
    cat "$FPATH"

    python -c "if 1:

    fpath = ub.Path('$HOME/Downloads/Rocket Pool Dashboard v1.3.0-1684781005746.json').expand()
    import json
    data = json.loads(fpath.read_text())
    walker = ub.IndexableWalker(data)

    title_to_pannel = {}

    for panel in data['panels']:
        title = panel.get('title', None)
        if title is not None:
            title_to_pannel[title] = panel

    for p, v in walker:
        if isinstance(v, str) and 'node_network_transmit_bytes_total' in v:
            print(p)
    #walker[['panels', 24, 'targets', 1]]
    #walker[['panels', 24]]
    #walker[['panels', 3]]

    sq = chr(34)
    title_to_pannel['CPU Temp']['targets'][0]['expr'] = f'node_hwmon_temp_celsius{{job={sq}node{sq}, chip={sq}platform_coretemp_0{sq}, sensor={sq}temp1{sq}}}'

    # Add chip='nvme_nvme0', sensor='temp1'
    title_to_pannel['Disk Temp']

    # Add device=eno1
    title_to_pannel['Network Usage']['targets'][0]['expr']

    title_to_pannel['Total Net I/O']['targets'][0]['expr']

    # Add device='nvme0n1'
    title_to_pannel['SSD Latency']['targets'][0]['expr']
    "

    sed -i 's|node_hwmon_temp_celsius{job=\"node\"||g' "$FPATH"
}


prune_nethermind(){
    __doc__="
    Note: pruning takes a long time, make sure that you let it run to
    completion.

    References:
        https://docs.rocketpool.net/guides/node/pruning.html#prerequisites
    "
    rocketpool service prune-eth1

    # Follow status with:
    rocketpool service logs eth1
}

claim_rewards(){
    __doc__="
    References:
        https://docs.rocketpool.net/guides/node/skimming.html#:~:text=Automatic%20Distribution%20%E2%80%8B,by%20following%20the%20steps%20below.&text=Navigate%20to%20the%20setting%20Smartnode,Auto%20Distribute%20Threshold%20shown%20below.
        https://docs.rocketpool.net/guides/node/responsibilities.html#how-ethereum-staking-works
    "

    # Look at expected rewards
    rocketpool node rewards

    # Look at minimpool EL rewards
    rocketpool minipool status | grep "Minipool Balance (EL)" -A 3 | grep "Your portion"

    # Claim node rewards
    rocketpool node claim-rewards

    # Claim minipool rewards
    rocketpool minipool distribute-balance
}

stake_on_behalf(){
    __doc__="
    To add stake more RPL

    References:
        https://docs.rocketpool.net/guides/node/create-validator.html#staking-via-the-website
    "
    echo "
    These instructions are currently manual

    Before you Start
    ----------------
    You should have a wallet (this could be your delegate wallet) with funds
    that you want to stake on behalf of the node.

    Instructions
    ------------
    * Navigate to https://stake.rocketpool.net/stake-behalf

    * Connect the webpage to your metamask wallet.

    * Enter your node's address in the 'Node Address' box (this is the address you see when you run).

    ..code:: bash

        rocketpool node status | grep -E 'The node .*0x[a-z0-9].* has a balance'

    * You are then prompted for how much RPL you would like approve to stake.

    * Metamask will then prompt you to set a limit (which can be filled in automatically) and sign the approval.

    * The previous steps just allowed a smart contract to move the money for you.

    * Now go back to stake on behalf and follow the remaining prompts entering
    the max amount of RPL you approved and then signing the transaction.
    "
}

is_reboot_required(){
    if test -f /var/run/reboot-required; then
        cat /var/run/reboot-required
    else
        echo "Nothing to do"
    fi
}


terms(){

    __doc__="

    References:
        https://launchpad.ethereum.org/en/faq#:~:text=A%20validator%20client%20is%20the,key%20pairs%2C%20controlling%20many%20validators.

    VC - validator client.

    BN - becon node.

    EC - execution client.

    "
}


rescue_node(){
    __doc__="
    For running maintainence that takes EC or BN offline.

    References:
        https://rescuenode.com/
        https://twitter.com/0xPatches/status/1597704860962795520?lang=en
        https://gist.github.com/jshufro/a22724f06702c8342b5d1b29ee0a6190
        https://github.com/Rocket-Rescue-Node/guarded-beacon-proxy
    "

    # It is a very good idea to enable doppleganger mode before you do this.

    # On the staking node run:
    rocketpool node sign-message -m "Rescue Node $(date +%s)"

    # Paste the message into https://rescuenode.com/
    # follow propmts (like picking the correct CC) then copy the result
    # into ~/.rocketpool/override/validator.yml

    rp service start

    # Now you can perform maintainence
    # e.g. rocketpool service resync-eth1

    docker image prune -a --filter "until=24h"

    # remove the extra line from:
    #  ~/.rocketpool/override/validator.yml

    rp service start

    cat << EOF
    Q. I'm curious how the rocketpool rescue node works in terms of security. Specifically, how is the ~/.rocketpool/override/validator.yml doing, and how is it secure to have another machine perform your attestations (i.e. how does this work without giving the rescue node your private keys)?

    In the about section I see the tech specs: https://gist.github.com/jshufro/a22724f06702c8342b5d1b29ee0a6190

    But I'm not sure if this answers all my questions. I see:

    > Node Operators using the rescue node acknowledge that they are trusting its maintainers not to steal tips or MEV. The maintainers will not be able to steal their keys or funds.

    But I don't understand exactly why that is the case.

    ---

    The validator is the only application in the stack that has access to the
    keys, and it never sends them to the beacon node. the rescue node is
    essentially just a beacon node, so it never gets access to the keys.

    The validator.yml changes just tell your validator to connect to the rescue
    node instead of its local beacon node

    But since the validator doesn't send the keys to the beacon node, it
    doesn't matter

    --

    Mostly yes, still grokking a few things. I understand that the validator
    (lodestar in my case) would be the only application with private key access.

    It's unclear to me what 'the becon node' is in this setting. I was under
    the impression that the validator was the 'Beacon Node' and that was the same
    thing as the concensus client. Is that not the case? Otherwise I dont
    understand why the validator connects to itself.

    When I run 'rp service stats' I'm noticing that there are 'ETH1' and 'ETH2' services.
    Is the becon node the ETH2 service?  I also see that on my node, the ETH2 service command is an invocation of lodestar, so is lodestar
      actually connecting to itself by running in different docker containers?
    "

    ---

    So the VC has access to private keys, and it delegates attestations to the
    BN server. Normally I would delegate to my own local instance, but in this case
    I would override it to call out to the rescue node.

    Is it the case that the BN server is also talking to the ETH1 service, and
    when I delegate to the rescue node it has its own ETH1 client running?

    If that is true, then the last question I have is how the rescue node is
    able to perform attestation if my VC is down.

    Patches: if your VC is down you cannot perform attestations
    [3:23 PM]Patches: 'delegates' is the wrong word here
    [3:23 PM]Patches: the bn and ec talk to each other and their peers to sync the ethereum chain
    [3:23 PM]Patches: the vc talks to the bn to perform duties
    --
    So I have to keep my VC up if I'm using the rescue node? If that is true then I think everything makes sense. If not, I still have questions.
    --
    Patches: that is correct
    [3:25 PM]Patches: in general, if you haven't given your keys away, it's impossible to perform duties when your VC is down
    [3:25 PM]Patches: the VC is the thing that does that, after all
    [3:26 PM]Patches: rescue node isn't there for power failures or internet outages
    [3:26 PM]Patches: it's there for fixing corrupt chain data, doing emergency maintenance, pruning
    [3:27 PM]erotemic: Yeah, that would've been my question. But that makes sense. The rescue node is for when the BN and EC are down. I think I'm getting a handle on it.
    [3:27 PM]Patches: there's a few other niche use-cases
    [] Patches: like if you want to deposit a minipool right away but only just set up your node, you can use infura+rescuenode to deposit before your clients finish syncing
    [3:28 PM]Patches: but for the most part people use it to prune and to resync
EOF

    .191 * 2

}


cleanup(){
    # Free a few hundred MB in /var/log/journal
    journalctl --vacuum-time=10d

    # Remove old kernels and packages
    sudo apt-get autoremove
}
