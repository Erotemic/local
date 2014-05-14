set INSTALL32=C:\Program Files (x86)
set LOCAL_DIR=%USERPROFILE%\local
:: Specify target and link
set LINK_PATH="%INSTALL32%\Vim\vimfiles"
set TARGET_PATH="%LOCAL_DIR%\vim\vimfiles"
cp %LOCAL_DIR%\vim\win_replace_vimrc.txt "%INSTALL32%\Vim\_vimrc"
rm -rf %LINK_PATH%
ln -s %TARGET_PATH% %LINK_PATH% 
:: vd C:\Program Files (x86)\Vim\vimfiles
:: MKLINK /D %LINK_PATH%  %TARGET_PATH%  # DO NOT USE THIS! THE RM WILL REMOVE THE REAL BUNDLE DIR
