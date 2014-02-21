#!/usr/bin/bash
# Bit Torrent Sync
# http://www.bittorrent.com/sync/downloads
# http://blog.bittorrent.com/2013/09/17/sync-hacks-how-to-set-up-bittorrent-sync-on-ubuntu-server-13-04/

sudo add-apt-repository ppa:tuxpoldo/btsync
sudo apt-get update
# Client 
sudo apt-get install btsync-user
# Server
sudo apt-get install btsync
#sudo dpkg-reconfigure btsync

# Set sync server to secret port
# get_secret bts sync_port
# get_secret bts web_interface_listen_port
# get_secret bts username



http://localhost:9422/gui/


http://127.0.0.1:8888/gui/
