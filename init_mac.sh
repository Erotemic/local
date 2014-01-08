enable_vnc_security()
{
    # Mac turn on screen sharing
    /System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -activate -configure -access -on -clientopts -setvnclegacy -vnclegacy yes -clientopts -setvncpw -vncpw mypasswd -restart -agent -privs -all
}

sudo enable_vnc_security

ln -s /Volumes/External/data/ ~/data


echo export PATH=$PATH:/opt/local/bin >> ~/.profile

