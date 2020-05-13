#!/bin/bash
__heredoc__="

Need to ensure ~/.ssh/config has the remote setup

Example:
   Host remote1
       HostName remote1.com
       Port 22
       User jon.crall

Notes:
    sshfs -o follow_symlinks,idmap=user remote1: ~/remote/remote1
    fusermount -u ~/remote/remote1

    sudo mount -t cifs -o dir_mode=0777,file_mode=0777 -osec=ntlmv2,domain=$DOMAIN,username=$USERNAME,password=$PASSWORD //$SMB_NAME $HOME/remote/$SMB_NAME

CommandLine:

    # Force mount a specific remote
    source ~/local/scripts/mount-remotes.sh
    mount_remote remotename

" 


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
    FORCE=$2
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
    FORCE=$2
    MOUNTPOINT=$HOME/remote/$REMOTE
    # Check if the directory is non-empty (proxy for checking mounted)
    #if test "$(ls -A "$MOUNTPOINT")"; then
    if ["$FORCE" != ""] || ["$(already_mounted $MOUNTPOINT)" != ""]; then
        # if so, then unmount it
        echo "Unmounting MOUNTPOINT = $MOUNTPOINT"
        fusermount -u $MOUNTPOINT
    else
        echo "Was not mounted MOUNTPOINT = $MOUNTPOINT"
    fi
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
                unmount_if_mounted $REMOTE $FORCE
            else
                mount_remote_if_available $REMOTE $FORCE
            fi
        done
    else
        echo "ERROR NEED TO SPECIFY REMOTE"
    fi
fi

#fusermount -u ~/remote1
#if [ "$(is_available remote1)" != "" ]; then
#    mkdir -p ~/remote1    
#fi
# FOR UNMOUNT
# fusermount -u ~/remote1
