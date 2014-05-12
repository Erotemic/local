import os
import sys
from os.path import join, exists, expanduser
import matplotlib as mpl
mplrc_dir   = mpl.get_configdir()

if sys.platform.startswith('linux'):
    mplrc_dir = expanduser('~/.config/matplotlib')

# To conform with the XDG base directory standard,
# this configuration location has been deprecated on Linux,
# and the new location is now '/home/joncrall/.config'/matplotlib/.
# Please move your configuration there to ensure that matplotlib will
# continue to find it in the future.
mplrc_fpath = join(mplrc_dir, 'matplotlibrc')

mplrc_text = '''
backend      : qt4agg

'''

if not exists(mplrc_dir):
    os.makedirs(mplrc_dir)

with open(mplrc_fpath, 'w') as file_:
    file_.write(mplrc_text)

print('wrote %r' % mplrc_fpath)
