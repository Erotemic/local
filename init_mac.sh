enable_vnc_security()
{
    /System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -activate -configure -access -on -clientopts -setvnclegacy -vnclegacy yes -clientopts -setvncpw -vncpw mypasswd -restart -agent -privs -all
}

# Mac turn on screen sharing
sudo enable_vnc_security

# Make link to Jasons data directory
ln -s /Volumes/External/data/ ~/data
