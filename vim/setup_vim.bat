:: "C:\Program Files (x86)/Vim/"
set LOCAL_DIR=%HOME%\local
cd %INSTALL32%\Vim\
move "vimfiles" "vimfiles_old"
move _vimrc clean_vimrc
copy %LOCAL_DIR%\vim\win_replace_vimrc.txt _vimrc
MKLINK /D vimfiles %LOCAL_DIR%\vim\vimfiles
