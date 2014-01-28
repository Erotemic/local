::C:\Program Files (x86)\Microsoft Visual Studio 10.0\Common7\Tools
::C:\Program Files (x86)\Microsoft Visual Studio 10.0\Common7\Tools\vsvars32.bat
::for /f "delims=" %%i in ('cd') do set cwd=%%i
runas /profile /savecred /user:%COMPUTER_NAME%\%USERNAME% %1
