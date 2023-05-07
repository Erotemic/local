__doc__="
Build the Dolphin Emulator

References:
    https://dolphin-emu.org/docs/guides/building-dolphin-linux/#18.04_LTS_and_up
"
sudo apt install --no-install-recommends ca-certificates qt6-base-dev qt6-base-private-dev git cmake make gcc g++ pkg-config libavcodec-dev libavformat-dev libavutil-dev libswscale-dev libxi-dev libxrandr-dev libudev-dev libevdev-dev libsfml-dev libminiupnpc-dev libmbedtls-dev libcurl4-openssl-dev libhidapi-dev libsystemd-dev libbluetooth-dev libasound2-dev libpulse-dev libpugixml-dev libbz2-dev libzstd-dev liblzo2-dev libpng-dev libusb-1.0-0-dev gettext

git clone https://github.com/dolphin-emu/dolphin.git "$HOME"/code/dolphin-emu

cd "$HOME"/code/dolphin-emu
git submodule update --init --recursive

#git co 5.0

mkdir -p build
cd build
cmake -DCMAKE_INSTALL_PREFIX="$HOME"/.local ..
make -j"$(nproc)"

make install
