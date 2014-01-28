:: Dos Extension
set file=%1
set noext=%file:~0,-4%

:: Dos Date
set tddt=%date:~10%-%date:~4,2%-%date:~7,2%
gs -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 -dNOPAUSE -dQUIET -dBATCH -sOutputFile=%noext%-compressed.pdf %1
