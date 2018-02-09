#!/bin/bash

# Need to ensure ~/.ssh/config has the host setup
# Example:
#    Host aretha
#        HostName aretha.kitware.com
#        Port 22
#        User jon.crall
# Notes:
# sshfs -o follow_symlinks,idmap=user aretha:/home/local/KHQ/jon.crall ~/aretha
# sshfs -o follow_symlinks,idmap=user aretha: ~/aretha

is-available(){
    # Quickly tests if a host is available
    #"
    ## https://serverfault.com/questions/200468/how-can-i-set-a-short-timeout-with-the-ping-command
    #sudo apt install fping -y
    #"
    RESULT="$(fping -c1 -t100 $1 2>&1 >/dev/null | grep 1/1/0)"
    if [ "$RESULT" != "" ]; then
        echo "True"
    fi
}

already-mounted(){
    MOUNTPOINT=$1
    if [ -d $MOUNTPOINT ]; then 
        mountpoint $MOUNTPOINT | grep 'is a mountpoint'
    fi
}


mount-if-available(){
    HOST=$1
    mkdir -p $HOME/remote
    MOUNTPOINT=$HOME/remote/$HOST

    if [ "$(which sshfs)" == "" ];  then
        echo "Error: sshf is not installed. sudo apt install sshfs"
    fi

    if [ "$(already-mounted $MOUNTPOINT)" != "" ]; then
        echo "Already mounted: $HOST"
    else
        if [ "$(is-available $HOST)" != "" ]; then
            echo "Mounting: $HOST"
            mkdir -p $MOUNTPOINT
            sshfs -o follow_symlinks,idmap=user $HOST: $MOUNTPOINT
        elif [ "$FORCE" != "" ]; then
            echo "Mounting: $HOST"
            mkdir -p $MOUNTPOINT
            sshfs -o follow_symlinks,idmap=user $HOST: $MOUNTPOINT
        else
            echo "Unavailable: $HOST"
        fi
    fi
}

unmount-if-mounted()
{
    HOST=$1
    MOUNTPOINT=$HOME/remote/$HOST
    # Check if the directory is non-empty (proxy for checking mounted)
    #if test "$(ls -A "$MOUNTPOINT")"; then
    if [ "$(already-mounted $MOUNTPOINT)" != "" ]; then
        # if so, then unmount it
        echo "Unmounting MOUNTPOINT = $MOUNTPOINT"
        fusermount -u $MOUNTPOINT
    else
        echo "Was not mounted MOUNTPOINT = $MOUNTPOINT"
    fi
}


mount-remotes()
{
    echo "Mounting remotes"
    mount-if-available aretha 
    mount-if-available hermes 
    mount-if-available arisia 
    mount-if-available acidalia 
    #mount-if-available lev 
}

unmount-remotes()
{
    echo "Unmounting remotes"
    unmount-if-mounted aretha
    unmount-if-mounted hermes 
}


# https://stackoverflow.com/questions/192249/how-do-i-parse-command-line-arguments-in-bash
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


if [ "$UNMOUNT" == "YES" ]; then
    unmount-remotes
else
    mount-remotes
fi

#fusermount -u ~/aretha

#if [ "$(is-available aretha)" != "" ]; then
#    mkdir -p ~/aretha    
#fi

# FOR UNMOUNT
# fusermount -u ~/aretha


# Didnt work
#mount-if-available videonas2 
# fusermount -u ~/videonas2

# This works now that I have permission
#mkdir -p ~/remote/videonas2/other
#sudo mount -t cifs //videonas2/other -o username=jon.crall ~/remote/videonas2/other
#sudo umount ~/remote/videonas2/other
