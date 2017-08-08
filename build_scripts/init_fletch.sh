#!/bin/bash


test_fletch_branch()
{
    BRANCH="test/update-opencv-3.3"
    mkdir -p $HOME/dash/$BRANCH
    REPO_DIR=$HOME/dash/$BRANCH/fletch
    git clone -b $BRANCH https://github.com/Erotemic/fletch.git $REPO_DIR
    git checkout $BRANCH
    git pull

    workon_py2

    echo REPO_DIR = $REPO_DIR
    mkdir -p $REPO_DIR/build
    cd $REPO_DIR/build 
    cmake -G "Unix Makefiles" \
        -D fletch_BUILD_WITH_PYTHON=On \
        -D fletch_ENABLE_ALL_PACKAGES=On \
        $REPO_DIR
}

update_symbolic_rebases()
{
    symbolic_rebase -e master -b test/update-opencv-3.3 -d="dev/update-opencv"

    BASE=master 
    BRANCH=test/update-opencv-3.3 
    DEPENDS="test/update-opencv"
    symbolic_rebase $BASE $BRANCH $DEPENDS
        
    #BASE=master
    #BRANCH=dev/python3-support
    #DEPENDS=dev/find_numpy dev/update-openblas-0.2.20 dev/update-opencv dev/update-vtk dev/update-caffe
    symbolic_rebase master dev/python3-support \
        dev/find_numpy dev/update-openblas-0.2.20 dev/update-opencv dev/update-vtk dev/update-caffe
}

# delete remote branch
#git push origin --delete test/upate-opencv

symbolic_rebase_clean(){
    git checkout master
    git reset --hard source/master

    git checkout $BASE
    git branch -D $BRANCH
    git branch -D $PRE_BRANCH
    
    git branch -D new/$PRE_BRANCH
    git push origin --delete new/$PRE_BRANCH

    git branch -D tmp/pre/test/update-opencv-3.3
    git push origin --delete test/update-opencv-3.3
}

symbolic_rebase(){
    #BASE=$1
    #BRANCH=$2
    #DEPENDS=$@

    PRE_BRANCH=pre/$BRANCH

    echo "
    BASE = $BASE
    BRANCH = $BRANCH
    DEPENDS = $DEPENDS
    PRE_BRANCH = $PRE_BRANCH
    "

    cd ~/code/fletch
    
    # $? == 0 means local branch with <branch-name> exists.
    git rev-parse --verify $BRANCH
    if [ $? == 0 ]; then
        echo "Branch exists"
        BRANCH_EXISTS=1
    else
        echo "Branch does not exist"
        BRANCH_EXISTS=0
    fi

    if [ $BRANCH_EXISTS == 0 ]; then
        # Starting from the base
        git checkout $BASE
        # Create the pre-branch off of the base
        git checkout -b $PRE_BRANCH
        # Merge all prereqs into the pre-branch
        git merge $DEPENDS --no-edit

        # Create the new "symbolic" branch to work on
        git checkout -b $BRANCH
    else
        # TODO: case where nothing happens and PRE_BRANCH == BRANCH

        # Starting from the base
        git checkout $BASE
        # Remember the hash of the old pre-branch
        OLD_PRE_BRANCH=$(git rev-parse $PRE_BRANCH)

        # Create a new pre-branch
        git checkout -b new/$PRE_BRANCH

        # Merge all prereqs into the tmp/pre branch
        git merge $DEPENDS --no-edit

        # Create a new post-branch
        git checkout -b new/$BRANCH

        # verify this looks good
        # git log $OLD_PRE_BRANCH..$BRANCH
        # git log --pretty=format:"%H" $OLD_PRE_BRANCH..$BRANCH

        # Cherry-pick the changes after the old pre-branch onto the new one
        git cherry-pick $OLD_PRE_BRANCH..$BRANCH

        # Overwrite old branches with the new ones
        git checkout $PRE_BRANCH
        git reset new/$PRE_BRANCH --hard 

        git checkout $BRANCH
        git reset new/$BRANCH --hard 

        # remote the temporary new branches
        git branch -D new/$BRANCH
        git branch -D new/$PRE_BRANCH
    fi

    ## backup the existing branch
    #git checkout $BRANCH
    #git checkout -b tmp/bak/$BRANCH

    ## Checkout a rebased verion we will do the work on
    #git checkout -b tmp/rebased/$BRANCH

    ##PRE_BRANCH=tmp/pre/$BRANCH
    ###git log -1 --pretty=format:"%H"
    ##git rev-parse $PRE_BRANCH
    ##git rev-parse $BRANCH

    #OLD_PRE_BRANCH_COMMIT=

    ## Find the oldest merge branch after master
    ## This should be the old tmp/pre branch
    #OLD_MERGE_POINT=$(python -c "import sys; print(sys.argv[-1])" $(git rev-list --min-parents=2 HEAD ^$BASE))
    ## Check to make sure its the merge point
    #git log -n 1 $OLD_MERGE_POINT
    #echo "OLD_MERGE_POINT = \"$OLD_MERGE_POINT\""

    ## These should be the relevant existing commits on the symbolic branch
    #git log $OLD_MERGE_POINT..$BRANCH

    ## Move all the relevant existing commits onto the new tmp/pre branch
    #git cherry-pick $OLD_MERGE_POINT..$BRANCH

    ## Now make the original branch point to this commit
    #git checkout $BRANCH
    #git reset --hard tmp/rebased-python3-support
}


git clone https://github.com/Erotemic/fletch.git ~/code/fletch


cd ~/code/fletch
git checkout dev/python3-support


PYTHON_EXECUTABLE=$(which python)
PY_VERSION=$(python -c "import sys; info = sys.version_info; print('{}.{}'.format(info.major, info.minor))")
PLAT_NAME=$(python -c "import setuptools, distutils; print(distutils.util.get_platform())")
REPO_DIR=~/code/fletch
#BUILD_DIR="$REPO_DIR/cmake_builds/build.$PLAT_NAME-$PY_VERSION"
BUILD_DIR="$REPO_DIR/build"

get_py_config_var()
{
    python -c "from distutils import sysconfig; print(sysconfig.get_config_vars()['$1'])"
}

# Check if we have a venv setup
if [[ "$VIRTUAL_ENV" == ""  ]]; then
    # The case where we are installying system-wide
    # It is recommended that a virtual enviornment is used instead
    _SUDO="sudo"
    if [[ '$OSTYPE' == 'darwin'* ]]; then
        # Mac system info
        LOCAL_PREFIX=/opt/local
        PYTHON_PACKAGES_PATH=$($PYTHON_EXECUTABLE -c "import site; print(site.getsitepackages()[0])")
    else
        # Linux system info
        LOCAL_PREFIX=/usr/local
        PYTHON_PACKAGES_PATH=$LOCAL_PREFIX/lib/python$PY_VERSION/dist-packages
    fi
    export PYTHON_LIBRARY=$(get_py_config_var 'LIBDIR')/$(get_py_config_var 'LDLIBRARY')
    export PYTHON_INCLUDE_DIR=$(get_py_config_var 'INCLUDEPY')
    # No windows support here
else
    # The prefered case where we are in a virtual environment
    #LOCAL_PREFIX=$VIRTUAL_ENV/local
    _SUDO=""
    LOCAL_PREFIX=$VIRTUAL_ENV
    PYTHON_PACKAGES_PATH=$LOCAL_PREFIX/lib/python$PY_VERSION/site-packages
    PYTHON_INCLUDE_DIR=$LOCAL_PREFIX/include/python"$PY_VERSION"m
    PYTHON_LIBRARY=$LOCAL_PREFIX/lib/python$PY_VERSION/config-"$PY_VERSION"m-x86_64-linux-gnu/libpython"$PY_VERSION".so
fi


echo "
======================
VARIABLE CONFIGURATION
======================
# Intermediate vars
PY_VERSION=$PY_VERSION
PLAT_NAME=$PLAT_NAME
# Final vars
_SUDO=$_SUDO
REPO_DIR=$REPO_DIR
BUILD_DIR=$BUILD_DIR
LOCAL_PREFIX=$LOCAL_PREFIX
PYTHON_EXECUTABLE=$PYTHON_EXECUTABLE
PYTHON_LIBRARY=$PYTHON_LIBRARY
PYTHON_INCLUDE_DIR=$PYTHON_INCLUDE_DIR
PYTHON_PACKAGES_PATH=$PYTHON_PACKAGES_PATH
"


mkdir -p $BUILD_DIR
cd $BUILD_DIR
cmake -G "Unix Makefiles" \
    -D fletch_ENABLE_ALL_PACKAGES=True \
    -D fletch_BUILD_WITH_PYTHON=True \
    -D fletch_BUILD_WITH_MATLAB=False \
    -D fletch_BUILD_WITH_CUDA=False \
    -D fletch_BUILD_WITH_CUDNN=False \
    $REPO_DIR


mkdir -p $BUILD_DIR
(cd $BUILD_DIR && cmake -G "Unix Makefiles" \
    -D CMAKE_BUILD_TYPE=RELEASE \
    -D CMAKE_INSTALL_PREFIX=$LOCAL_PREFIX \
    -D fletch_ENABLE_ALL_PACKAGES=True \
    -D fletch_BUILD_WITH_PYTHON=True \
    -D fletch_BUILD_WITH_MATLAB=False \
    -D fletch_BUILD_WITH_CUDA=False \
    -D fletch_BUILD_WITH_CUDNN=False \
    -D OpenCV_SELECT_VERSION=3.2.0 \
    -D VTK_SELECT_VERSION=8.0.0 \
    -D fletch_PYTHON_VERSION=3.5 \
    -D PYTHON_EXECUTABLE=$PYTHON_EXECUTABLE \
    -D PYTHON_INCLUDE_DIR=$PYTHON_INCLUDE_DIR \
    -D PYTHON_LIBRARY=$PYTHON_LIBRARY \
    -D fletch_ENABLE_Boost=True \
    -D fletch_ENABLE_Caffe=True \
    -D fletch_ENABLE_Ceres=True \
    -D fletch_ENABLE_Eigen=True \
    -D fletch_ENABLE_FFmpeg=True \
    -D fletch_ENABLE_GeographicLib=True \
    -D fletch_ENABLE_GFlags=True \
    -D fletch_ENABLE_GLog=True \
    -D fletch_ENABLE_HDF5=True \
    -D fletch_ENABLE_ITK=FALSE \
    -D fletch_ENABLE_jom=True \
    -D fletch_ENABLE_LevelDB=True \
    -D fletch_ENABLE_libjpeg-turbo=True \
    -D fletch_ENABLE_libjson=True \
    -D fletch_ENABLE_libkml=True \
    -D fletch_ENABLE_libtiff=True \
    -D fletch_ENABLE_libxml2=True \
    -D fletch_ENABLE_LMDB=True \
    -D fletch_ENABLE_log4cplus=True \
    -D fletch_ENABLE_OpenBLAS=True \
    -D fletch_ENABLE_OpenCV=True \
    -D fletch_ENABLE_OpenCV_contrib=True \
    -D fletch_ENABLE_PNG=True \
    -D fletch_ENABLE_PROJ4=True \
    -D fletch_ENABLE_Protobuf=True \
    -D fletch_ENABLE_Qt=True \
    -D fletch_ENABLE_shapelib=True \
    -D fletch_ENABLE_Snappy=True \
    -D fletch_ENABLE_SuiteSparse=True \
    -D fletch_ENABLE_TinyXML=True \
    -D fletch_ENABLE_VTK=True \
    -D fletch_ENABLE_VXL=True \
    -D fletch_ENABLE_yasm=True \
    -D fletch_ENABLE_ZLib=True \
    $REPO_DIR)
# Did Cmake fail?
CMAKE_EXITCODE=$?
echo "CMAKE_EXITCODE = $CMAKE_EXITCODE"

echo "--- FINISHED CMAKE ---"
#sleep 5s

codeblock()
{
    # Prevents python indentation errors in bash
    python -c "from textwrap import dedent; print(dedent('''$1''').strip('\n'))"
    #python -c "import utool as ut; print(ut.codeblock('''$1'''))"
}

cpu_arch_id()
{
    TO_PARSE=$(gcc -march=native -Q --help=target|grep march)
    # TODO: it would be nice to figure out a bash way to unindent
    python -c "$(codeblock "
    import re
    march_str = '$TO_PARSE'
    parts = re.sub('  *', ' ', march_str.replace('\\t', '')).strip().split(' ')
    print(parts[-1].upper()) 
    ")"
}



if [[ $CMAKE_EXITCODE == 0 ]]; then
    NCPUS=$(grep -c ^processor /proc/cpuinfo)
    #NCPUS=1

    if [ "$CLEAN_MARCH" == "$(cpu_arch_id)" ]; then
        # use target=haswell on broadwell systems
        #make -j$NCPUS --directory=$BUILD_DIR TARGET=HASWEL
        #(cd $BUILD_DIR && make TARGET=HASWELL)
        (cd $BUILD_DIR && make -j$NCPUS TARGET=HASWELL)
        #make --directory=$BUILD_DIR TARGET=HASWEL
    else
        #(cd $BUILD_DIR && make)
        (cd $BUILD_DIR && make -j$NCPUS)
        #make -j$NCPUS --directory=$BUILD_DIR
        #make --directory=$BUILD_DIR
    fi
else
    echo "Cmake Generation Failed"
fi
