# Apple pre-installed dirs
export apple_PATH=/usr/local/bin:/usr/local/lib:/usr/local/include
export apple_SITE_PACKAGES=/usr/local/lib/python2.7/site-packages

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
export PYTHONPATH=$ports_SITE_PACKAGES:$apple_SITE_PACKAGES:$PYTHONPATH

#if [ "$TERM" != "dumb" ]; then
    #export LS_OPTIONS='--color=auto'
    #eval `dircolors ~/local/dir_colors.sh`
#fi
