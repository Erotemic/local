import os
from os.path import join, exists
import matplotlib as mpl
mplrc_dir   = mpl.get_configdir()
mplrc_fpath = join(mplrc_dir, 'matplotlibrc')

mplrc_text = '''
backend      : qt4agg

'''

if not exists(mplrc_dir):
    os.makedirs(mplrc_dir)

with open(mplrc_fpath, 'w') as file_:
    file_.write(mplrc_text)

print('wrote %r' % mplrc_fpath)
