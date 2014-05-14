#!/usr/bin/env python
from __future__ import absolute_import, division, print_function
from os.path import expanduser, exists, normpath, realpath
import os
import sys

code_dir = expanduser('~/code')

DO_PULL = '--pull' in sys.argv
QUICK = ('--quick' in sys.argv or '--nopull' in sys.argv)


repo_urls = [
    'https://github.com/Erotemic/utool.git',
    'https://github.com/Erotemic/guitool.git',
    'https://github.com/Erotemic/plottool.git',
    'https://github.com/Erotemic/vtool.git',
    'https://github.com/Erotemic/hesaff.git',
    'https://github.com/Erotemic/ibeis.git',
]


def truepath(path):
    return normpath(realpath(expanduser(path)))


def unixpath(path):
    return truepath(path).replace('\\', '/')


def cd(dir_):
    dir_ = truepath(dir_)
    print('> cd ' + dir_)
    os.chdir(dir_)


def cmd(command):
    print('> ' + command)
    os.system(command)


IS_OWNER = True
if IS_OWNER:
    repo_urls = [repo.replace('.com/', '.com:').replace('https://', 'git@') for repo in repo_urls]


def get_repo_dir(repo_url):
    """ Break url into a dirname """
    slashpos = repo_url.rfind('/')
    colonpos = repo_url.rfind(':')
    if slashpos != -1 and slashpos > colonpos:
        pos = slashpos
    else:
        pos = colonpos
    repodir = repo_url[pos + 1:].replace('.git', '')
    return repodir


repo_dirs = map(get_repo_dir, repo_urls)

# Navigate to code dir
cd(code_dir)

# Check out any repo you dont have
for repodir, repourl in zip(repo_dirs, repo_urls):
    print('Checking: ' + repodir)
    if not exists(repodir):
        cmd('git clone ' + repourl)

if not QUICK:
    # Updating repos is a bit slower
    for repodir in repo_dirs:
        print('Updating: ' + repodir)
        cd(repodir)
        #cmd('git pull')
        cmd('python setup.py develop')
        cd(code_dir)
