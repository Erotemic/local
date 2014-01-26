#/usr/bin/python
import os
import shutil

minted_file   = r'minted.sty'
latex_install = r'/usr/share/texmf-texlive'
minted_dir    = latex_install+'/tex/latex/minted'

print('___INSTALLING_MINTED___')

if not os.path.exists(minted_file):
    print(' * Downloading')
    os.system(r'wget https://minted.googlecode.com/files/minted.sty')
else: 
    print('  * already downloaded')

if not os.path.exists(minted_dir):
    print('  * mkdir '+minted_dir)
    os.mkdir(minted_dir)
else:
    print('  * install directory exists')

src = minted_file
dst = minted_dir+minted_file
if not os.path.exists(dst):
    print('  * mv '+src+' '+dst)
    shutil.move(src, dst)
else:
    print('  * '+src+' is already installed')
