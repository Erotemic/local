#!/usr/bin/env bash
__doc__="
Based on benchmarks, it might be faster to use btrfs for a RAID-10 solution on
an older machine.

Benchmarks:
    .. [FSBench2018] https://www.phoronix.com/review/freebsd-12-zfs
    .. [FSBench2015] https://www.diva-portal.org/smash/get/diva2:822493/FULLTEXT01.pdf

References:
    https://linuxhint.com/install-and-use-btrfs-on-ubuntu-lts/
    https://www.moocowproductions.org/2014/12/04/fully-online-raid1-to-raid10-migration-using-btrfs/
    https://unix.stackexchange.com/questions/457603/convert-btrfs-raid10-to-raid0
    https://btrfs.wiki.kernel.org/index.php/Using_Btrfs_with_Multiple_Devices
    https://linuxhint.com/install-and-use-btrfs-on-ubuntu-lts/
    https://blog.programster.org/btrfs-cheatsheet
"

sudo apt update
sudo apt install btrfs-progs -y

#mkfs.btrfs -d single /dev/sdb /dev/sdc /dev/sdd /dev/sde

# List disks
lsblk -e7
lsblk --scsi --output NAME,KNAME,LABEL,MOUNTPOINT,UUID,PARTTYPE,PARTUUID,MODEL,TYPE,SIZE,STATE | grep disk
lsblk --output NAME,FSTYPE,KNAME,LABEL,MOUNTPOINT,UUID,PARTTYPE,PARTUUID,MODEL,TYPE,SIZE,STATE | grep disk

# Find the ones we want to use
# On OOO start out with
#sda  sda                                           ST10000DM0004-1ZC101      disk   9.1T running
#sdc  sdc                                           ST10000DM0004-1ZC101      disk   9.1T running


# Make a btrfs system on the chosen disks
DISK1=/dev/sda
DISK2=/dev/sdc

sudo parted "$DISK1" mktable gpt                            # Create the GPT
sudo parted "$DISK1" mkpart primary btrfs 0% 100%           # Create the partition
sudo parted "$DISK2" mktable gpt                            # Create the GPT
sudo parted "$DISK2" mkpart primary btrfs 0% 100%           # Create the partition

# We now have parts
PART1=/dev/sda1
PART2=/dev/sdc1
sudo mkfs.btrfs -d raid1 $PART1 $PART2

# Make mount location
sudo mkdir -v /data
sudo chmod 777 /data

# Mount any btrfs device
sudo mount $PART1 /data

sudo btrfs filesystem show

sudo btrfs filesystem usage /data
sudo btrfs filesystem du /data
sudo btrfs filesystem df /data
sudo btrfs filesystem du -s /data


# Migrate data
sudo rsync -avprPR /raid/ /data


##Rebooted

# Now we need to add the other two disks (first two disks changed label?)
DISK1=/dev/sda
DISK2=/dev/sdb
PART1=/dev/sda1
PART2=/dev/sdb1


# Mount original data
sudo mount $PART1 /data
btrfs filesystem df /data


sudo btrfs filesystem show

DISK3=/dev/sdc
DISK4=/dev/sde
# Format the new disks
#sdc    sdc ST10000DM0004-1ZC101      disk   9.1T running
#sde    sde ST10000DM0004-1ZC101      disk   9.1T running
sudo parted "$DISK3" mktable gpt                            # Create the GPT
sudo parted "$DISK3" mkpart primary btrfs 0% 100%           # Create the partition
sudo parted "$DISK4" mktable gpt                            # Create the GPT
sudo parted "$DISK4" mkpart primary btrfs 0% 100%           # Create the partition
#└─sdc1 sdc1                                                                                           0fc63daf-8483-4772-8e79-3d69d8477de4 9a9e2c5c-9b3c-419a-88d2-05255d8255e4                           part   9.1T
#└─sde1 sde1                                                                                           0fc63daf-8483-4772-8e79-3d69d8477de4 28297476-5a88-4eeb-a8aa-4298029dcb34                           part   9.1T

PART3=/dev/sdc1
PART4=/dev/sde1

# Add new partitions to the mount point
sudo btrfs device add $PART3 $PART4 /data -f


# Convert to RAID10
sudo btrfs balance start -dconvert=raid10 -mconvert=raid10 /data



### Monitor
sudo watch btrfs device stats /data/
sudo watch btrfs filesystem show
sudo watch btrfs filesystem df /data
sudo watch btrfs balance status /data/

sudo apt install sysstat
iostat -m -d 2 /dev/sd*1

# Add to fstab
lsblk --fs  /dev/sda1

# UUID=e5b5c118-fb56-4fad-a45d-ff5fad9a649d /data           btrfs   defaults,noatime      0  0
sudo sh -c "echo '# appended to fstab by by install scripts' >> /etc/fstab"
sudo sh -c "echo 'UUID=c34b5d87-a4bf-428d-8738-7c759534da1a  /data              btrfs    defaults,noatime        0 0' >> /etc/fstab"


fix_disk_failure_2025_02_27(){
    # 2025-02-27 -
    # Found a disk failure. sde is reporting end-to-end errors.
    # Also: btrfs is reporting issues
    #sudo btrfs device stats /dev/sde1
    #[/dev/sde1].write_io_errs    15215348
    #[/dev/sde1].read_io_errs     202792
    #[/dev/sde1].flush_io_errs    223392
    #[/dev/sde1].corruption_errs  10
    #[/dev/sde1].generation_errs  0

    # References:
    # https://wiki.tnonline.net/w/Btrfs/Replacing_a_disk

    sudo btrfs device scan
    sudo btrfs filesystem show

    sudo btrfs check --readonly /dev/sda1
    __result__="
    Opening filesystem to check...
    warning, device 4 is missing
    Checking filesystem on /dev/sda1
    UUID: c34b5d87-a4bf-428d-8738-7c759534da1a
    [1/7] checking root items
    [2/7] checking extents
    "
    __note__="
    NOTE: This seemed to crash the terminal, probably due to OOM.
    "


    # Mount the array in a degraded state
    sudo mount -o degraded,ro /dev/sda /data
    # The above did not seem to work. I got errors.
    __result__="
    mount: /data: wrong fs type, bad option, bad superblock on /dev/sda, missing codepage or helper program, or other error.
    "
    __note__="
    I physically removed sde and tried several things
    "

    # The superblocks seemed to have been damaged, but this did seem to work!
    sudo mount -o degraded,ro,usebackuproot /dev/sda1 /data

    # BACK UP STUFF

    # Now unmount, and mount in degraded rw mode
    sudo umount /data
    sudo mount -o degraded,rw,usebackuproot /dev/sda1 /data

    # We need to mount the new disk **before** removing the old bad device from
    # the array. This will allow btrfs to maintain RAID-10 redundancy
    NEW_DISK=/dev/sde
    NEW_PART=/dev/sde1
    sudo parted "$NEW_DISK" mktable gpt
    sudo parted "$NEW_DISK" mkpart primary btrfs 0% 100%
    sudo btrfs device add "$NEW_PART" /data

    # Rebalance the array
    sudo btrfs balance start -dconvert=raid10 -mconvert=raid10 /data

    # Monitor the rebalance process
    sudo btrfs device stats /data
    sudo dmesg -w
    sudo btrfs filesystem show
    sudo btrfs balance status /data
    sudo iotop -o
    sudo iostat -x 1

    sudo "$(which tmux_multi_monitor.sh)" \
        "dmesg -w" \
        "watch btrfs balance status /data" \
        "watch btrfs filesystem show" \
        "iostat sda sdb sdc sdd sde -x 1" \
        "watch btrfs filesystem df /data -g"

    # Now with the bad disk removed, tell btrfs to remove it
    sudo btrfs device delete missing /data

    # Verify device removal
    sudo btrfs filesystem show


}


replace_disk_2025_03_02(){
    __doc__="
    Now that the system is back up, we are going to replace one of the good
    10TB disks with a 16TB disk to match the other 16TB disk used to replace
    the old /dev/sde. (side note: still not sure how the order of sda/b/c gets
    chosen). To do this, I've removed the data disk from the drive,
    disconnected the drive we are going to remove, and added the new drive. So
    the rest of this should be a software exercise.
    "

    # Mount in degraded rw mode (this is taking an unusually long time, but it
    # worked) It also looks like I should check the superblock once I rebuild
    # again
    sudo mount -o degraded,rw,usebackuproot /dev/sda1 /data

    # Format and add the new disk to the array.
    NEW_DISK=/dev/sdc
    NEW_PART=/dev/sdc1
    sudo parted "$NEW_DISK" mktable gpt
    sudo parted "$NEW_DISK" mkpart primary btrfs 0% 100%
    sudo btrfs device add "$NEW_PART" /data

    # Rebalance the array
    sudo btrfs balance start -dconvert=raid10 -mconvert=raid10 /data
}
