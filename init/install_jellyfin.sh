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
    # Install .NET SDK 8.0
    curl -O https://download.visualstudio.microsoft.com/download/pr/5226a5fa-8c0b-474f-b79a-8984ad7c5beb/3113ccbf789c9fd29972835f0f334b7a/dotnet-sdk-8.0.100-linux-x64.tar.gz
    sha512sum dotnet-sdk-8.0.100-linux-x64.tar.gz
    13905ea20191e70baeba50b0e9bbe5f752a7c34587878ee104744f9fb453bfe439994d38969722bdae7f60ee047d75dda8636f3ab62659450e9cd4024f38b2a5

}

from_source(){
    echo ""

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
      --runtime nvidia \
      -e TZ=America/Eastern \
      -v /data/store/ErsatzTV/config:/root/.local/share/ersatztv \
      -v /data/store/ErsatzTV/media:/root/media:ro \
      -p 8409:8409 \
      --restart unless-stopped \
      jasongdove/ersatztv

      #jasongdove/ersatztv:develop-nvidia
      jasongdove/ersatztv
      #-v /path/to/config:/root/.local/share/ersatztv \
      #-v /path/to/local/media:/path/to/local/media:ro \

      #jasongdove/ersatztv:latest-nvidia


}
