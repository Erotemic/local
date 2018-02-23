ftype ShellScript=C:\MinGW\msys\1.0\bin\sh.exe %1 %* 
assoc .sh=ShellScript
set PATHEXT=.sh;%PATHEXT% 

:: https://superuser.com/questions/608978/is-it-possible-to-use-a-shell-script-in-the-sendto-folder
::
::https://stackoverflow.com/questions/105075/how-can-i-associate-sh-files-with-cygwin
:: 
