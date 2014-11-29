# References: http://www.bencode.net/blog/2012/10/20/clangonwindows/

cd C:\mingw\msys\1.0
mkdir src
cd src
svn co http://llvm.org/svn/llvm-project/llvm/trunk llvm

cd llvm/tools
svn co http://llvm.org/svn/llvm-project/cfe/trunk clang
cd ../..

cd llvm/projects
svn co http://llvm.org/svn/llvm-project/compiler-rt/trunk compiler-rt
cd ../..

mkdir llvm-build
cd llvm-build

python -c "import utool as ut; ut.write_to('mingw_llvm_configure.sh', 'export CC=gcc\nexport CXX=g++\n../llvm/configure --disable-docs --enable-optimized --enable-targets=x86,x86_64 --prefix=/mingw')"

mingw_llvm_configure.sh

make
make install
"
