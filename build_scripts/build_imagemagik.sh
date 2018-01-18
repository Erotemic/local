# References: http://imagemagick.org/discourse-server/viewtopic.php?t=16792

cd ~/tmp
wget ftp://ftp.imagemagick.org/pub/ImageMagick/ImageMagick-6.9.9-33.tar.gz
tar xvfz ImageMagick-6.9.9-33.tar.gz
cd ImageMagick-6.9.9-33
./configure --disable-openmp --prefix=$HOME/.local
make -j9
make install
