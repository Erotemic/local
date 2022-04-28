#!/usr/bin/env python
from os.path import normpath
from os.path import realpath
from os.path import expanduser
from os.path import relpath
import os
import ubelt as ub


def _getcwd():
    """
    Workaround to get the working directory without dereferencing symlinks.
    This may not work on all systems.

    References:
        https://stackoverflow.com/questions/1542803/getcwd-dereference-symlinks
    """
    # TODO: use ubelt version if it lands
    canidate1 = os.getcwd()
    real1 = normpath(realpath(canidate1))

    # test the PWD environment variable
    candidate2 = os.getenv('PWD', None)
    if candidate2 is not None:
        real2 = normpath(realpath(candidate2))
        if real1 == real2:
            # sometimes PWD may not be updated
            return candidate2
    return canidate1


def _add_sync_remote(host):
    cwd = _getcwd()
    relpwd = relpath(cwd, expanduser('~'))
    ssh_hostpath = f'{host}:{relpwd}/.git'
    ub.cmd(f'git remote add {host} {ssh_hostpath}', verbose=2)


def main():
    import argparse
    parser = argparse.ArgumentParser(description='Sync a git repo with a remote server via ssh')
    parser.add_argument('host', nargs=1, help='Sever corresponding to the remote to add')

    args = parser.parse_args()
    ns = args.__dict__.copy()
    ns['host'] = ns['host'][0]
    _add_sync_remote(args.host)


if __name__ == '__main__':
    main()
