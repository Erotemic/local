# References
# https://www.icc-usa.com/raid-calculator
# https://www.tecmint.com/create-raid-10-in-linux/
# https://superuser.com/questions/610538/convert-raid-1-to-raid-10-in-mdadm
# https://serverfault.com/questions/43677/best-way-to-grow-linux-software-raid-1-to-raid-10/43712#43712

# Problem References
# https://ubuntuforums.org/showthread.php?t=2327837
# https://askubuntu.com/questions/160946/mdadm-config-file
# https://www.technibble.com/forums/threads/linux-softraid-5-array-mdadm-creation-problem-anyone-know-what-to-do.36159/


# SATA Mobo Layout on ASUS P8P67 Pro (Ooo)
# Each column (chunk of 2) reads from right (on top) to left (on bottom)

#========================================================================
# MoboPort Name | Software Device |  Disk Device    |  Serial Num
#========================================================================
# ------------------------------- ----------------- ----------------- --
# SATA6G_E1     |  /dev/sde       |  Kingston SSD   |  50026B733300D0C7
# SATA6G_E2     |  /dev/sdf       |  Baracuda1-17   |  Z4Z8A5GH
# ------------------------------- ----------------- ----------------- --
# SATA6G_1      |  /dev/sda       |  Baracuda2-17   |  Z504SR71
# SATA6G_2      |  /dev/sdb       |  Baracuda3-17   |  Z4Z89N84
# ------------------------------- ----------------- ----------------- --
# SATA3G_3      |  /dev/sdc       |  Baracuda4-13   |  Z1E1V25E
# SATA3G_4      |  /dev/sdd       |  Top HDD Mount  |  <variable>
# ------------------------------- ----------------- ----------------- --
# SATA3G_4      |  /dev/sd?       |  Top ESATA Port |  <variable>
# SATA3G_5      |  /dev/sr0       |  Optical Disk   |  3743524285_2L8034501
# ------------------------------- ----------------- ----------------- --
#========================================================================


# SATA6G_E1     |  /dev/sde       |  Kingston SSD   |  50026B733300D0C7
# SATA6G_E2     |  /dev/sdf       |  Baracuda17 no1 |  Z4Z8A5GH
# ------------------------------- ----------------- ----------------- --
# SATA6G_1      |  /dev/sda       |  Baracuda17 no2 |  Z504SR71
# SATA6G_2      |  /dev/sdb       |  Baracuda17 no3 |  Z4Z89N84
# ------------------------------- ----------------- ----------------- --
# SATA3G_3      |  /dev/sdc       |  Baracuda13 no4 |  Z1E1V25E


resetup_raid_after_os_reinstall()
{
    # https://ubuntuforums.org/showthread.php?t=2002217
    # if you reinstalled your OS you just need to tell the system about the
    # raid to get things working again
    sudo apt-get install gdisk mdadm rsync -y
    # Simply scan for your preconfigured raid
    sudo mdadm --assemble --scan
    # Mount the RAID (temporary. modify fstab to automount)
    sudo mkdir -p /media/joncrall/raid
    sudo mount /dev/md0 /media/joncrall/raid
    # Modify fstab so RAID auto-mounts at startup
    sudo sh -c "echo '# appended to fstab by by install scripts' >> /etc/fstab"
    sudo sh -c "echo 'UUID=4bf557b1-cbf7-414c-abde-a09a25e351a6  /media/joncrall/raid              ext4    defaults,noatime        0 0' >> /etc/fstab"

    sudo ln -s /media/joncrall/raid /raid
}



# Show all devices wheter or not they are mounted
lsblk
cat /proc/scsi/scsi
lsblk --scsi
lsblk --scsi --output NAME,KNAME,LABEL,MOUNTPOINT,UUID,PARTTYPE,PARTUUID,MODEL,TYPE,SIZE,STATE | grep disk
lsblk --output-all


lsblk --scsi
# sda  0:0:0:0    disk ATA      ST2000DM006-2DM1 CC26 sata
# sdb  1:0:0:0    disk ATA      ST2000DM006-2DM1 CC26 sata
# sdc  2:0:0:0    disk ATA      ST2000DM001-1CH1 CC24 sata
# sde  9:0:0:0    disk ATA      ST2000DM006-2DM1 CC26 sata

# sdd  8:0:0:0    disk ATA      KINGSTON SH103S3 BBF0 sata



# Define disks (represents unique hard drives connected to the motherboard)
DISK1=/dev/sde
DISK2=/dev/sda
DISK3=/dev/sdb
DISK4=/dev/sdc

# Define disk partitions (typically on per hard drive)
PART1="$DISK1"1
PART2="$DISK2"1
PART3="$DISK3"1
PART4="$DISK4"1

echo $PART1
echo $PART2
echo $PART3
echo $PART4

RAID_DISKS="$DISK1 $DISK2 $DISK3 $DISK4"
RAID_PARTS="$PART1 $PART2 $PART3 $PART4"

# Check for existing RAIDs
sudo mdadm --examine $RAID_DISKS

# Ensure each drive has formatted partions
# I did this through gparted
# Formated everything with a GPT (guid partition table) and added the raid flag

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
sudo mkfs.ext4 /dev/md0

# Create mount point
sudo mkdir /media/joncrall/raid
sudo mount /dev/md0 /media/joncrall/raid/
ls -l /media/joncrall/raid/

# make symlink that I like
sudo ln -s /media/joncrall/raid /raid

# Check reads/writes work
touch /mnt/raid/raid_files.txt
ls -l /mnt/raid/
echo "raid 10 setup with 4 disks" > /mnt/raid/raid_files.txt
cat /mnt/raid/raid_files.txt

# Write mdadm config
sudo sh -c 'sudo mdadm --detail --scan >> /etc/mdadm/mdadm.conf'

# Update the initramfs (Initial-RAM-filesystem)
# (forgot to do this the first time)
sudo update-initramfs -u


# -----
# FIXES


# my raid was id-ed as 127 because I did not do the conf file properly
sudo mdadm --detail /dev/md127 | grep UUID
#
# UUID : b991b178:dd820492:3502ef74:5d527f6a
sudo mdadm --detail /dev/md0


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
