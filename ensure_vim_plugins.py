#!/usr/bin/env python
from __future__ import absolute_import, division, print_function
import os
from os.path import expanduser, exists, join, realpath


def cd(dir_):
    dir_ = realpath(dir_)
    print('cd ' + dir_)
    os.chdir(dir_)


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

__HAVE_SUBMODULES__ = [
    'jedi-vim',
    'syntastic',
]


__REPO_URLS__ = [
    'https://github.com/bling/vim-airline.git',
    'https://github.com/davidhalter/jedi-vim.git',
    #'https://github.com/koron/minimap-vim.git',
    'https://github.com/mhinz/vim-startify.git',
    'https://github.com/scrooloose/nerdtree.git',
    'https://github.com/scrooloose/syntastic.git',
    'https://github.com/scrooloose/nerdcommenter.git'
    'https://github.com/terryma/vim-multiple-cursors.git',
    'https://github.com/tpope/vim-repeat.git',
    'https://github.com/tpope/vim-surround.git',
    'https://github.com/tpope/vim-unimpaired.git',
    #'https://github.com/zhaocai/GoldenView.Vim.git',
]

BUNDLE_DIR = expanduser('~/local/vim/vimfiles/bundle')
__REPO_DIRS__ = map(get_repo_dir, __REPO_URLS__)
__BUNDLED__ = os.listdir(BUNDLE_DIR)

cd(BUNDLE_DIR)
for repodir, repourl in zip(__REPO_DIRS__, __REPO_URLS__):
    print('Checking: ' + repodir)
    if not exists(join(BUNDLE_DIR, repodir)):
        os.system('git clone ' + repourl)

for repodir in __BUNDLED__:
    print('Updating: ' + repodir)
    cd(repodir)
    os.system('git pull')
    if repodir in __HAVE_SUBMODULES__:
        os.system('git submodule init')
        os.system('git submodule update')
    cd('..')
