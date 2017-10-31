#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
Adds and commits a change to a local branch (but not the current one)
"""
from __future__ import absolute_import, division, print_function, unicode_literals
import git
# import sys


class CheckoutContext(object):
    def __init__(self, repo):
        self.repo = repo
        self.orig_branch_name = repo.active_branch.name

    def __enter__(self):
        return self

    def __exit__(self, type, value, tb):
        # if True:
        #     print('Changing to original branch {}'.format(self.orig_branch_name))
        self.repo.git.checkout(self.orig_branch_name)


def git_xadd(branch, files, base=None, message='wip', dry=False):
    repo = git.Repo()

    existing_branches = {branch.name for branch in repo.branches}

    if branch not in existing_branches:
        if base is None:
            raise ValueError('Branch {!r} does not exist'.format(branch))
        elif base not in existing_branches:
            raise ValueError('Base branch {!r} does not exist'.format(base))
        else:
            # Create the branch if the base is known
            with CheckoutContext(repo):
                repo.git.checkout(base)
                if dry:
                    print('Would created new branch {}'.format(branch))
                else:
                    repo.git.checkout(branch, b=True)
                    print('Created new branch {}'.format(branch))

    with CheckoutContext(repo):
        repo.git.checkout(branch)
        if dry:
            print('Changing to branch {}'.format(branch))
            print('Would add files {}'.format(files))
            print('Would commit with message {}'.format(message))
        else:
            repo.git.add(files)
            repo.git.commit(m=message)


# def get_varargs(argv=None):
#     """
#     Returns positional args specified directly after the scriptname
#     and before any args starting with '-' on the commandline.
#     """
#     if argv is None:
#         argv = sys.argv
#     scriptname = argv[0]
#     if scriptname == '':
#         # python invoked by iteself
#         pos_start = 0
#         pos_end = 0
#     else:
#         pos_start = pos_end = 1
#         for idx in range(pos_start, len(argv)):
#             if argv[idx].startswith('-'):
#                 pos_end = idx
#                 break
#         else:
#             pos_end = len(argv)
#     varargs = argv[pos_start:pos_end]
#     return varargs


if __name__ == '__main__':
    r"""
    SeeAlso:
        git_squash_streaks.py

    Ignore:
        python ~/misc/git/git_xadd.py dev/doc_fixes arrows/ocv/split_image.cxx -m "added a bit more info"
        git merge dev/doc_fixes

    CommandLine:
        export PYTHONPATH=$PYTHONPATH:/home/joncrall/misc
        python ~/misc/git_xadd.py
    """
    import argparse
    parser = argparse.ArgumentParser(description='git-xadd add files to non-working branches')
    parser.add_argument('files', nargs='+',
                        help='Files to externally add')
    parser.add_argument(*('-m', '--message'), type=str, default='wip',
                        help='commit message')
    parser.add_argument('--branch', type=str, default=None, required=True,
                        help='branch to add to')
    parser.add_argument('--base', type=str, default=None,
                        help='base of external branch (used if branch doesnt exist)')
    parser.add_argument(*('-n', '--dry'), action='store_true',
                        default=False, help='dry run')
    args = parser.parse_args()

    # import ubelt as ub
    # print('sys.argv = {!r}'.format(sys.argv))
    # message = ub.argval(('-m', '--message'), default='wip')
    # branch  = ub.argval('--branch', default=None)
    # base    = ub.argval('--base', default=None)
    # dry     = ub.argflag(('-n', '--dry'))
    # if branch is None:
    #     raise ValueError('must specify --branch')
    # varargs = get_varargs()
    # files = varargs[:]

    branch = args.branch
    message = args.message
    dry = args.dry
    base = args.base
    files = args.files

    if branch is None:
        raise ValueError('must specify --branch')
    if len(files) == 0:
        raise ValueError('Must specify files')

    # print('args = {!r}'.format(args))
    git_xadd(branch, files, message=message, base=base, dry=dry)
