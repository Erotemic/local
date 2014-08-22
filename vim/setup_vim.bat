:: "C:\Program Files (x86)/Vim/"
:: move "vimfiles" "vimfiles_old"
:: move _vimrc clean_vimrc
:: MKLINK /D vimfiles %LOCAL_DIR%\vim\vimfiles
:: copy %LOCAL_DIR%\vim\win_replace_vimrc.txt _vimrc

set INSTALL32=C:\Program Files (x86)
set LOCAL_DIR=%HOME%\local
cd %INSTALL32%\Vim\

echo source $USERPROFILE\local\vim\portable_vimrc > _vimrc

MKLINK /J vimfiles %LOCAL_DIR%\vim\vimfiles
