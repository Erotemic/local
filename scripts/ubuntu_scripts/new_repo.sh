#!/bin/sh
'
CommandLine:
    sudo new_repo.sh <reponame>

    sudo ~joncrall/local/scripts/ubuntu_scripts/new_repo.sh <reponame>
    git clone git@hyrule.cs.rpi.edu:<reponame>

    sudo ~joncrall/local/scripts/ubuntu_scripts/new_repo.sh crall-candidacy-2015
    git clone git@hyrule.cs.rpi.edu:crall-candidacy-2015
    cd crall-candidacy-2015
    touch main.tex.latexmain
    cp ../crall-lab-notebook/chapter* .
    cp ../crall-lab-notebook/main.tex .
    cp ../crall-lab-notebook/fix_bib.py .
    cp ../crall-lab-notebook/CrallPramb.tex .
    cp ../crall-lab-notebook/CrallDef.tex .
    cp ../crall-lab-notebook/appendix.tex .
    cp "../crall-lab-notebook/My Library.bib" .
    cp ../crall-lab-notebook/My_Library_clean.bib .
    cp ../crall-lab-notebook/guts.tex .
    cp ../crall-lab-notebook/.gitignore .
'
echo '1) Ensuring that you have sudo sued first:'

export LUID=$(id -u)
if [ $LUID -ne 0 ]; then
echo "$0 must be run as root"
exit 1
fi

echo 'Ok you are root.'

export repo_name=$1
export gitusername=erotemic

echo '2) Arguments Specified'
echo 'Your github username is: '$gitusername
echo '(although nothing github related is currently in this script)'
echo 'The new repo name is: '$repo_name

test -z $repo_name && echo "Repo name required." 1>&2 && exit 1

echo '3) Creating repo in ~git'

cd ~git

if [ -d $repo_name.git ]; then
    echo "Cannot overrride existing directory."
    exit 1
fi

mkdir $repo_name.git
cd $repo_name.git
git --bare init

echo '4) Appending to config'

echo '
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
#    url = https://github.com/'$gitusername'/'$repo_name'.git
#    fetch = +refs/heads/*:refs/remotes/github/*
' > config

echo '5) Fixing ownership'
#chown -R git:git *
cd ~git
chown -R git:git $repo_name.git

echo '6) Done'
