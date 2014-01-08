# Mac turn on screen sharing
sudo  /System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -activate -configure -access -on -clientopts -setvnclegacy -vnclegacy yes -clientopts -setvncpw -vncpw mypasswd -restart -agent -privs -all

mkdir ~/code
cd ~/code
git clone git@github.com:Erotemic/hotspotter.git
git clone git@github.com:Erotemic/flann.git
git clone git@github.com:Erotemic/hesaff.git
git clone git@github.com:Erotemic/opencv.git

cd ~/code/opencv
brew install cmake
#port install cmake
chmod +x build_opencv_unix.sh
sudo sh build_opencv_unix.sh
