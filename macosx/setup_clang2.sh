INTEL_OPENMP_LATEST_BUILD_LINK=https://www.openmprtl.org/sites/default/files/libomp_20131209_oss.tgz
CLANG_INCLUDE=~/code/llvm/include
CLANG_BIN=~/code/llvm/build/Debug+Asserts/bin
CLANG_LIB=~/code/llvm/build/Debug+Asserts/lib
OPENMP_INCLUDE=~/code/libomp_oss/exports/common/include
OPENMP_LIB=~/code/libomp_oss/exports/mac_32e/lib.thin

cd ~/
mkdir code
cd ~/code
git clone https://github.com/clang-omp/llvm
git clone https://github.com/clang-omp/compiler-rt llvm/projects/compiler-rt
git clone -b clang-omp https://github.com/clang-omp/clang llvm/tools/clang
cd llvm
mkdir build
cd build
../configure
make
cd Debug+Asserts/bin
mv clang clang2
rm -rf clang++
ln -s clang2 clang2++
echo "LLVM+Clang+OpenMP Include Path : " ${CLANG_INCLUDE}
echo "LLVM+Clang+OpenMP Bin Path     : " ${CLANG_BIN}
echo "LLVM+Clang+OpenMP Lib Path     : " ${CLANG_LIB}

cd ~/code
curl ${INTEL_OPENMP_LATEST_BUILD_LINK} -o libomp_oss_temp.tgz
gunzip -c libomp_oss_temp.tgz | tar xopf -
rm -rf libomp_oss_temp.tgz
cd libomp_oss
echo "If you do not have GCC installed (not normal on vanilla Mavericks), you must comment out lines 450-451 in libomp_oss/tools/check-tools.pl.  Have you done this or want to compile anyway?"
select yn in "Yes" "No"; do
    case $yn in
        Yes ) make compiler=clang; break;;
        No ) exit;;
    esac
done

echo "OpenMP Runtime Include Path : " ${OPENMP_INCLUDE}
echo "OpenMP Runtime Lib Path     : " ${OPENMP_LIB}

(echo 'export PATH='${CLANG_BIN}':$PATH';
    echo 'export C_INCLUDE_PATH='${CLANG_INCLUDE}':'${OPENMP_INCLUDE}':$C_INCLUDE_PATH'; 
    echo 'export CPLUS_INCLUDE_PATH='${CLANG_INCLUDE}':'${OPENMP_INCLUDE}':$CPLUS_INCLUDE_PATH';
    echo 'export LIBRARY_PATH='${CLANG_LIB}':'${OPENMP_LIB}':$LIBRARY_PATH';
    echo 'export DYLD_LIBRARY_PATH='${CLANG_LIB}':'${OPENMP_LIB}':$DYLD_LIBRARY_PATH}') >> ~/.profile

echo "LLVM+Clang+OpenMP is now accessible through [ clang2 ] via terminal and does not conflict with Apple's clang"
