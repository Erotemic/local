#cd ~/code
#git clone --recursive  http://itk.org/SimpleITK.git
#mkdir SimpleITK-build
#cd SimpleITK-build
#cmake ../SimpleITK/SuperBuild
#cd SimpleITK-build/Wrapping
#python PythonPackage/setup.py install

cd ~/code
git clone http://itk.org/ITK.git
git checkout -b release origin/release
mkdir build
cd build 
cmake -DITK_WRAP_PYTHON=True -DBUILD_SHARED_LIBS=True -DBUILD_TESTING=False -DBUILD_EXAMPLES=False  
make -j9
sudo checkinstall
