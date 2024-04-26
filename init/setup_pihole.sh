#!/usr/bin/env bash
__doc__="
https://github.com/pi-hole/pi-hole/#one-step-automated-install

Notes:
    https://discourse.pi-hole.net/t/how-do-i-configure-my-devices-to-use-pi-hole-as-their-dns-server/245
"

git clone --depth 1 https://github.com/pi-hole/pi-hole.git "$HOME"/code/pi-hole
cd "code/pi-hole/automated install/"
sudo bash basic-install.sh


echo "

Manual Steps
-----------

1. Configure the router to assign the pi a static IP

2. Configure the router to point at the pi's static IP for the DNS server.

"


# Get status
pihole status


setup_custom_dns(){
    # Setup custom DNS
    # https://thiagowfx.github.io/2022/01/pihole-add-custom-dns-mappings/
    # # https://discourse.pi-hole.net/t/documentation-on-local-dns-records/33777
    echo "addn-hosts=/etc/pihole/lan.list" | sudo tee /etc/dnsmasq.d/02-lan.conf

    sudo_writeto /etc/pihole/lan.list "
    192.168.222.29   mojo.home.lan  mojo
    192.168.222.16   toothbrush.home.lan  toothbrush
    192.168.222.38   ooo.home.lan  ooo
    192.168.222.35	 pewter.home.lan pewter
    "

    #sudo sh -c "echo \"
    #192.168.222.2  mojo.home.lan  mojo
    #192.168.222.3  rojo.home.lan  rojo
    #192.168.222.4  dojo.home.lan  dojo
    #192.168.222.5  jojo.home.lan  jojo
    #\" > /etc/pihole/lan.list"

    sudo pihole restartdns
}

test_pihole(){
    __doc__="
    https://canyoublockit.com/
    https://fuzzthepiguy.tech/adtest/
    "
}


configure_firewall(){
    __doc__="

    Admin Panel

        http://pi.hole/admin
        http://192.168.222.29/admin

    "

    # Check firewall status
    sudo ufw status

    # Configure firewall to allow a connection to port 80 (https) and 443 (https)
    # as long as it is from inside the LAN. (Note the /24 means the mask is 24
    # bits, so the first 3 blocks matter. Its a CIDR thing, need to learn more.)
    sudo ufw allow proto tcp from 192.168.222.1/24 to any port 80,443 comment 'allow LAN to connect to port 80 or 443 via TCP'
    sudo ufw allow proto udp from 192.168.222.1/24 to any port 80,443 comment 'allow LAN to connect to port 80 or 443 via UDP'
}

local_stuff(){
    # Flush DNS caches
    sudo resolvectl flush-caches
}

stop_pihole(){
    pihole status
    pihole disable
    service pihole-FTL stop
}

remove_pihole(){
    sudo pihole remove
    # Remove any extra dependencies
    # git iproute2 dialog ca-certificates cron curl iputils-ping psmisc sudo unzip idn2 libcap2-bin dns-root-data libcap2 netcat-openbsd procps jq grep dnsutils lighttpd php8.1-common php8.1-cgi php8.1-sqlite3 php8.1-xml php8.1-intl

}
