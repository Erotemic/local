sudo find /usr/lib -iname '*sqlite3*' 
sudo find /usr/include -iname '*sqlite3*'

sudo find / -iname '*sqlite3*'


sudo ldconfig -p | grep sqlite3

ls -il /usr/local/lib/libsqlite3.so.0 && ls -il /usr/local/lib/libsqlite3.so &&
    ls -il /usr/lib/i386-linux-gnu/libsqlite3.so.0 && ls -il /usr/lib/i386-linux-gnu/libsqlite3.so


sudo mv /usr/local/lib/libsqlite3.so ~/tmp/.bad_sqlitelib
sudo rm /usr/local/include/sqlite3ext.h
sudo rm /usr/local/include/sqlite3.h
sudo rm /usr/local/bin/sqlite3
sudo rm /usr/local/lib/libsqlite3.so.0.8.6
sudo rm /usr/local/lib/libsqlite3.la
sudo rm /usr/local/lib/libsqlite3.so.0
sudo rm /usr/local/lib/libsqlite3.a

sqlite3 --version

