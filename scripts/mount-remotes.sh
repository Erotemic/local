#!/bin/bash
echo "

Need to ensure ~/.ssh/config has the remote setup

Example:
   Host aretha
       HostName aretha.kitware.com
       Port 22
       User jon.crall

Notes:
    sshfs -o follow_symlinks,idmap=user aretha:/home/local/KHQ/jon.crall ~/aretha
    sshfs -o follow_symlinks,idmap=user aretha: ~/aretha

CommandLine:

    # Force mount a specific remote
    source ~/local/scripts/mount-remotes.sh
    mount_remote namek

" > /dev/null


setup_local_pseudo_mount(){
    __HEREDOC__=""" 
    Creates a link so it appears as if the localhost is a remote. 
    This way all scripts can be written as if they were connecting 
    to a remote, and when run on the host machine it will run locally.
    """
    mkdir -p $HOME/remote
    ln -s $HOME $HOME/remote/$HOSTNAME
}

is_available(){
    # Quickly tests if a remote is available
    #"
    ## https://serverfault.com/questions/200468/how-can-i-set-a-short-timeout-with-the-ping-command
    #sudo apt install fping -y
    #"
    RESULT="$(fping -c1 -t100 $1 2>&1 >/dev/null | grep 1/1/0)"
    if [ "$RESULT" != "" ]; then
        echo "True"
    fi
}

already_mounted(){
    MOUNTPOINT=$1
    if [ -d $MOUNTPOINT ]; then 
        mountpoint $MOUNTPOINT | grep 'is a mountpoint'
    fi
}

mount_remote(){
    REMOTE=$1
    mkdir -p $HOME/remote
    MOUNTPOINT=$HOME/remote/$REMOTE
    mkdir -p $MOUNTPOINT
    echo "Mounting: $REMOTE"
    sshfs -o follow_symlinks,idmap=user $REMOTE: $MOUNTPOINT
}

mount_remote_if_available(){
    REMOTE=$1
    mkdir -p $HOME/remote
    MOUNTPOINT=$HOME/remote/$REMOTE

    if [ "$(which sshfs)" == "" ];  then
        echo "Error: sshf is not installed. sudo apt install sshfs"
    fi

    if [ "$(already_mounted $MOUNTPOINT)" != "" ]; then
        echo "Already mounted: $REMOTE"
    else
        if [ "$(is_available $REMOTE)" != "" ]; then
            mount_remote "$REMOTE"
        elif [ "$FORCE" != "" ]; then
            mount_remote "$REMOTE"
        else
            echo "Unavailable: $REMOTE"
        fi
    fi
}

unmount_if_mounted()
{
    REMOTE=$1
    MOUNTPOINT=$HOME/remote/$REMOTE
    # Check if the directory is non-empty (proxy for checking mounted)
    #if test "$(ls -A "$MOUNTPOINT")"; then
    if [ "$(already_mounted $MOUNTPOINT)" != "" ]; then
        # if so, then unmount it
        echo "Unmounting MOUNTPOINT = $MOUNTPOINT"
        fusermount -u $MOUNTPOINT
    else
        echo "Was not mounted MOUNTPOINT = $MOUNTPOINT"
    fi
}


mount_registered_remotes()
{
    echo "Mounting remotes"
    mount_remote_if_available aretha 
    mount_remote_if_available hermes 
    mount_remote_if_available arisia 
    mount_remote_if_available namek 
    #mount_remote_if_available lev 
}

unmount_registered_remotes()
{
    echo "Unmounting remotes"
    unmount_if_mounted aretha
    unmount_if_mounted hermes 
}


# https://stackoverflow.com/questions/192249/how-do-i-parse-command-line-arguments-in-bash
if [[ $# -gt 0 ]]; then
    POSITIONAL=()
    while [[ $# -gt 0 ]]
    do
    key="$1"

    case $key in
        -u|--unmount)
        UNMOUNT=YES
        shift # past argument
        ;;
        -f|--force)
        FORCE=YES
        shift # past argument
        ;;
        *)    # unknown option
        POSITIONAL+=("$1") # save it in an array for later
        shift # past argument
        ;;
    esac
    done
    set -- "${POSITIONAL[@]}" # restore positional parameters

    if [[ ${#POSITIONAL[@]} -gt 0 ]]; then
        # User specified a specific set of remotes
        # Always force when user specifies the remotes
        FORCE=YES
        for REMOTE in "${POSITIONAL[@]}" 
        do :
            echo "REMOTE = $REMOTE"
            if [ "$UNMOUNT" == "YES" ]; then
                unmount_if_mounted $REMOTE
            else
                mount_remote_if_available $REMOTE
            fi
        done
    else
        # Do for all registered remotes
        if [ "$UNMOUNT" == "YES" ]; then
            unmount_registered_remotes
        else
            mount_registered_remotes
        fi
    fi
fi

#fusermount -u ~/aretha

#if [ "$(is_available aretha)" != "" ]; then
#    mkdir -p ~/aretha    
#fi

# FOR UNMOUNT
# fusermount -u ~/aretha


# Didnt work
#mount_remote_if_available videonas2 
# fusermount -u ~/videonas2

# This works now that I have permission
#mkdir -p ~/remote/videonas2/other
#sudo mount -t cifs //videonas2/other -o username=jon.crall ~/remote/videonas2/other
#sudo umount ~/remote/videonas2/other
