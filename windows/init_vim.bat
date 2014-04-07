set INSTALL32=C:\Program Files (x86)
set LOCAL_DIR=%USERPROFILE%\local
cd "%INSTALL32%\Vim\"
:: move "%INSTALL32%\Vim\vimfiles" "%INSTALL32%\Vim\vimfiles_old"
:: move _vimrc clean_vimrc
copy %LOCAL_DIR%\vim\win_replace_vimrc.txt _vimrc
rm -rf "%INSTALL32%\Vim\vimfiles"
MKLINK /D "%INSTALL32%\Vim\vimfiles" %LOCAL_DIR%\vim\vimfiles
