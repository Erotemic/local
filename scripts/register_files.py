# -*- coding: utf-8 -*-
"""
Script to register files on a drive and reconcile duplicates
"""
from __future__ import absolute_import, division, print_function, unicode_literals
import utool as ut


def register_drive(root_drive):
    r"""

    CommandLine:
        set PYTHONPATH=%PYTHONPATH%;C:/Users/joncrall/local/scripts
        python -m register_files --exec-register_drive

    Ignore:
        >>> # ENABLE_DOCTEST
        >>> import sys
        >>> from os.path import *
        >>> from register_files import *  # NOQA
        >>> sys.path.append(normpath(expanduser('~/local/scripts')))

    Example:
        >>> from register_files import *  # NOQA
        >>> result = register_drive('D:/')
        >>> result = register_drive('E:/')
        >>> result = register_drive('F:/')
    """
    import os
    from os.path import join, exists, dirname

    # BUILD INFO ABOUT A SPECIFIC DIRECTORY

    #dpath = ut.truepath('~/local')
    #ROOT_DPATH = ut.truepath('F:/')
    #ROOT_DPATH = ut.truepath('D:/')
    #ROOT_DPATH = ut.truepath('E:/')
    #ROOT_DPATH = ut.truepath('~')
    ROOT_DPATH = ut.truepath(root_drive)
    print('Registering %s' % (ROOT_DPATH,))
    #cfgstr = ut.hashstr27(ROOT_DPATH)

    cache_fname = join(ROOT_DPATH, 'ut_pathreg_cache.shelf')
    cache = ut.ShelfCacher(cache_fname)
    def prog_(iter_, lbl, freq=1000, **kwargs):
        return ut.ProgressIter(iter_, freq=freq, lbl=lbl, **kwargs)

    try:
        fpath_registry = cache.load('fpath_registry')
        dpath_registry = cache.load('dpath_registry')
    except ut.CacheMissException:
        fpath_gen_list = []
        dpath_gen_list = []
        for root, dname_list, fname_list in prog_(os.walk(ROOT_DPATH), 'walking'):
            # Ignore hidden directories
            dname_list[:] = [d for d in dname_list if not d.startswith('.')]
            fpath_gen_list.append((root, fname_list))
            dpath_gen_list.append((root, dname_list))
        fpath_registry = [join(root, f) for root, fs in fpath_gen_list for f in fs]
        dpath_registry =  [join(root, d) for root, ds in dpath_gen_list for d in ds]
        dpath_registry = [ROOT_DPATH] + dpath_registry
        print('Regsitering %d files and %d directories' % (len(fpath_registry), len(dpath_registry)))
        cache.save('fpath_registry', fpath_registry)
        cache.save('dpath_registry', dpath_registry)
    print('Loaded %d files and %d directories' % (len(fpath_registry), len(dpath_registry)))

    if False:
        # Update existing files
        fpath_exists_list = list(map(exists, prog_(fpath_registry, 'checkexist fpath')))
        dpath_exists_list = list(map(exists, prog_(dpath_registry, 'checkexist dpath')))
        if all(fpath_exists_list):
            print('No change in file structure')
        else:
            print('%d/%d files no longer exist' % (len(fpath_registry) - sum(fpath_exists_list), len(fpath_registry)))
            removed_fpaths = ut.compress(fpath_registry, ut.not_list(fpath_exists_list))
            print('removed_fpaths = %s' % (ut.list_str(removed_fpaths),))
        if all(dpath_exists_list):
            print('No change in dpath structure')
        else:
            print('%d/%d dirs no longer exist' % (len(dpath_registry) - sum(dpath_exists_list), len(dpath_registry)))
            removed_dpaths = ut.compress(dpath_registry, ut.not_list(dpath_exists_list))
            print('removed_dpaths = %s' % (ut.list_str(removed_dpaths),))

        fpath_registry = ut.compress(fpath_registry, fpath_exists_list)
        dpath_registry = ut.compress(dpath_registry, dpath_exists_list)
        cache.save('fpath_registry', fpath_registry)
        cache.save('dpath_registry', dpath_registry)

    import numpy as np
    try:
        fpath_bytes_list = cache.load('fpath_bytes_list')
        assert len(fpath_bytes_list) == len(fpath_registry)
        #print(len(fpath_bytes_list))
    except ut.CacheMissException:
        def tryread_nbytes(fpath):
            try:
                return ut.file_bytes(fpath)
            except WindowsError:
                return np.nan

        fpath_bytes_list = [
            tryread_nbytes(fpath)
            for fpath in prog_(fpath_registry, 'reading size')
        ]
        assert len(fpath_registry) == len(fpath_registry)
        cache.save('fpath_bytes_list', fpath_bytes_list)

    fpath_bytes_arr = np.array(fpath_bytes_list)
    print('Loaded filesize for %d / %d files' % ((~np.isnan(fpath_bytes_arr)).sum(), len(fpath_bytes_arr)))

    from six.moves import zip
    try:
        #fpath_hashX_list = cache.load('fpath_hashX_list')
        pass
    except ut.CacheMissException:
        def bytes_based_hash(fpath, nbytes):
            try:
                if nbytes > 2 ** 30:
                    return None
                elif nbytes > (2 ** 20):
                    return ut.get_file_hash(fpath, stride=256)
                else:
                    return ut.get_file_hash(fpath, stride=1)
            except IOError:
                return None

        fpath_hashX_list = [None] * len(fpath_registry)

        import numpy as np  # NOQA
        import vtool as vt  # NOQA
        assert len(fpath_bytes_list) == len(fpath_registry)

        nbytes_tiers = [
            np.inf, 2 ** 32, 2 ** 30,
            2 ** 29, 2 ** 28, 2 ** 25,
            2 ** 20, 2 ** 10, 0, -np.inf,
        ]
        tier_windows = list(ut.itertwo(nbytes_tiers))

        print('Tier Windows')
        for tier, (high, low) in enumerate(tier_windows):
            print('tier = %r' % (tier,))
            print('tier_windows = %s - %s' % (ut.byte_str2(high), ut.byte_str2(low)))

        tier_flags = [
            np.logical_and.reduce([fpath_bytes_arr <= high, fpath_bytes_arr > low])
            for high, low in tier_windows
        ]
        tier_fpaths = [ut.compress(fpath_registry, flags) for flags in tier_flags]

        for tier, fpaths in enumerate(tier_fpaths):
            print('tier = %r' % (tier,))
            high, low = tier_windows[tier]
            print('tier_windows = %s - %s' % (ut.byte_str2(high), ut.byte_str2(low)))
            print('len(fpaths) = %r' % (len(fpaths),))

        def tryhash(fpath_, stride=1):
            try:
                return ut.get_file_hash(fpath_, stride=stride)
            except IOError:
                return None

        #for tier, fpaths in enumerate(tier_fpaths):
        for tier in [3, 4, 5]:
            tier = 4
            window = np.array(tier_windows[tier])
            minbytes = window[np.isfinite(window)].min()
            stride = max(1, minbytes // (2 ** 20))
            fpaths = tier_fpaths[tier]

            tier_hashes = [
                tryhash(fpath, stride) for fpath in
                prog_(fpaths, 'tier=%r hashes' % (tier,), freq=100)
            ]
            tier_idxs = np.where(tier_flags[tier])[0]

            for idx, hash_ in zip(tier_idxs, tier_hashes):
                fpath_hashX_list[idx] = hash_

        cache.save('fpath_hashX_list', fpath_hashX_list)

    # Create mapping from directory to subfiles
    try:
        dpath_to_fidx = cache.load('dpath_to_fidx')
        assert len(dpath_to_fidx) <= len(dpath_registry)
    except ut.CacheMissException:
        dpath_to_fidx = ut.ddict(list)
        for fidx, fpath in prog_(enumerate(fpath_registry), 'making dpath fidx map', nTotal=len(fpath_registry)):
            current_path = fpath
            #last_dpath = None
            while True:
                #current_path != last_dpath:
                #last_dpath = current_path
                current_path = dirname(current_path)
                dpath_to_fidx[current_path].append(fidx)
                if current_path == ROOT_DPATH:
                    break
        cache.save('dpath_to_fidx', dpath_to_fidx)

    return

    # INFER INFORMATION ABOUT THINGS
    def biggest_files():
        sortx = ut.list_argsort(fpath_bytes_list)[::-1]
        sel = sortx[0:100]
        biggest_nbytes = ut.take(fpath_bytes_list, sel)
        biggest_files = ut.take(fpath_registry, sel)
        biginfo_list = list(zip(map(ut.byte_str2, biggest_nbytes), biggest_files))
        print(ut.list_str(biginfo_list, strvals=True))

    def biggest_dirs():
        dpath_list = dpath_registry
        #dpath_list = [ROOT_DPATH]
        fidxs_list = ut.dict_take(dpath_to_fidx, dpath_list)
        unflat_dpath_bytes_list = ut.list_unflat_take(fpath_bytes_list, fidxs_list)
        dpath_nbytes_list = list(map(sum, unflat_dpath_bytes_list))

        sortx = ut.list_argsort(dpath_nbytes_list)[::-1]
        sel = sortx[0:100]
        biggest_nbytes = ut.take(dpath_nbytes_list, sel)
        biggest_dpaths = ut.take(dpath_list, sel)
        biginfo_list = list(zip(map(ut.byte_str2, biggest_nbytes), biggest_dpaths))
        print(ut.list_str(biginfo_list, strvals=True))
        pass

    # --- FIND POTENTIALLY DUPLICATE FILES ---
    def fix_duplicate_files():
        from six.moves import zip, range  # NOQA
        import six  # NOQA
        def build_multindex(list_):
            multiindex_dict_ = ut.ddict(list)
            for item, index in zip(list_, range(len(list_))):
                if item is not None:
                    multiindex_dict_[item].append(index)
            return multiindex_dict_
        list_ = fpath_hashX_list
        multiindex_dict_ = build_multindex(list_)
        duplicate_hashes = [
            key for key, val in six.iteritems(multiindex_dict_)
            if len(val) > 1]
        duplicate_idxs = ut.dict_take(multiindex_dict_, duplicate_hashes)
        # Look at duplicate files
        unflat_fpaths = ut.list_unflat_take(fpath_registry, duplicate_idxs)
        unflat_sizes = ut.list_unflat_take(fpath_bytes_list, duplicate_idxs)
        print('Duplicate sizes: ' + ut.list_str(unflat_sizes[0:10], nl=True))
        print('Duplicate fpaths: ' + ut.list_str(unflat_fpaths[0:10], nl=True))

    # --- FIND EMPTY DIRECTORIES ---
    def find_empty_directories():
        fidxs_list = ut.dict_take(dpath_to_fidx, dpath_registry)
        isempty_flags = [len(fidxs) == 0 for fidxs in fidxs_list]
        empty_dpaths = ut.compress(dpath_registry, isempty_flags)

        def iswin32link(path_):
            try:
                os.listdir(d)
                return False
            except WindowsError:
                return True
        valid_flags = [not iswin32link(d) for d  in empty_dpaths]
        if not all(valid_flags):
            print('Filtered windows links %r / %r' % (len(empty_dpaths) - sum(valid_flags), len(empty_dpaths)))
            #print(ut.list_str(empty_dpaths[0:10]))
            empty_dpaths = ut.compress(empty_dpaths, valid_flags)

        print('Found %r / %r empty_dpaths' % (len(empty_dpaths), len(dpath_registry)))
        print(ut.list_str(empty_dpaths[0:10]))

        # Ensure actually still empty
        current_contents = [ut.glob(d, with_dirs=False) for d in prog_(empty_dpaths, 'checking empty status')]
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
        # FIX PART
        #from os.path import normpath
        #for d in prog_(truly_empty_dirs):
        #    break
        #    if ut.WIN32:
        #        # http://www.sevenforums.com/system-security/53095-file-folder-read-only-attribute-wont-disable.html
        #        ut.cmd('attrib', '-r', '-s', normpath(d), verbose=False)
        #x = ut.remove_fpaths(truly_empty_dirs, strict=False)

        exclude_dirs = [join(ROOT_DPATH, 'AppData')]
        truly_empty_dirs1 = truly_empty_dirs
        for ed in exclude_dirs:
            truly_empty_dirs1 = [d for d in truly_empty_dirs1 if not d.startswith(ed)]

        print('Deleting %d truly_empty_dirs1' % (len(truly_empty_dirs1),))
        print('truly_empty_dirs1 = %s' % (ut.list_str(truly_empty_dirs1[0::5], strvals=True),))

        for d in prog_(truly_empty_dirs1, 'DELETE empty dirs'):  # NOQA
            ut.delete(d, quiet=True)

        if False:
            # remove file that failed removing
            flags = list(map(exists, truly_empty_dirs1))
            truly_empty_dirs1 = ut.compress(truly_empty_dirs1, flags)
            for d in prog_(truly_empty_dirs1, 'rming'):
                ut.cmd('rmdir', d)

    # Ensure actually still empty (with recursive checks for hidden files)


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
