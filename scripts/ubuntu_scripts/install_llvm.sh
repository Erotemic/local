prereqs()
{
    sudo apt-get install g++ cmake build-essential libffi-dev
}

#http://clang.llvm.org/get_started.html
#http://llvm.org/docs/GettingStarted.html
clean_llvm()
{
    sudo apt-get remove llvm
    sudo apt-get remove llvm-2.9
    sudo apt-get remove llvm-2.9-runtime
    sudo apt-get remove llvm-runtime
    #
    sudo apt-get install llvm-3.2-dev
    sudo apt-get install llvm-3.2
    sudo apt-get install llvmpy
}


status_llvm()
{
    cd ~/code/llvm
    git config --get remote.origin.url
    git status
    echo ""

    cd cd ~/code/llvm/projects/compiler-rt
    git config --get remote.origin.url
    git status
    echo ""

    cd ~/code/llvm/tools/clang
    git config --get remote.origin.url
    git status
    echo ""

    cd ~/code/llvm/tools/clang/tools/extra
    git config --get remote.origin.url
    git status
    echo ""

    cd ~/code/llvm
}

checkout_llvm()
{
    # checkout llvm
    cd ~/code
    git clone http://llvm.org/git/llvm.git
    git checkout release_34

    # clean src
    cd ~/code/llvm
    rm *
    git checkout *

    # checkout compiler-rt -> llvm/projects
    cd ~/code/llvm/projects
    git clone http://llvm.org/git/compiler-rt.git
    cd compiler-rt
    git checkout release_34

    # checkout clang -> llvm/tools/
    cd ~/code/llvm/tools
    git clone http://llvm.org/git/clang.git
    cd clang
    git checkout release_34

    # checkout clang tools -> llvm/tools/clang/tools/
    cd ~/code/llvm/tools/clang/tools
    git clone http://llvm.org/git/clang-tools-extra.git extra
    cd extra
    git checkout release_34

    cd ~/code/llvm
}


configure_llvm()
{
    cd ~/code/llvm
    mkdir build
    #export LDFLAGS=''
    #export CXXPP
    #export CC='gcc'
    #export CFLAGS='-O3'
    #export CXX='g++'
    #export CXXFLAGS='-O3'
    # rm -rf build
    cd ~/code/llvm/build
    #../configure --with-python --enable-targets=host --enable-optimized --disable-assertions --disable-docs
    cmake -D CMAKE_BUILD_TYPE=Release -D LLVM_ENABLE_FFI=ON -D LLVM_INCLUDE_TESTS=OFF ..

}

build_llvm()
{
    # Build LLVM
    #--enable-targets=x86,x86_64
    cd ~/code/llvm/build
    make -j9
}

install_llvm()
{
    cd ~/code/llvm/build
    # Install LLVM
    sudo make install
}


test_clang()
{
    clang --help
    clang file.c -fsyntax-only 
    clang file.c -S -emit-llvm -o
    clang file.c -S -emit-llvm -o - -O3
    clang file.c -S -O3 -o -
}

default_clang()
{
    update-alternatives --install /usr/local/bin/clang++ clang++ /usr/local/bin/clang++-3.2 20
    update-alternatives --install /usr/local/bin/c++ c++ /usr/local/bin/clang++ 20
    update-alternatives --config c++
    sudo update-alternatives --config c++

}


install_llvmpy()
{
    #export LLVM_CONFIG_PATH='/home/joncrall/code/llvm/build/llvm-config'
    export PATH='~/code/llvm/build:'$PATH

    git clone https://github.com/llvmpy/llvmpy.git llvmpy.git
    cd ~/code/llvmpy
    llvm-config --version

    python setup.py install

    LLVM_CONFIG_PATH='~/code/llvm/build/llvm-config'
    lvm-config --libs vectorize -lLLVMVectorize -lLLVMInstCombine -lLLVMTransformUtils -lLLVMipa -lLLVMAnalysis -lLLVMTarget -lLLVMMC -lLLVMObject -lLLVMCore -lLLVMSupport

    #clang file.c -S -O3 -o - (output native machine code)
    #--disable-docs --enable-optimized  --prefix=/mingw
}

