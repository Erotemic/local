#!/usr/bin/env python
# -*- coding: utf-8 -*-
from __future__ import unicode_literals, print_function
import os
import parse
import itertools as it
import ubelt as ub
from os.path import exists, basename, join, abspath


def search_candidate_paths(candidate_path_list, candidate_name_list=None):
    """
    searches for existing paths that meed a requirement

    Args:
        candidate_path_list (list): list of paths to check. If
            candidate_name_list is specified this is the dpath list instead
        candidate_name_list (list): specifies several names to check
            (default = None)

    Returns:
        str: return_path
    """
    for dpath, fname in it.product(candidate_path_list, candidate_name_list):
        path = join(dpath, fname)
        if exists(path):
            yield path


def ldd(lib_fpath):
    patterns = [
        '\t{link:S}{:s}=>{:s}{abspath:S}{:s}({addr:S})',
        '\t{abspath:S}{:s}=>{:s}({addr:S})',
        '\t{abspath:S}{:s}=>{:s}not found',
        '\t{abspath:S}{:s}({addr:S})',
    ]
    lines = ub.cmd('ldd ' + lib_fpath)['out'].splitlines()

    for line in lines:
        if 'statically linked' in line:
            continue
        for pattern in patterns:
            result = parse.parse(pattern, line)
            if result is not None:
                break
        if result is None:
            raise ValueError(repr(line))
        child_lib_fpath = result.named['abspath']
        yield child_lib_fpath


def ldd_tree(lib_fpaths, print_tree=False):
    ldd_seen = {}

    def _ldd_tree(fpath, depth=0):
        prefix = '│    ' * (depth) + '├──'
        if fpath in ldd_seen:
            # if 'python' in fpath or 'py' in basename(fpath):
            #     print(ub.color_text(prefix + fpath + ' [SEEN]', 'red'))
            # else:
            #     print(prefix + fpath + ' [SEEN]')
            raise StopIteration()
        else:
            if print_tree:
                if 'python' in fpath or 'py' in basename(fpath):
                    print(ub.color_text(prefix + fpath, 'red'))
                else:
                    print(prefix + fpath)

        if not exists(fpath):
            yield fpath + ' (not found)'
            # print('ERROR: does not exist fpath = {!r}'.format(fpath))
            ldd_seen[fpath] = None
        else:
            yield fpath
            # print('fpath = {!r}'.format(fpath))
            if fpath not in ldd_seen:
                ldd_seen[fpath] = list(ldd(fpath))

            for child in ldd_seen[fpath]:
                for _ in _ldd_tree(child, depth=depth + 1):
                    yield _

    def _rectify_input_paths(lib_fpaths):
        PATH = os.environ['PATH'].split(os.pathsep)
        for fpath in lib_fpaths:
            if not exists(fpath):
                fpath = abspath(next(search_candidate_paths(PATH, [fpath])))
            else:
                fpath = abspath(fpath)
            yield fpath

    lib_fpaths = list(_rectify_input_paths(lib_fpaths))

    print('Parsing LDD Tree for {}'.format(lib_fpaths))

    for fpath in lib_fpaths:
        for _ in _ldd_tree(fpath):
            yield _


if __name__ == '__main__':
    r"""
    CommandLine:
        export PYTHONPATH=$PYTHONPATH:/home/joncrall/misc
        python ~/misc/scripts/ldd_graph.py *.so

        lib_fpaths = ['/home/joncrall/code/kwiver/build-py2/lib/libsprokit_pipeline.so.0']

        python ~/misc/ldd_graph.py * | sort
    """
    import sys
    lib_fpaths = sys.argv[1:]
    print('lib_fpaths = {!r}'.format(lib_fpaths))
    print_tree = True

    for child in ldd_tree(lib_fpaths, print_tree=print_tree):
        if not print_tree:
            print(child)
