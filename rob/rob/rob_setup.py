def dev_backup_settings(r):
    'Shouldnt run this very often and only on BakerStreet'
    if 0:
        import distutils.dir_util
        for (LOCAL_DIR, CLOUD_DIR) in r.symlink_local_cloud:
            print " * Backing Up "+LOCAL_DIR+" to "+CLOUD_DIR
            distutils.dir_util.copy_tree(LOCAL_DIR, CLOUD_DIR, preserve_mode=0)

def setup_vim(r):
    #make_dpath(r, r.d.VIMFILES)
    # MKLINK /D "%VIMFILES%" "%PORT_SETTINGS%\vim\vimfiles"
    #create_link(r, source=r.d.PORT_SETTINGS+'/vim/vimfiles', target=r.d.VIMFILES)

def pref_windows(r):
    setup_vim(r)
    robos.pref_registry(r)
    robos.no_login_dialog()
    call('attrib +h *.pyc /s')

def pref_settings(r, dry_run = False):
    import distutils.dir_util
    print " *  Setting up Settings"

    for (LOCAL_DIR, CLOUD_DIR) in r.symlink_local_cloud:
        print "    *  Symlinking "+LOCAL_DIR+" to "+CLOUD_DIR
        if dry_run:
            LOCAL_DIR = None
        create_link(r, CLOUD_DIR, LOCAL_DIR)

    for (LOCAL_DIR, CLOUD_DIR) in r.directcopy_local_cloud:
        print "    *  Hard Copying Folders: "+CLOUD_DIR+" to "+LOCAL_DIR
        if dry_run:
            LOCAL_DIR = '.'
        distutils.dir_util.copy_tree(CLOUD_DIR, LOCAL_DIR, preserve_mode=1)


def setup(r):
    #pref_registry(r)
    #pref_env(r)
    #pref_shortcuts(r)
    #pref_no_login(r)
    #pref_shortcuts(r)
    #fix_path(r)
#from rob_interface import *
from os.path import split, relpath, join, isdir, isfile
import os
import fnmatch
import re
from rob_interface import robos


def find_in_list(str_, tofind_list, agg_fn=all, case_insensitive=True):
    if len(tofind_list) == 0:
        return True
    if case_insensitive:
        str_ = str_.lower()
        tofind_list = [tofind.lower() for tofind in tofind_list]
    found_list = [str_.find(tofind) > -1 for tofind in tofind_list]
    return agg_fn(found_list)

# TODO: this grep stuff can be written nicer


def __grepfile(fpath, tofind_list, case_insensitive=True):
    with open(fpath, 'r') as file:
        lines = file.readlines()
        found = []
        # Search each line for the desired strings
        for lx, line in enumerate(lines):
            if find_in_list(line, tofind_list, any, case_insensitive):
                found.append((lx, line))
        # Print the results (if any)
        if len(found) > 0:
            print('----------------------')
            ret = 'Found %d line(s) in %r: ' % (len(found), fpath)
            print(ret)
            name = split(fpath)[1]
            max_line = len(lines)
            ndigits = str(len(str(max_line)))
            fmt_str = '%s : %' + ndigits + 'd |%s'
            for (lx, line) in iter(found):
                line = line.replace('\n', '')
                print(fmt_str % (name, lx, line))
            return ret
    return None


def __regex_grepfile(fpath, regexpr):
    with open(fpath, 'r') as file:
        lines = file.readlines()
        found = []
        # Search each line for the desired regexpr
        for lx, line in enumerate(lines):
            match_object = re.search(regexpr, line)
            if not match_object is None:
                found.append((lx, line))
        # Print the results (if any)
        if len(found) > 0:
            print('----------------------')
            rel_fpath = relpath(fpath, os.getcwd())
            ret = 'Found %d line(s) in %r: ' % (len(found), rel_fpath)
            print(ret)
            name = split(fpath)[1]
            max_line = len(lines)
            ndigits = str(len(str(max_line)))
            fmt_str = '%s : %' + ndigits + 'd |%s'
            for (lx, line) in iter(found):
                line = line.replace('\n', '')
                print(fmt_str % (name, lx, line))
            return ret
    return None


def _grep(r, tofind_list, recursive=True, case_insensitive=True, regex=False):
    include_patterns = ['*.py', '*.cxx', '*.cpp', '*.hxx', '*.hpp', '*.c',
                        '*.h', '*.txt']
    # TODO:
    exclude_dirs = ['_graveyard
    # ensure list input
    if isinstance(include_patterns, str):
        include_patterns = [include_patterns]
    dpath = os.getcwd()
    print('Greping %r for %r' % (dpath, tofind_list))
    found_files = []
    # Walk through each directory recursively
    for root, dname_list, fname_list in os.walk(dpath):
        for name in fname_list:
            # For the filesnames which match the patterns
            if any([fnmatch.fnmatch(name, pat) for pat in include_patterns]):
                # Inspect the file
                fpath = join(root, name)
                if regex:
                    regexpr = tofind_list[0]
                    ret = __regex_grepfile(fpath, regexpr)
                else:
                    ret = __grepfile(fpath, tofind_list, case_insensitive)
                if not ret is None:
                    found_files.append(ret)
        if not recursive:
            break
    print('====================')
    print('====================')
    print('\n'.join(found_files))
    return found_files


def fnmatch_any(path, exclude_list):
    return any([fnmatch.fnmatch(path, exclude)
                for exclude in exclude_list])


def ls(r):
    exclude_list = ['*.pyc', '.*']
    cwd = os.getcwd()
    to_list_files = []
    to_list_dirs  = []
    for path in os.listdir(cwd):
        if not fnmatch_any(path, exclude_list):
            if isdir(path):
                to_list_dirs += [path]
            if isfile(path):
                to_list_files += [path]

    sort_fn = lambda x: x.lower()
    to_list_dirs.sort(key=sort_fn)
    to_list_files.sort(key=sort_fn)

    to_list = to_list_dirs + ['-------'] + to_list_files
    for path in iter(to_list):
        print(path)


def _matching_fnames(dpath, include_patterns, recursive=True):
    #fname_list = []
    for root, dname_list, fname_list in os.walk(dpath):
        for name in fname_list:
            # For the filesnames which match the patterns
            if any([fnmatch.fnmatch(name, pat) for pat in include_patterns]):
                yield join(root, name)
                #fname_list.append((root, name))
        if not recursive:
            break
    #return fname_list


def __regex_sedfile(fpath, regexpr, repl, force=False):
    path, name = split(fpath)
    new_file_lines = []
    with open(fpath, 'r') as file:
        file_lines = file.readlines()
        # Search each line for the desired regexpr
        new_file_lines = [re.sub(regexpr, repl, line) for line in file_lines]

    changed_lines = [(newline, line)
                     for newline, line in zip(new_file_lines, file_lines)
                     if  newline != line]
    nChanged = len(changed_lines)
    if nChanged > 0:
        rel_fpath = relpath(fpath, os.getcwd())
        print(' * %s changed %d lines in %r ' %
              (['(dry-run)', '(real-run)'][force], nChanged, rel_fpath))
        print(' * --------------------')
        new_file = ''.join(new_file_lines)
        prefixold = ' * old (%d, %r):  \n | ' % (nChanged, name)
        prefixnew = ' * new (%d, %r):  \n | ' % (nChanged, name)
        #print(new_file.replace('\n','\n))
        changed_new, changed_old = zip(*changed_lines)
        print(prefixold + (' | '.join(changed_old)).strip('\n'))
        print(' * ____________________')
        print(prefixnew + (' | '.join(changed_new)).strip('\n'))
        print(' * --------------------')
        print(' * =====================================================')
        if force:
            print(' ! WRITING CHANGES')
            with open(fpath, 'w') as file:
                file.write(new_file)
        return changed_lines
    return None


def win32_default(r, assisted=False):
    #robos.default_envvars(r)
    #robos.default_path(r)
    robos.default_registry(r)
    print('Finished defaulting regisitry')
    os.system('%PORT_SETTINGS%/install_ipython.bat')
    if assisted:
        robos.default_assisted(r)
    else:
        print("win32_default: Run this command with True as an argument to get assisted options")
