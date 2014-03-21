# http://samindaw.wordpress.com/2012/03/21/mounting-a-file-as-a-file-system-in-linux/

dd if=/dev/zero of=crypt32 bs=1024 count=30720
#of – parameter specifies the name of the file

#bs – size of the block (represents x KB. You can specify x MB using xM: i.e. “bs=1M”)

#count – how many blocks to be present (thus the size of the file system = bs*count)

#if – from which device the file content initially should be filled with.

# check to see if the loop back device exists yet
sudo losetup /dev/loop0
# enable disk loopback on this device
sudo losetup /dev/loop0 crypt32
# check to see if worked
sudo losetup /dev/loop0


# Format as FAT32
sudo mkfs.msdos -m 1 -v /dev/loop0


# Mount partition
sudo mount -t vfat /dev/loop0 /media
