sudo apt-get update -y 
sudo apt-get upgrade -y


# Git
sudo apt-get install git -y

# Vim
sudo apt-get install vim -y
sudo apt-get install vim-gtk -y
 
# Trash put
sudo apt-get install trash-cli

# Google PPA
wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
sudo sh -c 'echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list'
sudo apt-get update
# Google Chrome
sudo apt-get install google-chrome-stable -y


# Dropbox 
cd ~/tmp && wget -O - "https://www.dropbox.com/download?plat=lnx.x86_64" | tar xzf -
.dropbox-dist/dropboxd


sudo apt-get install gparted -y
sudo apt-get install openssh-server
