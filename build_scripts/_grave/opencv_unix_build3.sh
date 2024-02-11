#!/usr/bin/env bash
source ~/py3env/bin/activate

# FIXME: relative path
cd ~/code/opencv
#rm -rf ~/code/opencv/build
#PYTHON_PACKAGES_PATH=$(python -c "import site; print(site.USER_SITE)" 2> /dev/null)

# Configure
source unix_configure.sh
cd ~/code/opencv/build

echo "Finished Configure"

export NCPUS=$(grep -c ^processor /proc/cpuinfo)

# Build and install if succesfull
make -j$NCPUS || { echo "FAILED MAKE" ; exit 1; }
#sudo make install || { echo "FAILED MAKE INSTALL" ; exit 1; }
echo "Finished Build"

# Test if this worked
python3.4 -c "import cv2; print(cv2.__version__)"
