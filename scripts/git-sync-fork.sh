#https://help.github.com/articles/syncing-a-fork

cd ~/code/sympy

# Do this on a new branch
git checkout -b synced-fork

# List remotes
git remote -v

# Set new "upstream" remote
git remote add upstream https://github.com/sherjilozair/sympy.git


# Verify new remote
git remote -v

# Fetch things from the new remote
git fetch upstream

# Merge the branch we want into the branched master

git merge upstream/SVD4
