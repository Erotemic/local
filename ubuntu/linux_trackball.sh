# http://superuser.com/questions/374504/configure-a-trackball-under-linux-without-editing-xorg-conf

/etc/X11/xorg.conf.d/10-evdev.conf


Section "InputClass"
    Identifier "Marble Mouse"
    Driver "evdev"
    MatchProduct "Logitech USB Trackball"
    MatchDevicePath "/dev/input/event*"
    MatchIsPointer "yes"
    Option "ButtonMapping" "1 9 3 4 5 6 7 2 8"
    Option "EmulateWheel" "true"
    Option "EmulateWheelButton" "3"
    Option "ZAxisMapping" "4 5"
    Option "XAxisMapping" "6 7"
    Option "Emulate3Buttons" "false"
EndSection


# http://unix.stackexchange.com/questions/40655/applying-changes-to-xorg-conf-without-restarting


