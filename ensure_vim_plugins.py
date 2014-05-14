#!/usr/bin/env python
from __future__ import absolute_import, division, print_function
import sys
import os
from os.path import expanduser, exists, join, realpath, isdir, normpath, split

DO_PULL = '--pull' in sys.argv
QUICK = ('--quick' in sys.argv or '--nopull' in sys.argv


__HAVE_SUBMODULES__ = [
    'jedi-vim',
    'syntastic',
]


__REPO_URLS__ = [
    'https://github.com/dbarsam/vim-vimtweak.git',
    'https://github.com/bling/vim-airline.git',
    'https://github.com/davidhalter/jedi-vim.git',
    'https://github.com/ervandew/supertab.git',
    'https://github.com/mhinz/vim-startify.git',
    'https://github.com/scrooloose/nerdcommenter.git',
    'https://github.com/scrooloose/nerdtree.git',
    'https://github.com/scrooloose/syntastic.git',
    'https://github.com/terryma/vim-multiple-cursors.git',
    'https://github.com/tpope/vim-repeat.git',
    'https://github.com/tpope/vim-sensible.git',
    'https://github.com/tpope/vim-surround.git',
    'https://github.com/tpope/vim-unimpaired.git',
    'https://github.com/vim-scripts/Conque-Shell.git',
    'https://github.com/vim-scripts/csv.vim.git',
    'https://github.com/vim-scripts/highlight.vim.git',
    #'https://github.com/koron/minimap-vim.git',
    #'https://github.com/zhaocai/GoldenView.Vim.git',
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


def checkgit(repo_dir):
    gitdir = join(repo_dir, '.git')
    return exists(gitdir) and isdir(gitdir)


BUNDLE_DPATH = unixpath('~/local/vim/vimfiles/bundle')
__REPO_DIRS__ = map(get_repo_dir, __REPO_URLS__)
__BUNDLE_DIRS__ = [join(BUNDLE_DPATH, name) for name in os.listdir(BUNDLE_DPATH)]


cd(BUNDLE_DPATH)

# Check out all repos listed
for repodir, repourl in zip(__REPO_DIRS__, __REPO_URLS__):
    print('Checking: ' + repodir)
    if not exists(repodir):
        cmd('git clone ' + repourl)

__NOT_GIT_REPOS__ = []
__BUNDLE_REPOS__  = []


for repodir in __BUNDLE_DIRS__:
    # Mark which repos do not have .git dirs
    if not checkgit(repodir):
        __NOT_GIT_REPOS__.append(repodir)
    else:
        __BUNDLE_REPOS__.append(repodir)


if not QUICK:
    # Updating repos is a bit slower
    for repodir in __BUNDLE_REPOS__:
        print('Updating: ' + repodir)
        cd(repodir)
        cmd('git pull')
        reponame = split(repodir)[1]
        if reponame in __HAVE_SUBMODULES__:
            cmd('git submodule init')
            cmd('git submodule update')
        cd('..')


if len(__NOT_GIT_REPOS__) > 0:
    print('Please fix these nongit repos: ')
    print('\n'.join(__NOT_GIT_REPOS__))
    print('maybe like this: ')
    clutterdir = unixpath('~/local/vim/vimfiles/clutter')
    suggested_cmds = (
        ['mkdir ' + clutterdir] +
        ['mv ' + unixpath(dir_) + ' ' + clutterdir for dir_ in __NOT_GIT_REPOS__])
    print('\n'.join(suggested_cmds))
