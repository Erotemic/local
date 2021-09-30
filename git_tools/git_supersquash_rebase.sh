make_backup_branch(){
    __doc__="
    This is a helper bash function that makes a backup branch and
    then returns to the main branch. Only works if the current branch
    is in a clean state.
    "
    PREFIX="$1"
    CURRENT_BRANCH=$(git branch --show-current)
    #TIMESTAMP=$(date --iso-8601=seconds)
    TIMESTAMP=$(date +"%Y%m%dT%H%M%S")
    BACKUP_BRANCHNAME="backup/$CURRENT_BRANCH/$HOSTNAME/${PREFIX}${TIMESTAMP}"
    echo "BACKUP_BRANCHNAME = $BACKUP_BRANCHNAME"
    # Make the new backup
    git checkout -b $BACKUP_BRANCHNAME
    # Go back ot the first branch
    git checkout $CURRENT_BRANCH
}

supersquash_rebase(){
    REBASE_BRANCH=$1
    TOPIC_BRANCH=$(git branch --show-current)
    BASE_BRANCH=$(git merge-base $TOPIC_BRANCH $REBASE_BRANCH)

    echo "REBASE_BRANCH = $REBASE_BRANCH"
    echo "TOPIC_BRANCH = $TOPIC_BRANCH"
    echo "BASE_BRANCH = $BASE_BRANCH"

    # Checkout a new branch to make changes in 
    git checkout -b flat/$TOPIC_BRANCH/rebaser

    # Change where current branch points, but dont change the filesystem state
    git reset $BASE_BRANCH

    # Add the files that are new to your branch
    PREVIOUSLY_TRACKED_FILES=$(git ls-tree -r $TOPIC_BRANCH --name-only | sort)
    UNTRCKED_FILES=$(git status --porcelain | awk '/^\?\?/ { print $2; }' | sort)
    NEED_TO_ADD="$(comm -12  <(echo "$UNTRCKED_FILES") <(echo "$PREVIOUSLY_TRACKED_FILES"))"
    git add $NEED_TO_ADD

    # Add all modified and new files in a single "squashed" commit
    git commit -am "megasquash"

    # Now try to rebase that one mega commit onto master
    git rebase -i $REBASE_BRANCH

}
