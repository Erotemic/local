#!/bin/sh
echo '
CommandLine:
    new_repo.sh <reponame>

    # Then it will ask you for a sudo password
    # Then it will ask you if you want to clone

    ~joncrall/local/scripts/ubuntu_scripts/new_repo.sh <reponame>
    git clone git@hyrule.cs.rpi.edu:<reponame>

    sudo ~joncrall/local/scripts/ubuntu_scripts/new_repo.sh crall-candidacy-2015
    git clone git@hyrule.cs.rpi.edu:crall-candidacy-2015
    cd crall-candidacy-2015
    touch main.tex.latexmain
    cp ../crall-lab-notebook/*.tex .
    cp ../crall-lab-notebook/*.bib .
    cp ../crall-lab-notebook/.gitignore .

    cd ~/latex/crall-thesis-2017
    git init
    git remote add origin git@hyrule.cs.rpi.edu:crall-thesis-2017

    # ENSURE THAT THE COMPUTER YOU ARE USING HAS ITS id_rsa.pub
    # ADDED TO THE GIT ACCOUNTs .ssh/authorized_keys file
'
echo '1) Ensuring that you have sudo sued first:'

#export LUID=$(id -u)
#if [ $LUID -ne 0 ]; then
#echo "$0 must be run as root"
#exit 1
#fi

#echo 'Ok you are root.'

export git_dpath=/home/git
export repo_name=$1
export server=hyrule.cs.rpi.edu
export repo_fpath="$git_dpath/$repo_name.git"
export github_username=erotemic

echo '2) Arguments Specified'
echo '  * git_dpath       : '$git_dpath
echo '  * repo_name       : '$repo_name
echo '  * repo_fpath      : '$repo_fpath
echo '  * github_username : '$github_username
echo '    (although nothing github related is currently in this script)'

test -z $repo_name && echo "ERROR: Repo name required." 1>&2 && exit 1

if [ ! -d $git_dpath ]; then
    echo "ERROR: No user named git. Cannot create repos"
    exit 1
fi

echo '3) Creating repo '$repo_fpath

if [ -d $repo_fpath ]; then
    echo "ERROR: Cannot overrride existing directory: $repo_fpath"
    exit 1
fi

sudo mkdir $repo_fpath
sudo git --bare init $repo_fpath

echo '4) Appending to config'

if [ -f $repo_fpath/config ]; then
    sudo rm $repo_fpath/config
fi
sudo bash -c "cat > $repo_fpath/config" <<'EOF'
[core]
	repositoryformatversion = 0
	filemode = true
	bare = true

[branch "master"]
    remote = origin 
    merge = refs/heads/master

[branch "next"]
    remote = origin 
    merge = refs/heads/next

[remote "hyrule"]
    fetch = +refs/heads/*:refs/remotes/origin/*
    url = git@hyrule.cs.rpi.edu:'$1'.git

#[remote "github"]
#    url = https://github.com/'$github_username'/'$repo_name'.git
#    fetch = +refs/heads/*:refs/remotes/github/*
EOF

echo '5) Fixing ownership'
sudo chown -R git:git $repo_fpath

echo '6) Done'


while true; do
    # References: https://stackoverflow.com/questions/226703/how-do-i-prompt-for-yes-no-cancel-input-in-a-linux-shell-script
    read -p "Do you wish to clone the repo here?" yn
    case $yn in
        [Yy]* ) git clone git@$server:$repo_name.git ; break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done
