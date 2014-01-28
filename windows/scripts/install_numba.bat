REM https://store.continuum.io/cshop/anaconda/
REM http://09c8d0b2229f813c1b93-c95ac804525aac4b6dba79b00b39d1d3.r79.cf1.rackcdn.com/Anaconda-1.6.2-Windows-x86.exe
cd %CODE%
:: LLVM 3.1 or 3.2
:: SVN VERSION LLVM
svn co http://llvm.org/svn/llvm-project/llvm/trunk llvm
cd llvm/tools
svn co http://llvm.org/svn/llvm-project/cfe/trunk clang
cd ../../llvm/projects
svn co http://llvm.org/svn/llvm-project/compiler-rt/trunk compiler-rt
cd ../..
:: GIT VERSION LLVM
git clone http://llvm.org/git/llvm.git
cd llvm/tools
git clone http://llvm.org/git/clang.git
cd ../../llvm/projects
git clone http://llvm.org/git/compiler-rt.git
:: 
mkdir build
REM ../llvm/configure
REM ../llvm/configure --disable-threads
../llvm/configure --disable-docs --enable-optimized --enable-targets=x86,x86_64 --prefix=/mingw
make
:: llvmpy (from llvmpy/llvmpy fork)
git clone https://github.com/llvmpy/llvmpy.git
:: llvmmath
git clone git@github.com:ContinuumIO/llvmmath.git
cd llvmmath
python setup.py install
:: numpy (version 1.6 or higher)
:: Already Installed
:: Meta (from numba/Meta fork (optional))
pip install meta
:: Already Installed
:: Cython (build dependency only)
:: Already Installed
:: nose (for unit tests)
pip install nose
:: argparse (for pycc)
pip install argparse 

git clone https://github.com/numba/numba

llvm-config --libs vectorize -lLLVMVectorize -lLLVMInstCombine -lLLVMTransformUtils -lLLVMipa -lLLVMAnalysis -lLLVMTarget -lLLVMMC -lLLVMObject -lLLVMCore -lLLVMSupport

::---------------easyway
:: Windows Binaries
git clone https://github.com/dand-oss/numba-windows-binaries.git
cd numba-windows-binaries\llvm-binary
7z x -ollvm-mingw llvm-2012-12-28-ver-3.2rel-mingw32-4.6.2.zip 
7z x -ollvm-mingw/bin mingw-4.6.2-dlls-for-llvm-3.2.zip
rob add_path llvm-mingw/bin
C:\newest_path.bat
cd ..
llvmpy-0.9.1.win32-py2.7.msi
numba-0.3.2.win32-py2.7.msi

::-----svn windows
REM http://subversion.apache.org/packages.html
REM http://www.sliksvn.com/en/download
http://www.sliksvn.com/pub/Slik-Subversion-1.8.3-x64.msi

::----googles
svn checkout http://unladen-swallow.googlecode.com/svn/trunk/ unladen-swallow-read-only

::----googles
conda install numba
conda update numba
