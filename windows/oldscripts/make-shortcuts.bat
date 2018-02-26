set SCR=%HOME%\Dropbox\Scripts\win_scripts

call CreateShortcut.bat %LOCAL%\ahk_scripts\crallj.ahk  "%STARTUP%"
call CreateShortcut.bat %SCR%  %HOME%
call DoubleShortcut.bat E:\TV   %HOME%
call DoubleShortcut.bat %HOME%  C:\MinGW
call DoubleShortcut.bat C:\MinGW\msys\1.0  C:\MinGW 
call CreateShortcut.bat %HOME% C:\MinGW\msys\1.0 

call CreateShortcut.bat %HOME% %ROOT% 
call CreateShortcut.bat %HOME%\Dropbox %Dropbox% 
