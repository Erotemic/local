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

# https://unix.stackexchange.com/questions/387855/make-lsblk-list-devices-by-id
ls /dev/disk/by-id/ -al
lsblk --scsi |awk 'NR==1{print $0" DEVICE-ID(S)"}NR>1{dev=$1;gsub("[^[:alnum:]]","",dev);printf $0"\t\t";system("find /dev/disk/by-id -lname \"*"dev"\" -printf \" %p\"");print "";}'



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
    sudo parted "$_DISK" mktable gpt                           # Create the GPT 
    sleep 1

    echo "Create a primary partition for $_DISK"
    sudo parted "$_DISK" mkpart primary ext4 0% 100%           # Create the partition
    sleep 1

    echo "Set the RAID flag for $_DISK on the primary partition"
    sudo parted "$_DISK" set 1 raid on                         # Set the RAID flag

    # wait a few seconds before formatting the drive
    # NOTE: we may not need to preformat the drive (because we fill format the raid device)
    sleep 3
    echo "Format the $_PART partition using the ext4 filesystem"
    sudo mkfs.ext4 -L "$_LABEL" "$_PART"   # Format the partition 
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
sudo usermod -aG raid "$USER"

# Create mount point with group permissions
echo "USER = $USER"
MOUNT_DPATH=/media/$USER/raid
sudo mkdir -p "$MOUNT_DPATH"
sudo chown -R "$USER":"$USER" "$MOUNT_DPATH"
sudo chmod -R 777 "$MOUNT_DPATH"
sudo mount /dev/md0 "$MOUNT_DPATH"
#sudo umount $MOUNT_DPATH
ls -l "$MOUNT_DPATH"
ls -l "$MOUNT_DPATH"/..

# make symlink that I like
sudo ln -s "$MOUNT_DPATH" /raid

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

MOUNT_DPATH=/media/$USER/raid
echo "MOUNT_DPATH = $MOUNT_DPATH"
sudo sh -c "echo '# appended to fstab raid setup scripts' >> /etc/fstab"
#sudo sh -c "echo 'UUID=$MD0_UUID  $MOUNT_DPATH              ext4    defaults        0 0' >> /etc/fstab"
sudo sh -c "echo '/dev/md0  $MOUNT_DPATH              ext4    defaults        0 0' >> /etc/fstab"

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



f2fs_notes(){
    __doc__="
    Notes about how to install the F2FS file system on the NVME SSD drives
    "
    sudo apt-get install f2fs-tools -y

    # Output info about file systems
    lsblk -fs 

    # Determine which disk devices should be formatted
    lsblk | grep disk

    DEVICE_DPATH=/dev/nvme1n1
    MOUNT_NAME="flash1"
    MOUNT_DPATH=/media/$USER/$MOUNT_NAME
    FS_FORMAT="f2fs"

    # Format device filesystem
    sudo mkfs -t "$FS_FORMAT" "$DEVICE_DPATH"

    # Create mount point with group permissions
    sudo mkdir -p "$MOUNT_DPATH" 
    sudo chown "$USER":"$USER" "$MOUNT_DPATH" 
    sudo chmod 777 "$MOUNT_DPATH"
    sudo mount "$DEVICE_DPATH" "$MOUNT_DPATH"
    #sudo umount $MOUNT_DPATH

    FSTAB_LINE="${DEVICE_DPATH}  ${MOUNT_DPATH}              $FS_FORMAT    defaults        0 0  # from erotemic local"
    grep "$FSTAB_LINE" /etc/fstab || sudo sh -c "echo '$FSTAB_LINE' >> /etc/fstab"




    ######
    DEVICE_DPATH=/dev/nvme1n1
    MOUNT_NAME="flash2"

    # Format device filesystem
    sudo mkfs -t f2fs "$DEVICE_DPATH"

    # Create mount point with group permissions
    MOUNT_DPATH=/media/$USER/$MOUNT_NAME
    sudo mkdir -p "$MOUNT_DPATH"
    sudo chown -R "$USER":"$USER" "$MOUNT_DPATH"
    sudo chmod -R 777 "$MOUNT_DPATH"
    sudo mount "$DEVICE_DPATH" "$MOUNT_DPATH"
    #sudo umount $MOUNT_DPATH

    ln -s "/media/$USER/flash1" "$HOME/flash1" 
}


btrfs_notes(){
    __doc__="
    Notes about how to install the BTRFS file system on the NVME SSD drives
    "
    sudo apt install btrfs-progs -y

    # Output info about file systems
    lsblk -fs 

    # Determine which disk devices should be formatted
    lsblk | grep disk

    DEVICE_DPATH=/dev/nvme1n1
    MOUNT_NAME="flash1"
    MOUNT_DPATH=/media/$USER/$MOUNT_NAME
    FS_FORMAT="btrfs"

    # If mounted unmount
    sudo umount "$DEVICE_DPATH"

    # Format device filesystem (the -d is for btrfs to denote a single drive)
    sudo mkfs -t "$FS_FORMAT" -f -d single "$DEVICE_DPATH"

    sudo mount "$DEVICE_DPATH" "$MOUNT_DPATH"

    # Create mount point with group permissions
    sudo mkdir -p "$MOUNT_DPATH" 
    sudo chown "$USER":"$USER" "$MOUNT_DPATH" 
    sudo chmod 777 "$MOUNT_DPATH"
    #sudo umount $MOUNT_DPATH

    FSTAB_LINE="${DEVICE_DPATH}  ${MOUNT_DPATH}              $FS_FORMAT    defaults        0 0  # from erotemic local"
    grep "$FSTAB_LINE" /etc/fstab || sudo sh -c "echo '$FSTAB_LINE' >> /etc/fstab"

    ln -s "/media/$USER/flash1" "$HOME/flash1" 
}


################################
#
#  ####### #######  #####  
#       #  #       #     # 
#      #   #       #       
#     #    #####    #####  
#    #     #             # 
#   #      #       #     # 
#  ####### #        #####  
#
################################



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

    mkdir -p "/data/$USER"
    ln -s "/data/$USER" "$HOME/data"


    # Lets add an L2ARC cache so we can have fast reads
    # shellcheck disable=SC2010
    ls /dev/disk/by-id/ -al | grep nvme2n1

    #/dev/nvme1n1               1.9T  1.6T  239G  88% /media/joncrall/flash1
    

    #nvme1n1             259:3    0   1.8T  0 disk /media/joncrall/flash1
    #nvme2n1             259:4    0   1.8T  0 disk 
    #lrwxrwxrwx 1 root root  13 Apr  6 11:46 nvme-Samsung_SSD_970_EVO_Plus_2TB_S59CNM0RB05028D -> ../../nvme1n1
    #lrwxrwxrwx 1 root root  13 Apr  6 11:46 nvme-Samsung_SSD_970_EVO_Plus_2TB_S59CNM0RB05113H -> ../../nvme2n1

    ls -al /dev/disk/by-uuid/67adab3b-5ea6-45c7-9bd7-cbfe5ea57abc
    ls /dev/disk/by-id/nvme-Samsung_SSD_970_EVO_Plus_2TB_S59CNM0RB05113H

    ls -al /dev/disk/by-id
    ls -al /dev/disk/by-uuid/
    
    POOL_NAME=data
    CACHE_DISK=/dev/disk/by-id/nvme-Samsung_SSD_970_EVO_Plus_2TB_S59CNM0RB05113H
    ls -al $CACHE_DISK
    sudo zpool add $POOL_NAME cache $CACHE_DISK


}

zfs-configure-memory(){
    # https://linuxhint.com/configure-zfs-cache-high-speed-io/

    python -c "import pint; print(pint.UnitRegistry().parse_expression('32GiB').to('bytes'))"
    python -c "import pint; print(pint.UnitRegistry().parse_expression('48GiB').to('bytes'))"

    python -c "import pint, sys; print(pint.UnitRegistry().parse_expression(sys.argv[1]).to(sys.argv[2]).m)" "48GiB" "bytes"
    python -c "import pint, sys; print(pint.UnitRegistry().parse_expression(sys.argv[1]).to(sys.argv[2]).m)" "80GiB" "bytes"

    source "$HOME"/local/init/utils.sh
    cat /etc/modprobe.d/zfs.conf
    sudo_appendto /etc/modprobe.d/zfs.conf "
    options zfs zfs_arc_max=85899345920
    "
}

zfs-clear-errors(){
    zpool status
    # If you get ZFS checksum errors, but SMART says the HDD is ok, you might
    # have just had a hickup. You can clear the errors.  If they come back
    # fairly quickly then you probably do have a bad drive.
    sudo zpool clear data
}

zfs-scrub(){

    zpool status
    zpool scrub data

}


zfs-setup-info(){
    set -x
    lsblk --scsi --output NAME,KNAME,TYPE,SIZE,STATE | grep disk
    zpool list
    zpool status
    zpool iostat -v
    set +x
}


handle_faulted_drive(){
    __doc__="
    https://serverfault.com/questions/1022292/could-zpool-status-be-showing-two-different-drives-with-same-device-name
    https://serverfault.com/questions/897108/zpool-reporting-same-drive-as-active-and-spare

    ls /dev/disk/by-id/
    "
    # I have a case where sda faulted
    FAULTED_DEVNAME=sda
    POOL_NAME=data
    # Disable faulted drive
    sudo zpool offline "$POOL_NAME" "$FAULTED_DEVNAME"

    # Make sure you have the import by id references

    # When the drive is replaced
    FAULTED_DEVNAME=sdd
    POOL_NAME=data
    sudo zpool replace "$POOL_NAME" "$FAULTED_DEVNAME"

    OLD_DISK_ID=sda
    NEW_DISK_ID=wwn-0x5000c5009399acab
    POOL_NAME=data
    sudo zpool replace "$POOL_NAME" "$OLD_DISK_ID" "$NEW_DISK_ID"
}


zfs_fix_replace_sdx_names_with_id_names(){
    sudo umount /data
    #zfs unmount $POOL_NAME

    # This removes the pool from the ZFS system!
    # But the disks themselves will remember that they were part of a pool.
    POOL_NAME=data
    sudo zpool export $POOL_NAME

    # It's not there anymore
    zpool status

    # This searches the actual disks for zpools they are part of and imports them
    sudo zpool import -d /dev/disk/by-id -aN

    OLD_DISK_ID=sda
    NEW_DISK_ID=wwn-0x5000c5009399acab
    POOL_NAME=data
    sudo zpool replace "$POOL_NAME" "$OLD_DISK_ID" "$NEW_DISK_ID"

    # Remount the pool
    sudo zpool mount "$POOL_NAME"
    
}



zfs_l2arc_calculation(){

    RECORDSIZE=$(zfs get recordsize data -o value | tail -n 1)
    echo "RECORDSIZE = $RECORDSIZE"

    __doc__="
    import pint
    u = pint.UnitRegistry()
    expr = u.parse_expression

    RAM_per_block = expr('400 bytes')

    blocksize = expr('128 KiB')
    l2arc_size = expr('2 TiB')

    l2arc_blocks = (l2arc_size / blocksize).to_base_units()

    RAM_for_l2arc = (l2arc_blocks * RAM_per_block).to('GiB')
    print(f'{RAM_for_l2arc=}')
    "
}

zfs_tuning(){
    # https://github.com/openzfs/zfs/discussions/13342
    arc_summary -d | more

    cat /sys/module/zfs/parameters/l2arc_write_max


    # Fill ARC
    pyblock "
    import ubelt as ub
    root = ub.Path('.')

    prog = ub.ProgIter()
    prog.start()
    for r, ds, fs in root.walk():
        for f in fs:
            p = r / f
            with open(p, rb') as file:
                prog.step()
                _ = file.read()

    "



}
