#!/usr/bin/env python
# PYTHON_ARGCOMPLETE_OK
# -*- coding: utf-8 -*-
"""
Shortcut to add a remote based off a username
"""
# import git
import ubelt as ub


def github_add_fork(new_user, dry=False):
    out = ub.cmd('git remote -v')['out']
    parts = [p.split(' ')[0] for p in out.split('\n') if p]
    remote_to_url = dict([p.split('\t') for p in parts])

    repo_names = set()
    for remote, url in remote_to_url.items():
        if new_user == remote:
            raise Exception('User already exists')
        if 'github.com' in url:
            user, gitname = url.split('github.com')[1][1:].split('/')
            repo_names.add(gitname)

    if len(repo_names) != 1:
        raise Exception('Conflicting repo names')

    gitname = list(repo_names)[0]

    new_url = 'https://github.com/{}/{}'.format(new_user, gitname)
    command = 'git remote add {} {}'.format(new_user, new_url)
    if not dry:
        ub.cmd(command, verbose=3)
    else:
        print('Dry run: would execute: {}'.format(command))


def main():
    import argparse
    parser = argparse.ArgumentParser(description='Shortcut to add a remote based off a username')

    parser.add_argument('new_user', help='Username to add')
    parser.add_argument(*('-n', '--dry'), dest='dry', action='store_true',
                        help='Perform a dry run', default=False)

    args = parser.parse_args()
    ns = args.__dict__.copy()

    github_add_fork(**ns)

if __name__ == '__main__':
    r"""
    CommandLine:
        python ~/local/git_tools/github_add_fork.py ZHAOTING -n
        python ~/local/git_tools/github_add_fork.py ZHAOTING
    """
    main()
