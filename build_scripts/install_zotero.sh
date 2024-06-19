#!/bin/bash
__doc__='
source ~/local/build_scripts/install_zotero.sh
'
#mkdir ~/tmp
#cd ~/tmp
#wget http://download.zotero.org/standalone/4.0.11/Zotero-4.0.11_linux-x86_64.tar.bz2

#tar jxf Zotero-4.0.11_linux-x86_64.tar.bz2

#chmod +x Zotero_linux-x86_64
#./Zotero_linux-x86_64

#/tmp/zotero_installer.sh
#/tmp/zotero_installer.sh


mkdir -p ~/tmp/setup-zotero
cd ~/tmp/setup-zotero

#https://www.zotero.org/download/client/dl?channel=release&platform=linux-x86_64&version=5.0.96.2
#req = requests.get('https://www.zotero.org/download/client/dl?channel=release&platform=linux-x86_64&version=5.0.84')
python -c "if 1:
    import requests
    req = requests.get('https://www.zotero.org/download/client/dl?channel=release&platform=linux-x86_64')
    with open('zotero.tar.bz2', 'wb') as file:
        file.write(req.content)
"
tar jxvf zotero.tar.bz2
mkdir -p ~/.local/opt/
mv Zotero_linux-x86_64 ~/.local/opt/
~/.local/opt/Zotero_linux-x86_64/set_launcher_icon
rm -f ~/.local/share/applications/zotero.desktop
ln -s ~/.local/opt/Zotero_linux-x86_64/zotero.desktop ~/.local/share/applications/


##https://forums.zotero.org/discussion/25317/install-zotero-standalone-from-ubuntu-linux-mint-ppa/%5d
#sudo add-apt-repository ppa:smathot/cogscinl
#sudo apt-get update
#sudo apt-get install zotero-standalone

#sudo add-apt-repository ppa:smathot/cogscinl
#sudo apt-get update
#sudo apt-get install zotero-standalone

#sudo apt-get install qnotero

#python -m utool.util_ubuntu --exec-make_application_icon --exe=/opt/zotero/zotero --icon=/opt/zotero/chrome/icons/default/main-window.ico -w


## Find the most recent release URL
#export ZOTERO_URL=$(python -c "
#from bs4 import BeautifulSoup
#import requests
#url = 'https://www.zotero.org/download/'
#html = requests.get(url).content
#soup = BeautifulSoup(html, 'html.parser')
##tags = [h for h in soup.find_all('a') if 'Download' in h.text and 'Linux 64-bit' in h.text]
#tags = [h for h in soup.find_all('a') if 'Download' in h.text]
#href = tags[0].get('href')
#print(href)
#")
## Zotero 5 broke this
#export ZOTERO_URL="https://www.zotero.org/download/client/dl?channel=release&platform=linux-x86_64&version=5.0.7"
#echo "ZOTERO_URL=$ZOTERO_URL"
##https://download.zotero.org/standalone/4.0.29.10/Zotero-4.0.29.10_linux-x86_64.tar.bz2
#cd ~/tmp
#wget $ZOTERO_URL
#tar jxf Zotero-*_linux-x86_64.tar.bz2
#sudo cp -r Zotero_linux-x86_64 /opt/zotero
## Change permissions so zotero can automatically update itself
#sudo chown -R root:$USER /opt/zotero
#sudo chmod -R g+w /opt/zotero
#sudo chmod -R u+w /opt/zotero

## Install Better-Bibtex AddOn
## Find the lastest version
#export LATEXT_BETTER_BIB_XPI=$(python -c "
#from bs4 import BeautifulSoup
#import requests, re
#url = 'https://github.com/retorquere/zotero-better-bibtex/releases/latest/'
#html = requests.get(url).content
#soup = BeautifulSoup(html, 'html.parser')
##pat = r'zotero-better-bibtex-.*.xpi'
#pat = r'.xpi'
#tags = [h for h in soup.find_all('a') if '.xpi' in h.text]
#href = tags[0].get('href')
#print('https://github.com' + href)
#")
#echo "LATEXT_BETTER_BIB_XPI=$LATEXT_BETTER_BIB_XPI"

## Need to do tools->Add-Ons->(setting icon)->Install Addon from file
## view citation key
#cd ~/tmp
#wget $LATEXT_BETTER_BIB_XPI

#https://github.com/ZotPlus/zotero-better-bibtex
# Find the lastest XPI
#https://github.com/retorquere/zotero-better-bibtex/releases/latest
# Download the XPI
#https://github.com/ZotPlus/zotero-better-bibtex/releases/download/1.6.30/zotero-better-bibtex-1.6.30.xpi
# others...
#http://www.rtwilson.com/academic/autozotbib
#http://www.rtwilson.com/academic/autozotbib.xpi
#https://addons.mozilla.org/en-US/firefox/addon/zotero-scholar-citations/
