# if running bash
if [ -n "$BASH_VERSION" ]; then
    # include .bashrc if it exists
    if [ -f "$HOME/.bashrc" ]; then
    . "$HOME/.bashrc"
    fi
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi
export PATH=/Users/joncrall/code/llvm/build/Debug+Asserts/bin:$PATH
export C_INCLUDE_PATH=/Users/joncrall/code/llvm/include:/Users/joncrall/code/libomp_oss/exports/common/include:$C_INCLUDE_PATH
export CPLUS_INCLUDE_PATH=/Users/joncrall/code/llvm/include:/Users/joncrall/code/libomp_oss/exports/common/include:$CPLUS_INCLUDE_PATH
export LIBRARY_PATH=/Users/joncrall/code/llvm/build/Debug+Asserts/lib:/Users/joncrall/code/libomp_oss/exports/mac_32e/lib.thin:$LIBRARY_PATH
export DYLD_LIBRARY_PATH=/Users/joncrall/code/llvm/build/Debug+Asserts/lib:/Users/joncrall/code/libomp_oss/exports/mac_32e/lib.thin:$DYLD_LIBRARY_PATH}
export PATH=/Users/joncrall/code/llvm/build/Debug+Asserts/bin:$PATH
export C_INCLUDE_PATH=/Users/joncrall/code/llvm/include:/Users/joncrall/code/libomp_oss/exports/common/include:$C_INCLUDE_PATH
export CPLUS_INCLUDE_PATH=/Users/joncrall/code/llvm/include:/Users/joncrall/code/libomp_oss/exports/common/include:$CPLUS_INCLUDE_PATH
export LIBRARY_PATH=/Users/joncrall/code/llvm/build/Debug+Asserts/lib:/Users/joncrall/code/libomp_oss/exports/mac_32e/lib.thin:$LIBRARY_PATH
export DYLD_LIBRARY_PATH=/Users/joncrall/code/llvm/build/Debug+Asserts/lib:/Users/joncrall/code/libomp_oss/exports/mac_32e/lib.thin:$DYLD_LIBRARY_PATH}
