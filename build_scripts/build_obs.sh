#!/bin/bash
__doc__="""

https://github.com/obsproject/obs-studio/wiki/Install-Instructions#linux-build-directions

Requirements:
  sudo apt-get install \
          build-essential checkinstall cmake git \
          libmbedtls-dev libasound2-dev libavcodec-dev libavdevice-dev \
          libavfilter-dev libavformat-dev libavutil-dev libcurl4-openssl-dev \
          libfdk-aac-dev libfontconfig-dev libfreetype6-dev \
          libgl1-mesa-dev libjack-jackd2-dev libjansson-dev \
          libluajit-5.1-dev libpulse-dev libqt5x11extras5-dev \
          libspeexdsp-dev libswresample-dev libswscale-dev \
          libudev-dev libv4l-dev libvlc-dev \
          libx11-dev libx264-dev libxcb-shm0-dev \
          libxcb-xinerama0-dev libxcomposite-dev \
          libxinerama-dev pkg-config \
          python3-dev qtbase5-dev \
          libqt5svg5-dev swig -y

  sudo apt-get install \

SeeAlso:
    https://www.kurokesu.com/main/2016/01/16/manual-usb-camera-settings-in-linux/
"""

sudo apt install cmake ninja-build pkg-config clang clang-format build-essential curl ccache git zsh -y
sudo apt install rustc -y
sudo apt install libavcodec-dev libavdevice-dev libavfilter-dev libavformat-dev libavutil-dev libswresample-dev libswscale-dev libx264-dev libcurl4-openssl-dev libmbedtls-dev libgl1-mesa-dev libjansson-dev libluajit-5.1-dev python3-dev libx11-dev libxcb-randr0-dev libxcb-shm0-dev libxcb-xinerama0-dev libxcb-composite0-dev libxcomposite-dev libxinerama-dev libxcb1-dev libx11-xcb-dev libxcb-xfixes0-dev swig libcmocka-dev libxss-dev libglvnd-dev libgles2-mesa libgles2-mesa-dev libwayland-dev libsrt-openssl-dev libpci-dev libpipewire-0.3-dev libqrcodegencpp-dev uthash-dev -y
sudo apt install \
       qt6-base-dev qt6-base-private-dev libqt6svg6-dev qt6-wayland qt6-image-formats-plugins \
       libasound2-dev libfdk-aac-dev libfontconfig-dev libfreetype6-dev libjack-jackd2-dev \
       libpulse-dev libsndio-dev libspeexdsp-dev libudev-dev libv4l-dev libva-dev libvlc-dev \
       libvpl-dev libdrm-dev nlohmann-json3-dev libwebsocketpp-dev libasio-dev -y




cd "$HOME"/code
git clone https://github.com/obsproject/obs-studio.git

cd "$HOME"/code/obs-studio
git submodpull


#git clone --recursive https://github.com/obsproject/obs-studio.git
#cd obs-studio
mkdir -p build && cd build

#PREFIX=$HOME/.local
#PREFIX=/usr
export PREFIX="${HOME}/.local/opt/obs"
mkdir -p "$PREFIX"
echo "PREFIX = $PREFIX"

BUILD_BROWSER=0

deactivate_venv
pyenv global system
pyenv shell system

#If building with browser source:
if [ "$BUILD_BROWSER" == "ON" ]; then
    cd $HOME/code/obs-studio
    mkdir -p $HOME/code/obs-studio/tpl
    cd $HOME/code/obs-studio/tpl
    wget https://cdn-fastly.obsproject.com/downloads/cef_binary_3770_linux64.tar.bz2
    tar -xjf ./cef_binary_3770_linux64.tar.bz2

    #With browser source:
    cd $HOME/code/obs-studio/build
    cmake -DUNIX_STRUCTURE=1 -D CMAKE_INSTALL_PREFIX=$PREFIX \
        -DENABLE_NEW_MPEGTS_OUTPUT=OFF \
        -DBUILD_BROWSER=ON -DCEF_ROOT_DIR="../tpl/cef_binary_3770_linux64" ..
else
    cd "$HOME"/code/obs-studio/build
    #Without browser source:
    cmake \
        -DBUILD_BROWSER=Off \
        -DUNIX_STRUCTURE=1 \
        -DENABLE_PIPEWIRE=Off \
        -DENABLE_PLUGINS=Off \
        -DENABLE_AJA=0 \
        -DENABLE_WEBRTC=0 \
        -DQT_VERSION=6  \
        -DENABLE_NEW_MPEGTS_OUTPUT=OFF \
        -DCMAKE_INSTALL_PREFIX="$PREFIX" ..
fi

make -j4
make install

#sudo checkinstall --default --pkgname=obs-studio --fstrans=no --backup=no \
# --pkgversion="$(date +%Y%m%d)-git" --deldoc=yes


####
#OR
#
# https://github.com/occ-ai/obs-backgroundremoval

# With flatpak
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

flatpak install flathub com.obsproject.Studio
flatpak install com.obsproject.Studio.Plugin.BackgroundRemoval

flatpak run com.obsproject.Studio
