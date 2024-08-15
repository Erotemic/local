# Install tizen studio
# https://developer.tizen.org/development/tizen-studio/download
# https://docs.tizen.org/application/tizen-studio/setup/install-sdk/


#wget https://dot.net/v1/dotnet-install.sh -O dotnet-install.sh
#chmod +x ./dotnet-install.sh
#./dotnet-install.sh --channel 8.0

#chmod +x /home/joncrall/Downloads/web-ide_Tizen_Studio_5.5_ubuntu-64.bin
#/home/joncrall/Downloads/web-ide_Tizen_Studio_5.5_ubuntu-64.bin

sudo apt install nodejs npm

chmod +x /home/joncrall/Downloads/web-cli_Tizen_Studio_5.5_ubuntu-64.bin

mkdir "$HOME/.local/opt/tizen-studio"

/home/joncrall/Downloads/web-cli_Tizen_Studio_5.5_ubuntu-64.bin \
    --accept-license \
    "$HOME/.local/opt/tizen-studio"

TIZEN_DPATH="$HOME/.local/opt/tizen-studio"
"$TIZEN_DPATH"/package-manager/package-manager-cli.bin show-pkgs --tree

TIZEN_DPATH="$HOME/.local/opt/tizen-studio"
"$TIZEN_DPATH"/package-manager/package-manager-cli.bin install Certificate-Manager
"$TIZEN_DPATH"/tools/ide/bin/tizen certificate -a MyTizen -p 1234

git clone -b release-10.8.z https://github.com/jellyfin/jellyfin-web.git

mkdir -p "$HOME"/code/samsung-tv
git clone -b v10.8.13 https://github.com/jellyfin/jellyfin-web.git "$HOME"/code/samsung-tv/jellyfin-web
git clone https://github.com/jellyfin/jellyfin-tizen.git "$HOME"/code/samsung-tv/jellyfin-tizen

cd "$HOME"/code/samsung-tv/jellyfin-web
SKIP_PREPARE=1 npm ci --no-audit
USE_SYSTEM_FONTS=1 npm run build:production

cd "$HOME"/code/samsung-tv/jellyfin-tizen
JELLYFIN_WEB_DIR=../jellyfin-web/dist npm ci --no-audit

TIZEN_DPATH="$HOME/.local/opt/tizen-studio"
"$TIZEN_DPATH"/tools/ide/bin/tizen build-web -e ".*" -e gulpfile.js -e README.md -e "node_modules/*" -e "package*.json" -e "yarn.lock"
"$TIZEN_DPATH"/tools/ide/bin/tizen package -t wgt -o . -- .buildResult


# Test deployment on emulator
"$TIZEN_DPATH"/tools/ide/bin/tizen install -n Jellyfin.wgt -t T-samsung-5.5-x86


# Deploy to real TV
"$TIZEN_DPATH"/tools/sdb connect YOUR_TV_IP

# If you are using a Samsung certificate, Permit to install applications on
# your TV using Device Manager

# Install package
"$TIZEN_DPATH"/tools/ide/bin/tizen install -n Jellyfin.wgt -t UE65NU7400
