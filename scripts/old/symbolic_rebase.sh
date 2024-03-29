#!/usr/bin/env bash
'
./symbolic_rebase.sh --base=master --branch=dev/python3-support \
    --depends="dev/find_numpy dev/update-openblas-0.2.20 dev/update-opencv dev/update-vtk dev/update-caffe"

BASE=master 
BRANCH=test/update-opencv-3.3 
DEPENDS="test/update-opencv"

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

# default options
if [ "$BASE" == "" ]; then
    BASE="master"
fi

echo "
BASE = $BASE
BRANCH = $BRANCH
DEPENDS = $DEPENDS
"

PRE_BRANCH=pre/$BRANCH


# $? == 0 means local branch with <branch-name> exists.
git rev-parse --verify $BRANCH
BRANCH_EXISTS=$?   # zero is success
OPT_ARR=('exists' 'does not exist')
echo "Branch ${OPT_ARR[$BRANCH_EXISTS]}" 


if [ $BRANCH_EXISTS != 0 ]; then
    # Starting from the base
    git checkout $BASE
    # Create the pre-branch off of the base
    git checkout -b $PRE_BRANCH
    # Merge all prereqs into the pre-branch
    git merge $DEPENDS --no-edit

    # Create the new "symbolic" branch to work on
    git checkout -b $BRANCH
else
    # Remember the hash of the old pre-branch
    OLD_PRE_BRANCH_HASH=$(git rev-parse $PRE_BRANCH)
    OLD_BRANCH_HASH=$(git rev-parse $BRANCH)

    if [ "$OLD_PRE_BRANCH_HASH" == "$PRE_BRANCH" ]; then
        # TODO: assert pre-hash exists
        echo "TODO assert pre-hash doesnt exists"
        CAN_CONTINUE="False"
    elif [ "$OLD_BRANCH_HASH" == "$OLD_PRE_BRANCH_HASH" ]; then
        # TODO: case where nothing happens and PRE_BRANCH == BRANCH
        echo "TODO already at prebranch == branch"
        CAN_CONTINUE="False"
    else
        echo "symbolicly rebasing between old hashes $OLD_PRE_BRANCH_HASH $OLD_BRANCH_HASH"
        CAN_CONTINUE="True"
    fi

    if [ "$CAN_CONTINUE" == "True" ]; then
        # Starting from the base
        git checkout $BASE

        # Create a new pre-branch
        git checkout -b new/$PRE_BRANCH

        # Merge all prereqs into the tmp/pre branch
        #MERGE_SUCCESS=false
        #git merge $DEPENDS -Xignore-all-space --no-edit && MERGE_SUCCESS=true

        # Try individual merge one at a time
        # While there are still things to do
        deparr=($DEPENDS) 
        while [ ${#deparr[@]} -eq 0 ]
        do
            item=${deparr[0]}
            deparr=("${deparr[@]:1}")  # basically a pop
            echo "merge item=$item"
            if [ "$item" == "" ]; then
                echo "We are done"
                break
            else
                RERERE_SUCCESS=false
                MERGE_SUCCESS=false
                git merge $item --no-ff -Xignore-all-space --no-edit --rerere-autoupdate && MERGE_SUCCESS=true
                [ "$(git rerere diff)" == "" ] && RERERE_SUCCESS=true 

                echo "
                MERGE_SUCCESS = $MERGE_SUCCESS
                RERERE_SUCCESS = $RERERE_SUCCESS
                "

                # Auto merge git rerere things
                # https://stackoverflow.com/questions/18003917/git-rerere-does-not-auto-commit-autoupdated-merge-resolutions
                if [ $MERGE_SUCCESS == true ]; then 
                    echo "normal merge success of $item"
                elif [ $RERERE_SUCCESS == true ]; then 
                    echo "rerere merge success"
                    git commit -a --no-edit
                else
                    echo "merge failed"
                    $(exit 1)
                    break
                fi
            fi
            # Hack: Fix release notes
            #pysed -r '^<<<<<<< .*\n' '' Doc/release-notes/1.1.0.txt -w
            #pysed -r '^=======\n' '' Doc/release-notes/1.1.0.txt -w
            #pysed -r '^>>>>>>> .*\n' '' Doc/release-notes/1.1.0.txt -w
            #cat Doc/release-notes/1.1.0.txt
            #git add Doc/release-notes/1.1.0.txt
            #git commit -am "merged release notes"
        done

        MERGE_SUCCESS=$?
        echo "MERGE_SUCCESS = $MERGE_SUCCESS (0 means success)"
        if [ $MERGE_SUCCESS != 0 ]; then
            # TODO: check that merge went smoothly
            echo "MERGE FAILED"
            #git checkout $BASE
            echo "Need to clean up:
                Ensure git rerere is enabled
                Then fix the conflict and commit
                Then reset the state, and try the merge again.
                It should happen automatically this time.

                git merge --abort

                git checkout $BASE
                git branch -D new/$PRE_BRANCH
            "
        else
            # Create a new post-branch
            git checkout -b new/$BRANCH

            # verify this looks good
            git log --pretty=oneline $OLD_PRE_BRANCH_HASH...$OLD_BRANCH_HASH
            #git log $OLD_PRE_BRANCH_HASH...$BRANCH
            #git log --pretty=format:"%H" $OLD_PRE_BRANCH_HASH..$BRANCH
            #gitk $BRANCH $OLD_PRE_BRANCH_HASH
            #gitk $OLD_BRANCH_HASH $OLD_PRE_BRANCH_HASH

            # Cherry-pick the changes after the old pre-branch onto the new one
            git cherry-pick $OLD_PRE_BRANCH_HASH..$OLD_BRANCH_HASH --rerere-autoupdate
            # Auto merge git rerere things
            # https://stackoverflow.com/questions/18003917/git-rerere-does-not-auto-commit-autoupdated-merge-resolutions
            if [[ $(git rerere diff) ]]
            then
                echo "Rerere cherry-pick merge success"
                git commit -a --no-edit
            else
                echo "Rerere cherry-pick merge failed"
                $(exit 1)
            fi

            #git log --pretty=oneline 466934535f97481afadb4cbede2fda25ce295a37..fcc37a6a4df4e5be84fb3a2d73017114e570ae2d
            #git cherry-pick fcc37a6a4df4e5be84fb3a2d73017114e570ae2d

            CHERRY_PICK_SUCCESS=$?
            echo "CHERRY_PICK_SUCCESS = $CHERRY_PICK_SUCCESS (0 means success)"

            if [ $CHERRY_PICK_SUCCESS != 0 ]; then
                pass
            else
                # TODO: check that cherry-pick went smoothly
                NEW_PRE_BRANCH_HASH=$(git rev-parse new/$PRE_BRANCH)
                NEW_BRANCH_HASH=$(git rev-parse new/$BRANCH)

                # Overwrite old branches with the new ones
                git checkout $PRE_BRANCH && git reset $NEW_PRE_BRANCH_HASH --hard 
                git checkout $BRANCH && git reset $NEW_BRANCH_HASH --hard 

                # remote the temporary new branches
                git branch -D new/$BRANCH
                git branch -D new/$PRE_BRANCH
            fi
        fi
    fi
fi
