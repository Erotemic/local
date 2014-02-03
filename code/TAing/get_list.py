import os
import fnmatch

fname_list = os.listdir('.')
for fname in fname_list:
    if fnmatch.fnmatch(fname,'*.txt'):
        f = open(fname,'r')
        fstr = f.read()
        f.close()
        print fname +' --- ' + fstr[fstr.find('TOTAL'):fstr.find('TOTAL')+20].replace('\n','')
