enable_vnc_security()
{
    sudo /System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -activate -configure -access -on -clientopts -setvnclegacy -vnclegacy yes -clientopts -setvncpw -vncpw mypasswd -restart -agent -privs -all
}
reinstall_python()
{
    sudo port -n upgrade --force python27
}

scp_hotspotter_db()
{
    DBNAME = $1
    DST = $2
    export DBNAME = 'NAUT_DAN'
    export DST = 'joncrall@longerdog.com'
    scp -r ~/data/work/$DBNAME/images $DST:data/work/$DBNAME/images
    scp ~/data/work/_hsdb/image_table.csv $DST:data/work/_hsdb/image_table.csv
    scp ~/data/work/_hsdb/name_table.csv  $DST:data/work/_hsdb/name_table.csv
    scp ~/data/work/_hsdb/chip_table.csv  $DST:data/work/_hsdb/chip_table.csv
}

if [["Parham's Mac Mini Server" == $(scutil --get ComputerName)]]; then
    # Make link to Jasons data directory
    ln -s /Volumes/External/data/ ~/data
    # Move a small database
fi

enable_vnc_security

sudo port install tree

sudo port install python27
sudo port select python python27 @2.7.6

# Python packages we cant get from pip
sudo port install py27-ipython
sudo port select --set ipython ipython27

sudo pip install pandas

