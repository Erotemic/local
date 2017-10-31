#!/bin/bash

echo "

Usage:
    cmake-cache-items.sh ~/code/kwiver/build-py2-old

    cmake \$(cmake-cache-items.sh <other-dir>) ..
    cmake \$(cmake-cache-items.sh ~/code/fletch/build-py2) ..
" > /dev/null
    # cmake $(cmake-cache-items.sh <other-dir>) ..
    # cmake $(cmake-cache-items.sh ~/code/fletch/build-py2) ..
    # cmake $(cmake-cache-items.sh ~/code/kwiver/build-py2-old) -D fletch_DIR=$HOME/code/fletch/build-py2 ..

if [ "$#" -eq 0 ]; then
    DPATH="."
else
    DPATH=$1
fi

# Filter out vars that start with cmake, and non-portable settings like paths
#cmake -L $DPATH | grep -v ^CMAKE_ | grep -v :PATH=  | grep -v :FILEPATH= | grep -v :STRING=/

# Filter out comments, advanced variables, and vars that start with cmake
FILTER_COMMENTS(){
    cat - | grep ^[^//] | grep -v "^#"
}
FILTER_CMAKE(){
    cat - | grep -v ^CMAKE_
}
FILTER_PATHS(){
    cat - | grep -v :PATH=  | grep -v :FILEPATH= | grep -v :STRING=/ | grep -v :STATIC=/
}
FILTER_INTERNAL(){
    cat - | grep -v INTERNAL | grep -v STATIC
}
FILTER_HEURISTIC(){
    cat - | grep -v ^CUDA | grep -v ^CPACK  | grep -v ^CTEST | grep -v ^DART | grep -v ^CVS
}

PREFIX_LINES(){
    python3 -c "import sys; [sys.stdout.write('-D ' + line) for line in sys.stdin.readlines()]"
}

cat $DPATH/CMakeCache.txt | FILTER_COMMENTS | FILTER_CMAKE | FILTER_PATHS | FILTER_INTERNAL | FILTER_HEURISTIC | PREFIX_LINES
#grep -v ADVANCED | grep -v INTERNAL
#grep :BOOL 
