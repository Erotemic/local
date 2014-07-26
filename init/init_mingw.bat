mingw-get --help
mingw-get source


mingw-get remove msys-libintl
mingw-get install msys-libintl
mingw-get --reinstall install msys-libintl

mingw-get update
mingw-get upgrade


cd %HOME%/local/tests
call test_openmp.bat

:: Manual extract 
cd C:\MinGW\var\cache\mingw-get\packages
7z x libintl-0.18.3.2-1-mingw32-dll-8.tar.xz
7z x libintl-0.18.3.2-1-mingw32-dll-8.tar
mv bin/libintl-8.dll C:/MinGW/bin
rm -rf bin


