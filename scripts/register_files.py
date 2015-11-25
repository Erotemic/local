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
from os.path import splitext
import functools
import numpy as np
import numpy as np  # NOQA
import vtool as vt  # NOQA
from six.moves import zip, range  # NOQA

if ut.WIN32:
    SystemErrors = (OSError, WindowsError)
else:
    SystemErrors = (OSError)


dryrun = not ut.get_argflag('--force')


def prog_(iter_, lbl, freq=1000, **kwargs):
    return ut.ProgressIter(iter_, freq=freq, lbl=lbl, **kwargs)


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
    import utool as ut
    try:
        return ut.get_file_hash(fpath_, stride=stride)
    except IOError:
        return None


def analyize_multiple_drives(drives):
    """
    CommandLine:
        export PYTHONPATH=$PYTHONPATH:~/local/scripts

        set PYTHONPATH=%PYTHONPATH%;%HOME%/local/scripts
        python -m register_files --exec-analyize_multiple_drives --drives E:/ D:/

        python -m register_files --exec-analyize_multiple_drives --drives ~ /media/Store

        cd ~/local/scripts

    Example:
        >>> from register_files import *  # NOQA
        >>> dpaths = ut.get_argval('--drives', type_=list, default=['E:/'])#'D:/', 'E:/', 'F:/'])
        >>> drives = [Drive(root_dpath) for root_dpath in dpaths]
        >>> drive = Broadcaster(drives)
        >>> drive.compute_info()
        >>> drive.build_fpath_hashes()
        >>> drive.check_consistency()
        >>> E = drive = drives[0]
        >>> analyize_multiple_drives(drives)
        >>> #D, E, F = drives
        >>> #drive = D
    """
    for drive in drives:
        drive.num_fpaths = len(drive.fpath_registry)

    for drive in drives:
        drive.fpath_idxs = list(range(drive.num_fpaths))

    for drive in drives:
        drive.fpath_exts = [splitext(fpath)[1].lower() for fpath in drive.fpath_registry]

    #for drive in drives:
    #    print(ut.dict_str(ut.dict_hist(drive.fpath_exts), key_order_metric='val'))

    #for drive in drives:
    #    drive.nbytes_to_idxs = ut.hierarchical_group_items(drive.fpath_idxs, [drive.fpath_exts, drive.fpath_bytes_list])

    for drive in drives:
        drive.hash_to_fidxs = build_multindex(drive.fpath_hashX_list)
        drive.hash_to_fpaths = dict(
            [(hash_, ut.take(drive.fpath_registry, idxs))
             for hash_, idxs in drive.hash_to_fidxs.items()])

    # Find the files shared on all disks
    allhave = reduce(
        functools.partial(ut.dict_intersection, combine=True),
        [drive.hash_to_fpaths for drive in drives])
    print('allhave = %r' % (len(allhave),))
    #allhave = reduce(set.intersection, [set(drive.hash_to_fpaths.keys()) for drive in drives])

    for drive in drives:
        drive.hash_to_fidxs = ut.delete_keys(
            drive.hash_to_fidxs.copy(), allhave.keys())
        drive.hash_to_unique_fpaths = ut.delete_keys(
            drive.hash_to_fpaths.copy(), allhave.keys())

    for drive in drives:
        #drive.rrr()
        print(drive.root_dpath)
        print(len(drive.hash_to_unique_fpaths))
        print(len(drive.hash_to_fpaths))
        print(len(drive.hash_to_unique_fpaths) / len(drive.hash_to_fpaths))
        print()

        # Use subset while developing
        #unique_fpaths_list = drive.hash_to_unique_fpaths.values()
        unique_fidxs_list = drive.hash_to_fidxs.values()

        fidxs = ut.flatten(unique_fidxs_list)
        fpaths = sorted(ut.take(drive.fpath_registry, fidxs))
        #fpaths = sorted([items[0] for items in unique_fpaths_list if len(items) == 1])

        dpath_to_unique_fidx = dict([(key, ut.list_intersection(fidx, fidxs)) for key, fidx in drive.dpath_to_fidx.items()])

        #def make_tree_structure(root):
        root = {}

        def dict_getitem_default(dict_, key, type_):
            try:
                val = dict_[key]
            except KeyError:
                val = type_()
                dict_[key] = val
            return val

        for fpath in fpaths:
            path_components = ut.dirsplit(fpath)
            current = root
            for comp in path_components[:-1]:
                current = dict_getitem_default(current, comp, dict)
            contents = dict_getitem_default(current, '.', list)
            contents.append(path_components[-1])
        #print(ut.dict_str(root, indent_='-'))

        root['E:'].keys()

        print(ut.byte_str2(sum(ut.take(drive.fpath_bytes_list, dpath_to_unique_fidx['E:\\']))))

        def print_tree(root, path, dpath_to_unique_fidx=dpath_to_unique_fidx, drive=drive):
            print('path = %r' % (path,))
            print(ut.byte_str2(sum(ut.take(drive.fpath_bytes_list, dpath_to_unique_fidx[path + os.sep]))))
            import utool as ut
            path_components = ut.dirsplit(path)
            current = root
            for c in path_components:
                current = current[c]
            print(ut.repr3(current))

        def print_keys(root, path, dpath_to_unique_fidx=dpath_to_unique_fidx, drive=drive):
            import os
            import utool as ut
            print('path = %r' % (path,))
            print(ut.byte_str2(sum(ut.take(drive.fpath_bytes_list, dpath_to_unique_fidx[path + os.sep]))))
            path_components = ut.dirsplit(path)
            current = root
            for c in path_components:
                current = current[c]
            print(ut.repr3(current.keys()))
            # hacky. build more rubust str reprs of paths
            print(ut.repr3([(key,
                             ut.byte_str2(sum(ut.take(drive.fpath_bytes_list,
                                                      dpath_to_unique_fidx.get((path + os.sep + key), []))))) for key in current.keys()], nl=1))

        print_keys(root, path=r'E:')
        print_tree(root, path=r'E:\TV')
        print_tree(root, path=r'E:\Movies')
        print_tree(root, path=r'E:\Boot')

        print_tree(root, path=r'E:\.')
        print_tree(root, path=r'E:\Downloaded')
        print_tree(root, path=r'E:\Recordings')
        print_tree(root, path=r'E:\Clutter')
        print_tree(root, path=r'E:')
        print_tree(root, path=r'E:\Audio Books')

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

    def __init__(drive, root_dpath=None, state_fpath=None):
        drive.root_dpath = ut.truepath(ut.ensure_unicode(root_dpath))
        print('Initializing drive %s' % (drive.root_dpath,))
        ut.assert_exists(drive.root_dpath)
        # Mapping from dpath strings to fpath indexes
        assert state_fpath is None, 'not yet supported for external analysis'
        drive.cache_fname = join(drive.root_dpath, 'ut_pathreg_cache.shelf')
        drive.fpath_bytes_list = None
        drive.dpath_to_fidx = None
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

    @property
    def total_bytes(drive):
        if drive.fpath_bytes_list is None:
            return None
        return np.nansum(drive.fpath_bytes_list)

    def biggest_files(drive):
        print('Biggest Files in %r' % (drive,))
        sortx = ut.list_argsort(drive.fpath_bytes_list)[::-1]
        sel = sortx[0:10]
        biggest_nbytes = ut.take(drive.fpath_bytes_list, sel)
        biggest_files = ut.take(drive.fpath_registry, sel)
        biginfo_list = list(zip(map(ut.byte_str2, biggest_nbytes), biggest_files))
        print(ut.list_str(biginfo_list, strvals=True))

    def biggest_dirs(drive):
        print('Biggest Dirs in %r' % (drive,))
        dpath_list = drive.dpath_registry
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
        unflat_fpaths = ut.list_unflat_take(drive.fpath_registry, duplicate_idxs)
        # Check if any dups have been removed
        still_exists = ut.unflat_map(exists, unflat_fpaths)
        unflat_idxs2 = ut.zipcompress(duplicate_idxs, still_exists)
        duplicate_idxs = [idxs for idxs in unflat_idxs2 if len(idxs) > 1]
        # Look at duplicate files
        unflat_fpaths = ut.list_unflat_take(drive.fpath_registry, duplicate_idxs)
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
        fidxs_list = ut.dict_take(drive.dpath_to_fidx, drive.dpath_registry)
        #exists_list = list(map(exists, drive.fpath_registry))
        #unflat_exists = ut.list_unflat_take(exists_list, fidxs_list)
        fname_registry = [basename(fpath) for fpath in drive.fpath_registry]
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
        fidxs_list = ut.dict_take(drive.dpath_to_fidx, drive.dpath_registry)
        isempty_flags = [len(fidxs) == 0 for fidxs in fidxs_list]
        empty_dpaths = ut.compress(drive.dpath_registry, isempty_flags)

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

        print('Found %r / %r empty_dpaths' % (len(empty_dpaths), len(drive.dpath_registry)))
        print(ut.list_str(empty_dpaths[0:10]))

        # Ensure actually still empty
        current_contents = [ut.glob(d, with_dirs=False)
                            for d in prog_(empty_dpaths, 'checking empty status')]
        current_lens = list(map(len, current_contents))
        assert not any(current_lens), 'some dirs are not empty'

        # n ** 2 check to get only the base directories
        isbase_dir = [
            not any([d.startswith(dpath_) and d != dpath_
                        for dpath_ in empty_dpaths])
            for d in prog_(empty_dpaths, 'finding base dirs')
        ]
        base_empty_dirs = ut.compress(empty_dpaths, isbase_dir)
        def list_only_files(dpath):
            # glob is too slow
            for root, dirs, fpaths in os.walk(dpath):
                for fpath in fpaths:
                    yield fpath
        base_current_contents = [
            list(list_only_files(d))
            for d in prog_(base_empty_dirs, 'checking emptyness', freq=10)]
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
            #for d in prog_(truly_empty_dirs):
            #    break
            #    if ut.WIN32:
            #        # http://www.sevenforums.com/system-security/53095-file-folder-read-only-attribute-wont-disable.html
            #        ut.cmd('attrib', '-r', '-s', normpath(d), verbose=False)
            #x = ut.remove_fpaths(truly_empty_dirs, strict=False)

            print('Deleting %d truly_empty_dirs1' % (len(truly_empty_dirs1),))

            for d in prog_(truly_empty_dirs1, 'DELETE empty dirs'):  # NOQA
                ut.delete(d, quiet=True)

            if ut.WIN32 and False:
                # remove file that failed removing
                flags = list(map(exists, truly_empty_dirs1))
                truly_empty_dirs1 = ut.compress(truly_empty_dirs1, flags)
                for d in prog_(truly_empty_dirs1, 'rming'):
                    ut.cmd('rmdir', d)

    def compute_info(drive):
        print('Computing Info of %r' % (drive,))
        drive.register_files()
        drive.get_fpath_bytes_list()
        drive.build_dpath_to_fidx()
        #drive.build_fpath_hashes()

    def register_files(drive):
        print('Loading registered files in %r' % (drive,))
        try:
            fpath_registry = drive.cache.load('fpath_registry')
            dpath_registry = drive.cache.load('dpath_registry')
        except ut.CacheMissException:
            print('Recomputing registry')
            fpath_gen_list = []
            dpath_gen_list = []
            for root, dname_list, fname_list in prog_(os.walk(drive.root_dpath), 'walking'):
                # Ignore hidden directories
                dname_list[:] = [d for d in dname_list if not d.startswith('.')]
                fpath_gen_list.append((root, fname_list))
                dpath_gen_list.append((root, dname_list))
            fpath_registry = [join(root, f) for root, fs in fpath_gen_list for f in fs]
            dpath_registry =  [join(root, d) for root, ds in dpath_gen_list for d in ds]
            dpath_registry = [drive.root_dpath] + dpath_registry
            print('Regsitering %d files and %d directories' % (len(fpath_registry), len(dpath_registry)))
            drive.cache.save('fpath_registry', fpath_registry)
            drive.cache.save('dpath_registry', dpath_registry)
        print('Loaded %d files and %d directories' % (len(fpath_registry), len(dpath_registry)))
        drive.fpath_registry = fpath_registry
        drive.dpath_registry = dpath_registry

    def update_registry(drive):
        print('Updating registered files in %r' % (drive,))
        # Update existing files
        fpath_exists_list = list(map(exists, prog_(drive.fpath_registry, 'checkexist fpath')))
        dpath_exists_list = list(map(exists, prog_(drive.dpath_registry, 'checkexist dpath')))
        if all(fpath_exists_list):
            print('No change in file structure')
        else:
            print('%d/%d files no longer exist' % (
                len(drive.fpath_registry) - sum(fpath_exists_list),
                len(drive.fpath_registry)))
            removed_fpaths = ut.compress(drive.fpath_registry, ut.not_list(fpath_exists_list))
            print('removed_fpaths = %s' % (ut.list_str(removed_fpaths),))
        if all(dpath_exists_list):
            print('No change in dpath structure')
        else:
            print('%d/%d dirs no longer exist' % (
                len(drive.dpath_registry) - sum(dpath_exists_list),
                len(drive.dpath_registry)))
            removed_dpaths = ut.compress(
                drive.dpath_registry,
                ut.not_list(dpath_exists_list))
            print('removed_dpaths = %s' % (ut.list_str(removed_dpaths),))

        drive.fpath_registry = ut.compress(drive.fpath_registry, fpath_exists_list)
        drive.dpath_registry = ut.compress(drive.dpath_registry, dpath_exists_list)
        drive.cache.save('fpath_registry', drive.fpath_registry)
        drive.cache.save('dpath_registry', drive.dpath_registry)

    def get_fpath_bytes_list(drive):
        print('Building fpath bytes for %r' % (drive,))
        try:
            fpath_bytes_list = drive.cache.load('fpath_bytes_list')
            assert len(fpath_bytes_list) == len(drive.fpath_registry)
            #print(len(fpath_bytes_list))
        except ut.CacheMissException:
            def tryread_nbytes(fpath):
                try:
                    return ut.file_bytes(fpath)
                except SystemErrors:
                    return np.nan

            fpath_bytes_list = [
                tryread_nbytes(fpath)
                for fpath in prog_(drive.fpath_registry, 'reading size')
            ]
            assert len(drive.fpath_registry) == len(drive.fpath_registry)
            drive.cache.save('fpath_bytes_list', fpath_bytes_list)
        drive.fpath_bytes_list = fpath_bytes_list

        drive.fpath_bytes_arr = np.array(fpath_bytes_list)
        fpath_bytes_arr = drive.fpath_bytes_arr
        print('Loaded filesize for %d / %d files' % ((~np.isnan(fpath_bytes_arr)).sum(), len(fpath_bytes_arr)))

    def check_filesize_errors(drive):
        flags = np.isnan(drive.fpath_bytes_arr)
        nan_fpaths = ut.compress(drive.fpath_registry, flags)
        print('#nan fsize fpaths = %r' % (len(nan_fpaths),))
        print('nan_fpaths = %r' % (nan_fpaths[0:10],))

    def build_dpath_to_fidx(drive):
        """
        Build mapping from each dpath to contained file indexes
        """
        # Create mapping from directory to subfiles
        try:
            dpath_to_fidx = drive.cache.load('dpath_to_fidx')
            assert len(dpath_to_fidx) <= len(drive.dpath_registry)
        except ut.CacheMissException:
            dpath_to_fidx = ut.ddict(list)
            _iter = prog_(enumerate(drive.fpath_registry), 'making dpath fidx map', freq=10000,
                          nTotal=len(drive.fpath_registry))
            for fidx, fpath in _iter:
                current_path = fpath
                #last_dpath = None
                while True:
                    #current_path != last_dpath:
                    #last_dpath = current_path
                    current_path = dirname(current_path)
                    dpath_to_fidx[current_path].append(fidx)
                    if current_path == drive.root_dpath:
                        break
            drive.cache.save('dpath_to_fidx', dpath_to_fidx)
        drive.dpath_to_fidx = dpath_to_fidx

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
            fpath_hashX_list = [None] * len(drive.fpath_registry)

            assert len(drive.fpath_bytes_list) == len(drive.fpath_registry)

            tier_windows = drive.get_tier_windows()
            tier_flags = drive.get_tier_flags()
            tier_fpaths = [ut.compress(drive.fpath_registry, flags) for flags in tier_flags]

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
                    prog_(fpaths, 'tier=%r hashes' % (tier,), freq=100)
                ]
                #import register_files
                #tier_hashes = list(ut.buffered_generator((
                #    register_files.tryhash(fpath, stride) for fpath in
                #    prog_(fpaths, 'tier=%r hashes' % (tier,), freq=100)
                #)))
                tier_idxs = np.where(tier_flags[tier])[0]

                for idx, hash_ in zip(tier_idxs, tier_hashes):
                    fpath_hashX_list[idx] = hash_

            drive.cache.save('fpath_hashX_list', fpath_hashX_list)
        drive.fpath_hashX_list = fpath_hashX_list


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
