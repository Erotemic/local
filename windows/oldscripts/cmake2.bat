:: Batch file to take precidence over cmake.exe and use my toolchain

"C:\Program Files (x86)\CMake 2.8\bin\cmake.exe" ^
-G "MSYS Makefiles" ^
-DCMAKE_TOOLCHAIN_FILE=%PORT_SETTINGS%\cmake-msys-toolchain.cmake ^
%*
