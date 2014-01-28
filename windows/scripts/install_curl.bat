cd %code%
:: Download Curl
wget "http://curl.haxx.se/download/curl-7.32.0.tar.gz"
:: Unzip Curl
call untar.bat curl-7.32.0.tar.gz
cd %code%\curl-7.32.0
mkdir build
cd build
cmake -G "MSYS Makefiles" -DCMAKE_INSTALL_PREFIX="C:\MinGW" ..
:: bash -c "./configure --help"
:: mingw32-make -j3 "MAKE=mingw32-make -j3" -f Cmake\Makefile2 all
call mymake.bat
make install

rm -rf %code%\curl-7.32.0.tar.gz
