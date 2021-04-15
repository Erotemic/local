# https://github.com/OSGeo/gdal/releases/download/v3.2.2/gdal-3.2.2.tar.gz


build_gdal_with_fletch(){
    __heredoc__="""

    $HOME/remote/namek/code/fletch/CMake/External_GDAL.cmake

    """
    cd ~/code
    if [ ! -d "$HOME/code/fletch" ]; then
        git clone https://github.com/Kitware/fletch.git ~/code/fletch
    fi

    git co dev/add_gdal_3

    cd ~/code/fletch
    # Setup a build directory and build fletch
    FLETCH_BUILD=$HOME/code/fletch/build-gdal-test

    mkdir -p $FLETCH_BUILD
    cd $FLETCH_BUILD
    cmake -G "Unix Makefiles" \
        -D GDAL_SELECT_VERSION=3.2.1 \
        -D fletch_ENABLE_GDAL=True \
        -D fletch_ENABLE_PROJ=True \
        -D fletch_ENABLE_SQLite3=True \
        -D fletch_ENABLE_ZLib=True \
        -D fletch_ENABLE_libtiff=True \
        -D fletch_ENABLE_PNG=True \
        -D fletch_ENABLE_libxml2=True \
        -D fletch_ENABLE_libgeotiff=False \
        -D fletch_ENABLE_GEOS=True \
        -D fletch_ENABLE_libjpeg-turbo=True \
        ..


    cmake -G "Unix Makefiles" \
        -D GDAL_SELECT_VERSION=3.2.1 \
        -D fletch_ENABLE_GDAL=True \
        -D fletch_ENABLE_PROJ=True \
        -D fletch_ENABLE_SQLite3=True \
        -D fletch_ENABLE_GEOS=True \
        ..

        -D fletch_ENABLE_libjpeg-turbo=True \
        -D fletch_ENABLE_ZLib=True \
        -D fletch_ENABLE_libtiff=True \
        -D fletch_ENABLE_PNG=True \
        -D fletch_ENABLE_libxml2=True \

    # Fletch only supports libgeotiff 1.4.2, but we need 1.5 for gdal 3.2.1
    # libtiff >= 4.0 is required

    NCPUS=$(grep -c ^processor /proc/cpuinfo)
    make -j$NCPUS

        # TODO: only enable sqlite3 if the system does not have it
        # ALSO: need the sqlite3 binary
        #-D fletch_ENABLE_SQLite3=True \

        #-D fletch_ENABLE_log4cplus=True \
        #-D fletch_ENABLE_Eigen=True \
        #-D fletch_ENABLE_GLog=True \
        #-D fletch_ENABLE_FFmpeg=True \
        #-D fletch_ENABLE_Boost=True \
        #-D fletch_ENABLE_PDAL=True \
        #-D fletch_ENABLE_SuiteSparse=True \
        #-D fletch_ENABLE_Ceres=True \
        #-D fletch_BUILD_WITH_PYTHON:BOOL=True \
        #-D fletch_PYTHON_MAJOR_VERSION=3 \
        #-D fletch_ENABLE_OpenCV=True \


    NCPUS=$(grep -c ^processor /proc/cpuinfo)
    make -j$NCPUS

    # TEST
    #(cd ../python && python -c "import caffe")
}


does_not_work(){

pip install conan

mkdir -p $HOME/tmp/conan-gdal
cd $HOME/tmp/conan-gdal

# https://conan.io/center/gdal
conan profile update settings.compiler.libcxx=libstdc++11 default



cd $HOME/tmp
wget https://github.com/OSGeo/gdal/releases/download/v3.2.2/gdal-3.2.2.tar.gz
7z x gdal-3.2.2.tar.gz
7z x gdal-3.2.2rc1.tar
cd gdal-3.2.2

if [[ ! -d "$HOME/code/PROJ" ]]; then
    git clone https://github.com/OSGeo/PROJ.git $HOME/code/PROJ
fi
cd $HOME/code/PROJ
mkdir -p $HOME/code/PROJ/build
cd $HOME/code/PROJ/build


if [[ ! -d "$HOME/code/GDAL" ]]; then
    git clone https://github.com/OSGeo/GDAL.git $HOME/code/GDAL
fi

echo "
[requires]
# You may have multiple lines like the one below, if you have many dependencies.
gdal/3.2.1 

[generators]
cmake
" > conanfile.txt

conan install .


cd $HOME/code/GDAL
git co v3.2.2
cd $HOME/code/GDAL/gdal


./configure
}
