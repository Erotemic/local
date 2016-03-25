:: Startup directory
:: C:\Users\joncrall\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup
::
:: CreateShortcut.bat
::
call %LOCAL%\rob\win32\win_scripts\CreateShortcut.bat %LOCAL%\scripts\ahk_scripts\crallj.ahk  "%STARTUP%"
:: call %LOCAL%\rob\win32\win_scripts\CreateShortcut.bat %LOCAL%\ahk_scripts\middle_click.ahk  "%STARTUP%"
::
:: HACK to get middle click to import correctly
cp %LOCAL%\scripts\ahk_scripts\middle_click.ahk  "%STARTUP%"
