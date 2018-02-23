@echo off
REM version-of-mingw.bat
REM credit to Peter Ward work in ReactOS Build Environment RosBE.cmd it gave me a starting point that I edited.
::
:: Display the current version of GCC, ld, make and others.
::

REM %CD% works in Windows XP, not sure when it was added to Windows
REM set MINGWBASEDIR=C:\MinGW
set MINGWBASEDIR=C:\MinGW
ECHO MINGWBASEDIR=%MINGWBASEDIR%
if exist %MINGWBASEDIR%\bin\gcc.exe (gcc -v 2>&1 | find "gcc version")
REM if exist %MINGWBASEDIR%\bin\gcc.exe gcc -print-search-dirs
if exist %MINGWBASEDIR%\bin\c++.exe (c++ -v 2>&1 | find "gcc version")
if exist %MINGWBASEDIR%\bin\gcc-sjlj.exe (gcc-sjlj.exe -v 2>&1 | find "gcc version")
if exist %MINGWBASEDIR%\bin\gcc-dw2.exe (gcc-dw2.exe -v 2>&1 | find "gcc version")
if exist %MINGWBASEDIR%\bin\gdb.exe (gdb.exe -v | find "GNU gdb")
if exist %MINGWBASEDIR%\bin\nasm.exe (nasm -v)
if exist %MINGWBASEDIR%\bin\ld.exe (ld -v)
if exist %MINGWBASEDIR%\bin\windres.exe (windres --version | find "GNU windres")
if exist %MINGWBASEDIR%\bin\dlltool.exe (dlltool --version | find "GNU dlltool")
if exist %MINGWBASEDIR%\bin\pexports.exe (pexports | find "PExports" )
if exist %MINGWBASEDIR%\bin\mingw32-make.exe (mingw32-make -v | find "GNU Make")
if exist %MINGWBASEDIR%\bin\make.exe (ECHO It is not recommended to have make.exe in mingw/bin)
REM ECHO "The minGW runtime version is the same as __MINGW32_VERSION"
if exist "%MINGWBASEDIR%\include\_mingw.h" (type "%MINGWBASEDIR%\include\_mingw.h" | find "__MINGW32_VERSION" | find "#define")
if exist "%MINGWBASEDIR%\include\w32api.h" (type "%MINGWBASEDIR%\include\w32api.h" | find "__W32API_VERSION")

:_end
PAUSE

