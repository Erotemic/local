set INSTALL32=C:\Program Files (x86)
rm -rf "%INSTALL32%\Vim\vimfiles"
ln -s "%USERPROFILE%\local\vim\vimfiles" "%INSTALL32%\Vim\vimfiles"
:: vd C:\Program Files (x86)\Vim\vimfiles
