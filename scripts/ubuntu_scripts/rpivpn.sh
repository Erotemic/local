#/bin/sh
echo "$(~/pass/decrypt.sh ~/pass/std.tc)" | sudo openconnect -b vpn.net.rpi.edu -ucrallj --passwd-on-stdin
sleep .5
echo "Finished connection script"
echo ""
