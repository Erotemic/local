__heredoc__="""

https://github.com/obsproject/obs-studio/wiki/Install-Instructions#linux-build-directions

Requirements:
  sudo apt-get install \
          build-essential \
          checkinstall \
          cmake \
          git \
          libmbedtls-dev \
          libasound2-dev \
          libavcodec-dev \
          libavdevice-dev \
          libavfilter-dev \
          libavformat-dev \
          libavutil-dev \
          libcurl4-openssl-dev \
          libfdk-aac-dev \
          libfontconfig-dev \
          libfreetype6-dev \
          libgl1-mesa-dev \
          libjack-jackd2-dev \
          libjansson-dev \
          libluajit-5.1-dev \
          libpulse-dev \
          libqt5x11extras5-dev \
          libspeexdsp-dev \
          libswresample-dev \
          libswscale-dev \
          libudev-dev \
          libv4l-dev \
          libvlc-dev \
          libx11-dev \
          libx264-dev \
          libxcb-shm0-dev \
          libxcb-xinerama0-dev \
          libxcomposite-dev \
          libxinerama-dev \
          pkg-config \
          python3-dev \
          qtbase5-dev \
          libqt5svg5-dev \
          swig

SeeAlso:
    https://www.kurokesu.com/main/2016/01/16/manual-usb-camera-settings-in-linux/
"""

cd $HOME/code
git clone https://github.com/obsproject/obs-studio.git
cd $HOME/code/obs-studio
git submodpull


#git clone --recursive https://github.com/obsproject/obs-studio.git
#cd obs-studio
mkdir -p build && cd build

PREFIX=$HOME/.local
echo "PREFIX = $PREFIX"

BUILD_BROWSER=ON

#If building with browser source:
if [ "$BUILD_BROWSER" == "ON" ]; then 
    cd $HOME/code/obs-studio
    mkdir -p $HOME/code/obs-studio/tpl
    cd $HOME/code/obs-studio/tpl
    wget https://cdn-fastly.obsproject.com/downloads/cef_binary_3770_linux64.tar.bz2
    tar -xjf ./cef_binary_3770_linux64.tar.bz2

    #With browser source:
    cd $HOME/code/obs-studio/build

    conda deactivate
    cmake -DUNIX_STRUCTURE=1 -DCMAKE_INSTALL_PREFIX=$PREFIX \
        -DBUILD_BROWSER=ON -DCEF_ROOT_DIR="../tpl/cef_binary_3770_linux64" ..
else
    #Without browser source:
    conda deactivate
    cmake -DUNIX_STRUCTURE=1 -DCMAKE_INSTALL_PREFIX=$PREFIX ..
fi

make -j4
checkinstall --default --pkgname=obs-studio --fstrans=no --backup=no \
 --pkgversion="$(date +%Y%m%d)-git" --deldoc=yes

