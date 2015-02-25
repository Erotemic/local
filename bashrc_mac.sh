# Apple pre-installed dirs
export apple_PATH=/usr/local/bin:/usr/local/lib:/usr/local/include
#export apple_SITE_PACKAGES=/Library/Python/2.7/site-packages

# Macports dirs
export ports_GNU=/opt/local/libexec/gnubin/
export ports_PATH=/opt/local/bin:/opt/local/lib:/opt/local/include
export ports_MANPATH=/opt/local/share/man
export ports_PYFRAMEWORK=/opt/local/Library/Frameworks/Python.framework/Versions/2.7
export ports_SITE_PACKAGES=$ports_PYFRAMEWORK/lib/python2.7/site-packages/
export ports_PYTHON=/opt/local/bin/python

# System variables
export PATH=$ports_PATH:$ports_GNU:$apple_PATH:$PATH
export MANPATH=$ports_MANPATH:$MANPATH
export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig:$PKG_CONFIG_PATH
export PYTHONPATH=$ports_SITE_PACKAGES:$PYTHONPATH

#if [ "$TERM" != "dumb" ]; then
    #export LS_OPTIONS='--color=auto'
    #eval `dircolors ~/local/dir_colors.sh`
#fi


ports_profile()
{
    # the following was foundin my .profile presumably put there by ports 
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
}
