# Must be run as sudo


# not sure why there is a /usr/local/share and a /usr/share
sudo mkdir /usr/local/share/fonts/truetype
sudo mkdir /usr/share/fonts/truetype

sudo cp ~joncrall/.fonts/* /usr/local/share/fonts/truetype/
sudo cp ~joncrall/.fonts/* /usr/local/share/fonts

sudo cp ~joncrall/.fonts/* /usr/share/fonts/truetype/
sudo cp ~joncrall/.fonts/* /usr/share/fonts/

sudo chown root /usr/share/fonts/truetype/*.ttf
sudo chown root /usr/local/share/fonts/truetype/*.ttf

ls -al /usr/local/share/fonts

sudo fc-cache

sudo cp ~/Dropbox/Installers/Fonts/*.ttf /usr/local/share/fonts/truetype
