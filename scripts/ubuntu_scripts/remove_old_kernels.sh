#"""
#References:
#    http://askubuntu.com/questions/89710/how-do-i-free-up-more-space-in-boot
#"""


# Show removable kernels
kernelver=$(uname -r | sed -r 's/-[a-z]+//')
dpkg -l linux-{image,headers}-"[0-9]*" | awk '/ii/{print $2}' | grep -ve $kernelver
