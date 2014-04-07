::C:\Program Files (x86)\Microsoft Visual Studio 10.0\Common7\Tools
::C:\Program Files (x86)\Microsoft Visual Studio 10.0\Common7\Tools\vsvars32.bat
::for /f "delims=" %%i in ('cd') do set cwd=%%i
::


:: Try1
:: runas /profile /savecred /user:%COMPUTER_NAME%\%USERNAME% %1

:: Try2
@echo Set objShell = CreateObject("Shell.Application") > %temp%\sudo.tmp.vbs
@echo args = Right("%*", (Len("%*") - Len("%1"))) >> %temp%\sudo.tmp.vbs
@echo objShell.ShellExecute "%1", args, "", "runas" >> %temp%\sudo.tmp.vbs
@cscript %temp%\sudo.tmp.vbs
