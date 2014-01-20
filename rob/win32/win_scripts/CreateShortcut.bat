:: CreateShortcut target dest
@echo off
set argC=0
for %%x in (%*) do Set /A argC+=1

if %argc% == 2 GOTO :two_args
if %argc% == 1 GOTO :one_args
echo "Incorrect Arguments"

goto :endpart


:two_args
set WIN_SCRIPTS=%ROB%\win32\win_scripts
set SRC_PATH=%1
set DST_PATH=%2\%~n1.lnk
echo ""
echo "Creating shortcut from %SRC_PATH% to %DST_PATH%"
cscript %WIN_SCRIPTS%\CreateShortcutHelper.vbs %DST_PATH% %SRC_PATH%
goto :endpart

:one_args
set WIN_SCRIPTS=%ROB%\win32\win_scripts
cscript %WIN_SCRIPTS%\CreateShortcutHelper.vbs %~n1.lnk %1
goto :endpart


:endpart
echo "Created Shortcut for %1"
@echo on

