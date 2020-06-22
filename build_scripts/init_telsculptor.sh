

cd $HOME/code
git clone https://github.com/Kitware/TeleSculptor.git
cd $HOME/code/TeleSculptor
mkdir builds
cd builds

cmake -DCMAKE_BUILD_TYPE:STRING=Release ..
