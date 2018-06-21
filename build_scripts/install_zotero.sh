#mkdir ~/tmp
#cd ~/tmp
#wget http://download.zotero.org/standalone/4.0.11/Zotero-4.0.11_linux-x86_64.tar.bz2

#tar jxf Zotero-4.0.11_linux-x86_64.tar.bz2

#chmod +x Zotero_linux-x86_64
#./Zotero_linux-x86_64

#/tmp/zotero_installer.sh
#/tmp/zotero_installer.sh


mkdir -p ~/tmp
cd ~/tmp

source $HOME/local/init/utils.sh
pyblock """
import requests
req = requests.get('https://www.zotero.org/download/client/dl?channel=release&platform=linux-x86_64&version=5.0.49')
with open('zotero.tar.bz2', 'wb') as file:
    file.write(req.content)
"""
tar jxf zotero.tar.bz2
mkdir -p ~/.local/opt/
mv Zotero_linux-x86_64 ~/.local/opt/
~/.local/opt/Zotero_linux-x86_64/set_launcher_icon
ln -s ~/.local/opt/Zotero_linux-x86_64/zotero.desktop ~/.local/share/applications/


##https://forums.zotero.org/discussion/25317/install-zotero-standalone-from-ubuntu-linux-mint-ppa/%5d
#sudo add-apt-repository ppa:smathot/cogscinl
#sudo apt-get update
#sudo apt-get install zotero-standalone

#sudo add-apt-repository ppa:smathot/cogscinl
#sudo apt-get update
#sudo apt-get install zotero-standalone

#sudo apt-get install qnotero
