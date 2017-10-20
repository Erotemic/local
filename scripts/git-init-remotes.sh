#!/bin/sh
echo 'Must be run from git directory'

export githubusername=Erotemic
export repo_name=`basename \`git rev-parse --show-toplevel\``
test -z $repo_name && echo "Repo name required." 1>&2 && exit 1

cd ~/code/$repo_name

if [ -d ./.git ]; then
    echo "This is a git direcotry"
else
    echo "Not in a git directory"
    exit 1
fi

echo "Your github username is: $githubusername"
echo "The repo name is: $repo_name"

echo "Creating repo on Github"
curl -u 'erotemic' https://api.github.com/user/repos -d "{\"name\":\"$repo_name\"}"

echo "Adding remotes to hyrule and github"
git remote add hyrule "git@hyrule.cs.rpi.edu:$repo_name.git"
#git remote add github "https://github.com/$githubusername/$repo_name.git"
git remote add github git@github.com:$githubusername/$repo_name.git

git push -u github master
#git branch --set-upstream origin/master
