#http://www.howtogeek.com/70374/how-to-geek-explains-what-is-wake-on-lan-and-how-do-i-enable-it/
sudo apt-get install ethtool
sudo ethtool eth0
sudo ethtool -s eth0 wol g
