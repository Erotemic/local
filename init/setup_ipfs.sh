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
        # shellcheck disable=SC2016
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
    # shellcheck disable=SC2016
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
    # shellcheck disable=SC2181
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
    # shellcheck disable=SC2181
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
    #UPDATE=1 apt_ensure curl tmux
    UPDATE=1 apt_ensure curl
}

install_go(){
    __doc__="
    References:
        # CHeck for new versions here
        https://go.dev/dl

    Ignore:
        # Logic to scrape the download table and help populate our known hashes
        import bs4
        from packaging.version import parse as Version
        import pandas as pd
        from bs4 import BeautifulSoup
        import requests
        url = 'https://go.dev/dl'
        got = requests.request('get', url)
        print(got.text)
        soup = BeautifulSoup(got.text, 'html.parser')
        for item in soup.find_all(name='table'):
            if 'downloadtable' in item.attrs.get('class', []):
                go_version = Version(item.parent.parent.attrs['id'].replace('go', ''))
                if go_version < Version('1.17'):
                    continue
                print('=====')
                print(go_version)
                print('=====')
                table = pd.read_html(str(item))[0]
                subtable = table
                subtable = subtable[subtable['Kind'] == 'Archive']
                subtable = subtable[subtable['OS'] == 'Linux']
                for _, row in subtable.iterrows():
                    dq, sq = chr(34), chr(39)
                    go_key = row['File name'].replace('.tar.gz', '')
                    hashid = row['SHA256 Checksum']
                    print(f'[{dq}{go_key}-sha256{dq}]={dq}{hashid}{dq}')
    "
    ARCH="$(dpkg --print-architecture)"
    echo "ARCH = $ARCH"
    GO_VERSION="1.19.5"
    OS_KEY=linux
    GO_KEY=go${GO_VERSION}.${OS_KEY}-${ARCH}
    URL="https://go.dev/dl/${GO_KEY}.tar.gz"

    STAGING_DPATH="$HOME/temp/setup-go/go-${GO_VERSION}"
    mkdir -p "$STAGING_DPATH"

    declare -A GO_KNOWN_HASHES=(
        ["go1.19.5.linux-386-sha256"]="f68331aa7458a3598060595f5601d5731fd452bb2c62ff23095ddad68854e510"
        ["go1.19.5.linux-amd64-sha256"]="36519702ae2fd573c9869461990ae550c8c0d955cd28d2827a6b159fda81ff95"
        ["go1.19.5.linux-arm64-sha256"]="fc0aa29c933cec8d76f5435d859aaf42249aa08c74eb2d154689ae44c08d23b3"
        ["go1.19.5.linux-armv6l-sha256"]="ec14f04bdaf4a62bdcf8b55b9b6434cc27c2df7d214d0bb7076a7597283b026a"
        ["go1.19.5.linux-ppc64le-sha256"]="e4032e7c52ebc48bad5c58ba8de0759b6091d9b1e59581a8a521c8c9d88dbe93"
        ["go1.19.5.linux-s390x-sha256"]="764871cbca841a99a24e239b63c68a4aaff4104658e3165e9ca450cac1fcbea3"

        ["go1.18.10.linux-386-sha256"]="9249551992c9518ec8ce6690d32206f12ed9122e360407f7e7ab9a6adc627a9b"
        ["go1.18.10.linux-amd64-sha256"]="5e05400e4c79ef5394424c0eff5b9141cb782da25f64f79d54c98af0a37f8d49"
        ["go1.18.10.linux-arm64-sha256"]="160497c583d4c7cbc1661230e68b758d01f741cf4bece67e48edc4fdd40ed92d"
        ["go1.18.10.linux-armv6l-sha256"]="e9f2f2361364c04a8f0d12228e4c5c2b870f4d1639ca92031c4013a95aa205be"
        ["go1.18.10.linux-ppc64le-sha256"]="761014290febf0e10dfeba44ec551792dad32270a11debee8ed4f30c5f3c760d"
        ["go1.18.10.linux-s390x-sha256"]="9755ab0460a04b535e513fac84db2e1ae6a197d66d3a097e14aed3b3114df85d"

        ["go1.17.5.linux-386-sha256"]="4f4914303bc18f24fd137a97e595735308f5ce81323c7224c12466fd763fc59f"
        ["go1.17.5.linux-amd64-sha256"]="bd78114b0d441b029c8fe0341f4910370925a4d270a6a590668840675b0c653e"
        ["go1.17.5.linux-arm64-sha256"]="6f95ce3da40d9ce1355e48f31f4eb6508382415ca4d7413b1e7a3314e6430e7e"
        ["go1.17.5.linux-armv6l-sha256"]="aa1fb6c53b4fe72f159333362a10aca37ae938bde8adc9c6eaf2a8e87d1e47de"
        ["go1.17.5.linux-ppc64le-sha256"]="3d4be616e568f0a02cb7f7769bcaafda4b0969ed0f9bb4277619930b96847e70"
        ["go1.17.5.linux-s390x-sha256"]="8087d4fe991e82804e6485c26568c2e0ee0bfde00ceb9015dc86cb6bf84ef40b"
    )
    EXPECTED_HASH="${GO_KNOWN_HASHES[${GO_KEY}-sha256]}"
    BASENAME=$(basename "$URL")
    curl_verify_hash "$URL" "$STAGING_DPATH/$BASENAME" "$EXPECTED_HASH" sha256sum "-L"

    echo "Downloaded go archive to staging directory"
    ls -al "$STAGING_DPATH"

    if [[ "$INSTALL_PREFIX" == "" ]]; then
        INSTALL_PREFIX=$HOME/.local
        echo "defaulting INSTALL_PREFIX = $INSTALL_PREFIX"
    fi
    mkdir -p "$INSTALL_PREFIX/bin"
    mkdir -p "$INSTALL_PREFIX/go"

    echo "Unpacking archive"
    tar -C "$STAGING_DPATH" -xzf "$STAGING_DPATH/$BASENAME"
    echo "Moving unpacked archive into a versioned install prefix"
    rm -rf "$INSTALL_PREFIX/go/go-${GO_VERSION}"
    mv -v "$STAGING_DPATH/go" "$INSTALL_PREFIX/go/go-${GO_VERSION}"

    # Add $INSTALL_PREFIX/go/bin to your path or make symlinks
    echo "Symlinking binaries into the main install bin"
    ln -sfv "$INSTALL_PREFIX/go/go-${GO_VERSION}/bin/go" "$INSTALL_PREFIX/bin/go"
    ln -sfv "$INSTALL_PREFIX/go/go-${GO_VERSION}/bin/gofmt" "$INSTALL_PREFIX/bin/gofmt"
}


install_ipfs(){
    __doc__="
    Install or upgrade IPFS

    source ~/local/init/setup_ipfs.sh
    install_ipfs

    References:
        https://dist.ipfs.tech/#kubo
        https://dist.ipfs.io/kubo/
    "
    # IPFS itself
    mkdir -p "$HOME/temp/setup-ipfs"
    # shellcheck disable=SC2164
    cd "$HOME/temp/setup-ipfs"

    export INSTALL_PREFIX=$HOME/.local

    ARCH="$(dpkg --print-architecture)"
    echo "ARCH = $ARCH"
    IPFS_VERSION="v0.21.0"
    IPFS_KEY=kubo_${IPFS_VERSION}_linux-${ARCH}
    URL="https://dist.ipfs.io/kubo/${IPFS_VERSION}/${IPFS_KEY}.tar.gz"
    #IPFS_KEY=go-ipfs_${IPFS_VERSION}_linux-${ARCH}
    #URL="https://dist.ipfs.io/go-ipfs/${IPFS_VERSION}/${IPFS_KEY}.tar.gz"
    #declare -A IPFS_KNOWN_HASHES=(
    #    ["go-ipfs_v0.12.0-rc1_linux-arm64-sha512"]="730c9d7c31f5e10f91ac44e6aa3aff7c3e57ec3b2b571e398342a62d92a0179031c49fc041cd063403147377207e372d005992fee826cd4c4bba9b23df5c4e0c"
    #    ["go-ipfs_v0.12.0-rc1_linux-amd64-sha512"]="b0f913f88c515eee75f6dbf8b41aedd876d12ef5af22762e04c3d823964207d1bf314cbc4e39a12cf47faad9ca8bbbbc87f3935940795e891b72c4ff940f0d46"
    #    ["go-ipfs_v0.13.0_linux-arm64-sha512"]="90c695eedd7e797b9200c91698ef1a6577057fa1774b8afaa4dcf8e6c9580baa323acef25cc25b70e0591954e049f5cd7ddc0ad12274f882fe3e431bb6360c0b"
    #    ["go-ipfs_v0.13.0_linux-amd64-sha512"]="40c3f69af9e7a72fa9836ba87cd471c82194bd64cf4a9cedfd730ab457b7f2a4ede861a2cfcb936e232e690fd26ef398d88e3ca55e1ec57795bf0bb8aae62a78"
    #)
    declare -A IPFS_KNOWN_HASHES=(
        ["kubo_v0.14.0_linux-amd64-sha512"]="d841cc5c727c41ba40a815bc1a63e2bc2b9e1ce591e5cd9815707bfcd4400f2d3700dbc18dfaa8460748279a89d2cc6086b1dedc2ab37d4d7dc4ab8f1c50e723"
        ["kubo_v0.14.0_linux-arm64-sha512"]="aba56721621e4f4b42350bfe43fa50e2166e8841e65da948b24eb243d962effa4a6b8b8a55dac35fc34961b65d739d3ac0550654819e59804a66d211f95f822c"
        ["kubo_v0.20.0_linux-amd64-sha512"]="2113053565c8e6ccd1c28b70ef2a12871d3485256b8d5c8576a1bacb530a91d1a9eaeb619368353355d236f75b2dbda205da6051004cffad7086edbbdd116951"
        ["kubo_v0.20.0_linux-arm64-sha512"]="ba94be6d35ca77b056c4a9367122ce33484e21c0650e9001800f69bea27e5af1c84840e9df944542eaa909a9b50131a53a47a4cae56cbff5efcf30fe4282d2ad"
        ["kubo_v0.21.0_linux-amd64.tar.gz"]="ae6be96a112159fee9994c1c9547cbaf71438eb0fa819e898ddfa677c964f15ec5c9698d1a2f121f2c7dac88b0d032938941d2bffa755fac61d9fcaa1829050f"
        ["kubo_v0.21.0_linux-arm64.tar.gz"]="1eeb4015f135a1775e8cd96ab249f14a94306170bd714a97c3d907979022d7a5fb6a1070bf0e598e0b02bc439cf4f2a3e61901d5db245993fce29f6a7ce675d9"

    )
    EXPECTED_HASH="${IPFS_KNOWN_HASHES[${IPFS_KEY}-sha512]}"
    BASENAME=$(basename "$URL")
    curl_verify_hash "$URL" "$BASENAME" "$EXPECTED_HASH" sha512sum

    echo "BASENAME = $BASENAME"
    #rm -rf-ipfs/ipfs
    tar -xvzf "$BASENAME"

    # TODO: stop and start the IPFS service before upgrade
    #sudo systemctl stop ipfs
    #sudo systemctl stop ipfs-cluster
    cp kubo/ipfs "$INSTALL_PREFIX/bin"
    #sudo systemctl start ipfs-cluster
    ipfs --version
    #sudo systemctl start ipfs
}


_scrape_ipfs_version_info(){
    # Use to generate the declared known hash table
    pip install beautifulsoup4
    __doc__='
    import requests
    import json
    base_url = "https://dist.ipfs.io/kubo"
    resp = requests.get(base_url + "/versions")
    versions = [v for v_ in resp.text.split("\n") if (v:= v_.strip())]
    from distutils.version import LooseVersion
    min = LooseVersion("v0.11.0")
    export_versions = []
    for ver in versions:
        if LooseVersion(ver) > min:
            export_versions.append(ver)

    print(export_versions)
    table = []
    for ver in export_versions:
        dist_url = base_url + f"/{ver}/dist.json"
        dist_resp_fpath = ub.grabdata(dist_url, fname=ub.hash_data(dist_url) + ".json", expires=1000)
        dist_data = json.loads(ub.Path(dist_resp_fpath).read_text())
        #data = dist_resp.json()

        dist_data["releaseLink"]
        for plat_name, items in dist_data["platforms"].items():
            for arch_name, arch_info in items["archs"].items():
                arch_info["cid"]
                full_url = base_url + "/" + arch_info["link"]
                hash = arch_info["sha512"]
                arch_info["full_url"] = full_url
                arch_info["plat_name"] = plat_name
                arch_info["arch"] = arch_name
                table.append(arch_info)

    for arch_info in table:
        name = arch_info["link"].lstrip("/")
        sha = arch_info["sha512"]
        if arch_info["plat_name"] in {"linux"}:
            if arch_info["arch"] in {"amd64", "arm64"}:
                line = f""" ["{name}"]="{sha}" """.strip()
                print(line)
    '
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

    # To run a node you have to start the ipfs daemon (we can do it in tmux)
    # You will also need to ensure port 4001 is open
    # TODO: test if daemon already running
    tmux new-session -d -s "ipfs_daemon" "ipfs daemon"

    # Maybe server is not the best profile?
    # https://docs.ipfs.io/how-to/command-line-quick-start/#prerequisites
    #ipfs init --profile server
    #ipfs init --profile badgerds
    ipfs init --profile lowpower

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

    # Stop the IPFS daemon
    tmux kill-session -t "ipfs_deamon"
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

    # Note: can add "--mount" to ExecStart if you
    # Want to mount ipfs via fuse
    #
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
    # shellcheck disable=SC1090
    source ~/local/init/utils.sh
    mkdir -p "$HOME/temp/setup-ipfs-cluster"
    # shellcheck disable=SC2164
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


setup_lotus_filecoin(){
    sudo apt install mesa-opencl-icd ocl-icd-opencl-dev gcc git bzr jq pkg-config curl clang build-essential hwloc libhwloc-dev wget -y && sudo apt upgrade -y

    git clone https://github.com/filecoin-project/lotus.git "$HOME"/code/lotus
    # shellcheck disable=SC2164
    cd ~/code/lotus/
    git checkout v1.15.1

    # Building for the mainnet
    make clean all #mainnet

    # Current version has no PREFIX support, we have to install into /usr/local
    # https://github.com/filecoin-project/lotus/discussions/8499
    sudo make install

    # shellcheck disable=SC1090
    source ~/local/init/utils.sh
    tmux_spawn "FULLNODE_API_INFO=wss://api.chain.love lotus daemon --lite"

    # Generate a new wallet
    FILECOIN_WALLET_ADDRESS=$(lotus wallet new)
    echo "FILECOIN_WALLET_ADDRESS = $FILECOIN_WALLET_ADDRESS"
    # This public address for me is f1pd7drg3lw5rnfay3hyfojb4dc2tqjytzbmwv2ty
    lotus wallet list

    # Do whatever you need to do to load a super secret place to store your
    # private keys. This is money. Do more than transcrypt protection.
    load_secrets
    mount_super_secrets
    echo "$SUPER_SECRET_DPATH"
    mkdir -p "$SUPER_SECRET_DPATH/coins/filecoin"
    lotus wallet export "$FILECOIN_WALLET_ADDRESS" > "$SUPER_SECRET_DPATH/coins/filecoin/filecoin_$FILECOIN_WALLET_ADDRESS.key"
    dismount_super_secrets

    # Need to get a "DataCap" by connecting an establish github account
    # to
    # For me, the verified message I got for my first data cap is here
    # https://filfox.info/en/message/bafy2bzacea4xbidxeycalqw73ef4mj4ekqrpyeisw5avfcpo4grmdpgh7ecim

    # We are going to start a deal to

    # Find a few storage providers on https://plus.fil.org/miners and import their client ids

    # We have an IPFS directory we can use
    Qmd4PzLWTZiawH1W3VzoAbkyh9hCopjqSVAddYF8PrYBfE
    bafybeieomldhqd2iehx6bgtnkwznw2q3ozzjlu5pkkmjjmintp2fer4koq

    ipfs cid base32 Qmd4PzLWTZiawH1W3VzoAbkyh9hCopjqSVAddYF8PrYBfE
    ipfs cid base32 bafybeieomldhqd2iehx6bgtnkwznw2q3ozzjlu5pkkmjjmintp2fer4koq

    ipfs cid format -v 1 -b base32 Qmd4PzLWTZiawH1W3VzoAbkyh9hCopjqSVAddYF8PrYBfE

    # to use existing IPFS data we need to specify a lotus config:
    # https://lotus.filecoin.io/tutorials/lotus/import-data-from-ipfs/
    sed -ie 's|#*UseIpfs.*|UseIpfs=true|g' ~/.lotus/config.toml
    lotus client deal

    lotus client list-deals --show-failed
    lotus client list-deals

    lotus client list-transfers

    # Specify the CID: Qmd4PzLWTZiawH1W3VzoAbkyh9hCopjqSVAddYF8PrYBfE
    # Specify duration in days: 180
    # Specify miner ids f01652333 f015927 f01278 f071624

    # Results:
    #Deal (f01652333) CID: bafyreiczjybwrnnq2it3jyayhyxq6j52m7xxnwa76nkzghbb46axx3xnry
    #Deal (f015927) CID: bafyreiekudp5avm23hzxozdzabzq6augoxf2dnz3mjie46kng7qjzi3uky
    #Deal (f01278) CID: bafyreiegvbeyoh5ad3mvei5c33ch5bhsqqudd7v6hn2kauxehrjca7762q
    #Deal (f071624) CID: bafyreig2sx3knejoef6xbrsztuyvihog5przpvol6qfxt5fesmxpdf6er4

    # or we can specify an environ
    #LOTUS_CLIENT_USEIPFS=true lotus client deal Qmd4PzLWTZiawH1W3VzoAbkyh9hCopjqSVAddYF8PrYBfE 180 f01652333
    #cd /home/joncrall/data/dvc-repos/shitspotter_dvc/assets/
    #lotus client import poop-2022-04-16-T135257
}


configure_ipfs_location(){
    # Move the IPFS folder to a data drive and symlink to the homedrive
    export IPFS_PATH=$HOME/.ipfs
    # For example...
    IPFS_STORAGE_DPATH=/data/ipfs

    sudo systemctl stop ipfs

    rsync -avprP "$HOME"/.ipfs "$IPFS_STORAGE_DPATH"

    # Symlink the default location to the storage loc
    mv "$IPFS_PATH" "$IPFS_PATH"-old
    ln -s "$IPFS_STORAGE_DPATH" "$IPFS_PATH"

    sudo systemctl start ipfs
    sudo systemctl status ipfs
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

    # Step 3.1 init ipfs as a service
    install_ipfs_service

    # Step 3.5 test pinning
    ipfs pin add QmWhKBAQ765YH2LKMQapWp7mULkQxExrjQKeRAWNu5mfBK --progress

    # Step 4 (optional): Pin my shit
    #pin_my_shit
}


install_client_only(){

    # Step 1: Ensure we have a go executable
    install_go

    install_ipfs

    ipfs init
}

pin_named_content(){
    ipfs pin add --name "Crall-Thesis-2017-Final-State" --progress QmTD1nZ4pbrB1SnjkLGt9Cs37mZbabXqjn6YZaAKVEoSvY
    ipfs pin add --name "crall-2023-mcc-fm-relation-paper.pdf" --progress bafkreih66fikzpaic3opzhuyunje7sqapgpyzaxxs3mvbhdpin65x3bbru

    # List named pins
    ipfs pin ls --type="recursive" --names
}


install-ipfs-update(){
    # https://github.com/ipfs/ipfs-update
    # https://docs.ipfs.tech/how-to/ipfs-updater/
    wget https://dist.ipfs.tech/ipfs-update/v1.9.0/ipfs-update_v1.9.0_linux-arm.tar.gz
    tar -xvzf ipfs-update_v1.9.0_linux-arm.tar.gz

    wget https://dist.ipfs.tech/ipfs-update/v1.9.0/ipfs-update_v1.9.0_linux-amd64.tar.gz
    tar -xvzf ipfs-update_v1.9.0_linux-amd64.tar.gz

    export INSTALL_PREFIX=$HOME/.local
    mv ipfs-update/ipfs-update "$INSTALL_PREFIX"/bin/
    rm -rf ipfs-update
    ipfs-update install latest
}

install-ipget(){
    # https://dist.ipfs.tech/#ipget
    curl -LJO https://dist.ipfs.tech/ipget/v0.9.1/ipget_v0.9.1_linux-amd64.tar.gz
    tar -xvzf ipget_v0.9.1_linux-amd64.tar.gz
    export INSTALL_PREFIX=$HOME/.local
    mv ipget/ipget "$INSTALL_PREFIX"/bin/
    rm -rf ipget

    ipget bafybeicydgguvhts4ejcnyausvw6sff453htpxp5tktcigdyy6hdkuovgy --progress
}

local_ipfs_mount(){
    __doc__="
    References:
        https://github.com/ipfs/kubo/blob/master/docs/fuse.md
    "
    sudo apt-get install fuse
    #sudo usermod -a -G fuse "$USER"

    sudo systemctl stop ipfs.service

    sudo mkdir /ipfs
    sudo mkdir /ipns
    sudo chown "$USER" /ipfs
    sudo chown "$USER" /ipns

    # MANUAL: Ensure the daemon is run with --mount as done in install_ipfs_service

    sudo systemctl start ipfs.service
    systemctl status ipfs.service

    #sudo systemctl stop ipfs.service


    # Case where fuse did not exist
    sudo addgroup fuse
    sudo usermod -G fuse -a "$USER"
    sudo chgrp fuse /etc/fuse.conf
    sudo chmod g+r  /etc/fuse.conf


}

ipfs_howto(){
    # Remove a pin
    ipfs pin rm QmPptXKFKi6oTJL3VeCNy5Apk8MJsHhCAAwVmegHhuRY83
    ipfs pin rm bafybeif2yoidrnrzbpofcdlvl33em5e6eoslk4ryb7pe6ployl7najdi7q
}


check_ipfs_status(){
    __doc__="
    References:
        https://discuss.ipfs.tech/t/how-can-i-tell-if-my-ipfs-node-is-publicly-available/14237
        https://discuss.ipfs.tech/t/feasibility-for-self-hosting-scientific-datasets/17355
    "

    # Check if accelerated dht is on
    ipfs config --json Routing.AcceleratedDHTClient

    # Check your id
    ipfs id

    # Alternative single-output way to get the NodeID
    ipfs config --json Identity.PeerID

    # Force providing a CID
    ipfs dht provide bafybeie275n5f4f64vodekmodnktbnigsvbxktffvy2xxkcfsqxlie4hrm

    # Quick status
    systemctl -l status ipfs.service --no-pager

    # Full service logs
    journalctl -u ipfs.service

    # Get your WAN IP Address
    WAN_IP_ADDRESS=$(curl ifconfig.me)
    echo "WAN_IP_ADDRESS = $WAN_IP_ADDRESS"

    # Check if node is visible to WAN
    # https://canyouseeme.org/
    # https://portchecker.co/canyouseeme


    # Check if the DHT has been initially populated
    ipfs stats dht
}

setup_firewall(){
    sudo ufw status

    # Check ports currently in use:  sudo lsof -i -P -n | grep LISTEN
    # https://github.com/imthenachoman/How-To-Secure-A-Linux-Server#firewall-with-ufw-uncomplicated-firewall

    # ssh should be allowed
    sudo ufw allow "22/tcp" comment 'Allow SSH'

    # Add rules to allow IPFS traffic on port 4001
    sudo ufw allow in 4001/udp comment 'Public IPFS libp2p UDP swarm port'
    sudo ufw allow in 4001/tcp comment 'Public IPFS libp2p TCP swarm port'
    sudo ufw allow from 127.0.0.1 to 127.0.0.1 port 5001 proto tcp comment 'Private IPFS API'
    sudo ufw allow from 127.0.0.1 to 127.0.0.1 port 8080 proto tcp comment 'Protected IPFS Gateway + read only API subset'

    # Enable firewall if needed
    sudo ufw enable

    # https://docs.ipfs.tech/how-to/nat-configuration/#configuration-options
    #
    IPFS_PORT=4001
    WAN_IP_ADDRESS=$(curl ifconfig.me)
    echo "WAN_IP_ADDRESS = $WAN_IP_ADDRESS"

    echo "[
        \"/ip4/${WAN_IP_ADDRESS}/tcp/${IPFS_PORT}\",
        \"/ip4/${WAN_IP_ADDRESS}/udp/${IPFS_PORT}/quic\",
        \"/ip4/${WAN_IP_ADDRESS}/udp/${IPFS_PORT}/quic-v1\",
        \"/ip4/${WAN_IP_ADDRESS}/udp/${IPFS_PORT}/quic-v1/webtransport\",
    ]"
    echo "WAN_IP_ADDRESS = $WAN_IP_ADDRESS"
    ipfs config --json Addresses.AppendAnnounce

}

tweaks(){
    __doc__="
    https://github.com/quic-go/quic-go/wiki/UDP-Buffer-Sizes
    "
    # Original values on mojo       212992
    # Original value on toothbrush 2621440
    sysctl net.core.rmem_max
    sysctl net.core.wmem_max

    sudo sysctl -w net.core.rmem_max=2500000
    sudo sysctl -w net.core.wmem_max=2500000
}


check_pin_random_data(){
    RANDOM_SUFFIX=$(head -c128 /dev/random | sha512sum)
    echo "
    This is some random data
    Written on $(date) by $HOSTNAME
    $RANDOM_SUFFIX
    " > random_data.txt
    ipfs add --pin random_data.txt | tee "test_pin_job.log"
    NEW_CID=$(tail -n 1 test_pin_job.log | cut -d ' ' -f 2)
    echo "NEW_CID=$NEW_CID"

    PEER_ID=$(ipfs config --json Identity.PeerID)
    echo "PEER_ID=$PEER_ID"

    CHECK_URL="https://ipfs-check.on.fleek.co/?cid=${NEW_CID}&multiaddr=%2Fp2p%2F${PEER_ID}"
    echo "CHECK_URL = $CHECK_URL"


    NEW_CID=QmYxGEEr5K6SbT7hV9d4DJCGFhjJt1d2rSPrdQWB4Fjp9B

    NEW_CID=QmaRssZfmkya5LX53hoyxHgk4RzTvo9grUCcR412xCva4B
    PEER_ID=12D3KooWMJxwdSsxYwyb6KCqHNpBcE2oM9HWz6yNkRHiavgQLsbr
    CHECK_URL="https://ipfs-check.on.fleek.co/?cid=${NEW_CID}&multiaddr=%2Fp2p%2F${PEER_ID}"
    echo "CHECK_URL = $CHECK_URL"

    ipfs dht findprovs QmaRssZfmkya5LX53hoyxHgk4RzTvo9grUCcR412xCva4B
    ipfs cat QmaRssZfmkya5LX53hoyxHgk4RzTvo9grUCcR412xCva4B

    # ip4/172.100.113.212/tcp/4001

    # Check
    # http://ipfs.io/ipfs/QmaRssZfmkya5LX53hoyxHgk4RzTvo9grUCcR412xCva4B
    # https://ipfs-check.on.fleek.co/
    # https://pl-diagnose.on.fleek.co/#/diagnose/access-content?
}


check_external_availability(){
    __doc__="
    Tools to check external availability

    https://ipfs-check.on.fleek.co
    https://pl-diagnose.on.fleek.co/#/diagnose/access-content

    "
    # Get this nodes peer-id
    PEER_ID=$(ipfs config --json Identity.PeerID)
    echo "PEER_ID=$PEER_ID"

    # Create a file unique to the specific node.
    echo "The PeerID of $HOSTNAME is $PEER_ID" > unique_node_file.txt
    ipfs add --progress --pin unique_node_file.txt | tee "unique_node_file.txt.pin.log"
    NEW_CID=$(tail -n 1 unique_node_file.txt.pin.log | cut -d ' ' -f 2)
    echo "NEW_CID=$NEW_CID"
    # Give it a name
    ipfs pin add --name "UniqueFileFor-${HOSTNAME}" --progress "$NEW_CID"

    # FOR MOJO: Qmc4RtnxBt6Tf6XAMuFraoDND5ofAFGJ4yUKL1YPxoYWbS
    # FOR IPFS: QmdJhwGS7Y5hd2HoHLWV8sBHwTPadP89WQZxXFLCob74or

    # Generate URL to check its availability
    CHECK_URL="https://ipfs-check.on.fleek.co/?cid=${NEW_CID}&multiaddr=%2Fp2p%2F${PEER_ID}"
    echo "CHECK_URL = $CHECK_URL"

    ipfs dht findprovs QmaRssZfmkya5LX53hoyxHgk4RzTvo9grUCcR412xCva4B
    ipfs cat QmaRssZfmkya5LX53hoyxHgk4RzTvo9grUCcR412xCva4B

    # ip4/172.100.113.212/tcp/4001
    # Check
    # http://ipfs.io/ipfs/QmaRssZfmkya5LX53hoyxHgk4RzTvo9grUCcR412xCva4B
    # https://ipfs-check.on.fleek.co/
    # https://pl-diagnose.on.fleek.co/#/diagnose/access-content?
    #


    # Check if port 4001 is open on the WAN
    WAN_IP_ADDRESS=$(curl ifconfig.me)
    echo "WAN_IP_ADDRESS = $WAN_IP_ADDRESS"
}
