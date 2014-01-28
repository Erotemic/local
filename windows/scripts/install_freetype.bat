mkdir C:\TMP
cd C:\TMP
wget http://sourceforge.net/projects/freetype/files/freetype2/2.4.10/freetype-2.4.10.tar.gz
tar zxvf freetype-2.4.10.tar.gz
cd freetype-2.4.10

msys MSYS

./configure --enable-static
make install
cd ..

::http://wiki.openttd.org/Compiling_on_Windows_using_MinGW#Compiling_libfreetype
