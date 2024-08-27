#!/usr/bin/env bash
__doc__="

Need to ensure ~/.ssh/config has the remote setup

Example:
   Host remote1
       HostName remote1.com
       Port 22
       User jon.crall

Notes:
    sshfs -o follow_symlinks,idmap=user EE_534: ~/remote/EE_534

    sshfs -o follow_symlinks,idmap=user remote1: ~/remote/remote1
    fusermount -u ~/remote/remote1

    sudo mount -t cifs -o dir_mode=0777,file_mode=0777 -osec=ntlmv2,domain=$DOMAIN,username=$USERNAME,password=$PASSWORD //$SMB_NAME $HOME/remote/$SMB_NAME

    TODO:

    if a nautilus window is hanging on a remove directory you may need to killall -9 ssfh [SE59348]_.

CommandLine:

    # Force mount a specific remote
    source ~/local/scripts/mount-remotes.sh
    mount_remote remotename

References:
    .. [SE59348] https://askubuntu.com/questions/59348/nautilus-is-frozen-cannot-be-used-and-cannot-be-killed
"
if [[ ${BASH_SOURCE[0]} == "$0" ]]; then
	# Running as a script
	set -eo pipefail
fi

if [[ "${DEBUG_MOUNT_REMOTES+x}" != "" ]]; then
	set -x
fi


setup_local_pseudo_mount(){
    __doc__="
    Creates a link so it appears as if the localhost is a remote.
    This way all scripts can be written as if they were connecting
    to a remote, and when run on the host machine it will run locally.
    "
    mkdir -p "$HOME"/remote
    ln -s "$HOME" "$HOME"/remote/"$HOSTNAME"
}

is_available(){
    __doc__="
    Quickly tests if a remote is available

    References:
        https://serverfault.com/questions/200468/how-can-i-set-a-short-timeout-with-the-ping-command

    Requirements:
        sudo apt install fping -y

    Ignore:
        source ~/local/scripts/mount-remotes.sh
        is_available namek
        is_available toothbrush

    "
    if [ "$(which fping)" == "" ];  then
        >&2 echo "Error: fping is not installed. sudo apt install fping"
        return 1
    fi
    REMOTE=$1
    RESULT="$(fping -c1 -t100 "$REMOTE" 2>&1 >/dev/null | grep 1/1/0)"
    if [ "$RESULT" != "" ]; then
        echo "True"
    fi
}

already_mounted(){
    MOUNTPOINT=$1
    if [ -d "$MOUNTPOINT" ]; then
        mountpoint "$MOUNTPOINT" | grep 'is a mountpoint'
    fi
}

mount_remote(){
    __doc__="
    Executes the sshfs command. Note some options like those discussed in
    [SE344255]_ can help make this faster.

    References:
        .. [SE344255] https://superuser.com/questions/344255/faster-way-to-mount-a-remote-file-system-than-sshfs
        .. [autocache] https://libfuse.github.io/doxygen/structfuse__config.html#a9db154b1f75284dd4fccc0248be71f66


    Note: rclone mount might be a good alternative to sshfs?

    TEST Rclone
        mkdir -p $HOME/test-rclone/namek
        rclone mount namek $HOME/test-rclone/namek
    "
    REMOTE=$1
    mkdir -p "$HOME"/remote
    MOUNTPOINT=$HOME/remote/$REMOTE
    mkdir -p "$MOUNTPOINT"
    echo "Mounting: $REMOTE"

    # Basic
    sshfs -o follow_symlinks,idmap=user "$REMOTE": "$MOUNTPOINT"

    echo "Mounted on: $MOUNTPOINT"
    # Experimental Options?
    #sshfs -o follow_symlinks,idmap=user,max_conns=4 "$REMOTE": "$MOUNTPOINT"
    #sshfs -o follow_symlinks,idmap=user,max_conns=4,auto_cache,reconnect "$REMOTE": "$MOUNTPOINT"
}

mount_remote_if_available(){
    __doc__="
    Tests if a remote is available, and if it is attempts to mount it.

    Args:
        REMOTE : name of the remote machine
        FORCE : non-empty implies True, forces the mount even if not available.
    "
    REMOTE=$1
    FORCE=$2
    mkdir -p "$HOME"/remote
    MOUNTPOINT=$HOME/remote/$REMOTE

    if [ "$(which sshfs)" == "" ];  then
        echo "Error: sshf is not installed. sudo apt install sshfs"
        exit 1
    fi

    REMOTE_LOWER=${REMOTE,,}
    HOSTNAME_LOWER=${HOSTNAME,,}
    if [ "$REMOTE_LOWER" == "$HOSTNAME_LOWER" ];  then
        echo "Attempting to mount self. Ensuring symlink instead"
        if [ ! -L "$MOUNTPOINT" ]; then
            echo "Creating symlink to home"
            ln -s "$HOME" "$MOUNTPOINT"
            echo "Mounted on: $MOUNTPOINT"
        fi
        exit 0
    fi

    if [ "$(already_mounted "$MOUNTPOINT")" != "" ]; then
        echo "Already mounted: $REMOTE"
        echo "Mounted on: $MOUNTPOINT"
    else
        if [ "$FORCE" != "" ]; then
            mount_remote "$REMOTE"
        elif [ "$(is_available "$REMOTE")" != "" ]; then
            mount_remote "$REMOTE"
        else
            echo "Unavailable: $REMOTE"
            exit 1
        fi
    fi
}


check_status(){
    __doc__="
    Check status of a mount point

    References:
        https://unix.stackexchange.com/questions/687459/how-to-check-in-bash-if-a-file-is-currently-in-use-from-a-sshfs-mount

    REMOTE=namek
    "
    REMOTE=$1
    MOUNTPOINT=$HOME/remote/$REMOTE

    echo "Checking Status of REMOTE=$REMOTE"
    lsof "$MOUNTPOINT"
    fuser "$MOUNTPOINT"

    # shellcheck disable=SC2009
    ps aux | grep -i sftp | grep -v grep
}

unmount_if_mounted()
{
    __doc__="
    Unmount a mountpoint.

    References:
        https://unix.stackexchange.com/questions/313852/is-there-a-user-level-foolproof-way-to-force-termination-of-sshfs-connections

    "
    REMOTE=$1
    FORCE=$2
    MOUNTPOINT=$HOME/remote/$REMOTE
    # Check if the directory is non-empty (proxy for checking mounted)
    #if test "$(ls -A "$MOUNTPOINT")"; then
    if [[ "$FORCE" != "" || "$(already_mounted "$MOUNTPOINT")" != "" ]]; then
        # if so, then unmount it
        echo "Unmounting MOUNTPOINT = $MOUNTPOINT"
        # Note, if the ssh session is cut then try
        # kill -9 $(pgrep -lf sshfs | cut -d " " -f2)
        # or user the lazy -z option with fusermount

        if [[ "$FORCE" != "" ]]; then
            # TODO: add -z when force is true
            # References:
            fusermount -uz "$MOUNTPOINT"
        else
            fusermount -u "$MOUNTPOINT"
        fi

    else
        echo "Was not mounted MOUNTPOINT = $MOUNTPOINT"
    fi
}

mount_remotes_main(){

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
                -s|--status)
                STATUS=YES
                shift # past argument
                ;;
                -h|--help)
                SHOW_HELP=YES
                shift # past argument
                ;;
                *)    # unknown option
                POSITIONAL+=("$1") # save it in an array for later
                shift # past argument
                ;;
            esac
        done

        set -- "${POSITIONAL[@]}" # restore positional parameters

        if [[ "$SHOW_HELP" == "YES" ]]; then
            echo "TODO: SHOW HELP FOR MOUNT_REMOTES"
        elif [[ ${#POSITIONAL[@]} -gt 0 ]]; then
            # User specified a specific set of remotes
            # Always force when user specifies the remotes
            FORCE=YES
            for REMOTE in "${POSITIONAL[@]}"
            do :

                if [ "$STATUS" == "YES" ]; then
                    check_status "$REMOTE"
                elif [ "$UNMOUNT" == "YES" ]; then
                    unmount_if_mounted "$REMOTE" "$FORCE"
                else
                    mount_remote_if_available "$REMOTE" "$FORCE"
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

}


# https://stackoverflow.com/questions/192249/how-do-i-parse-command-line-arguments-in-bash
#
if [[ ${BASH_SOURCE[0]} != "$0" ]]; then
    # We are sourcing the library
    echo "Sourcing prepare_system as a library and environment"
else
    mount_remotes_main "${@}"
    exit $?
fi
