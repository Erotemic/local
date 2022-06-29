move_hdd(){
    # BROKEN
    # https://www.linux.com/learn/clone-your-ubuntu-installation-new-hard-disk
    # https://help.ubuntu.com/community/MovingLinuxPartition
    # https://suntong.github.io/blogs/2015/12/26/creating-gpt-partitions-easily-on-the-command-line/
    # https://www.rodsbooks.com/gdisk/sgdisk-walkthrough.html 
    # https://askubuntu.com/questions/741723/moving-entire-linux-installation-to-another-drive


    # Scan the hard disks and list their partitions
    sudo fdisk -l


    sudo apt install gddrescue -y

    echo "OLD_DISK = $OLD_DISK"
    echo "NEW_DISK = $NEW_DISK"

    sudo ddrescue -v "$OLD_DISK" "$NEW_DISK"


    # I opened gparted
    # I created a new GDP partition table (that erased all data on the drive)


    # Dump the partition table of the old disk
    cd ~/tmp
    #sudo sfdisk -l "$OLD_DISK" > old_disk_partinfo.txt

    cat old_disk_partinfo.txt

    NEW_DISK=/dev/sdf
    echo "OLD_DISK = $OLD_DISK"
    sudo sfdisk $NEW_DISK


    echo "NEW_DISK = $NEW_DISK"

    # DEFINE which disk we are going to clober
    OLD_DISK=/dev/sdd
    NEW_DISK=/dev/sdf

    # Create a new GDP partition table.
    # Use -Z to zap (erase) all the data on the drive
    sudo sgdisk -Z $NEW_DISK

    # Create new paritions with -n, -t, and -c
    # ------------------------
    #     -n, --new=partnum:start:end                 create new partition
    #     -t, --typecode=partnum:{hexcode|GUID}       change partition type code
    #     -c, --change-name=partnum:name              change partition's name
    #
    # Notes: 
    #     Boot disks for EFI-based systems require an EFI System Partition (sgdisk
    #     internal code 0xEF00) formatted as FAT-32. The recommended size of this
    #     partition is between 100 and 300 MiB. Boot-related files are stored here.
    #     (Note that GNU Parted identifies such partitions as having the "boot
    #     flag" set.)

    # Enumerate some common typecodes
    BOOT_EFI_FAT32=ef00
    LINUX_SWAP=8200
    LINUX_FILESYSTEM=8300
    # we wont use these, but for reference
    BOOT_BIOS=ef02
    MS_RESERVE=0c01
    WINDOWS_FILESYSTEM=0700

    # Create the boot partition with 512 MB at the start of the disk
    sudo sgdisk -n 0:0:+512M -t 0:$BOOT_EFI_FAT32   -c 0:"boot"   $NEW_DISK
    # Use all but the last 8GB of space for the main filesystem
    sudo sgdisk -n 0:0:-8G   -t 0:$LINUX_FILESYSTEM -c 0:"system" $NEW_DISK
    # USe the last 8GB of space for disk swap
    sudo sgdisk -n 0:0:0     -t 0:$LINUX_SWAP       -c 0:"swap"   $NEW_DISK

    # print what we did
    sudo sgdisk -p $NEW_DISK

    # I did do a mkfs.ext4 -F -L "" ${NEW_DISK}2 using gparted to fix a warning
    sudo mkfs.ext4 -F -L "" ${NEW_DISK}2

    # inform the OS of partition table changes
    sudo partprobe $NEW_DISK

    # Mount the new disk to copy data onto it
    sudo mkdir -p /mnt/new_disk1
    sudo mkdir -p /mnt/new_disk2
    sudo mount ${NEW_DISK}1 /mnt/new_disk1
    sudo mount ${NEW_DISK}2 /mnt/new_disk2

    # Copy the system on the old hard drive onto the new one
    sudo rsync -aAXvP /* /mnt/new_disk2 --exclude={/dev/*,/proc/*,/sys/*,/tmp/*,/var/tmp/*,/run/*,/mnt/*,/media/*,/lost+found}

    # Install grub on the new disk
    echo "installing grub on NEW_DISK = $NEW_DISK"
    sudo grub-install $NEW_DISK

    # We need to modify fstab on the new disk, because the UUIDs have changed

    # For each old partition, we need to modify its mount UUID in fstab

    find_uuid_column(){
        # Helper script to find a UUID column
        python -c "$(codeblock "
        import sys
        for part in sys.stdin.read().split(' '):
            if part.startswith('UUID'):
                print(part[6:-1])
        ")" $@
    }

    echo "OLD_DISK = $OLD_DISK"
    echo "NEW_DISK = $NEW_DISK"

    OLD_UUID1=$(blkid | grep "${OLD_DISK}1" | find_uuid_column)
    OLD_UUID2=$(blkid | grep "${OLD_DISK}2" | find_uuid_column)
    OLD_UUID3=$(blkid | grep "${OLD_DISK}3" | find_uuid_column)

    NEW_UUID1=$(blkid | grep "${NEW_DISK}1" | find_uuid_column)
    NEW_UUID2=$(blkid | grep "${NEW_DISK}2" | find_uuid_column)
    NEW_UUID3=$(blkid | grep "${NEW_DISK}3" | find_uuid_column)

    # Replace the old UUIDs with the new ones in the new fstab file
    sudo sed -i "s/$OLD_UUID1/$NEW_UUID1/" /mnt/new_disk2/etc/fstab
    sudo sed -i "s/$OLD_UUID2/$NEW_UUID2/" /mnt/new_disk2/etc/fstab
    sudo sed -i "s/$OLD_UUID3/$NEW_UUID3/" /mnt/new_disk2/etc/fstab

    cat /mnt/new_disk2/etc/fstab | grep "$OLD_UUID1" 
    cat /mnt/new_disk2/etc/fstab | grep "$OLD_UUID2" 
    cat /mnt/new_disk2/etc/fstab | grep "$OLD_UUID3" 

    cat /mnt/new_disk2/etc/fstab | grep "$NEW_UUID1" 
    cat /mnt/new_disk2/etc/fstab | grep "$NEW_UUID2" 
    cat /mnt/new_disk2/etc/fstab | grep "$NEW_UUID3" 
}
