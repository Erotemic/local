# http://www.webupd8.org/2012/10/how-to-get-complete-gnome-3-desktop-in.html

sudo apt-get install ubuntu-gnome-desktop ubuntu-gnome-default-settings
sudo dpkg-reconfigure gdm
sudo apt-get remove ubuntu-settings


sudo apt-get install gnome-documents gnome-boxes
sudo add-apt-repository ppa:gnome3-team/gnome3

#Then, launch Software Updater from Dash / menu and use it to upgrade your packages.

#The packages that will be upgraded once you add the PPA are: GNOME Control Center 3.6.3, Aisleriot 3.6.0, Brasero 3.6.0, Nautilus 3.6.3 and Totem 3.6.2. The PPA also provides Transmission 0.7.1, Transmageddon 0.23 and Sound Juicer 3.5.0.


sudo apt-get remove overlay-scrollbar*


#=---------------
# but im 12.04

sudo add-apt-repository ppa:gnome3-team/gnome3
sudo apt-get update
sudo apt-get install gnome-shell

sudo apt-get install gnome-tweak-tool


sudo add-apt-repository ppa:ricotz/testing
sudo apt-get update
sudo apt-get install gnome-shell-extensions-common


sudo apt-get update
sudo apt-get install gnome-shell gnome-tweak-tool


sudo add-apt-repository ppa:gnome3-team/gnome3

gnome-shell --version

sudo apt-get update
sudo apt-get upgrade
sudo apt-get dist-upgrade


sudo add-apt-repository ppa:upubuntu-com/gnome3
sudo apt-get update
sudo apt-get install gnome-shell-extensions


list_gnome3_extensions()
{
    echo "---"
    echo "~/.local/share/gnome-shell/extensions"
    ls ~/.local/share/gnome-shell/extensions
    echo "---"
    echo "/usr/share/gnome-shell/extensions"
    ls /usr/share/gnome-shell/extensions
}


# FIX VIM Menubar
# http://vim.wikia.com/wiki/Restore_missing_gvim_menu_bar_under_GNOME
 rm ~/.gnome2/Vim



 gtk_activate_slider_problem()
 {              
     # Injects a line into a theme file
     chmod +x ~/local/scripts/inject_line.py
     export GTK_RC_FNAME="/usr/share/themes/MediterraneanDark/gtk-2.0/gtkrc"
     export INSERT="$(echo -e "\tGtkRange\t\t\t\t::activate-slider\t\t= 1")"
     export PATTERN="GtkRange"
     sudo cp $GTK_RC_FNAME "$GTK_RC_FNAME.backup.$(date +"%s")"
     sudo ~/local/scripts/inject_line.py $PATTERN "$INSERT" $GTK_RC_FNAME
 }
