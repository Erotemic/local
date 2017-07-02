from utool.experimental import file_organizer
import utool as ut

SourceDir = file_organizer.SourceDir

d1 = self = SourceDir('/media/joncrall/store/Videos')
d2 = SourceDir('/media/joncrall/media/TV')

self, other = d1, d2


# TODO: NEED TO PURGE EVERY FILE NAMED Thumbs.db

comp = d1.isect_info(d2)


# Cascading duplicate checks
d1.get_prop('md5_stride')
d2.get_prop('md5_stride')

d1.populate()
d2.populate()


self.populate()


# strategy
"""
GOAL: organize files, remove duplicates, put data on a RAID

* Need to ensure that everything on backup exists in either media or store.
* Move things that are ensured to exist to a special folder
* Do this until backup can be formatted



* Need to have notion of what needs to go where.
* Needs to figure out what goes in videos / movies / tv / etc..

"""


def populate2(self):
    # Find all mounted drives
    import csv
    with open('/proc/mounts') as file_:
        row_iter = csv.reader(file_, delimiter=str(' '))
        rows = [ut.lmap(ut.ensure_unicode, row) for row in row_iter]
    mount_dirs = [p for p in ut.take_column(rows, 1)
                  if p.startswith('/media')]

    mount_dirs = [
        '/',
        '/media/joncrall/store',
        # '/media/joncrall/media',
        # '/media/joncrall/backup',
    ]

    # Calculate the approx number of files in the system
    import os
    for mount in mount_dirs:
        print('mount = %r' % (mount,))
        result = os.statvfs(mount)
        # print('result = %r' % (result,))
        result.f_files
        print('result.f_files = %r' % (result.f_files,))
        result.f_ffree
        # out = ut.cmd2('df --inodes / %s' % p, shell=True, verbose=True)['out']

    dpath = '/home/joncrall/code'
    dpath = '/media/joncrall/store'

    self = SourceDir(dpath)
    ext_list = ['.jpg']
    ext_regex = '\(' + '\|'.join(ext_list) + '\)'
    linux_find_command = 'find %s -regex ".*%s"' % (self.dpath, ext_regex)
    print('linux_find_command = %r' % (linux_find_command,))

    nfiles = os.statvfs(self.dpath).f_files

    import itertools as it
    import six
    prog = ut.ProgIter(it.count(), length=nfiles,
                       label='walking filesystem')
    piter = iter(prog)
    for root, dirs, files in os.walk(self.dpath, topdown=False):
        for fpath in files:
            six.next(piter)
    # import re
    # row_data = [re.split(' +', line) for line in out.split('\n')]
    # row_data = list(filter(len, row_data))
    # data = ut.CSV(row_data[1:], col_headers=row_data[0])
