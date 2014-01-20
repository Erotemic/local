ln -s "%USERPROFILE%\local\vim\vimfiles" "C:\Program Files (x86)\Vim\vimfiles"

:: Startup directory
:: C:\Users\joncrall\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup
::
call CreateShortcut.bat %LOCAL%\ahk_scripts\crallj.ahk  "%STARTUP%"
call CreateShortcut.bat %LOCAL%\ahk_scripts\middle_click.ahk  "%STARTUP%"
