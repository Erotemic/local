SET ORIGINAL=%CD%

call :build_opencv
goto :exit 

:build_opencv
:: helper variables
set INSTALL32=C:\Program Files (x86)
set OPENCV_INSTALL="%INSTALL32%\OpenCV"

cd %HOME%\code\opencv
mkdir %HOME%\code\opencv\build
cd %HOME%\code\opencv\build

:: OpenCV settings on windows
cmake -G "MSYS Makefiles" ^
-DCMAKE_INSTALL_PREFIX=%OPENCV_INSTALL% ^
-DCMAKE_C_FLAGS=-m32 ^
-DCMAKE_CXX_FLAGS=-m32 ^
-DENABLE_SSE=OFF ^
-DENABLE_SSE2=OFF ^
-DENABLE_SSE3=OFF ^
-DENABLE_SSE41=OFF ^
-DENABLE_SSE42=OFF ^
-DENABLE_SSEE3=OFF ^
-DINSTALL_PYTHON_EXAMPLES=ON ^
..
:: -DBUILD_opencv_world=ON ^
:: -DWITH_QT=ON ^
:: -DCMAKE_CXX_FLAGS_RELWITHDEBINFO="-O2 -g -DNDEBUGS" ^
:: -DCMAKE_C_FLAGS_RELWITHDEBINFO="-O2 -g -DNDEBUGS" ^
:: -DCMAKE_CXX_FLAGS_RELEASE="-O2 -DNDEBUGS" ^
:: -DCMAKE_C_FLAGS_RELEASE="-O2 -DNDEBUGS" ^

:: make command that doesn't freeze on mingw
mingw32-make -j7 "MAKE=mingw32-make -j3" -f CMakeFiles\Makefile2 all
make install
exit /b

:exit
cd %ORIGINAL%
exit /b
