:: "C:\Program Files (x86)/Vim/"
::mkdir %VIMFILES%

set VIMFILES="C:\Program Files (x86)\vim\vimfiles"
set PORT_SETTINGS="C:\Users\joncrall\Dropbox\Settings"

cd "C:\Program Files (x86)\Vim\"

move "vimfiles" "vimfiles_old"

move _vimrc clean_vimrc

copy %PORT_SETTINGS%\vim\win_replace_vimrc.txt _vimrc

MKLINK /D %VIMFILES% %PORT_SETTINGS%\vim\vimfiles



