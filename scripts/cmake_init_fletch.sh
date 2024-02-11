#!/usr/bin/env bash
cmake -G "Unix Makefiles" \
    -D fletch_BUILD_WITH_PYTHON:BOOL=True \
    -D fletch_ENABLE_GLog:BOOL=True \
    -D fletch_ENABLE_ZLib:BOOL=True \
    -D fletch_ENABLE_VXL:BOOL=True \
    -D fletch_ENABLE_PNG:BOOL=True \
    -D fletch_ENABLE_PyBind11:BOOL=True \
    -D fletch_ENABLE_Boost:BOOL=True \
    -D fletch_ENABLE_OpenCV:BOOL=True \
    -D fletch_ENABLE_libtiff:BOOL=True \
    -D fletch_ENABLE_libjson:BOOL=True \
    -D fletch_ENABLE_libjpeg-turbo:BOOL=True \
    -D fletch_ENABLE_libxml2:BOOL=True \
    -D fletch_ENABLE_GLog:BOOL=True \
    -D fletch_ENABLE_GTest:BOOL=True \
    -D fletch_ENABLE_log4cplus:BOOL=True \
    -D fletch_PYTHON_MAJOR_VERSION=3 \
    -D fletch_ENABLE_Protobuf:BOOL=True \
    -D Protobuf_SELECT_VERSION=3.4.1 \
    -D fletch_ENABLE_HDF5:BOOL=True \
    -D fletch_ENABLE_SuiteSparse:BOOL=True \
    -D fletch_ENABLE_OpenBLAS:BOOL=True \
    ..



kwiver_travis(){
    #!/usr/bin/env bash
    cmake -G "Unix Makefiles" \
        -D fletch_BUILD_WITH_PYTHON:BOOL=True \
        -D fletch_ENABLE_GLog:BOOL=True \
        -D fletch_ENABLE_ZLib:BOOL=True \
        -D fletch_ENABLE_VXL:BOOL=True \
        -D fletch_ENABLE_PNG:BOOL=True \
        -D fletch_ENABLE_PyBind11:BOOL=True \
        -D fletch_ENABLE_Boost:BOOL=True \
        -D fletch_ENABLE_OpenCV:BOOL=True \
        -D fletch_ENABLE_libtiff:BOOL=True \
        -D fletch_ENABLE_libjson:BOOL=True \
        -D fletch_ENABLE_libjpeg-turbo:BOOL=True \
        -D fletch_ENABLE_libxml2:BOOL=True \
        -D fletch_ENABLE_GLog:BOOL=True \
        -D fletch_ENABLE_GTest:BOOL=True \
        -D fletch_ENABLE_log4cplus:BOOL=True \
        -D fletch_PYTHON_MAJOR_VERSION=3 \
        -D fletch_ENABLE_Protobuf:BOOL=True \
        -D Protobuf_SELECT_VERSION=3.4.1 \
        -D fletch_ENABLE_HDF5:BOOL=True \
        -D fletch_ENABLE_SuiteSparse:BOOL=True \
        -D fletch_ENABLE_OpenBLAS:BOOL=True \
        -D fletch_ENABLE_Ceres:BOOL=True \
        -D fletch_ENABLE_TinyXML:BOOL=True \
        ..
}
