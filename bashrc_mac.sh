# Apple installed mac directories
export APPLE_PATH=/usr/local/bin:/usr/local/lib:/usr/local/include
export APPLE_SITE_PACKAGES=/usr/local/lib/python2.7/site-packages
# Macports directories
export PORTS_GNU=/opt/local/libexec/gnubin/
export PORTS_PATH=/opt/local/bin:/opt/local/lib:/opt/local/include
export PORTS_MANPATH=/opt/local/share/man
export PORTS_PYFRAMEWORK=/opt/local/Library/Frameworks/Python.framework/Versions/2.7
export PORTS_SITE_PACKAGES=$PORTS_PYFRAMEWORK/lib/python2.7/site-packages/
export PORTS_PYTHON=/opt/local/bin/python

# System variables
export PATH=$PORTS_PATH:$PORTS_GNU:$APPLE_PATH:$PATH
export MANPATH=$PORTS_MANPATH:$MANPATH
export PKG_CONFIG_PATH=$PKG_CONFIG_PATH:/usr/local/lib/pkgconfig
export PYTHONPATH=$PYTHONPATH:$APPLE_SITE_PACKAGES:$PORTS_SITE_PACKAGES

#if [ "$TERM" != "dumb" ]; then
    #export LS_OPTIONS='--color=auto'
    #eval `dircolors ~/local/dir_colors.sh`
#fi
