::C:\Program Files (x86)\Microsoft Visual Studio 10.0\Common7\Tools
::C:\Program Files (x86)\Microsoft Visual Studio 10.0\Common7\Tools\vsvars32.bat
::for /f "delims=" %%i in ('cd') do set cwd=%%i
set cwd=%cd%
runas /savecred /user:Ooo\jon.crall "cmd /T:0B /K cd %cwd%"
