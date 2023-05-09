__doc__="
Build the Dolphin Emulator

References:
    https://dolphin-emu.org/docs/guides/building-dolphin-linux/#18.04_LTS_and_up
    https://wiki.dolphin-emu.org/index.php?title=How_to_use_the_Official_GameCube_Controller_Adapter_for_Wii_U_in_Dolphin#Linux
"
sudo apt install --no-install-recommends ca-certificates qt6-base-dev qt6-base-private-dev git cmake make gcc g++ pkg-config libavcodec-dev libavformat-dev libavutil-dev libswscale-dev libxi-dev libxrandr-dev libudev-dev libevdev-dev libsfml-dev libminiupnpc-dev libmbedtls-dev libcurl4-openssl-dev libhidapi-dev libsystemd-dev libbluetooth-dev libasound2-dev libpulse-dev libpugixml-dev libbz2-dev libzstd-dev liblzo2-dev libpng-dev libusb-1.0-0-dev gettext

git clone https://github.com/dolphin-emu/dolphin.git "$HOME"/code/dolphin-emu

cd "$HOME"/code/dolphin-emu || return
git submodule update --init --recursive

#git co 5.0

mkdir -p build
cd build || return
cmake -DCMAKE_INSTALL_PREFIX="$HOME"/.local ..
make -j"$(nproc)"

make install

sudo_appendto /etc/udev/rules.d/51-gcadapter.rules '
SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", ATTRS{idVendor}=="057e", ATTRS{idProduct}=="0337", MODE="0666"
'
cat /etc/udev/rules.d/51-gcadapter.rules

sudo udevadm control --reload-rules
echo "Unplug/Replug the adapter now"

# See ALso
# ~/local/tools/joystick_setup.py


project_plus(){
    mkdir -p "$HOME"/temp/project_plus
    cd "$HOME"/temp/project_plus || return
    # For project plus
    # https://github.com/jlambert360/FPM-AppImage/releases/tag/v2.3.2
    curl -LOJ https://github.com/jlambert360/FPM-AppImage/releases/download/v2.3.2/Faster_Project_Plus-x86-64.AppImage
    curl -LOJ https://github.com/jlambert360/FPM-AppImage/releases/download/v2.3.2/Faster_Project_Plus-x86-64.AppImage.zsync
    curl -LOJ https://github.com/jlambert360/FPM-AppImage/releases/download/v2.3.2/Launcher.tar.gz
    curl -LOJ https://github.com/jlambert360/FPM-AppImage/releases/download/v2.3.2/ProjectPlusSd2.3.2.tar.gz

    chmod +x Faster_Project_Plus-x86-64.AppImage
    tar -xvzf ProjectPlusSd2.3.2.tar.gz
    tar -xvzf Launcher.tar.gz

    mkdir -p "$HOME"/Games/ProjectPlus
    mkdir -p "$HOME"/Games/ProjectPlus/ISOs
    mv -t "$HOME"/Games/ProjectPlus/ISOs Launcher
    mv -t "$HOME"/Games/ProjectPlus/ISOs sd.raw
    mv -t "$HOME"/Games/ProjectPlus Faster_Project_Plus-x86-64.AppImage

    python -c "if 1:
        import pathlib
        src_dpath = pathlib.Path('/data/store/Applications/Wii-Games')
        dst_dpath = pathlib.Path('~/Games/ProjectPlus/ISOs').expanduser()
        for src in dpath.glob('*.iso'):
            dst = dst_dpath / src.name
            if not dst.exists():
                dst.symlink_to(src)
        for src in dpath.glob('*.wbfs'):
            dst = dst_dpath / src.name
            if not dst.exists():
                dst.symlink_to(src)
    "

}

