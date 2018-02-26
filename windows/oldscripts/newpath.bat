call rob update_path

call rob kill AutoHotkey

echo "Changing directory"

cd %AHK_SCRIPTS%

echo "Starting Autohotkey"

start crallj.ahk

echo set PATH=%PATH% > C:\newest_path.bat

PAUSE
