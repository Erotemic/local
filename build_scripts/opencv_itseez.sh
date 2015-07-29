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
mkdir build27
cd build27

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

python -c "import numpy; print(numpy.__file__)"
python -c "import numpy; print(numpy.__version__)"
python -c "import cv2; print(cv2.__version__)"
python -c "import cv2; print(cv2.__file__)"
python -c "import cv2; print(cv2.__file__)"
python -c "import vtool"

# Check if we have contrib modules
python -c "import cv2; print(cv2.xfeatures2d)"


uninstall_opencv()
{
    sudo rm -rf /usr/local/bin/opencv*
    sudo rm -rf /usr/local/include/opencv
    sudo rm -rf /usr/local/include/opencv2
    sudo rm -rf /usr/local/lib/libopencv*
    sudo rm -rf /usr/local/lib/pkgconfig/opencv.pc
    sudo rm -rf /opt/local/Library/Frameworks/Python.framework/Versions/2.7/lib/python2.7/site-packages/cv2.so
    sudo rm -rf /opt/local/Library/Frameworks/Python.framework/Versions/2.7/lib/python2.7/site-packages/cv.py
    sudo rm -rf /opt/local/Library/Frameworks/Python.framework/Versions/2.7/lib/python2.7/site-packages/cv2.pyd
}


python -c "import cv2, utool; print(utool.align(utool.dict_str(utool.get_file_info(cv2.__file__)), ':'))"

install_python3_version()
{
    code 
    cd opencv
    mkdir build3
    cd build
    # This seems to build both 2 and 3
    cmake -G "Unix Makefiles" \
        -D WITH_OPENMP=ON \
        -D CMAKE_BUILD_TYPE=RELEASE \
        -D CMAKE_INSTALL_PREFIX=/usr/local \
        -D OPENCV_EXTRA_MODULES_PATH=../opencv_contrib/modules \
        -D PYTHON2_PACKAGES_PATH=lib/python2.7/dist-packages\
        -D PYTHON3_PACKAGES_PATH=lib/python3.4/dist-packages\
        ..
    make -j9

    opencv_python3

    # Weird would not install properly
    #sudo cp /home/joncrall/code/opencv/build3/lib/python3.4/dist-packages/cv2.cpython-34m.so /usr/local/lib/python3.4/dist-packages/
}



install_extras()
{
    code 
    cd opencv
    git clone https://github.com/Itseez/opencv_contrib.git
    code 
    cd opencv
    cd build
    cmake -G "Unix Makefiles" \
        -D WITH_OPENMP=ON \
        -D CMAKE_BUILD_TYPE=RELEASE \
        -D PYTHON2_PACKAGES_PATH=/usr/local/lib/python2.7/dist-packages\
        -D CMAKE_INSTALL_PREFIX=/usr/local \
        -D OPENCV_EXTRA_MODULES_PATH=../opencv_contrib/modules \
        ..
    make -j9
}

