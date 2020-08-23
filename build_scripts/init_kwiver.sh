KWIVER_REPO=$HOME/code/kwiver

cd ~/code
if [ ! -d "$HOME/code/KWIVER" ]; then
    git clone https://github.com/Kitware/KWIVER.git $KWIVER_REPO
    cd $KWIVER_REPO
    git pull master
fi
cd $KWIVER_REPO

update_kwiver(){
    git checkout master
    git pull origin master
    git submodule update --init --recursive
}


PYTHON_VERSION=$(python -c "import sys; info = sys.version_info; print('{}.{}'.format(info.major, info.minor))")
KWIVER_REPO=$HOME/code/kwiver
KWIVER_BUILD=$KWIVER_REPO/build-py$PYTHON_VERSION
FLETCH_BUILD=$HOME/code/fletch/build-py$PYTHON_VERSION

mkdir -p $KWIVER_BUILD
cd $KWIVER_BUILD

cmake -G "Unix Makefiles" \
    -D CMAKE_BUILD_TYPE=Release \
    -D KWIVER_BUILD_SHARED=OFF \
    -D KWIVER_ENABLE_C_BINDINGS=ON \
    -D KWIVER_ENABLE_PYTHON=ON \
    -D KWIVER_PYTHON_MAJOR_VERSION=3 \
    -D PYBIND11_PYTHON_VERSION=3 \
    -D CMAKE_BUILD_WITH_INSTALL_RPATH=ON \
    -D KWIVER_ENABLE_SPROKIT=ON \
    -D KWIVER_ENABLE_ARROWS=ON \
    -D KWIVER_ENABLE_PROCESSES=ON \
    -D KWIVER_ENABLE_TOOLS=ON \
    -D KWIVER_ENABLE_LOG4CPLUS=ON \
    -D KWIVER_INSTALL_SET_UP_SCRIPT=OFF \
    -D KWIVER_ENABLE_OPENCV=ON \
    -D KWIVER_ENABLE_FFMPEG=ON \
    -D KWIVER_ENABLE_ZeroMQ=ON \
    -D KWIVER_ENABLE_SERIALIZE_JSON=ON \
    -D KWIVER_ENABLE_SERIALIZE_PROTOBUF=ON \
    -D fletch_DIR=$FLETCH_BUILD \
    ..

    #-D KWIVER_ENABLE_C_BINDINGS=TRUE \
    #-D KWIVER_ENABLE_TESTS=TRUE \
    #-D KWIVER_ENABLE_EXTRAS:BOOL=ON \
    #-D KWIVER_ENABLE_LOG4CPLUS:BOOL=ON \
    #-D KWIVER_ENABLE_PROCESSES:BOOL=ON \
    #-D KWIVER_ENABLE_SPROKIT:BOOL=ON \
    #-D KWIVER_ENABLE_TOOLS:BOOL=ON \
    #-D KWIVER_SYMLINK_PYTHON=TRUE \

NCPUS=$(grep -c ^processor /proc/cpuinfo)
make -j$NCPUS


__heredoc__="""
ALT:

docker pull kitware/kwiver
docker run -it kitware/kwiver bash


cat /kwiver/.git/config
sed -i 's|git@github.com:Kitware|https://github.com/Kitware|g' /kwiver/.git/config
cat /kwiver/.git/config

git pull 
git checkout dev/pipeline-bindings


cd /kwiver/build
source setup_KWIVER.sh
python -m pip install xdoctest[optional] setuptools

cd /kwiver/build/lib/python3/dist-packages
python -m xdoctest -m ./kwiver -c list --analysis dynamic 

I get

Start doctest_module('./kwiver')
Listing tests
    python -m xdoctest ./kwiver/arrows/python/simple_image_detector.py SimpleImageObjectDetector:0
    python -m xdoctest ./kwiver/vital/vital_logging.py print_exc:0
    python -m xdoctest ./kwiver/sprokit/sprokit_logging.py print_exc:0
python -m xdoctest ./kwiver/sprokit/adapters/embedded_pipeline.so EmbeddedPipeline:0 --analysis dynamic 
python -m xdoctest ./kwiver/sprokit/adapters/adapter_data_set.so AdapterDataSet:0 --analysis dynamic 



apt update 
apt install vim -y
vim /kwiver/sprokit/adapters/adapter_data_set.cxx
vim /kwiver/sprokit/adapters/embedded_pipeline.cxx
.cxx


cd /kwiver/python/sprokit


"""
