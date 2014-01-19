# Apple installed mac directories
export APPLE_PATH=/usr/local/bin:/usr/local/lib:/usr/local/include
export APPLE_SITE_PACKAGES=/usr/local/lib/python2.7/site-packages

# Macports directories
export PORTS_PATH=/opt/local/bin:/opt/local/lib:/opt/local/include
export PORTS_SITE_PACKAGES=/opt/local/Library/Frameworks/Python.framework/Versions/2.7/lib/python2.7/site-packages/
export PORTS_PYTHON=/opt/local/bin/python

# System variables
export PATH=$PORTS_PATH:$APPLE_PATH:$PATH
export PKG_CONFIG_PATH=$PKG_CONFIG_PATH:/usr/local/lib/pkgconfig
export PYTHONPATH=$PYTHONPATH:$APPLE_SITE_PACKAGES:$PORTS_SITE_PACKAGES
