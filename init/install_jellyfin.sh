#!/bin/bash
__doc__="
https://jellyfin.org/docs/general/installation/linux
"
sudo apt install curl gnupg
sudo add-apt-repository universe

sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://repo.jellyfin.org/jellyfin_team.gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/jellyfin.gpg


cat <<EOF | sudo tee /etc/apt/sources.list.d/jellyfin.sources
Types: deb
URIs: https://repo.jellyfin.org/$( awk -F'=' '/^ID=/{ print $NF }' /etc/os-release )
Suites: $( awk -F'=' '/^VERSION_CODENAME=/{ print $NF }' /etc/os-release )
Components: main
Architectures: $( dpkg --print-architecture )
Signed-By: /etc/apt/keyrings/jellyfin.gpg
EOF

sudo apt update
sudo apt install jellyfin

sudo systemctl start jellyfin
sudo systemctl status jellyfin

echo "Navigate to: http://localhost:8096/"

Default username is "jellyfin"
Default password is empty

sudo ufw status
sudo ufw allow proto tcp from 192.168.222.1/24 to any port 8096,8920 comment 'allow Jellyfin via TCP'

source_dependencies(){
    # Install dotNET SDK 8.0
    __doc__="
    References:
        https://dotnet.microsoft.com/en-us/download
        https://dotnet.microsoft.com/download/dotnet
    "
    #source "$HOME/local/init/utils.sh"
    #DOWNLOAD_DPATH="$HOME"/temp/downloads
    #URL=https://download.visualstudio.microsoft.com/download/pr/5226a5fa-8c0b-474f-b79a-8984ad7c5beb/3113ccbf789c9fd29972835f0f334b7a/dotnet-sdk-8.0.100-linux-x64.tar.gz
    #TARGET_FNAME=$(basename "$URL")
    #DST=$DOWNLOAD_DPATH/$TARGET_FNAME

    #URL=$URL \
    #DST=$DST \
    #HASHER=sha512sum \
    #EXPECTED_HASH="13905ea20191e70baeba50b0e9bbe5f752a7c34587878ee104744f9fb453bfe439994d38969722bdae7f60ee047d75dda8636f3ab62659450e9cd4024f38b2a5" \
    #VERBOSE=3 \
    #    curl_grabdata

    sudo apt-get install -y dotnet-sdk-8.0

    # TODO: modify https://github.com/jellyfin/jellyfin.org/blob/master/docs/general/installation/source.md
    # to include these depends in instructions
    sudo apt install debhelper dotnet-sdk-8.0 libc6-dev libcurl4-openssl-dev libfontconfig1-dev libfreetype6-dev libssl-dev
}

install_nodejs_local(){
    sudo apt remove nodejs

    # https://nodejs.org/en/download
    URL=https://nodejs.org/dist/v20.10.0/node-v20.10.0-linux-x64.tar.xz \
    DST="$HOME"/temp/downloads/node.tar.xz \
    HASHER=sha512sum \
    EXPECTED_HASH="12cf6158cc574a0cdb6b3946a990623fecbf9ab972f3bde81ef957982e67889b849e88fd2a6f1a8a0a3a19113e509c8a8f343d3a877843c3eb28861938731f93" \
    VERBOSE=3 \
        curl_grabdata

    tar -xvf ~/temp/downloads/node.tar.xz -C ~/.local/opt

    ln -s "$HOME/.local/opt/node-v20.10.0-linux-x64" "$HOME/.local/opt/node"

    if [ -d "$HOME/.local/opt/node" ]; then
        export PATH=$PATH:$HOME/.local/opt/node/bin
        export CPATH=$HOME/.local/opt/node/include:$CPATH
        export LD_LIBRARY_PATH=$HOME/.local/opt/node/lib:$LD_LIBRARY_PATH
    fi
}

from_source(){

    if ! test -d "$HOME"/code/jellyfin; then
        git clone https://github.com/jellyfin/jellyfin.git "$HOME"/code/jellyfin
    fi
    cd "$HOME"/code/jellyfin
    git submodule update --init
    git submodule update --init --recursive

    dotnet --list-sdks

    cd "$HOME"/code/jellyfin
    ./build --type native --platform linux.amd64 --output-dir ./out
    tar -xvf ./out/bin/linux.amd64/jellyfin-server_10.9.0_linux-amd64.tar.gz -C ./out

    # The runtime wants the web-client in its binary dir
    cd "$HOME"/code/jellyfin/out/jellyfin-server_10.9.0/
    git clone https://github.com/jellyfin/jellyfin-web.git
    cd jellyfin-web

}


ersatztv(){
    __doc__="
    https://ersatztv.org/docs/user-guide/install
    "
    cd "$HOME"/code
    #git clone https://github.com/ErsatzTV/ErsatzTV.git

    docker pull jasongdove/ersatztv
    docker pull jasongdove/ersatztv:latest-nvidia

    mkdir -p /data/store/ErsatzTV/config
    mkdir -p /data/store/ErsatzTV/media

    docker run -d \
      --name ersatztv \
      -e TZ=America/Eastern \
      -v /data/store/ErsatzTV/config:/root/.local/share/ersatztv \
      -v /data/store/ErsatzTV/media:/root/media:ro \
      -p 8409:8409 \
      --restart unless-stopped \
      jasongdove/ersatztv

      #--runtime nvidia \
      #jasongdove/ersatztv:develop-nvidia
      jasongdove/ersatztv
      #-v /path/to/config:/root/.local/share/ersatztv \
      #-v /path/to/local/media:/path/to/local/media:ro \

      #jasongdove/ersatztv:latest-nvidia


}
