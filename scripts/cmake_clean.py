#!/bin/env python
"""
Simlar to make clean, removes files, but (tries to) keeps relevant cmake cache
information
"""
import glob
from os.path import exists, basename, join
import shutil
import ubelt as ub


def cmake_clean(dpath='.'):
    """
    """
    dpath = ub.expandpath(dpath)
    cmake_cache_fpath = join(dpath, 'CMakeCache.txt')
    if not exists(cmake_cache_fpath):
        raise Exception(
            'This does not look like a cmake build directory. '
            'No CMakeCache.txt exists')
    fpath_set = set(glob.glob(join(dpath, '*'))) - {cmake_cache_fpath}

    for fpath in list(fpath_set):
        if basename(fpath).startswith('_cmake_build_backup_'):
            fpath_set.remove(fpath)

    backup_dpath = ub.ensuredir(join(dpath, '_cmake_build_backup_' + ub.timestamp()))
    for fpath in ub.ProgIter(fpath_set, 'moving files'):
        shutil.move(fpath, backup_dpath)


if __name__ == '__main__':
    """
    CommandLine:
        python ~/misc/cmake_clean.py
    """
    cmake_clean()
