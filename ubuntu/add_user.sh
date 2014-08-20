export NEW_USERNAME=
sudo adduser $NEW_USERNAME

# then have them send you a public key

# Grant sudoers
#sudo visudo


# Delete user
#deluser --remove-home newuser

# Ad group
sudo groupadd rpi
sudo usermod -a -G rpi jason
sudo usermod -a -G rpi joncrall


sudo chown -R joncrall:rpi *
umask 002 work
chgrp rpi work
chmod g+s work
