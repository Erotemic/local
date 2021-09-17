# https://github.com/ihaque/memtestCL

#sudo apt update -y
#sudo apt upgrade -y
sudo apt install ocl-icd-opencl-dev -y


co
git clone https://github.com/ihaque/memtestCL.git
cd memtestCL

cat Makefiles/Makefile.linux64
make -f Makefiles/Makefile.linux64

./memtestCL --gpu 0 20000 100
