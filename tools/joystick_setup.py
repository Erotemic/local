"""
References:
    https://unix.stackexchange.com/questions/197729/udev-keyboard-remapping-with-hwdb-for-secondary-keyboards
    https://www.foell.org/justin/remapping-keyboard-keys-in-ubuntu-with-udev-evdev/

https://manpages.ubuntu.com/manpages/trusty/man1/evtest.1.html
https://www.kernel.org/doc/Documentation/input/event-codes.txt


sudo apt install evtest evemu-tools


ls -al /dev/input
ls -al /dev/input/by-id/

# N64 controller with hyperkin adapter
ls -al /dev/input/by-id/usb-20d6_WUP-028-event-joystick

# xbox 360 controller
ls -al /dev/input/by-id/usb-*Microsoft*-event-joystick

N64_DEV=/dev/input/by-id/usb-20d6_WUP-028-event-joystick
XB360_DEV=/dev/input/by-id/usb-*Microsoft*-event-joystick

evemu-describe "$N64_DEV"
evemu-describe $XB360_DEV

evtest --grab "$N64_DEV"
evtest --grab "$XB360_DEV"

/usr/include/libusb-1.0/libusb.h
/home/joncrall/.pyenv/versions/3.10.5/envs/pyenv3.10.5/lib/python3.10/site-packages/libusb/__init__.py



#### Try to get raw usb permission with udev
https://stackoverflow.com/questions/22713834/libusb-cannot-open-usb-device-permission-isse-netbeans-ubuntu
"""


def add_udev_permission_rule_n64():
    """
    cat /etc/udev/rules.d/80-wup028.rules

    cd /lib/udev/rules.d
    cat /lib/udev/rules.d/69-wacom.rules
    cat /lib/udev/rules.d/70-joystick.rules
    """
    import ubelt as ub
    dest_dpath = ub.Path('/etc/udev/rules.d')

    dest_fpath = dest_dpath / '80-wup028.rules'
    owner = ub.Path.home().name
    id_vendor = '20d6'
    id_product='a710'
    rule = ub.codeblock(
        f'''
        SUBSYSTEM=="usb", ATTRS{{idVendor}}=="{id_vendor}", ATTRS{{idProduct}}=="{id_product}", MODE="0666", OWNER="{owner}"'
        SUBSYSTEM=="usb_device", ATTRS{{idVendor}}=="{id_vendor}", ATTRS{{idProduct}}=="{id_product}", MODE="0666", OWNER="{owner}"'
        ''') + chr(10)
    # SUBSYSTEM=="usb", ATTRS{idVendor}=="1234", MODE="0666"
    # SUBSYSTEM=="usb_device", ATTRS{idVendor}=="1234", MODE="0666"

    import tempfile
    temp_fpath = ub.Path(tempfile.mktemp())
    temp_fpath.write_text(rule)

    ub.cmd(f'sudo cp {temp_fpath} {dest_fpath}', verbose=3, shell=1)
    ub.cmd('sudo udevadm control --reload-rules', verbose=3, shell=1)


import libusb
import ctypes as ct
import libusb as usb

# https://libusb.readthedocs.io/en/latest/
libusb.config(LIBUSB=None)  # included libusb-X.X.* will be used
# devlist_type = ct.POINTER(ct.POINTER(ct.POINTER(libusb.device)))
# devlist = devlist_type()
# libusb.get_device_list(None, devlist)

ctx = ct.POINTER(usb.context)()
r = usb.init(ct.byref(ctx))
assert r == usb.LIBUSB_SUCCESS

device_list_type = ct.POINTER(ct.POINTER(usb.device))

device_list = device_list_type()
list_size = usb.get_device_list(ctx, ct.byref(device_list))

for i in range(list_size):
    desc = usb.device_descriptor()
    desc_ptr = ct.POINTER(usb.device_descriptor)(desc)
    dev_ptr = device_list[i]

    usb.get_device_descriptor(dev_ptr, desc_ptr)
    print(f'{desc.idVendor:04x}:{desc.idProduct:04x}')

    dev_handle_ptr = ct.POINTER(usb.device_handle)()
    status = libusb.open(dev_ptr, dev_handle_ptr)
    print(f'status={status}')
    if status == 0:
        break

    buff = ct.create_string_buffer(1024)
    usb.get_string_descriptor_ascii(dev_ptr, i, buff, len(buff))

    # printf("Vendor:Device = %04x:%04x\n", desc.idVendor, desc.idProduct);
