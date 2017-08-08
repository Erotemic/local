#!/bin/bash
'
./symbolic_rebase.sh --base=master --branch=dev/python3-support \
    --depends="dev/find_numpy dev/update-openblas-0.2.20 dev/update-opencv dev/update-vtk dev/update-caffe"
'

# References:
# https://stackoverflow.com/questions/192249/how-do-i-parse-command-line-arguments-in-bash
for i in "$@"
do
case $i in
    -e|--base)
    BASE="$2"
    shift # past argument
    ;;
    -e=*|--base=*)
    BASE="${i#*=}"
    shift # past argument=value
    ;;
    # -----
    -b=*|--branch=*)
    BRANCH="${i#*=}"
    shift # past argument=value
    ;;
    -b|--branch)
    BRANCH="$2"
    shift # past argument
    ;;
    # -----
    -d=*|--depends=*)
    DEPENDS="${i#*=}"
    shift # past argument=value
    ;;
    -d|--depends)
    DEPENDS="$2"
    shift # past argument
    ;;
    # -----
    --flag)
    DEFAULT=YES
    shift # past argument with no value
    ;;
    *)
            # unknown option
    ;;
esac
done

echo "
BASE = $BASE
BRANCH = $BRANCH
DEPENDS = $DEPENDS
"

PRE_BRANCH=pre/$BRANCH


# $? == 0 means local branch with <branch-name> exists.
git rev-parse --verify $BRANCH
if [ $? == 0 ]; then
    echo "Branch exists"
    BRANCH_EXISTS=1
else
    echo "Branch does not exist"
    BRANCH_EXISTS=0
fi

if [ $BRANCH_EXISTS == 0 ]; then
    # Starting from the base
    git checkout $BASE
    # Create the pre-branch off of the base
    git checkout -b $PRE_BRANCH
    # Merge all prereqs into the pre-branch
    git merge $DEPENDS --no-edit

    # Create the new "symbolic" branch to work on
    git checkout -b $BRANCH
else
    # TODO: case where nothing happens and PRE_BRANCH == BRANCH

    # Starting from the base
    git checkout $BASE
    # Remember the hash of the old pre-branch
    OLD_PRE_BRANCH=$(git rev-parse $PRE_BRANCH)

    # Create a new pre-branch
    git checkout -b new/$PRE_BRANCH

    # Merge all prereqs into the tmp/pre branch
    git merge $DEPENDS --no-edit

    # Create a new post-branch
    git checkout -b new/$BRANCH

    # verify this looks good
    # git log $OLD_PRE_BRANCH..$BRANCH
    # git log --pretty=format:"%H" $OLD_PRE_BRANCH..$BRANCH

    # Cherry-pick the changes after the old pre-branch onto the new one
    git cherry-pick $OLD_PRE_BRANCH..$BRANCH

    # Overwrite old branches with the new ones
    git checkout $PRE_BRANCH
    git reset new/$PRE_BRANCH --hard 

    git checkout $BRANCH
    git reset new/$BRANCH --hard 

    # remote the temporary new branches
    git branch -D new/$BRANCH
    git branch -D new/$PRE_BRANCH
fi

