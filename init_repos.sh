
mkdir ~/code
cd ~/code
git clone git@github.com:Erotemic/hotspotter.git
git clone git@github.com:Erotemic/flann.git
git clone git@github.com:Erotemic/hesaff.git
git clone git@github.com:Erotemic/opencv.git

cd ~/code/opencv
#port install cmake
chmod +x build_opencv_unix.sh
sudo sh build_opencv_unix.sh
