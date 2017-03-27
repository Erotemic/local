sudo pip install llvmmath
sudo apt-get install curl

cd ~/code
git clone http://llvm.org/git/llvm.git
git clone https://github.com/llvmpy/llvmpy.git
git clone https://github.com/numba/numba.git

cd ~/code/llvm
export REQUIRES_RTTI=1
git checkout remotes/origin/release_32
mkdir build
cd build
../configure --enable-optimized --enable-pic --enable-assertions --disable-docs --enable-targets=x86,x86_64
#cmake -DLLVM_TARGETS_TO_BUILD=X86 -DLLVM_REQUIRES_RTTI=1 ..
make -j9
sudo make install

#export LLVM_INSTALL_PATH=/usr/local/bin
#export LLVM_CONFIG_PATH=/usr/local/bin/llvm-config
cd ~/code/llvmpy
python setup.py build 
sudo python setup.py install -q
cd ~
python -c "import llvm; llvm.test()"


cd ~/code/numba 
python setup.py build 
sudo python setup.py install

cd $hs/research
python test_numba.py


#cd tools
#git clone http://llvm.org/git/clang.git
#cd ../../llvm/projects
#git clone http://llvm.org/git/compiler-rt.git


#--disable-docs --enable-optimized  --prefix=/mingw

llvm-config --version

sudo pip install llvmpy-0.11.0

sudo pip uninstall llvmpy
sudo pip uninstall numba

cd /usr/local/lib/python2.7/dist-packages

sudo rm -rf numba*
sudo rm -rf llvm*

sudo apt-get remove python3.2
sudo apt-get purge llvm

sudo apt-get remove llvm
sudo apt-get remove llvm-2.9
sudo apt-get remove llvm-2.9-runtime

sudo dpkg -r libllvm2.9
sudo dpkg -r libllvm3.0
sudo dpkg -r libllvm3.0:i386
sudo dpkg -r libllvm3.1
sudo dpkg -r libllvm3.1:i386
sudo dpkg -r libllvm3.1:i386

sudo dpkg --purge libllvm3.0:i386
sudo dpkg --purge libllvm3.1  
sudo dpkg --purge libllvm3.1:i386 

sudo dpkg --purge libllvm3.1:i386

sudo dpkg --purge libllvm

dpkg -l | grep llvm

sudo apt-get remove llvm-runtime
sudo pip install llvmpy

#sudo apt-get install llvm-3.2


sudo apt-get install llvm-3.2-dev
sudo apt-get install llvmpy

cd ~/code/archive/llvm
mkdir build

llvm-config --libs vectorize -lLLVMVectorize -lLLVMInstCombine -lLLVMTransformUtils -lLLVMipa -lLLVMAnalysis -lLLVMTarget -lLLVMMC -lLLVMObject -lLLVMCore -lLLVMSupport 
llvm-config --version

pip install llvmpy
pip install meta
pip install argparse 
pip install numba

cd ~/code

git clone https://github.com/numba/numba.git
cd numba 
python.exe setup.py build 

git clone https://github.com/llvmpy/llvmpy.git
cd llvmpy
export LLVM_CONFIG_PATH='python llvm-config'
python setup.py build 



