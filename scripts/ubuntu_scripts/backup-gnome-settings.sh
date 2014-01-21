cd ~
mkdir .old-gnome-config
mkdir .old-gnome-config/.config
mkdir .old-gnome-config/.config/dconf

mv .gnome* .old-gnome-config/ 

mv .gconf* .old-gnome-config/ 

mv .metacity .old-gnome-config/ 

mv .cache .old-gnome-config/ 

mv .dbus .old-gnome-config/ 

mv .dmrc .old-gnome-config/ 

mv .mission-control .old-gnome-config/ 

mv .thumbnails .old-gnome-config/   

mv .config/dconf/* .old-gnome-config/.config/dconf

# Remove the old settings now
rm -rf .gnome .gnome2 .gconf .gconfd .metacity .cache .dbus .dmrc .mission-control .thumbnails ~/.config/dconf/user ~.compiz*

