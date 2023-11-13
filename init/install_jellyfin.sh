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

sudo ufw allow proto tcp from 192.168.222.1/24 to any port 8096,8920 comment 'allow Jellyfin via TCP'
