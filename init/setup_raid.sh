# Tutorials
#http://feeding.cloud.geek.nz/posts/setting-up-raid-on-existing/


resetup_raid_after_os_reinstall()
{
    # https://ubuntuforums.org/showthread.php?t=2002217
    # if you reinstalled your OS you just need to tell the system about the
    # raid to get things working again
    sudo apt-get install gdisk mdadm rsync -y
    # Simply scan for your preconfigured raid
    sudo mdadm --assemble --scan 
    # Mount the RAID (temporary. modify fstab to automount)
    sudo mount /dev/md0 /media/raid
    # Modify fstab so RAID auto-mounts at startup
    echo "/dev/md0    /media/raid       ext4  defaults     1  2" >> /etc/fstab
}

#=================
# Install prereqs
#-----------------
# for guuid partition tables
sudo apt-get install gdisk -y
# raid managment tool
sudo apt-get install mdadm -y
sudo apt-get install rsync -y
sudo apt-get install initramfs-tools
#=================

    
#=================
# Info
#-----------------
# list hard drives
sudo fdisk -l
ls -a /dev/ | grep "sd"
sudo fdisk -l | grep -e '^/dev/sd'

# List all RAIDS
ls -a /dev/ | grep "md"

# lists all drives
sudo fdisk -l | grep -e '^Disk /dev/sd'

cat /etc/fstab | grep -Ev '^#'
#=================


# edit hdd configs
sudo gvim /etc/fstab

sudo fdisk /dev/sdb

# MAKE GUID PARTITION TABLES

sudo man sgdisk

sudo sgdisk -p /dev/sdb
sudo sgdisk -p /dev/sdd
sudo sgdisk -p /dev/sde

# DELETE ALL DATA 
#sudo sgdisk --clear /dev/sdb
#sudo sgdisk --clear /dev/sdd
#sudo sgdisk --clear /dev/sde

sudo sgdisk -n 1:2048:3907028991 /dev/sdb -c 1:"R1b"
sudo sgdisk -n 1:2048:3907028991 /dev/sdd -c 1:"R2d"
sudo sgdisk -n 1:2048:3907028991 /dev/sde -c 1:"R3e"

#sudo mkfs.ext4 -t ext4 /dev/sdb1 
#sudo mkfs.ext4 -t ext4 /dev/sdd1 
#sudo mkfs.ext4 -t ext4 /dev/sde1 

#https://raid.wiki.kernel.org/index.php/RAID_setup
#chunk size = 128kB (set by mdadm cmd, see chunk size advise above)
#block size = 4kB (recommended for large files, and most of time)
#stride = chunk / block = 128kB / 4k = 32
#stripe-width = stride * ( (n disks in raid5) - 1 ) = 32 * ( (3) - 1 ) = 32 * 2 = 64

sudo mkfs.ext4 -v -m .1 -b 4096 -E stride=32,stripe-width=64 /dev/sdb1 
sudo mkfs.ext4 -v -m .1 -b 4096 -E stride=32,stripe-width=64 /dev/sdd1 
sudo mkfs.ext4 -v -m .1 -b 4096 -E stride=32,stripe-width=64 /dev/sde1 


# make sure you have RAID module in the linux kernel
sudo modprobe raid456
cat /proc/mdstat

# Create RAID 5
sudo mdadm --create --verbose /dev/md0 --level=5 --raid-devices=3  /dev/sdb1 /dev/sdd1 /dev/sde1
sudo mdadm --detail --scan 
sudo mdadm --query --detail /dev/md0
sudo mdadm --detail --scan >> /etc/mdadm/mdadm.conf

cat /proc/mdstat

# Start RAID
sudo mdadm --assemble --scan 
sudo mdadm --assemble /dev/md0

# Stop RAID
sudo mdadm --stop /dev/md0

# Format the RAID
sudo mkfs.ext4 -v -m .1 -b 4096 -E stride=32,stripe-width=64 /dev/md0 

# Create mountpoint for the RAID
sudo mkdir /media/raid
sudo chown joncrall:joncrall /media/raid

# Mount the RAID (temporary. modify fstab to automount)
sudo mount /dev/md0 /media/raid

# Modify fstab so RAID auto-mounts at startup
sudo sh -c 'echo "/dev/md0    /media/raid       ext4  defaults     1  2" >> /etc/fstab'

# Stop Rebuild
sudo /usr/share/mdadm/checkarray -xa
# Reconfigure initramfs
sudo update-initramfs -u

# DEBUG
sudo mdadm --examine /dev/sdb
sudo mdadm --examine /dev/sdd
sudo mdadm --examine /dev/sde

sudo mdadm --detail /dev/md127 

# INFORMATION
sudo mdadm --detail --scan 
sudo mdadm --query --detail /dev/md0
sudo mdadm --detail /dev/md0 
cat /proc/mdstat

ln -s /raid /media/raid 
cp -r /data/* .