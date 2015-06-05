# References:
#http://docs.opencv.org/doc/tutorials/introduction/linux_install/linux_install.html#linux-installation
# compiler
#sudo apt-get install build-essential
# required
#sudo apt-get install cmake git libgtk2.0-dev pkg-config libavcodec-dev libavformat-dev libswscale-dev
# optional
#sudo apt-get install python-dev python-numpy libtbb2 libtbb-dev libjpeg-dev libpng-dev libtiff-dev libjasper-dev libdc1394-22-dev

code
git clone https://github.com/Itseez/opencv.git

cd opencv

mkdir build

# use dist packages on ubuntu. may need to change for other platforms
cmake -G "Unix Makefiles" \
    -D WITH_OPENMP=ON \
    -D CMAKE_BUILD_TYPE=RELEASE \
    -D PYTHON2_PACKAGES_PATH=/usr/local/lib/python2.7/dist-packages\
    -D CMAKE_INSTALL_PREFIX=/usr/local \
    ..
#cmake -D CMAKE_BUILD_TYPE=RELEASE -D PYTHON2_PACKAGES_PATH="lib/python2.7/dist-packages" -D CMAKE_INSTALL_PREFIX=/usr/local ..

make -j9
sudo make install

python -c "import cv2; print(cv2.__version__)"
python -c "import cv2; print(cv2.__file__)"
python -c "import cv2; print(cv2.__file__)"
python -c "import vtool"
