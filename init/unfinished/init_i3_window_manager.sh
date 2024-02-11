#!/usr/bin/env bash

sudo apt-get install i3

#sudo mv /usr/share/xsessions/gnome-i3.desktop /usr/share/xsessions/gnome-i3.desktop.old

sudo echo "[Desktop Entry]
Name=GNOME with i3
Comment=A GNOME fallback mode session using i3 as the window manager.
Exec=gnome-session --session=i3
TryExec=gnome-session
Icon=
Type=Application
" > /usr/share/xsessions/gnome-i3.desktop



sudo echo "[GNOME Session]
Name=gnome-i3
RequiredComponents=gnome-settings-daemon;gnome-panel;i3;
" > /usr/share/gnome-session/sessions/i3.session

