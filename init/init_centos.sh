# Install virtualbox addons
# http://download.virtualbox.org/virtualbox/4.1.12/
# Mount the .iso on the guest machine
sudo mount /dev/cdrom /mnt/
cd /mnt
./VBoxLinuxAdditions.run

useradd joncrall
passwd joncrall

yup install vim


# Add user to suoders file
visudo
echo "joncrall ALL=(ALL) ALL" >> /etc/sudoers

# Init Dynamic IP
vi /etc/sysconfig/network-scripts/ifcfg-eth0
# Ensure the following variables
DEVICE=eth0
BOOTPROTO=dhcp
ONBOOT=yes
NM_CONTROLLED=no

export GLOBAL_ifcfg_eth0=/etc/sysconfig/network-scripts/ifcfg-eth0


sed s/ONBOOT=no/ONBOOT=yes/ /etc/sysconfig/network-scripts/ifcfg-eth0
