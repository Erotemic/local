#from rob_interface import *
from os.path import split, relpath, join, isdir, isfile
import os
import fnmatch
import re
from rob import rob_util as rutil
try:
    from six import string_types
except ImportError:
    string_types = (str,)

HS_EXCLUDE = ['_graveyard',
              '_broken',
              'CompilerIdCXX',
              'CompilerIdC',
              'build',
              'old',
              #'vim',
              #'src',
              ]
__DEBUG__ = True


def find_in_list(str_, tofind_list, agg_fn=all, case_insensitive=True):
    if len(tofind_list) == 0:
        return True
    if case_insensitive:
        str_ = str_.lower()
        tofind_list = [tofind.lower() for tofind in tofind_list]
    found_list = [str_.find(tofind) > -1 for tofind in tofind_list]
    return agg_fn(found_list)

# TODO: this grep stuff can be written nicer


def __grepfile(fpath, tofind_list, case_insensitive=True, verbose=False):
    with open(fpath, 'r') as file:
        try:
            lines = file.readlines()
        except UnicodeDecodeError:
            print("UNABLE TO READ fpath={}".format(fpath))
        else:
            found = []
            # Search each line for the desired strings
            for lx, line in enumerate(lines):
                if find_in_list(line, tofind_list, any, case_insensitive):
                    found.append((lx, line))
            # Print the results (if any)
            if len(found) > 0:
                ret = 'Found %d line(s) in %r: ' % (len(found), fpath)
                if verbose:
                    print('----------------------')
                    print(ret)
                name = split(fpath)[1]
                max_line = len(lines)
                ndigits = str(len(str(max_line)))
                fmt_str = '%s : %' + ndigits + 'd |%s'
                for (lx, line) in iter(found):
                    line = line.replace('\n', '')
                    if verbose:
                        print(fmt_str % (name, lx, line))
                return ret
    return None


def __regex_grepfile(fpath, regexpr, verbose=True):
    ret = None
    with open(fpath, 'r') as file:
        try:
            lines = file.readlines()
        except UnicodeDecodeError:
            print("UNABLE TO READ fpath={}".format(fpath))
        else:
            #found = []
            found_lines = []
            found_lxs = []
            # Search each line for the desired regexpr
            for lx, line in enumerate(lines):
                match_object = re.search(regexpr, line)
                if match_object is not None:
                    found_lines.append(line)
                    found_lxs.append(lx)
                    #found.append((lx, line))
            found = list(zip(found_lxs, found_lines))
            # Print the results (if any)
            if len(found) > 0:
                rel_fpath = relpath(fpath, os.getcwd())
                ret = 'Found %d line(s) in %r: ' % (len(found), rel_fpath)
                if verbose:
                    print('----------------------')
                    print(ret)
                name = split(fpath)[1]
                max_line = len(lines)
                ndigits = str(len(str(max_line)))
                fmt_str = '%s : %' + ndigits + 'd |%s'
                for (lx, line) in iter(found):
                    line = line.replace('\n', '')
                    if verbose:
                        print(fmt_str % (name, lx, line))
    return ret


def extend_regex(regexpr):
    regex_map = {
        r'\<': r'\b(?=\w)',
        r'\>': r'\b(?!\w)',
        ('UNSAFE', r'\x08'): r'\b',
    }
    for key, repl in regex_map.items():
        if isinstance(key, tuple):
            search = key[1]
        else:
            search = key
        if regexpr.find(search) != -1:
            if isinstance(key, tuple):
                print('WARNING! Unsafe regex with: %r' % (key,))
            regexpr = regexpr.replace(search, repl)
    return regexpr


def _ut_matching_fpaths(dpath_list, include_patterns, exclude_dirs=[],
                        greater_exclude_dirs=[], exclude_patterns=[],
                        recursive=True):
    r"""
    walks dpath lists returning all directories that match the requested
    pattern.

    Args:
        dpath_list       (list):
        include_patterns (str):
        exclude_dirs     (None):
        recursive        (bool):

    References:
        # TODO: fix names and behavior of exclude_dirs and greater_exclude_dirs
        http://stackoverflow.com/questions/19859840/excluding-directories-in-os-walk

    Example:
        >>> # DISABLE_DOCTEST
        >>> dpath_list = [dirname(dirname(__file__))]
        >>> include_patterns = get_standard_include_patterns()
        >>> exclude_dirs = ['_page']
        >>> greater_exclude_dirs = get_standard_exclude_dnames()
        >>> recursive = True
        >>> fpath_gen = matching_fpaths(dpath_list, include_patterns, exclude_dirs,
        >>>                             greater_exclude_dirs, recursive)
        >>> result = list(fpath_gen)
        >>> print('\n'.join(result))
    """
    if isinstance(dpath_list, string_types):
        dpath_list = [dpath_list]

    def pathsplit_full(path):
        """ splits all directories in path into a list """
        return path.replace('\\', '/').split('/')

    for dpath in dpath_list:
        for root, dname_list, fname_list in os.walk(dpath):
            # Look at all subdirs
            subdirs = pathsplit_full(relpath(root, dpath))
            # HACK:
            if any([dir_ in greater_exclude_dirs for dir_ in subdirs]):
                continue
            # Look at one subdir
            if os.path.basename(root) in exclude_dirs:
                continue
            _match = fnmatch.fnmatch
            for name in fname_list:
                # yeild filepaths that are included
                if any(_match(name, pat) for pat in include_patterns):
                    # ... and not excluded
                    if not any(_match(name, pat) for pat in exclude_patterns):
                        fpath = join(root, name)
                        yield fpath
            if not recursive:
                break


def _ut_get_standard_exclude_dnames():
    return ['dist', 'build', '_page', '_doc', '.git']


def _ut_sed(regexpr, repl, force=False, recursive=False, dpath_list=None,
            fpath_list=None, verbose=None, include_patterns=None,
            exclude_patterns=[]):
    """
    Python implementation of sed. NOT FINISHED

    searches and replaces text in files

    Args:
        regexpr (str): regx patterns to find
        repl (str): text to replace
        force (bool):
        recursive (bool):
        dpath_list (list): directories to search (defaults to cwd)
    """
    import ubelt as ub
    #_grep(r, [repl], dpath_list=dpath_list, recursive=recursive)
    if include_patterns is None:
        include_patterns = ['*.py', '*.pyx', '*.pxi', '*.cxx', '*.cpp', '*.hxx', '*.hpp', '*.c', '*.h', '*.html', '*.tex']
    if dpath_list is None:
        dpath_list = [os.getcwd()]
    if verbose is None:
        verbose = not ub.argflag('--quiet')
    if fpath_list is None:
        greater_exclude_dirs = _ut_get_standard_exclude_dnames()
        exclude_dirs = []
        fpath_generator = _ut_matching_fpaths(
            dpath_list, include_patterns, exclude_dirs,
            greater_exclude_dirs=greater_exclude_dirs,
            recursive=recursive, exclude_patterns=exclude_patterns)
    else:
        fpath_generator = fpath_list
    if verbose:
        print('sed-ing %r' % (dpath_list,))
        print(' * regular expression : %r' % (regexpr,))
        print(' * replacement        : %r' % (repl,))
        print(' * include_patterns   : %r' % (include_patterns,))
        print(' * recursive: %r' % (recursive,))
        print(' * force: %r' % (force,))
        print(' * fpath_list: %s' % (ub.repr2(fpath_list),))
    regexpr = extend_regex(regexpr)
    #if '\x08' in regexpr:
    #    print('Remember \\x08 != \\b')
    #    print('subsituting for you for you')
    #    regexpr = regexpr.replace('\x08', '\\b')
    #    print(' * regular expression : %r' % (regexpr,))

    # Walk through each directory recursively
    num_changed = 0
    num_files_checked = 0
    fpaths_changed = []
    for fpath in fpath_generator:
        num_files_checked += 1
        changed_lines = __regex_sedfile(fpath, regexpr, repl, force)
        if len(changed_lines) > 0:
            fpaths_changed.append(fpath)
            num_changed += len(changed_lines)
    print('num_files_checked = %r' % (num_files_checked,))
    print('fpaths_changed = %s' % (ub.repr2(sorted(fpaths_changed)),))
    print('total lines changed = %r' % (num_changed,))


def _sed(r, regexpr, repl, force=False, recursive=False, dpath_list=None):
    if isinstance(force, string_types):
        force = force.lower() == 'true'

    include_patterns = ['*.py', '*.cxx', '*.cpp', '*.hxx', '*.hpp', '*.c',
                        '*.h', '*.pyx', '*.pxi', '*.cmake',
                        '*.sh', '*.yml',
                        'CMakeLists.txt']
    _ut_sed(regexpr, repl, force=force, recursive=recursive,
            dpath_list=dpath_list, verbose=True,
            include_patterns=include_patterns)
    return


def _grep(r, tofind_list, recursive=True, case_insensitive=True, regex=False,
          dpath_list=None, invert=False):
    include_patterns = ['*.py', '*.cxx', '*.cpp', '*.hxx', '*.hpp', '*.c',
                        '*.h', '*.vim', '*.sh']  # , '*.txt']
    exclude_dirs = HS_EXCLUDE
    # ensure list input
    if isinstance(include_patterns, str):
        include_patterns = [include_patterns]
    if dpath_list is None:
        dpath_list = [os.getcwd()]
    recursive = rutil.cast(recursive, bool)
    recursive_stat_str = ['flat', 'recursive'][recursive]
    print('Greping (%s) %r for %r' % (recursive_stat_str, dpath_list, tofind_list))
    found_filestrs = []
    found_fpaths = []
    # Walk through each directory recursively
    for fpath in _matching_fnames(dpath_list, include_patterns, exclude_dirs,
                                  recursive=recursive):
        if regex:
            if len(tofind_list) > 1:
                print('WARNING IN ROB NAV 133')
            #import re
            regexpr = extend_regex(tofind_list[0])
            regexpr = tofind_list[0]
            #regexpr = re.escape(regexpr)
            ret = __regex_grepfile(fpath, regexpr, verbose=not invert)
        else:
            ret = __grepfile(fpath, tofind_list, case_insensitive,
                             verbose=not invert)
        if ret is None and invert:
            found_filestrs.append(fpath)  # regular matching
        elif ret is not None and not invert:
            found_filestrs.append(ret)  # inverse matching
        if ret is not None:
            found_fpaths.append(fpath)

    print('====================')
    print('====================')
    print('\n'.join(found_filestrs))

    print('')
    print('gvim -o ' + ' '.join(found_fpaths))
    return found_filestrs


def fnmatch_any(path, exclude_list):
    return any([fnmatch.fnmatch(path, exclude)
                for exclude in exclude_list])


def ls2(r):
    exclude_list = ['*.pyc', '.*']
    cwd = os.getcwd()
    to_list_files = []
    to_list_dirs  = []
    for root, path_list, dir_list in os.walk(cwd):
        for path in path_list:
            if root.find('.git') > 0 or root.find('.git') > 0:
                continue
            print(join(root, path))
            if not fnmatch_any(path, exclude_list):
                if isdir(path):
                    to_list_dirs += [path]
                if isfile(path):
                    to_list_files += [path]
    def sort_fn(x):
        return x.lower()
    to_list_dirs.sort(key=sort_fn)
    to_list_files.sort(key=sort_fn)

    to_list = to_list_dirs + ['-------'] + to_list_files
    for path in iter(to_list):
        print(path)


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

    def sort_fn(x):
        return x.lower()
    to_list_dirs.sort(key=sort_fn)
    to_list_files.sort(key=sort_fn)

    to_list = to_list_dirs + ['-------'] + to_list_files
    for path in iter(to_list):
        print(path)


def _matching_fnames(dpath_list, include_patterns, exclude_dirs=None, recursive=True):
    if isinstance(dpath_list, (str)):
        dpath_list = [dpath_list]
    recursive = rutil.cast(recursive, bool)
    if exclude_dirs is None:
        exclude_dirs = HS_EXCLUDE
    if __DEBUG__:
        print('Excluding: %r' % (exclude_dirs,))
        #exclude_dirs = HS_EXCLUDE
        #exclude_dirs = []
    #fname_list = []
    for dpath in dpath_list:
        for root, dname_list, fname_list in os.walk(dpath):
            # Look at all subdirs
            subdirs = relpath(root, dpath).replace('\\', '/').split('/')
            greater_exclude_dirs = [
                'lib.linux-x86_64-2.7',
                'lib.linux-x86_64-3.4',
                'lib',
                'bundle',
            ]
            if any([dir_ in greater_exclude_dirs for dir_ in subdirs]):
                continue
            # Look at one subdir
            if split(root)[1] in exclude_dirs:
                continue
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
        if True:
            import ubelt as ub
            old_file = ub.ensure_unicode(
                ''.join(list(map(ub.ensure_unicode, file_lines))))
            _ut_print_difftext(old_file, new_file)
        else:
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
    return []


def _ut_difftext(text1, text2, num_context_lines=0, ignore_whitespace=False):
    r"""
    Uses difflib to return a difference string between two similar texts

    Args:
        text1 (str):
        text2 (str):

    Returns:
        str: formatted difference text message

    References:
        http://www.java2s.com/Code/Python/Utility/IntelligentdiffbetweentextfilesTimPeters.htm

    Example:
        >>> # DISABLE_DOCTEST
        >>> # build test data
        >>> text1 = 'one\ntwo\nthree'
        >>> text2 = 'one\ntwo\nfive'
        >>> # execute function
        >>> result = _ut_difftext(text1, text2)
        >>> # verify results
        >>> print(result)
        - three
        + five

    Example2:
        >>> # DISABLE_DOCTEST
        >>> # build test data
        >>> text1 = 'one\ntwo\nthree\n3.1\n3.14\n3.1415\npi\n3.4\n3.5\n4'
        >>> text2 = 'one\ntwo\nfive\n3.1\n3.14\n3.1415\npi\n3.4\n4'
        >>> # execute function
        >>> num_context_lines = 1
        >>> result = _ut_difftext(text1, text2, num_context_lines)
        >>> # verify results
        >>> print(result)
    """
    import difflib
    import ubelt as ub
    text1 = ub.ensure_unicode(text1)
    text2 = ub.ensure_unicode(text2)
    text1_lines = text1.splitlines()
    text2_lines = text2.splitlines()
    if ignore_whitespace:
        text1_lines = [t.rstrip() for t in text1_lines]
        text2_lines = [t.rstrip() for t in text2_lines]
        ndiff_kw = dict(linejunk=difflib.IS_LINE_JUNK,
                        charjunk=difflib.IS_CHARACTER_JUNK)
    else:
        ndiff_kw = {}
    all_diff_lines = list(difflib.ndiff(text1_lines, text2_lines, **ndiff_kw))

    if num_context_lines is None:
        diff_lines = all_diff_lines
    else:
        # boolean for every line if it is marked or not
        ismarked_list = [len(line) > 0 and line[0] in '+-?'
                         for line in all_diff_lines]
        # flag lines that are within num_context_lines away from a diff line
        isvalid_list = ismarked_list[:]
        for i in range(1, num_context_lines + 1):
            def or_lists(*args):
                return [any(tup) for tup in zip(*args)]
            isvalid_list[:-i] = or_lists(isvalid_list[:-i], ismarked_list[i:])
            isvalid_list[i:]  = or_lists(isvalid_list[i:], ismarked_list[:-i])
        USE_BREAK_LINE = True
        if USE_BREAK_LINE:
            # insert a visual break when there is a break in context
            diff_lines = []
            prev = False
            visual_break = '\n <... FILTERED CONTEXT ...> \n'
            #print(isvalid_list)
            for line, valid in zip(all_diff_lines, isvalid_list):
                if valid:
                    diff_lines.append(line)
                elif prev:
                    if False:
                        diff_lines.append(visual_break)
                prev = valid
        else:
            diff_lines = list(ub.compress(all_diff_lines, isvalid_list))
    return '\n'.join(diff_lines)


def _ut_print_difftext(text, other=None):
    """
    Args:
        text (str):
    """
    if other is not None:
        # hack
        text = _ut_difftext(text, other)
    import ubelt as ub
    colortext = ub.highlight_code(text, lexer_name='diff')
    try:
        print(colortext)
    except UnicodeEncodeError as ex:  # NOQA
        import unicodedata
        colortext = unicodedata.normalize('NFKD', colortext).encode('ascii', 'ignore')
        print(colortext)
