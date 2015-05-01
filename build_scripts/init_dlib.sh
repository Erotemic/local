code 
git clone https://github.com/davisking/dlib.git
cd dlib

mkdir build
cd build
#cmake ../dlib/

cmake ../tools/python
cmake --build . --config Release --target install

cd ..
cd python_examples

export PYTHON_SITE_PACKAGES=$(python -c "from distutils.sysconfig import get_python_lib; print(get_python_lib())")
cp dlib.so $PYTHON_SITE_PACKAGES/dlib.so -v
