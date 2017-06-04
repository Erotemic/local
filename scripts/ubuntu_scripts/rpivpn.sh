#/bin/sh
# Kill any connections to rpi that exist
VPN_URL=vpn.net.rpi.edu
sudo pkill -f "openconnect.*$VPN_URL"
echo "$(~/pass/decrypt.sh ~/pass/std.tc)" | sudo openconnect -b $VPN_URL -ucrallj --passwd-on-stdin
sleep .5
echo "Finished connection script"
echo ""
