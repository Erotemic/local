rem START BATCH COMMANDS
rem PLEASE MAKE SURE THAT USER ACCOUNT CONTROL (UAC) IS TURNED OFF AND PC HAS BEEN REBOOTED FIRST!
rem If you are using VISTA x32 version, then edit this file first by adding “rem ” in front of every line that contains the phrase “syswow64?. Then run the acript again.
@echo off
PAUSE

takeown /f c:\windows\syswow64\notepad.exe
cacls c:\windows\syswow64\notepad.exe /G Administrators:F

takeown /f c:\windows\system32\notepad.exe
cacls c:\windows\system32\notepad.exe /G Administrators:F

takeown /f c:\windows\notepad.exe
cacls c:\windows\notepad.exe /G Administrators:F

copy c:\windows\syswow64\notepad.exe c:\windows\syswow64\notepad.exe.backup
copy c:\windows\system32\notepad.exe c:\windows\system32\notepad.exe.backup
copy c:\windows\notepad.exe c:\windows\notepad.exe.backup

copy "%VIM_BIN%\gvim.exe" c:\windows\syswow64\notepad.exe
copy "%VIM_BIN%\gvim.exe" c:\windows\system32\notepad.exe
copy "%VIM_BIN%\gvim.exe" c:\windows\notepad.exe
copy "%VIM_BIN%\..\_vimrc" c:\windows\syswow64\_vimrc
copy "%VIM_BIN%\..\_vimrc" c:\windows\system32\_vimrc
copy "%VIM_BIN%\..\_vimrc" c:\windows\_vimrc


@echo on
rem END BATCH COMMANDS

