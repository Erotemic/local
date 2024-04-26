#!/bin/bash
__doc__="
This logic is for formating and mounting a new drive. This handles:

* formatting the disk with a filesystem (btrfs)
* adding it to fstab
* creating the mount point
* mounting it
* modifying directory permissions so all new folders should default to the smart group
"

# Output info about file systems to determine which disk devices to format
lsblk -fs
lsblk | grep disk
ls -al /dev/disk/by-id
ls -al /dev/disk/by-uuid

#################
# CONFIGURATION #
#################

# TODO: allow user to specify config with reasonable suggestions

# Configure what device, filesystem, and mountpoint to use
DEVICE_DPATH=/dev/disk/by-id/scsi-35000000000000001

# Choose urive name location
MOUNT_NAME="flash"
MOUNT_DPATH=/$MOUNT_NAME

# Choose drive ownership
MOUNT_OWNER=$USER
MOUNT_GROUP=$USER

# Choose a filesystem
#FS_FORMAT="f2fs"   Dont use F2FS, inodes are too low
FS_FORMAT="ext4"
#FS_FORMAT="btrfs"


#########
# LOGIC #
#########

# Install the relevant packages to use the requested filesystem
if [[ "$FS_FORMAT" == "btrfs" ]]; then
    # Use btrfs instead
    sudo apt install btrfs-progs -y
elif [[ "$FS_FORMAT" == "ext4" ]]; then
    echo "Ext4 should be preinstalled"
elif [[ "$FS_FORMAT" == "f2fs" ]]; then
    # Install packages for the f2fs filesystem
    ## NOTE: flashfs inode usage is a bit constraining
    # https://github.com/archlinux/archinstall/issues/771
    # F2FS (Flash-Friendly File System)
    # https://en.wikipedia.org/wiki/F2FS
    # https://www.phoronix.com/scan.php?page=news_item&px=Linux-5.14-File-Systems
    sudo apt-get install f2fs-tools -y  #
else
    echo "Unknown FS_FORMAT" || exit 1
fi

# Force Unmount if necessary
#sudo fuser -km $DEVICE_DPATH
sudo umount $DEVICE_DPATH

# Format device filesystem
if [[ "$FS_FORMAT" == "ext4" ]]; then
    # no -f
    sudo mkfs -t "$FS_FORMAT" "$DEVICE_DPATH"
else
    # Works for btrfs, not sure about others
    sudo mkfs -t "$FS_FORMAT" -f "$DEVICE_DPATH"
fi


# Create mount point with group permissions
sudo mkdir -p "$MOUNT_DPATH"
sudo chown "$MOUNT_OWNER":"$MOUNT_GROUP" "$MOUNT_DPATH"

# Setup fstab to auto-mount the device on startup (if it doesnt exist)
FSTAB_LINE="${DEVICE_DPATH}  ${MOUNT_DPATH}              $FS_FORMAT    defaults        0 0  # from flash setup script"
grep "^$FSTAB_LINE" /etc/fstab || sudo sh -c "echo '$FSTAB_LINE' >> /etc/fstab"

# Mount the device if the mount point exists, but the device is unmounted
if [ -d $MOUNT_DPATH ]; then
    mountpoint "$MOUNT_DPATH"
    EXITCODE=$?
    if [ $EXITCODE -ne 0 ]; then
        # Mount the device right now
        sudo mount "$DEVICE_DPATH" "$MOUNT_DPATH"
    else
        echo "Device is already mounted"
    fi
else
    echo "Mount point does not exist"
fi


#### OPTIONAL
# After mounting set the owner and permissions

# Reset the owner on the mounted filesystem
sudo chown "$MOUNT_OWNER":"$MOUNT_GROUP" "$MOUNT_DPATH"
# Set group and user permissions to be permissive
# Restrict other permissions
sudo chmod ug+srwx $MOUNT_DPATH
sudo chmod o-rwx $MOUNT_DPATH

# Set file access control lists (ACL) so new directories and files are group read/write by default
# https://unix.stackexchange.com/questions/12842/make-all-new-files-in-a-directory-accessible-to-a-group
# Note: not all filesystems support ACL
sudo setfacl -d -m "group:${MOUNT_GROUP}:rwx" "$MOUNT_DPATH"
sudo setfacl -m "group:${MOUNT_GROUP}:rwx" "$MOUNT_DPATH"


__notes__='
# To Unmount
sudo umount $MOUNT_DPATH
'

# https://unix.stackexchange.com/questions/176666/how-do-i-know-acls-are-supported-on-my-file-system
#tune2fs -o acl /dev/nvme0n1
#grep acl /etc/mke2fs.conf
