#!/usr/bin/env bash

export CC=/usr/bin/clang-4.0
export CXX=/usr/bin/clang++-4.0

cmake -G "Unix Makefiles" \
    -D KWIVER_ENABLE_ARROWS=TRUE \
    -D KWIVER_ENABLE_C_BINDINGS=TRUE \
    -D KWIVER_ENABLE_PYTHON=TRUE \
    -D KWIVER_ENABLE_TESTS=TRUE \
    -D KWIVER_ENABLE_EXTRAS:BOOL=ON \
    -D KWIVER_ENABLE_LOG4CPLUS:BOOL=ON \
    -D KWIVER_ENABLE_PROCESSES:BOOL=ON \
    -D KWIVER_ENABLE_SPROKIT:BOOL=ON \
    -D KWIVER_ENABLE_TOOLS:BOOL=ON \
    -D KWIVER_SYMLINK_PYTHON=TRUE \
    -D fletch_DIR=$HOME/code/fletch/build-clang \
    ../..

    #-D fletch_DIR=$HOME/code/fletch/build-py2 \



# TRAVIS SETTINGS
travis-settings(){ 

export CC=/usr/bin/clang-4.0
export CXX=/usr/bin/clang++-4.0
cmake  -G "Unix Makefiles" \
  -Dfletch_DIR=$HOME/code/fletch/build-clang \
  -DKWIVER_ENABLE_ARROWS=ON \
  -DKWIVER_ENABLE_CERES=ON \
  -DKWIVER_ENABLE_C_BINDINGS=ON \
  -DKWIVER_ENABLE_DOCS=OFF \
  -DKWIVER_ENABLE_LOG4CXX=OFF \
  -DKWIVER_ENABLE_LOG4CPLUS=ON \
  -DKWIVER_ENABLE_OPENCV=ON \
  -DKWIVER_ENABLE_PROJ=ON \
  -DKWIVER_ENABLE_PROCESSES=ON \
  -DKWIVER_ENABLE_PYTHON=OFF \
  -DKWIVER_ENABLE_SPROKIT=ON \
  -DKWIVER_ENABLE_TESTS=ON \
  -DKWIVER_ENABLE_TOOLS=ON \
  -DKWIVER_ENABLE_TRACK_ORACLE=ON \
  -DKWIVER_ENABLE_VISCL=OFF \
  -DKWIVER_ENABLE_VXL=ON \
  -DKWIVER_USE_BUILD_TREE=ON \
  ../..

}
