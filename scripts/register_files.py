# -*- coding: utf-8 -*-
"""
Script to register files on a drive and reconcile duplicates

CommandLine:
    cd ~/local/scripts
    import register_files

    set PYTHONPATH=%PYTHONPATH%;%HOME%/local/scripts
    export PYTHONPATH=$PYTHONPATH:~/local/scripts
    python -m register_files --exec-register_drive --drives ~
    python %HOME%/local/scripts/register_files.py --exec-register_drive --drives D:/ E:/ F:/
"""
from __future__ import absolute_import, division, print_function, unicode_literals
import utool as ut
import six  # NOQA
import os
from os.path import join, exists, dirname, basename
from os.path import islink
#from os.path import splitext
import re
import numpy as np
import numpy as np  # NOQA
import vtool as vt  # NOQA
from six.moves import zip, range  # NOQA

if ut.WIN32:
    SystemErrors = (OSError, WindowsError)
else:
    SystemErrors = (OSError)


dryrun = not ut.get_argflag('--force')


def build_multindex(list_):
    """
    Creates mapping from unique items to indicies at which they appear
    """
    multiindex_dict_ = ut.ddict(list)
    for item, index in zip(list_, range(len(list_))):
        if item is not None:
            multiindex_dict_[item].append(index)
    return multiindex_dict_


def tryhash(fpath_, stride=1):
    try:
        return ut.get_file_hash(fpath_, stride=stride)
    except IOError:
        return None


def build_dpath_to_fidx(fpath_list, fidx_list, root_dpath):
    dpath_to_fidx = ut.ddict(list)
    nTotal = len(fpath_list)
    _iter = zip(fidx_list, fpath_list)
    dpath_to_fidx = ut.ddict(list)
    for fidx, fpath in ut.ProgIter(_iter, 'making dpath fidx map',
                                   freq=50000, nTotal=nTotal):
        current_path = fpath
        while True:
            current_path = dirname(current_path)
            dpath_to_fidx[current_path].append(fidx)
            if current_path == root_dpath:
                break
    return dpath_to_fidx


def analyize_multiple_drives(drives):
    """
    CommandLine:
        export PYTHONPATH=$PYTHONPATH:~/local/scripts

        set PYTHONPATH=%PYTHONPATH%;%HOME%/local/scripts
        python -m register_files --exec-analyize_multiple_drives --drives ~ E:/ D:/

        python -m register_files --exec-analyize_multiple_drives --drives ~ /media/Store

        cd ~/local/scripts

    Example:
        >>> from register_files import *  # NOQA
        >>> dpaths = ut.get_argval('--drives', type_=list, default=['E://', 'D://'])#'D:/', 'E:/', 'F:/'])
        >>> drives = [Drive(root_dpath) for root_dpath in dpaths]
        >>> drive = Broadcaster(drives)
        >>> drive.compute_info()
        >>> #drive.build_fpath_hashes()
        >>> drive.check_consistency()
        >>> E = drive = drives[0]
        >>> analyize_multiple_drives(drives)
        >>> #D, E, F = drives
        >>> #drive = D
    """
    # -----
    ## Find the files shared on all disks
    #allhave = reduce(ut.dict_isect_combine, [drive.hash_to_fpaths for drive in drives])
    #print('#allhave = %r' % (len(allhave),))
    #allhave.keys()[0:3]
    #allhave.values()[0:3]
    #ut.embed()
    #for drive in drives:
    #drive.rrr()
    #print(drive.root_dpath)
    #print(len(drive.hash_to_unique_fpaths))
    #print(len(drive.hash_to_fpaths))
    #print(len(drive.hash_to_unique_fpaths) / len(drive.hash_to_fpaths))

    # Build dict to map from dpath to file pointers of unique descendants
    #unique_fidxs_list = drive.hash_to_fidxs.values()
    #fidxs = ut.flatten(unique_fidxs_list)

    esc = re.escape

    # Find which files exist on all drives
    hashes_list = [set(drive_.hash_to_fidxs.keys()) for drive_ in drives]
    allhave_hashes = reduce(set.intersection, hashes_list)
    print('Drives %r have %d file hashes in common' % (drives, len(allhave_hashes)))

    lbls = [drive_.root_dpath for drive_ in drives]
    isect_lens = np.zeros((len(drives), len(drives)))
    for idx1, (hashes1, drive1) in enumerate(zip(hashes_list, drives)):
        for idx2, (hashes2, drive2) in enumerate(zip(hashes_list, drives)):
            if drive1 is not drive2:
                common = set.intersection(hashes1, hashes2)
                isect_lens[idx1, idx2] = len(common)
            else:
                isect_lens[idx1, idx2] = len(hashes2)
    import pandas as pd
    print(pd.DataFrame(isect_lens, index=lbls, columns=lbls))

    # for drive in drives
    drive = drives[0]
    print('Finding unique files in drive=%r' % (drive,))
    # Get subset of fidxs on this drive
    unflat_valid_fidxs = ut.take(drive.hash_to_fidxs, allhave_hashes)
    valid_fidxs = sorted(ut.flatten(unflat_valid_fidxs))

    # Filter fpaths by patterns
    ignore_patterns = [
        esc('Thumbs.db')
    ]
    ignore_paths = [
        'Spotify'
    ]
    patterns = ignore_paths + ignore_patterns
    valid_fpaths = ut.take(drive.fpath_list, valid_fidxs)
    valid_flags = [not any([re.search(p, fpath) for p in patterns])
                   for fpath in valid_fpaths]
    valid_flags = np.array(valid_flags)
    valid_fidxs = ut.compress(valid_fidxs, valid_flags)

    print(ut.filtered_infostr(valid_flags, 'invalid fpaths'))

    fidxs = valid_fidxs
    valid_fpaths = sorted(ut.take(drive.fpath_list, fidxs))

    dpath_to_unique_fidx = build_dpath_to_fidx(valid_fpaths, valid_fidxs,
                                                drive.root_dpath)

    def make_tree_structure(valid_fpaths):
        root = {}

        def dict_getitem_default(dict_, key, type_):
            try:
                val = dict_[key]
            except KeyError:
                val = type_()
                dict_[key] = val
            return val

        for fpath in ut.ProgIter(valid_fpaths, 'building tree', freq=30000):
            path_components = ut.dirsplit(fpath)
            current = root
            for comp in path_components[:-1]:
                current = dict_getitem_default(current, comp, dict)
            contents = dict_getitem_default(current, '.', list)
            contents.append(path_components[-1])
        return root

    root = make_tree_structure(valid_fpaths)

    def print_tree(root, path, dpath_to_unique_fidx=dpath_to_unique_fidx, drive=drive, depth=None):
        print('path = %r' % (path,))
        print(ut.byte_str2(drive.get_total_nbytes(dpath_to_unique_fidx[path])))
        path_components = ut.dirsplit(path)
        # Navigate to correct spot in tree
        current = root
        for c in path_components:
            current = current[c]
        print(ut.repr3(current, truncate=1))

    def get_tree_info(root, path, dpath_to_unique_fidx=dpath_to_unique_fidx, drive=drive, depth=0):
        path_components = ut.dirsplit(path)
        current = root
        for c in path_components:
            current = current[c]
        if isinstance(current, list):
            tree_tmp = []
        else:
            key_list = list(current.keys())
            child_list = [join(path, key) for key in key_list]
            dpath_nbytes_list = [
                drive.get_total_nbytes(dpath_to_unique_fidx.get(child, []))
                for child in child_list
            ]
            nfiles_list = [
                len(dpath_to_unique_fidx.get(child, []))
                for child in child_list
            ]
            tree_tmp = sorted([
                (key, ut.byte_str2(nbytes), nfiles)
                if depth == 0 else
                (key, ut.byte_str2(nbytes), nfiles,
                    get_tree_info(root, path=child,
                                  dpath_to_unique_fidx=dpath_to_unique_fidx, drive=drive,
                                  depth=depth - 1))
                for key, child, nbytes, nfiles in zip(key_list, child_list, dpath_nbytes_list, nfiles_list)
            ])
        return tree_tmp

    def print_tree_struct(*args, **kwargs):
        tree_str = (ut.indent(ut.repr3(get_tree_info(*args, **kwargs), nl=1)))
        print(tree_str)
        #bytes_str = ut.byte_str2(drive.get_total_nbytes(dpath_to_unique_fidx[path]))
        #print('path = %r, %s' % (path, bytes_str))
        #print(ut.repr3(key_list))
        return tree_str

    dpath_to_unique_fidx
    dpath_to_fidxs = ut.map_dict_vals(set, drive.dpath_to_fidx)
    complete_unique_dpaths = ut.dict_isect(dpath_to_fidxs, dpath_to_unique_fidx)
    complete_root = make_tree_structure(complete_unique_dpaths.keys())

    globals()['ut'] = ut
    globals()['os'] = os
    globals()['join'] = join

    print(ut.byte_str2(drive.get_total_nbytes(dpath_to_unique_fidx['E:\\'])))
    get_tree_info(root, path='E:\\', depth=0)

    get_tree_info(complete_root, path='E:\\', depth=0)

    get_tree_info(root, path='E:\\', depth=1)
    print(print_tree_struct(root, path='E:\\Clutter', depth=0))
    print_tree(root, path=r'E:\TV')
    print_tree(root, path=r'E:\Movies')
    print_tree(root, path=r'E:\Boot')

    print_tree(root, path='E:\\')
    print_tree(root, path=r'E:\Downloaded')
    print_tree(root, path=r'E:\Recordings')
    print_tree(root, path=r'E:\Clutter')
    print_tree(root, path=r'E:\Audio Books')

    # TODO:
    # * Ignore list
    # * Find and rectify internal duplicates
    # * Update registry with new files and deleted ones
    # * Ensure that all unique files are backed up
    # Index the C: Drive as well.
    # * Lazy properties of drive
    # * Multiple types of identifiers (hash, fname, ext, fsize)
    # Drive subsets
    # Export/Import Drive for analysis on other machines

    ut.embed()


class Broadcaster(object):
    def __init__(bcast, objs):
        bcast.objs = objs

    def __repr__(bcast):
        return repr(bcast.objs)

    def __str__(bcast):
        return str(bcast.objs)

    def __call__(battr, *args, **kwargs):
        return [a(*args, **kwargs) for a in battr.objs]

    def __getattr__(bcast, attr):
        attr_list = [getattr(obj, attr) for obj in bcast.objs]
        return Broadcaster(attr_list)
        #def execute(*args, **kwargs):
        #    return [a(*args, **kwargs) for a in attr_list]
        #return execute
        #return attr_list
        #print('attr = %r' % (attr,))


@six.add_metaclass(ut.ReloadingMetaclass)
class Drive(object):
    r"""
    Stores properties, builds properties, infers info

    CommandLine:
        set PYTHONPATH=%PYTHONPATH%;%HOME%/local/scripts
        python -m register_files --exec-Drive --drives E:/

        export PYTHONPATH=$PYTHONPATH:~/local/scripts
        python -m register_files --exec-Drive --drives ~

        python %HOME%/local/scripts/register_files.py --exec-Drive --drives D:/ E:/ F:/

    Ignore:
        >>> # ENABLE_DOCTEST
        >>> import sys
        >>> from os.path import *
        >>> from register_files import *  # NOQA
        >>> sys.path.append(normpath(expanduser('~/local/scripts')))

    Example:
        >>> from register_files import *  # NOQA
        >>> dpaths = ut.get_argval('--drives', type_=list, default=[])
        >>> drives = [Drive(root_dpath) for root_dpath in dpaths]
        >>> drive = Broadcaster(drives)
        >>> #drive.cache.clear()
        >>> #drive = drives[0]
        >>> drive.compute_info()
        >>> print(drive)
        >>> drive.check_consistency()
        >>> drive.build_fpath_hashes()
        >>> #analyize_multiple_drives(drives)
        #>>> result = register_drive('D:/')
        #>>> result = register_drive('E:/')
        #>>> result = register_drive('F:/')

    Ignore:
        drive.rrr()
        drive.total_bytes
        E, D, F = drives
    """

    @property
    def fpath_list(drive):
        if getattr(drive, 'fpath_list_', None) is None:
            drive.register_files()
        return drive.fpath_list_

    @property
    def dpath_list(drive):
        if getattr(drive, 'dpath_list_', None) is None:
            drive.register_files()
        return drive.dpath_list_

    @property
    def fpath_hashX_list(drive):
        if getattr(drive, 'fpath_hashX_list_', None) is None:
            drive.fpath_hashX_list_ = drive.build_fpath_hashes()
        return drive.fpath_hashX_list_

    @property
    def hash_to_fidxs(drive):
        if getattr(drive, 'hash_to_fidxs_', None) is None:
            drive.hash_to_fidxs_ = build_multindex(drive.fpath_hashX_list)
        return drive.hash_to_fidxs_

    @property
    def dpath_to_fidx(drive):
        if getattr(drive, 'dpath_to_fidx_', None) is None:
            drive.dpath_to_fidx_ = drive.get_dpath_to_fidx()
        return drive.dpath_to_fidx_

    @property
    def fpath_bytes_list(drive):
        if getattr(drive, 'fpath_bytes_list_', None) is None:
            drive.fpath_bytes_list_ = drive.get_fpath_bytes_list()
        return drive.fpath_bytes_list_

    @property
    def total_bytes(drive):
        if getattr(drive, 'total_bytes_', None) is None:
            drive.total_bytes_ = drive.get_total_nbytes()
        return drive.total_bytes_

    def compute_info(drive):
        print('Computing Info of %r' % (drive,))
        drive.register_files()
        drive.fpath_bytes_list
        #drive.group_duplicates()

    #def group_duplicates(drive):
    #    # Map to the fpaths as well
    #    drive.hash_to_fpaths = dict(
    #        [(hash_, ut.take(drive.fpath_list, idxs))
    #         for hash_, idxs in drive.hash_to_fidxs.items()])

    def __init__(drive, root_dpath=None, state_fpath=None):
        drive.root_dpath = ut.truepath(ut.ensure_unicode(root_dpath))
        print('Initializing drive %s' % (drive.root_dpath,))
        ut.assert_exists(drive.root_dpath)
        # Mapping from dpath strings to fpath indexes
        assert state_fpath is None, 'not yet supported for external analysis'
        drive.cache_fname = join(drive.root_dpath, 'ut_pathreg_cache.shelf')

        drive.fpath_bytes_list_ = None
        drive.dpath_to_fidx_ = None
        drive.fpath_hashX_list_ = None
        drive.hash_to_fidxs_ = None
        drive.cache = ut.ShelfCacher(drive.cache_fname)

    def check_consistency(drive):
        print('Checking %r consistency' % (drive,))
        total = ut.get_total_diskbytes(drive.root_dpath)
        free = ut.get_free_diskbytes(drive.root_dpath)
        used = total - free
        print('total             = %r' % (total,))
        print('used              = %r' % (used,))
        print('drive.total_bytes = %r' % (drive.total_bytes,))

        print('total             = %r' % (ut.byte_str2(total),))
        print('used              = %r' % (ut.byte_str2(used),))
        print('drive.total_bytes = %r' % (ut.byte_str2(drive.total_bytes),))

    def __str__(drive):
        if drive.total_bytes is None:
            bytes_str = '?'
        else:
            bytes_str = ut.byte_str2(drive.total_bytes)
        return drive.root_dpath + ' - ' + bytes_str

    def __repr__(drive):
        return '<Drive ' + drive.__str__() + '>'

    def get_infostr(drive, extra=False):
        drive.num_fpaths = len(drive.fpath_list)
        infostr_list = [str(drive)]
        drive.get_filesize_errors()
        nan_fpaths = drive.get_filesize_errors()
        infostr_list += ['#nan fsize fpaths = %r' % (len(nan_fpaths),)]
        if extra:
            infostr_list += ['#nan_fpaths = %r' % (nan_fpaths[0:10],)]
        total_drive_bytes = ut.get_total_diskbytes(drive.root_dpath)
        infostr_list += [('total drive size = %r' % (ut.byte_str2(total_drive_bytes),))]
        infostr_list += [('drive.num_fpaths = %r' % (drive.num_fpaths,))]
        infostr = '\n'.join(infostr_list)
        return infostr

    def print_infostr(drive):
        print(drive.get_infostr())

    def get_filesize_errors(drive):
        flags = np.isnan(drive.fpath_bytes_arr)
        nan_fpaths = ut.compress(drive.fpath_list, flags)
        return nan_fpaths

    def get_total_nbytes(drive, fidx_list=None):
        if fidx_list is None:
            if drive.fpath_bytes_list_ is None:
                return None
        if fidx_list is None:
            return np.nansum(drive.fpath_bytes_list)
        else:
            return np.nansum(ut.take(drive.fpath_bytes_list, fidx_list))

    def biggest_files(drive):
        print('Biggest Files in %r' % (drive,))
        sortx = ut.list_argsort(drive.fpath_bytes_list)[::-1]
        sel = sortx[0:10]
        biggest_nbytes = ut.take(drive.fpath_bytes_list, sel)
        biggest_files = ut.take(drive.fpath_list, sel)
        biginfo_list = list(zip(map(ut.byte_str2, biggest_nbytes), biggest_files))
        print(ut.list_str(biginfo_list, strvals=True))

    def biggest_dirs(drive):
        print('Biggest Dirs in %r' % (drive,))
        dpath_list = drive.dpath_list
        fidxs_list = ut.dict_take(drive.dpath_to_fidx, dpath_list)
        unflat_dpath_bytes_list = ut.list_unflat_take(drive.fpath_bytes_list, fidxs_list)
        dpath_nbytes_list = list(map(sum, unflat_dpath_bytes_list))

        sortx = ut.list_argsort(dpath_nbytes_list)[::-1]
        sel = sortx[0:10]
        biggest_nbytes = ut.take(dpath_nbytes_list, sel)
        biggest_dpaths = ut.take(dpath_list, sel)
        biginfo_list = list(zip(map(ut.byte_str2, biggest_nbytes), biggest_dpaths))
        print(ut.list_str(biginfo_list, strvals=True))
        pass

    def fix_duplicates(drive):
        r"""
        for every duplicate file passing a (eg avi) filter, remove the file
        that is in the smallest directory. On a tie use the smallest dpath.
        This will filter all duplicate files in a folder into a single folder.

        but... need to look at non-duplicates in that folder and decide if they
        should be moved as well.  So, should trigger on folders that have at
        least 50% duplicate.  Might not want to move curated folders.

        Example:
            cd ~/local/scripts
            >>> from register_files import *  # NOQA
            >>> dpaths = ut.get_argval('--drives', type_=list, default=['E:/'])#'D:/', 'E:/', 'F:/'])
            >>> drives = [Drive(root_dpath) for root_dpath in dpaths]
            >>> E = drive = drives[0]
            >>> #D, E, F = drives
        """
        print('Fixing Duplicates in %r' % (drive,))
        list_ = drive.fpath_hashX_list
        multiindex_dict_ = build_multindex(list_)
        duplicate_hashes = [
            key for key, val in six.iteritems(multiindex_dict_)
            if len(val) > 1
        ]
        duplicate_idxs = ut.dict_take(multiindex_dict_, duplicate_hashes)
        unflat_fpaths = ut.list_unflat_take(drive.fpath_list, duplicate_idxs)
        # Check if any dups have been removed
        still_exists = ut.unflat_map(exists, unflat_fpaths)
        unflat_idxs2 = ut.zipcompress(duplicate_idxs, still_exists)
        duplicate_idxs = [idxs for idxs in unflat_idxs2 if len(idxs) > 1]
        # Look at duplicate files
        unflat_fpaths = ut.list_unflat_take(drive.fpath_list, duplicate_idxs)
        unflat_sizes = ut.list_unflat_take(drive.fpath_bytes_list, duplicate_idxs)
        # Find highly coupled directories
        if True:
            coupled_dirs = []
            for fpaths in unflat_fpaths:
                #basedir = ut.longest_existing_path(commonprefix(fpaths))
                dirs = sorted(list(map(dirname, fpaths)))
                _list = list(range(len(dirs)))
                idxs = ut.upper_diag_self_prodx(_list)
                coupled_dirs.extend(list(map(tuple, ut.list_unflat_take(dirs, idxs))))
            hist_ = ut.dict_hist(coupled_dirs)
            coupled_idxs = ut.list_argsort(hist_.values())[::-1]
            most_coupled = ut.list_take(list(hist_.keys()), coupled_idxs[0:100])
            print('Coupled fpaths: ' + ut.list_str(most_coupled, nl=True))
        print('%d unique files are duplicated' % (len(unflat_sizes),))
        #print('Duplicate sizes: ' + ut.list_str(unflat_sizes[0:10], nl=True))
        #print('Duplicate fpaths: ' + ut.list_str(unflat_fpaths[0:10], nl=True))
        #print('Duplicate fpaths: ' + ut.list_str(unflat_fpaths[0::5], nl=True))
        print('Duplicate fpaths: ' + ut.list_str(unflat_fpaths, nl=True))
        # Find duplicate directories
        dpath_list = list(drive.dpath_to_fidx.keys())
        fidxs_list = ut.dict_take(drive.dpath_to_fidx, drive.dpath_list)
        #exists_list = list(map(exists, drive.fpath_list))
        #unflat_exists = ut.list_unflat_take(exists_list, fidxs_list)
        fname_registry = [basename(fpath) for fpath in drive.fpath_list]
        unflat_fnames = ut.list_unflat_take(fname_registry, fidxs_list)
        def unsorted_list_hash(list_):
            return ut.hashstr27(str(sorted(list_)))
        unflat_fname_sets = list(map(unsorted_list_hash, ut.ProgIter(unflat_fnames, freq=10000)))
        fname_based_duplicate_dpaths = []
        multiindex_dict2_ = build_multindex(unflat_fname_sets)
        fname_based_duplicate_hashes = [key for key, val in multiindex_dict2_.items() if len(val) > 1]
        print('#fname_based_duplicate_dpaths = %r' % (len(fname_based_duplicate_hashes),))
        fname_based_duplicate_didxs = ut.dict_take(multiindex_dict2_, fname_based_duplicate_hashes)
        fname_based_duplicate_dpaths = ut.list_unflat_take(dpath_list, fname_based_duplicate_didxs)
        print(ut.repr3(fname_based_duplicate_dpaths[0:10]))
        #dpath_to_contents

    def fix_empty_dirs(drive):
        """
        # --- FIND EMPTY DIRECTORIES ---
        """
        print('Fixing Empty Dirs in %r' % (drive,))
        fidxs_list = ut.dict_take(drive.dpath_to_fidx, drive.dpath_list)
        isempty_flags = [len(fidxs) == 0 for fidxs in fidxs_list]
        empty_dpaths = ut.compress(drive.dpath_list, isempty_flags)

        def is_cplat_link(path_):
            try:
                if islink(path_):
                    return True
                os.listdir(d)
                return False
            except SystemErrors:
                return True
        valid_flags = [not is_cplat_link(d) for d  in empty_dpaths]
        if not all(valid_flags):
            print('Filtered windows links %r / %r' % (
                len(empty_dpaths) - sum(valid_flags), len(empty_dpaths)))
            #print(ut.list_str(empty_dpaths[0:10]))
            empty_dpaths = ut.compress(empty_dpaths, valid_flags)

        print('Found %r / %r empty_dpaths' % (len(empty_dpaths), len(drive.dpath_list)))
        print(ut.list_str(empty_dpaths[0:10]))

        # Ensure actually still empty
        current_contents = [ut.glob(d, with_dirs=False)
                            for d in ut.ProgIter(empty_dpaths, 'checking empty status')]
        current_lens = list(map(len, current_contents))
        assert not any(current_lens), 'some dirs are not empty'

        # n ** 2 check to get only the base directories
        isbase_dir = [
            not any([d.startswith(dpath_) and d != dpath_
                        for dpath_ in empty_dpaths])
            for d in ut.ProgIter(empty_dpaths, 'finding base dirs')
        ]
        base_empty_dirs = ut.compress(empty_dpaths, isbase_dir)
        def list_only_files(dpath):
            # glob is too slow
            for root, dirs, fpaths in os.walk(dpath):
                for fpath in fpaths:
                    yield fpath
        base_current_contents = [
            list(list_only_files(d))
            for d in ut.ProgIter(base_empty_dirs, 'checking emptyness', freq=10)]
        is_actually_empty = [len(fs) == 0 for fs in base_current_contents]
        not_really_empty = ut.compress(base_empty_dirs, ut.not_list(is_actually_empty))
        print('%d dirs are not actually empty' % (len(not_really_empty),))
        print('not_really_empty = %s' % (ut.list_str(not_really_empty[0:10]),))
        truly_empty_dirs = ut.compress(base_empty_dirs, is_actually_empty)

        def list_all(dpath):
            # glob is too slow
            for root, dirs, fpaths in os.walk(dpath):
                for dir_ in dirs:
                    yield dir_
                for fpath in fpaths:
                    yield fpath

        exclude_base_dirs = [join(drive.root_dpath, 'AppData')]
        exclude_end_dirs = ['__pycache__']
        truly_empty_dirs1 = truly_empty_dirs
        for ed in exclude_base_dirs:
            truly_empty_dirs1 = [
                d for d in truly_empty_dirs1
                if (
                    not any(d.startswith(ed) for ed in exclude_base_dirs) and
                    not any(d.endswith(ed) for ed in exclude_end_dirs)
                )
            ]
        # Ensure actually still empty (with recursive checks for hidden files)
        print('truly_empty_dirs1[::5] = %s' % (
            ut.list_str(truly_empty_dirs1[0::5], strvals=True),))
        #print('truly_empty_dirs1 = %s' % (ut.list_str(truly_empty_dirs1, strvals=True),))

        if not dryrun:
            # FIX PART
            #from os.path import normpath
            #for d in ut.ProgIter(truly_empty_dirs):
            #    break
            #    if ut.WIN32:
            #        # http://www.sevenforums.com/system-security/53095-file-folder-read-only-attribute-wont-disable.html
            #        ut.cmd('attrib', '-r', '-s', normpath(d), verbose=False)
            #x = ut.remove_fpaths(truly_empty_dirs, strict=False)

            print('Deleting %d truly_empty_dirs1' % (len(truly_empty_dirs1),))

            for d in ut.ProgIter(truly_empty_dirs1, 'DELETE empty dirs', freq=1000):  # NOQA
                ut.delete(d, quiet=True)

            if ut.WIN32 and False:
                # remove file that failed removing
                flags = list(map(exists, truly_empty_dirs1))
                truly_empty_dirs1 = ut.compress(truly_empty_dirs1, flags)
                for d in ut.ProgIter(truly_empty_dirs1, 'rming', freq=1000):
                    ut.cmd('rmdir', d)

    def register_files(drive):
        print('Loading registered files in %r' % (drive,))
        try:
            fpath_list = drive.cache.load('fpath_registry')
            dpath_list = drive.cache.load('dpath_registry')
        except ut.CacheMissException:
            print('Recomputing registry')
            fpath_gen_list = []
            dpath_gen_list = []
            for root, dname_list, fname_list in ut.ProgIter(os.walk(drive.root_dpath), 'walking', freq=1000):
                # Ignore hidden directories
                dname_list[:] = [d for d in dname_list if not d.startswith('.')]
                fpath_gen_list.append((root, fname_list))
                dpath_gen_list.append((root, dname_list))
            fpath_list = [join(root, f) for root, fs in fpath_gen_list for f in fs]
            dpath_list =  [join(root, d) for root, ds in dpath_gen_list for d in ds]
            dpath_list = [drive.root_dpath] + dpath_list
            print('Regsitering %d files and %d directories' % (len(fpath_list), len(dpath_list)))
            drive.cache.save('fpath_registry', fpath_list)
            drive.cache.save('dpath_registry', dpath_list)
        print('Loaded %d files and %d directories' % (len(fpath_list), len(dpath_list)))
        drive.fpath_list_ = fpath_list
        drive.dpath_list_ = dpath_list

    def update_registry(drive):
        print('Updating registered files in %r' % (drive,))
        # Update existing files
        fpath_exists_list = list(map(exists, ut.ProgIter(drive.fpath_list, 'checkexist fpath', freq=1000)))
        dpath_exists_list = list(map(exists, ut.ProgIter(drive.dpath_list, 'checkexist dpath', freq=1000)))
        if all(fpath_exists_list):
            print('No change in file structure')
        else:
            print('%d/%d files no longer exist' % (
                len(drive.fpath_list) - sum(fpath_exists_list),
                len(drive.fpath_list)))
            removed_fpaths = ut.compress(drive.fpath_list, ut.not_list(fpath_exists_list))
            print('removed_fpaths = %s' % (ut.list_str(removed_fpaths),))
        if all(dpath_exists_list):
            print('No change in dpath structure')
        else:
            print('%d/%d dirs no longer exist' % (
                len(drive.dpath_list) - sum(dpath_exists_list),
                len(drive.dpath_list)))
            removed_dpaths = ut.compress(
                drive.dpath_list,
                ut.not_list(dpath_exists_list))
            print('removed_dpaths = %s' % (ut.list_str(removed_dpaths),))

        drive.fpath_list = ut.compress(drive.fpath_list, fpath_exists_list)
        drive.dpath_list = ut.compress(drive.dpath_list, dpath_exists_list)
        drive.cache.save('fpath_list', drive.fpath_list)
        drive.cache.save('dpath_list', drive.dpath_list)

    def get_fpath_bytes_list(drive):
        print('Building fpath bytes for %r' % (drive,))
        try:
            fpath_bytes_list = drive.cache.load('fpath_bytes_list')
            assert len(fpath_bytes_list) == len(drive.fpath_list), 'bad length'
        except ut.CacheMissException:
            def tryread_nbytes(fpath):
                try:
                    return ut.file_bytes(fpath)
                except SystemErrors:
                    return np.nan
            fpath_bytes_list = [
                tryread_nbytes(fpath)
                for fpath in ut.ProgIter(drive.fpath_list, 'reading size', freq=1000)
            ]
            assert len(drive.fpath_list) == len(drive.fpath_list)
            drive.cache.save('fpath_bytes_list', fpath_bytes_list)
        return fpath_bytes_list

    def get_dpath_to_fidx(drive):
        """
        Build mapping from each dpath to contained file indexes
        """
        # Create mapping from directory to subfiles
        try:
            dpath_to_fidx = drive.cache.load('dpath_to_fidx')
            assert len(dpath_to_fidx) <= len(drive.dpath_list)
        except ut.CacheMissException:
            fpath_list = drive.fpath_list
            fidx_list = list(range(len(fpath_list)))
            dpath_to_fidx = build_dpath_to_fidx(fpath_list, fidx_list, drive.root_dpath)
            drive.cache.save('dpath_to_fidx', dpath_to_fidx)
        return dpath_to_fidx

    def get_tier_windows(drive):
        nbytes_tiers = [
            np.inf,
            2 ** 32,
            2 ** 30,
            2 ** 29,
            2 ** 28,
            2 ** 27,
            2 ** 26,
            2 ** 25,
            2 ** 24,
            2 ** 23,
            2 ** 22,
            2 ** 21,
            2 ** 20,
            2 ** 10,
            0,
            -np.inf,
        ]
        tier_windows = list(ut.itertwo(nbytes_tiers))
        return tier_windows

    def get_tier_flags(drive):
        try:
            tier_flags = drive.cache.load('tier_flags')
        except ut.CacheMissException:
            tier_windows = drive.get_tier_windows()

            print('Tier Windows')
            for tier, (high, low) in enumerate(tier_windows):
                print('tier %r window = %s - %s' % (tier, ut.byte_str2(high), ut.byte_str2(low)))

            fpath_bytes_arr = np.array(drive.fpath_bytes_list)
            tier_flags = [
                np.logical_and.reduce([fpath_bytes_arr <= high, fpath_bytes_arr > low])
                for high, low in tier_windows
            ]
            drive.cache.save('tier_flags', tier_flags)
        return tier_flags

    def print_tier_info(drive):
        tier_windows = drive.get_tier_windows()
        tier_flags = drive.get_tier_flags()

        for tier, flags in enumerate(tier_flags):
            high, low = tier_windows[tier]
            print('tier %r window = %s - %s' % (tier, ut.byte_str2(high), ut.byte_str2(low)))
            print('    len(fpaths) = %r' % (np.sum(flags)))

    def build_fpath_hashes(drive):
        try:
            fpath_hashX_list = drive.cache.load('fpath_hashX_list')
        except ut.CacheMissException:
            fpath_hashX_list = [None] * len(drive.fpath_list)

            assert len(drive.fpath_bytes_list) == len(drive.fpath_list)

            tier_windows = drive.get_tier_windows()
            tier_flags = drive.get_tier_flags()
            tier_fpaths = [ut.compress(drive.fpath_list, flags) for flags in tier_flags]

            #for tier, fpaths in enumerate(tier_fpaths):
            #chosen_tiers = [6, 5, 4, 3, 2, 1, 0]
            chosen_tiers = list(range(len(tier_windows)))[::-1]
            for tier in chosen_tiers:
                window = np.array(tier_windows[tier])
                minbytes = window[np.isfinite(window)].min()
                #stride = max(1, minbytes // (2 ** 20))
                stride = max(1, minbytes // (2 ** 20))
                print('%s tier %d stride = %r' % (drive.root_dpath, tier, stride,))
                fpaths = tier_fpaths[tier]
                print('# fpaths = %r' % (len(fpaths),))

                tier_hashes = [
                    tryhash(fpath, stride) for fpath in
                    ut.ProgIter(fpaths, 'tier=%r hashes' % (tier,), freq=100)
                ]
                #import register_files
                #tier_hashes = list(ut.buffered_generator((
                #    register_files.tryhash(fpath, stride) for fpath in
                #    ut.ProgIter(fpaths, 'tier=%r hashes' % (tier,), freq=100)
                #)))
                tier_idxs = np.where(tier_flags[tier])[0]

                for idx, hash_ in zip(tier_idxs, tier_hashes):
                    fpath_hashX_list[idx] = hash_

            drive.cache.save('fpath_hashX_list', fpath_hashX_list)
        return fpath_hashX_list


if __name__ == '__main__':
    r"""
    CommandLine:
        set PYTHONPATH=%PYTHONPATH%;C:/Users/joncrall/local/scripts
        python -B %HOME%/local/scripts/register_files.py
        python -B %HOME%/local/scripts/register_files.py --allexamples
    """
    import multiprocessing
    multiprocessing.freeze_support()  # for win32
    import utool as ut  # NOQA
    ut.doctest_funcs()
