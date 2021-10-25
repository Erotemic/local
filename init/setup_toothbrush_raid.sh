__doc__="
This script documents how I setup a RAID on my machine toothbrush.

It has a hard coded that assumes 4 drives, but this should be easy to modify.
It also includes a unused function that illustrates how to re-register an
existing RAID after an OS reinstall.

This script is meant to serve as a reference. It is not meant to be run
end-to-end. Look at each block of code and its comments, and choose to execute
/ modify each line carefully. In addition to the commands to actually create
the RAID, it contains commands that do read-only inspection, which helps the
user understand the process.

References:

    # Setting up RAID on an existing Debian/Ubuntu installation
    http://feeding.cloud.geek.nz/posts/setting-up-raid-on-existing/

    # Reinstall Ubuntu, do i keep the software RAID?
    https://ubuntuforums.org/showthread.php?t=2002217
"


resetup_raid_after_os_reinstall()
{
    # if you reinstalled your OS you just need to tell the system about the
    # raid to get things working again
    sudo apt-get install gdisk mdadm rsync -y
    # Simply scan for your preconfigured raid
    sudo mdadm --assemble --scan 
    # Mount the RAID (temporary. modify fstab to automount)
    sudo mkdir -p /media/$USER/raid
    sudo mount /dev/md0 /media/$USER/raid
    # Modify fstab so RAID auto-mounts at startup
    sudo sh -c "echo '# appended to fstab by by install scripts' >> /etc/fstab"
    sudo sh -c "echo 'UUID=4bf557b1-cbf7-414c-abde-a09a25e351a6  /media/$USER/raid              ext4    defaults        0 0' >> /etc/fstab"

    sudo ln -s /media/$USER/raid /raid
}

__notes__(){
    (cd $HOME/misc/notes && python -m hardwareinfo)
}


#=================
# Install prereqs
#-----------------
# for guuid partition tables and raid managment tools
sudo apt install gdisk mdadm initramfs-tools rsync -y
sudo apt install zfsutils-linux -y
#=================



# Show all devices wheter or not they are mounted 
lsblk 
cat /proc/scsi/scsi
lsblk --scsi
lsblk --scsi --output NAME,KNAME,LABEL,MOUNTPOINT,UUID,PARTTYPE,PARTUUID,MODEL,TYPE,SIZE,STATE | grep disk
lsblk --output-all
lsblk --scsi


# Use the above information to determine which devices correspond to the drives
# Define disks (represents unique hard drives connected to the motherboard) 
DISK1=/dev/sda
DISK2=/dev/sdb
DISK3=/dev/sdc
DISK4=/dev/sdd

# Define disk partitions (typically on per hard drive)
PART1="$DISK1"1
PART2="$DISK2"1
PART3="$DISK3"1
PART4="$DISK4"1

RAID_DISKS="$DISK1 $DISK2 $DISK3 $DISK4"
RAID_PARTS="$PART1 $PART2 $PART3 $PART4"
echo "RAID_DISKS = $RAID_DISKS"
echo "RAID_PARTS = $RAID_PARTS"

# Check for existing RAIDs
sudo mdadm --examine $RAID_DISKS


zfs-init-on-reinstall(){
    __doc__="
    https://unix.stackexchange.com/questions/483465/restore-zfs-pool-and-storage-data-after-a-system-re-install
    "

    POOL_NAME=data
    sudo zpool $POOL_NAME 
    zpool status

}


zfs-notes(){
    __doc__="
        # ZFS RAID
        https://linuxconfig.org/configuring-zfs-on-ubuntu-20-04
        https://www.cyberciti.biz/faq/how-to-create-raid-10-striped-mirror-vdev-zpool-on-ubuntu-linux/
        https://ubuntu.com/tutorials/setup-zfs-storage-pool?_ga=2.210175133.962459875.1618424233-746558168.1612391761#3-creating-a-zfs-pool

        https://askubuntu.com/questions/404172/zpools-dont-automatically-mount-after-boot
        https://askubuntu.com/questions/1294944/zfs-pool-not-auto-mounting-after-upgrade-to-20-04
    "

    # Create a RAID 10 (striped + mirrored) zfs pool
    POOL_NAME=data
    #sudo zpool create $POOL_NAME mirror $DISK1 $DISK2 mirror $DISK3 $DISK4
    #sudo zpool destroy data
    sudo zpool create $POOL_NAME mirror $DISK1 $DISK2
    sudo zpool add $POOL_NAME mirror $DISK3 $DISK4

    zpool status
    zpool list

    # Wow, zfs is simple to use.

    _sync_="
    rsync -avrpR ooo:/data/./Documents /data/store/
    rsync -avrpR ooo:/data/./Media /data/store/
    "

    mkdir -p /data/$USER
    ln -s /data/$USER $HOME/data 


}


# --- <FORMAT EACH DRIVE> ---
# Ensure each drive has formatted partions
# Previously, I did this through gparted
# Formated everything with a GPT (guid partition table) and added the raid flag

# However, now lets do it via the parted CLI
create-raid-parition(){
    __doc__="""
    Setup a the disk for usage in a RAID, parition, format, and flags.
    """
    _DISK=$1
    _PART=$2
    _LABEL=$3

    echo "Create the GPT for $_DISK"
    sudo parted $_DISK mktable gpt                           # Create the GPT 
    sleep 1

    echo "Create a primary partition for $_DISK"
    sudo parted $_DISK mkpart primary ext4 0% 100%           # Create the partition
    sleep 1

    echo "Set the RAID flag for $_DISK on the primary partition"
    sudo parted $_DISK set 1 raid on                         # Set the RAID flag

    # wait a few seconds before formatting the drive
    # NOTE: we may not need to preformat the drive (because we fill format the raid device)
    sleep 3
    echo "Format the $_PART partition using the ext4 filesystem"
    sudo mkfs.ext4 -L "$_LABEL" $_PART   # Format the partition 
}

create-raid-parition $DISK1 $PART1 "Raid-Disk-1"
create-raid-parition $DISK2 $PART2 "Raid-Disk-2"
create-raid-parition $DISK3 $PART3 "Raid-Disk-3"
create-raid-parition $DISK4 $PART4 "Raid-Disk-4"
# --- </FORMAT EACH DRIVE> ---


# Check that the labels for each drive look good
sudo fdisk $DISK1 -l
sudo fdisk $DISK2 -l
sudo fdisk $DISK3 -l
sudo fdisk $DISK4 -l


# Check for existing RAIDs (AGAIN, but this time on the partitions)
sudo mdadm --examine $RAID_PARTS


# Create the RAID10 device
sudo mdadm --create /dev/md0 --level=10 --raid-devices=4 $RAID_PARTS
# answer yes

# Check status
cat /proc/mdstat
sudo mdadm --examine $RAID_PARTS
sudo mdadm --detail /dev/md0

# Create the filesystem
sudo mkfs.ext4 -L "Raid" /dev/md0

# Create a raid group and add self to it
sudo groupadd raid
sudo usermod -aG raid $USER

# Create mount point with group permissions
echo "USER = $USER"
MOUNT_POINT=/media/$USER/raid
sudo mkdir -p $MOUNT_POINT
sudo chown -R $USER:$USER $MOUNT_POINT
sudo chmod -R 777 $MOUNT_POINT
sudo mount /dev/md0 $MOUNT_POINT
#sudo umount $MOUNT_POINT
ls -l $MOUNT_POINT
ls -l $MOUNT_POINT/..

# make symlink that I like
sudo ln -s $MOUNT_POINT /raid

# Test that reads/writes work
touch /raid/raid_files.txt
ls -l /raid/
echo "raid 10 setup with 4 disks" > /raid/raid_files.txt
cat /raid/raid_files.txt
rm /raid/raid_files.txt

# Write mdadm config
sudo sh -c 'sudo mdadm --detail --scan >> /etc/mdadm/mdadm.conf'

# Update the initramfs (Initial-RAM-filesystem)
# (forgot to do this the first time)
sudo update-initramfs -u

# Update the FSTAB file so the raid automounts on startup

MD0_UUID=$(sudo mdadm --detail /dev/md0 | grep UUID | awk '{print $3}' | sed 's/:/-/g')
echo "MD0_UUID = '$MD0_UUID'"

MOUNT_POINT=/media/$USER/raid
echo "MOUNT_POINT = $MOUNT_POINT"
sudo sh -c "echo '# appended to fstab raid setup scripts' >> /etc/fstab"
#sudo sh -c "echo 'UUID=$MD0_UUID  $MOUNT_POINT              ext4    defaults        0 0' >> /etc/fstab"
sudo sh -c "echo '/dev/md0  $MOUNT_POINT              ext4    defaults        0 0' >> /etc/fstab"

__directory_setup(){
    mkdir -p /raid/home
    mkdir -p /raid/home/$USER

    rsync -avrP /media/joncrall/lacie /raid/unsorted
}


__dev_fixes_notes(){
    # -----
    # FIXES
    # my raid was id-ed as 127 because I did not do the conf file properly
    sudo mdadm --detail /dev/md127 | grep UUID
    #
    # UUID : b991b178:dd820492:3502ef74:5d527f6a
    sudo mdadm --detail /dev/md127


    # Change 127 to 0
    sudo mdadm --stop /dev/md127
    # Assemble the drives in a new raid at md0
    sudo mdadm --assemble /dev/md0 $RAID_PARTS
    # Now re-write the mdadm config (ensure the lines arent duplicated)
    sudo sh -c 'sudo mdadm --detail --scan >> /etc/mdadm/mdadm.conf'

    sudo mdadm --detail --scan
    # Update the initramfs (Initial-RAM-filesystem)
    sudo update-initramfs -u

    # Use blkid or mdadm to get the UUID of md0
    sudo mdadm -Q /dev/md0
}

