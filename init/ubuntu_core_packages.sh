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
sudo apt-get install htop -y
sudo apt-get install openssh-server -y
sudo apt-get install python-tk -y
sudo apt-get install screen -y
sudo apt-get install synaptic -y
sudo apt-get install okular -y
sudo apt-get install tree -y

# Zotero
sudo add-apt-repository ppa:smathot/cogscinl
sudo apt-get update
sudo apt-get install zotero-standalone -y
 

# Latex
#sudo apt-get install texlive-base -y
#sudo apt-get install texlive -y
#sudo apt-get install texlive-bibtex-extra -y
#sudo apt-get install texlive-full -y


sudo pip install jedi
sudo pip install line_profiler

# Cleanup
#sudo apt-get remove jasper -y

