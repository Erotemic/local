#!/bin/bash
__doc__="
Build the Super Mario PC Port
"

sudo apt install unrar
sudo apt install -y binutils-mips-linux-gnu build-essential libcapstone-dev pkgconf 
sudo apt install -y build-essential pkg-config libusb-1.0-0-dev 
sudo apt install -y libsdl2-dev
sudo apt install -y libglew-dev

basic_version(){
    REPO_DPATH="$HOME"/code/sm64-port
    if [ ! -d "$REPO_DPATH" ]; then
        git clone https://github.com/sm64-port/sm64-port "$REPO_DPATH"
    fi
    ipfs get bafybeia5zpnnm6by7b5sncaxztwhsdcowe7xy3nhhsjsibcnq5auoushwu -o "$REPO_DPATH/baserom.us.z64"
}



install_luigi_daisy_mod_ex(){
    ####
    # Mods

    cd "$HOME"/code/sm64ex
    rm -rf -- *
    git checkout -- *
    # This requires the baserom exists in the repo root
    ipfs get bafybeia5zpnnm6by7b5sncaxztwhsdcowe7xy3nhhsjsibcnq5auoushwu -o "baserom.us.z64"

    mkdir -p mods
    ipfs get bafybeich3zobccna7k4dctejhnuetwwbl652wwvvq3dfrk7lvxmtmonwf4 -o"mods/DaisyOverPeach.rar"
    unrar x "mods/DaisyOverPeach.rar"  "mods/"
    #7z x DaisyOverPeach.rar  # fails

    cd "$HOME"/code/sm64ex
    # Copy the target folder before compile
    #rsync -avpr "mods/Mario/Modern/decomp/" .
    #rsync -avpr "mods/Mario/Modern HD/decomp/" .
    #rsync -avpr "mods/Mario/Classic/decomp/" .
    #rsync -avpr "mods/Mario/Classic HD/decomp/" .
    #rsync -avpr "mods/Luigi/Modern/decomp/" .
    #rsync -avpr "mods/Luigi/Modern HD/decomp/" .
    rsync -avpr "mods/Luigi/Classic/decomp/" .
    #rsync -avpr "mods/Luigi/Classic HD/decomp/" .

    # Insert line into actors/group10.h
    pyblock '
    import pathlib
    fpath = pathlib.Path("./actors/group10.h")
    text = fpath.read_text()
    lines = text.split(chr(10))
    lines.insert(-2, """#include "peach/geo_header.h" """)
    fpath.write_text(chr(10).join(lines))
    '

    # Does not seem to work right

    # Compilie
    make VERSION=us DEBUG=0 EXT_OPTIONS_MENU=1 EXTERNAL_DATA=1 TEXTSAVES=0 DISCORDRPC=0 TEXTURE_FIX=1 NODRAWINGDISTANCE=1 BETTERCAMERA=0 -j4

    # Copy the build folder (hd only)
    #rsync -avprPR "mods/Luigi/Modern HD/./build/" .
    #rsync -avprPR "mods/Luigi/Classic HD/./build/" .
    #rsync -avprPR "mods/Mario/Modern HD/./build/" .
    #rsync -avprPR "mods/Mario/Classic HD/./build/" .

    build/us_pc/sm64.us.f3dex2e 

}

install_squidward_daisy_mod_ex(){
    ##  Squidward 
    # https://drive.google.com/drive/folders/1kmwvo49AVz4C73gj82SvHLH8-cJ0YgKd

    cd "$HOME"/code/sm64ex
    rm -rf -- *
    git checkout -- *

    ipfs get bafybeia5zpnnm6by7b5sncaxztwhsdcowe7xy3nhhsjsibcnq5auoushwu -o"baserom.us.z64"
    mkdir -p mods
    ipfs get bafybeiejcwoyay2ogkiy7oo5pitdeilb4wnwsdsvqts5vonykqhvyzejya -o"mods/SquidwardHolidaySpecial.zip"
    7z x "mods/SquidwardHolidaySpecial.zip" -o"mods"
    7z x "mods/Squidward 64 Holiday special/Mod files.zip" -y

    make VERSION=us DEBUG=0 EXT_OPTIONS_MENU=1 EXTERNAL_DATA=1 TEXTSAVES=0 DISCORDRPC=0 TEXTURE_FIX=1 NODRAWINGDISTANCE=1 BETTERCAMERA=0 -j4
    
    7z x "mods/Squidward 64 Holiday special/Sq64 Christmas special demo texture pack.zip" -o"build/us_pc/res/"

}



ex_version(){
    ### Ex version
    # https://github.com/sm64pc/sm64ex/wiki/Compiling-on-Linux

    REPO_DPATH="$HOME"/code/sm64ex
    if [ ! -d "$REPO_DPATH" ]; then
        git clone https://github.com/sm64pc/sm64ex.git "$REPO_DPATH"
    fi
    cd "$REPO_DPATH"

    cd "$HOME"/code/sm64ex
    git reset --hard HEAD
    git clean -xf

    # This requires the baserom exists in the repo root
    ipfs get bafybeia5zpnnm6by7b5sncaxztwhsdcowe7xy3nhhsjsibcnq5auoushwu -o "baserom.us.z64"

    #patch -p1 < ~/code/sm64-port/enhancements/fps.patch
    #patch -p1 < "enhancements/60fps_ex.patch"
    #./tools/apply_patch.sh enhancements/60fps_ex.patch
    #./tools/revert_patch.sh enhancements/60fps_ex.patch

    # Build the variant you want
    # https://github.com/sm64pc/sm64ex/wiki/Build-options
    make VERSION=us DEBUG=0 EXT_OPTIONS_MENU=1 EXTERNAL_DATA=1 TEXTSAVES=0 DISCORDRPC=0 TEXTURE_FIX=1 NODRAWINGDISTANCE=1 BETTERCAMERA=0 -j4
    build/us_pc/sm64.us.f3dex2e --skip-intro
}
