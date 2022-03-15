#!/bin/bash
__doc__="
Minimal requirements bash script to install and init IPFS


Based on old code in:
    ~/code/shitspotter/dev/standalone_install_ipfs.sh

Requires:
    python or python3
    curl
    tmux (optional)

Test:
    docker run -it python bash

    # End-to-end test
    export PATH=$HOME/.local/bin:$PATH
    apt update -y && apt install curl -y && curl https://raw.githubusercontent.com/Erotemic/shitspotter/main/dev/standalone_install_ipfs.sh > standalone_install_ipfs.sh
    source standalone_install_ipfs.sh
    main
"

export INSTALL_PREFIX=$HOME/.local
# Ensure you have this installed in your path
export PATH=$INSTALL_PREFIX/bin:$PATH
export IPFS_PATH=$HOME/.ipfs
export IPFS_CLUSTER_PATH=$HOME/.ipfs-cluster
#export IPFS_PATH=/data/ipfs
#export IPFS_CLUSTER_PATH=/data/ipfs-cluster


apt_ensure(){
    __doc__="
    Checks to see if the packages are installed and installs them if needed.

    The main reason to use this over normal apt install is that it avoids sudo
    if we already have all requested packages.

    Args:
        *ARGS : one or more requested packages 

    Environment:
        UPDATE : if this is populated also runs and apt update

    Example:
        apt_ensure git curl htop 
    "
    # Note the $@ is not actually an array, but we can convert it to one
    # https://linuxize.com/post/bash-functions/#passing-arguments-to-bash-functions
    ARGS=("$@")
    MISS_PKGS=()
    HIT_PKGS=()
    # Root on docker does not use sudo command, but users do
    if [ "$(whoami)" == "root" ]; then 
        _SUDO=""
    else
        _SUDO="sudo "
    fi
    # shellcheck disable=SC2068
    for PKG_NAME in ${ARGS[@]}
    do
        #apt_ensure_single $EXE_NAME
        RESULT=$(dpkg -l "$PKG_NAME" | grep "^ii *$PKG_NAME")
        if [ "$RESULT" == "" ]; then 
            echo "Do not have PKG_NAME='$PKG_NAME'"
            # shellcheck disable=SC2268,SC2206
            MISS_PKGS=(${MISS_PKGS[@]} "$PKG_NAME")
        else
            echo "Already have PKG_NAME='$PKG_NAME'"
            # shellcheck disable=SC2268,SC2206
            HIT_PKGS=(${HIT_PKGS[@]} "$PKG_NAME")
        fi
    done
    if [ "${#MISS_PKGS}" -gt 0 ]; then
        if [ "${UPDATE}" != "" ]; then
            $_SUDO apt update -y
        fi
        $_SUDO apt install -y "${MISS_PKGS[@]}"
    else
        echo "No missing packages"
    fi
}


ensure_required_packages(){
    __doc__="
    Try to install apt packages if we dont have them
    "

    # Root on docker does not use sudo command, but users do
    if [ "$(whoami)" == "root" ]; then 
        _SUDO=""
    else
        _SUDO="sudo "
    fi
    if [ "$(type -P python3)" != "" ]; then
        if [ "$(type -P python)" != "" ]; then
            $_SUDO apt update && $_SUDO apt install python3
        fi
    fi
    if [ "$(type -P tmux)" != "" ]; then
        $_SUDO apt update && $_SUDO apt install tmux
    fi
    if [ "$(type -P curl)" != "" ]; then
        $_SUDO apt update && $_SUDO apt install curl
    fi
}



system_python(){
    __doc__="
    Return name of system python
    "
    if [ "$(type -P python)" != "" ]; then
        echo "python"
    elif [ "$(type -P python3)" != "" ]; then
        echo "python3"
    else
        echo "python"
    fi 
}


codeblock()
{
    if [ "-h" == "$1" ] || [ "--help" == "$1" ]; then 
        # Use codeblock to show the usage of codeblock, so you can use
        # codeblock while you codeblock.
        codeblock '
            Unindents code before its executed so you can maintain a pretty
            indentation in your code file. Multiline strings simply begin  
            with 
                "$(codeblock "
            and end with 
                ")"

            Usage:
               codeblock <TEXT>

            Args:
               TEXT : text to remove leading indentation of

            Example:
               echo "$(codeblock "
                    a long
                    multiline string.
                    this is the last line that will be considered.
                    ")"

               # No indentation errors
               python -c "$(codeblock "
                   import math
                   for i in range(10):
                       print(math.factorial(i))
                   ")"
        '
    else
        # Prevents python indentation errors in bash
        #python -c "from textwrap import dedent; print(dedent('$1').strip('\n'))"
        local PYEXE
        PYEXE=$(system_python)
        echo "$1" | $PYEXE -c "import sys; from textwrap import dedent; print(dedent(sys.stdin.read()).strip('\n'))"
    fi
}


sudo_writeto()
{
    __doc__="
    Unindents text and writes it to a file with sudo privledges

    Usage:
        sudo_writeto <fpath> <text>
    "
    # NOTE: FAILS WITH QUOTES IN BODY
    fpath=$1
    text=$2
    fixed_text=$(codeblock "$text")
    # IS THERE A BETTER WAY TO FORWARD AN ENV TO SUDO SO sudo writeto works
    sudo sh -c "echo \"$fixed_text\" > $fpath"
}


verify_hash(){
    __doc__='
    Verifies the hash of a file

    Example:
        FPATH="$(which ls)"
        EXPECTED_HASH=4ef89baf437effd684a125da35674dc6147ef2e34b76d11ea0837b543b60352f
        verify_hash $FPATH $EXPECTED_HASH
    '
    local FPATH=${1:-${FPATH:-"Unspecified"}}
    local EXPECTED_HASH=${2:-${EXPECTED_HASH:-'*'}}
    local HASHER=${3:-sha256sum}
    local VERBOSE=${4:-${VERBOSE:-"3"}}

    $(system_python) -c "import sys; sys.exit(0 if ('$HASHER' in {'sha256sum', 'sha512sum'}) else 1)"

    if [ $? -ne 0 ]; then
        echo "HASHER = $HASHER is not in the known list"
        return 1
    fi

    # Get the hash
    local GOT_HASH
    GOT_HASH=$($HASHER "$FPATH" | cut -d' ' -f1)
    echo "FPATH = $FPATH"
    echo "GOT_HASH = $GOT_HASH"

    # Verify the hash
    if [[ "$GOT_HASH" != $EXPECTED_HASH* ]]; then
        codeblock "
            Checking hash
                * GOT_HASH      = '$GOT_HASH'
                * EXPECTED_HASH = '$EXPECTED_HASH'
            Downloaded file does not match hash!
            DO NOT CONTINUE WITHOUT VALIDATING NEW VERSION AND UPDATING THE HASH!
        "
        return 1
    else
        if [ "$VERBOSE" -ge 1 ]; then
            codeblock "
                Checking hash
                    * GOT_HASH      = '$GOT_HASH'
                    * EXPECTED_HASH = '$EXPECTED_HASH'
                Hash prefixes match
                "
        fi
        return 0
    fi
}


curl_verify_hash(){
    __doc__='
    A thin wrapper around curl that adds the feature where it will return a
    failure integer code if the hash of the downloaded file does not match an
    expected version.

    Usage:
        curl_verify_hash <URL> <DST> <EXPECTED_HASH> [HASHER] [CURL_OPTS] [VERBOSE]

    Args:
        URL : the url to download
        DST : the destination for the file
        EXPECTED_HASH : the prefix of the expected hash
        HASHER : the hasher to use use (defaults to sha256sum)
        CURL_OPTS : any additional options to CURL
        VERBOSE : for debugging

    References:
        https://github.com/curl/curl/issues/1399

    Example:
        URL=https://file-examples-com.github.io/uploads/2017/02/file_example_JSON_1kb.json \
        DST=file_example_JSON_1kb.json \
        VERBOSE=0 \
        EXPECTED_HASH="aa20e971f6a0a7c482f3ed70cc6edc" \
            curl_verify_hash
    '
    local URL=${1:-${URL:-""}}
    local DEFAULT_DST
    DEFAULT_DST=$(basename "$URL")
    local DST=${2:-${DST:-$DEFAULT_DST}}
    local EXPECTED_HASH=${3:-${EXPECTED_HASH:-'*'}}
    local HASHER=${4:-sha256sum}
    local CURL_OPTS=${5:-"${CURL_OPTS}"}
    local VERBOSE=${6:-${VERBOSE:-"3"}}

    $(system_python) -c "import sys; sys.exit(0 if ('$HASHER' in {'sha256sum', 'sha512sum'}) else 1)"

    if [ $? -ne 0 ]; then
        echo "HASHER = $HASHER is not in the known list"
        return 1
    fi

    if [ "$VERBOSE" -ge 3 ]; then
        codeblock "
            curl_verify_hash
                * URL='$URL'
                * DST='$DST'
                * CURL_OPTS='$CURL_OPTS'
            "
    fi

    # Download the file
    # shellcheck disable=SC2086
    curl $CURL_OPTS "$URL" --output "$DST"

    # Verify the hash
    verify_hash "$DST" "$EXPECTED_HASH" "$HASHER" "$VERBOSE"
    return $?
}


install_prereqs(){
    if [ "$(type -P python)" != "" ]; then
        if [ "$(type -P python3)" != "" ]; then
            apt_ensure python3
        fi
    fi
    UPDATE=1 apt_ensure curl tmux
}

install_go(){
    ARCH="$(dpkg --print-architecture)"
    echo "ARCH = $ARCH"
    GO_VERSION="1.17.5"
    GO_KEY=go${GO_VERSION}.linux-${ARCH}
    URL="https://go.dev/dl/${GO_KEY}.tar.gz"

    mkdir -p "$HOME/temp/setup-go"
    cd "$HOME/temp/setup-go"

    declare -A GO_KNOWN_HASHES=(
        ["go1.17.5.linux-amd64-sha256"]="bd78114b0d441b029c8fe0341f4910370925a4d270a6a590668840675b0c653e"
        ["go1.17.5.linux-arm64-sha256"]="6f95ce3da40d9ce1355e48f31f4eb6508382415ca4d7413b1e7a3314e6430e7e"
    )
    EXPECTED_HASH="${GO_KNOWN_HASHES[${GO_KEY}-sha256]}"
    BASENAME=$(basename "$URL")
    curl_verify_hash "$URL" "$BASENAME" "$EXPECTED_HASH" sha256sum "-L"

    #INSTALL_PREFIX=$HOME/.local

    mkdir -p "$INSTALL_PREFIX"
    tar -C "$INSTALL_PREFIX" -xzf "$BASENAME"
    mkdir -p "$INSTALL_PREFIX/bin"
    # Add $INSTALL_PREFIX/go/bin to your path or make symlinks
    ln -s "$INSTALL_PREFIX/go/bin/go" "$INSTALL_PREFIX/bin/go"
    ln -s "$INSTALL_PREFIX/go/bin/gofmt" "$INSTALL_PREFIX/bin/gofmt"
}


install_ipfs(){
    # IPFS itself
    mkdir -p "$HOME/temp/setup-ipfs"
    cd "$HOME/temp/setup-ipfs"

    ARCH="$(dpkg --print-architecture)"
    echo "ARCH = $ARCH"
    IPFS_VERSION="v0.12.0-rc1"
    IPFS_KEY=go-ipfs_${IPFS_VERSION}_linux-${ARCH}
    URL="https://dist.ipfs.io/go-ipfs/${IPFS_VERSION}/${IPFS_KEY}.tar.gz"
    declare -A IPFS_KNOWN_HASHES=(
        ["go-ipfs_v0.12.0-rc1_linux-arm64-sha512"]="730c9d7c31f5e10f91ac44e6aa3aff7c3e57ec3b2b571e398342a62d92a0179031c49fc041cd063403147377207e372d005992fee826cd4c4bba9b23df5c4e0c"
        ["go-ipfs_v0.12.0-rc1_linux-amd64-sha512"]="b0f913f88c515eee75f6dbf8b41aedd876d12ef5af22762e04c3d823964207d1bf314cbc4e39a12cf47faad9ca8bbbbc87f3935940795e891b72c4ff940f0d46"
    )
    EXPECTED_HASH="${IPFS_KNOWN_HASHES[${IPFS_KEY}-sha512]}"
    BASENAME=$(basename "$URL")
    curl_verify_hash "$URL" "$BASENAME" "$EXPECTED_HASH" sha512sum

    echo "BASENAME = $BASENAME"
    tar -xvzf "$BASENAME"
    cp go-ipfs/ipfs "$INSTALL_PREFIX/bin"
}


initialize_ipfs(){
    __doc__="

    In addition to these steps, to get the IPFS node online we need to:
        (1) give the machine a static IP on your local (router) network
        (2) Forward port 4001 to your machine

    "
    # That should install IPFS now, lets set it up

    # https://github.com/lucas-clemente/quic-go/wiki/UDP-Receive-Buffer-Size
    # Optional: Increase max buffer size to 2.5MB
    #if [ "$(whoami)" == "root" ]; then 
    #    sysctl -w net.core.rmem_max=2500000
    #else
    #    sudo sysctl -w net.core.rmem_max=2500000
    #fi

    # Maybe server is not the best profile?
    # https://docs.ipfs.io/how-to/command-line-quick-start/#prerequisites
    #ipfs init --profile server
    #ipfs init --profile badgerds
    ipfs init --profile lowpower

    # To run a node you have to start the ipfs daemon (we can do it in tmux)
    # You will also need to ensure port 4001 is open
    tmux new-session -d -s "ipfs_daemon" "ipfs daemon"

    # Swarm wont work until the daemon is running, so retry until it works
    max_retry=60
    counter=0
    COMMAND="ipfs swarm peers"
    until $COMMAND
    do
       sleep 5
       # https://unix.stackexchange.com/questions/168354/can-i-see-whats-going-on-in-a-tmux-session-without-attaching-to-it/168384
       # check whats going on with the deamon
       tmux capture-pane -pt "ipfs_daemon" -S -10
       [[ counter -eq $max_retry ]] && echo "Failed!" && exit 1
       echo "Trying again. Try #$counter"
       ((counter++))
    done

    # Quick test that we can look at the IPFS README
	ipfs cat /ipfs/QmQPeNsJPyVWPFDVHb77w8G42Fvo15z4bG2X8D2GhfbSXc/readme
}


install_ipfs_service(){
    __doc__="
    Installing a service to run the IPFS daemon requires sudo

    Usage:
        source ~/local/init/setup_ipfs.sh
        install_ipfs_service
    "
    # https://gist.github.com/pstehlik/9efffa800bd1ddec26f48d37ce67a59f
    # https://www.maxlaumeister.com/u/run-ipfs-on-boot-ubuntu-debian/
    # https://linuxconfig.org/how-to-create-systemd-service-unit-in-linux#:~:text=There%20are%20basically%20two%20places,%2Fetc%2Fsystemd%2Fsystem%20.
    SERVICE_DPATH=/etc/systemd/system
    SERVICE_FPATH=$SERVICE_DPATH/ipfs.service
    IPFS_EXE=$(which ipfs)

    # TODO: This will depend on how you initialized IPFS
    #IPFS_PATH=/data/ipfs
    #IPFS_PATH=$HOME/.ipfs

    echo "IPFS_EXE = $IPFS_EXE"
    echo "SERVICE_FPATH = $SERVICE_FPATH"
    echo "IPFS_PATH = $IPFS_PATH"

    sudo_writeto $SERVICE_FPATH "
        [Unit]
        Description=IPFS daemon
        After=network.target
        [Service]
        Environment=\"IPFS_PATH=$IPFS_PATH\"
        User=$USER
        ExecStart=${IPFS_EXE} daemon
        [Install]
        WantedBy=multiuser.target
        "
    #sudo systemctl daemon-reload
    sudo systemctl start ipfs
    sudo systemctl status ipfs
}


install_ipfs_cluster(){
    __doc__="
    Downloads and installs the IPFS cluster binaries

    References:
        https://cluster.ipfs.io/documentation/deployment/setup/
    "
    source ~/local/init/utils.sh
    mkdir -p "$HOME/temp/setup-ipfs-cluster"
    cd "$HOME/temp/setup-ipfs-cluster"

    ARCH="$(dpkg --print-architecture)"
    IPFS_CLUSTER_VERSION="v0.14.4"

    EXE_NAME=ipfs-cluster-ctl
    KEY=${EXE_NAME}_${IPFS_CLUSTER_VERSION}_linux-${ARCH}
    URL="https://dist.ipfs.io/${EXE_NAME}/${IPFS_CLUSTER_VERSION}/$KEY.tar.gz"
    declare -A KNOWN_HASHES=(
        ["ipfs-cluster-ctl_v0.14.4_linux-arm64-sha512"]="2c8d2d5023c4528a902889b33a7e52fd71261f34ada62999d6a8fe3910d652093a95320693f581937d8509ccb07ff5b9501985e0262a67c12e64419fa49e4339"
        ["ipfs-cluster-ctl_v0.14.4_linux-amd64-sha512"]="454331518c0d67319c873c69b7fceeab06cbe4bb926cecb16cc46da86be79d56f63b7100b9ccba5a9c6e99722e27446e33623d7191f3b09c6faed4c36c15204a"
    )
    EXPECTED_HASH="${KNOWN_HASHES[${KEY}-sha512]}"
    BASENAME=$(basename "$URL")
    curl_verify_hash "$URL" "$BASENAME" "$EXPECTED_HASH" sha512sum

    EXE_NAME=ipfs-cluster-service
    KEY=${EXE_NAME}_${IPFS_CLUSTER_VERSION}_linux-${ARCH}
    URL="https://dist.ipfs.io/${EXE_NAME}/${IPFS_CLUSTER_VERSION}/$KEY.tar.gz"
    declare -A KNOWN_HASHES=(
        ["ipfs-cluster-service_v0.14.4_linux-arm64-sha512"]="79129b6cc94d36a9921f8e07e207ee13336c89a245a44b075b0ada50b72796b31a7e90bf15171e355e0a1e08cc55e40e67376f813016d678f5a7d007327ffd04"
        ["ipfs-cluster-service_v0.14.4_linux-amd64-sha512"]="430dbbab5c651fcf99ae9b122fc663cdb5785e51e8dc6c2381b0b82e5f963c5945f9c1c10781d50a5aeac675dc3bbf783b2e03b8c3d5fb5e94804cb2c2efcc9f"
    )
    EXPECTED_HASH="${KNOWN_HASHES[${KEY}-sha512]}"
    BASENAME=$(basename "$URL")
    curl_verify_hash "$URL" "$BASENAME" "$EXPECTED_HASH" sha512sum


    EXE_NAME=ipfs-cluster-follow
    KEY=${EXE_NAME}_${IPFS_CLUSTER_VERSION}_linux-${ARCH}
    URL="https://dist.ipfs.io/${EXE_NAME}/${IPFS_CLUSTER_VERSION}/$KEY.tar.gz"
    declare -A KNOWN_HASHES=(
        ["ipfs-cluster-follow_v0.14.4_linux-arm64-sha512"]="136fe71f0df0dd44b5ac3e97db8529399dfa84e18fb7b15f16120503dcb44b339e55263a264d1c3ff4bd693c68bcfe5bc208b4b37aa29402fb545256ab06eb88"
        ["ipfs-cluster-follow_v0.14.4_linux-amd64-sha512"]="22ac2f2a89693c715be5f8a528c89def7c54abc3a3256a85468730c974831dff2e0a21ea489d66c0457f61e7e76d948614c99794333cb8a0dabf3e4a04f74ef8"
    )
    EXPECTED_HASH="${KNOWN_HASHES[${KEY}-sha512]}"
    BASENAME=$(basename "$URL")
    curl_verify_hash "$URL" "$BASENAME" "$EXPECTED_HASH" sha512sum

    tar -xvzf "ipfs-cluster-ctl_v0.14.4_linux-${ARCH}.tar.gz"
    tar -xvzf "ipfs-cluster-follow_v0.14.4_linux-${ARCH}.tar.gz"
    tar -xvzf "ipfs-cluster-service_v0.14.4_linux-${ARCH}.tar.gz"

    [ "$INSTALL_PREFIX" != "" ] || (echo "need to set INSTALL_PREFIX" && false)

    #INSTALL_PREFIX="$HOME/.local"
    mkdir -p "$INSTALL_PREFIX/bin"
    cp -v -- */ipfs-cluster-* "$INSTALL_PREFIX/bin"
}


install_ipfs_cluster_service(){
    __doc__="
    Installing a service to run the IPFS daemon requires sudo

    Usage:
        source ~/local/init/setup_ipfs.sh
        install_ipfs_service
    "
    # https://gist.github.com/pstehlik/9efffa800bd1ddec26f48d37ce67a59f
    # https://www.maxlaumeister.com/u/run-ipfs-on-boot-ubuntu-debian/
    # https://linuxconfig.org/how-to-create-systemd-service-unit-in-linux#:~:text=There%20are%20basically%20two%20places,%2Fetc%2Fsystemd%2Fsystem%20.
    SERVICE_DPATH=/etc/systemd/system
    SERVICE_FPATH=$SERVICE_DPATH/ipfs-cluster.service
    SERVICE_EXE=$(which ipfs-cluster-service)
    SERVICE_COMMAND="${SERVICE_EXE} daemon"

    # TODO: This will depend on how you initialized IPFS
    #IPFS_PATH=/data/ipfs
    #IPFS_PATH=$HOME/.ipfs

    echo "SERVICE_FPATH = $SERVICE_FPATH"
    echo "SERVICE_COMMAND = $SERVICE_COMMAND"
    echo "IPFS_CLUSTER_PATH = $IPFS_CLUSTER_PATH"

    sudo_writeto $SERVICE_FPATH "
        [Unit]
        Description=IPFS Cluster daemon
        After=network.target
        [Service]
        Environment=\"IPFS_CLUSTER_PATH=$IPFS_CLUSTER_PATH\"
        User=$USER
        ExecStart=${SERVICE_COMMAND}
        [Install]
        WantedBy=multiuser.target
        "
    #sudo systemctl daemon-reload
    sudo systemctl start ipfs-cluster
    systemctl status ipfs-cluster
    #sudo systemctl stop ipfs-cluster
}


init_ipfs_cluster(){
    __doc__="
    Simple configuration of IPFS cluster

    source ~/local/init/setup_ipfs.sh

    References:
        https://cluster.ipfs.io/documentation/deployment/setup/
    "

    #export IPFS_PATH=/data/ipfs

    # The online docs aren't entirely clear what is going on here My thought is
    # that you initialize a "root peer" once, which gives you and ID and then
    # you need to init other members of the cluster (with full permissions) by
    # passing along that root info.
    ipfs-cluster-service init --consensus crdt


    # Followers should not need that root info.
}

start_ipfs_cluster(){

    # https://cluster.ipfs.io/documentation/deployment/bootstrap/ 
    ### probably needs to make a service for this:
    ipfs-cluster-service daemon
}


pin_my_shit(){
    # Quicker test
    ipfs pin add QmWhKBAQ765YH2LKMQapWp7mULkQxExrjQKeRAWNu5mfBK --progress

    # Pin my shit (15GB might take awhile)
    #tmux new-session -d -s "ipfs_pin" "ipfs pin add QmNj2MbeL183GtPoGkFv569vMY8nupUVGEVvvvqhjoAATG --progress"
    ipfs pin add QmaPPoPs7wXXkBgJeffVm49rd63ZtZw5GrhvQQbYrUbrYL --progress

    # High level analysis subdir
    ipfs ls QmbvEN1Ky3MGGBVDwyMBZvdUCFi1WvfdzkTzgtE7sAvW9B

    # Should be possible to viz a single image without too much DL time
    ipfs get QmWpFhhLfXhWhnYdCJP6pE8E8obFceYTa7XZyc2Dkk9AaZ -o scat_scatterplot.png && eog scat_scatterplot.png
    ipfs get QmVnDcQdcB59yt8e6ky49MnNCCuMNbSjyFkwRBM4bDysBq -o viz_align_process.png  && eog viz_align_process.png
}


main(){
    # Step 0: Ensure we have prereqs
    install_prereqs

    # Step 1: Ensure we have a go executable
    install_go 

    # Step 2: Install IPFS itself
    install_ipfs 

    # Step 3: Initialize IPFS
    initialize_ipfs

    # Step 4 (optional): Pin my shit
    pin_my_shit
}
