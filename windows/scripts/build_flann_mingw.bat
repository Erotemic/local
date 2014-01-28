:: helper variables
set INSTALL32=C:\Program Files (x86)
set FLANN_INSTALL="%INSTALL32%\Flann"
set CMAKE_EXE="%INSTALL32%\CMake 2.8\bin\cmake.exe"
set CMAKE_GUI_EXE="%INSTALL32%\CMake 2.8\bin\cmake-gui.exe"

cd %code%\flann
rm -rf %code%\flann\build
mkdir %code%\flann\build
cd %code%\flann\build

:: OpenCV settings on windows
%CMAKE_EXE% ^
-G "MSYS Makefiles" ^
-DCMAKE_INSTALL_PREFIX=%FLANN_INSTALL% ^
-DBUILD_MATLAB_BINDINGS=Off ^
-DCMAKE_BUILD_TYPE=Release ^
-DCMAKE_C_FLAGS=-m32 ^
-DCMAKE_CXX_FLAGS=-m32 ^
-DUSE_OPENMP=Off ^
-DHDF5_INCLUDE_DIRS="" ^
-DHDF5_ROOT_DIR="" ^
 %code%\flann

:: make command that doesn't freeze on mingw
:: mingw32-make -j7 "MAKE=mingw32-make -j3" -f CMakeFiles\Makefile2 all
echo "THIS WILL TAKE AWHILE!!!"
make
