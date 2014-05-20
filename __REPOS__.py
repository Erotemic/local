from __future__ import absolute_import, division, print_function
from os.path import expanduser
from itertools import izip
from os.path import normpath, realpath
import platform


def truepath(path):
    return normpath(realpath(expanduser(path)))


def unixpath(path):
    return truepath(path).replace('\\', '/')


# USER DEFINITIONS
CODE_DIR = unixpath('~/code')
BUNDLE_DPATH = unixpath('~/local/vim/vimfiles/bundle')


# Local project repositories
PROJECT_REPOS = map(unixpath, [
    '~/local',
    '~/code/opencv',
    '~/code/flann',
    '~/code/utool',
    '~/code/hesaff',
    '~/code/vtool',
    '~/code/guitool',
    '~/code/plottool',
    '~/code/ibeis',
    '~/code/pyrf',
    '~/latex/crall-lab-notebook',
    '~/latex/crall-candidacy-2013',
])


# Non local project repos
IBEIS_REPOS_URLS = [
    'https://github.com/Erotemic/utool.git',
    'https://github.com/Erotemic/guitool.git',
    'https://github.com/Erotemic/plottool.git',
    'https://github.com/Erotemic/vtool.git',
    'https://github.com/Erotemic/hesaff.git',
    'https://github.com/Erotemic/ibeis.git',
]


VIM_REPO_URLS = [
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

VIM_REPOS_WITH_SUBMODULES = [
    'jedi-vim',
    'syntastic',
]


def fix_repo_url(repo_url, in_type='https', out_type='ssh'):
    """ Changes the repo_url format """
    format_dict = {
        'https': ('.com/', 'https://'),
        'ssh':   ('.com:', 'git@'),
    }
    for old, new in izip(format_dict[in_type], format_dict[out_type]):
        repo_url = repo_url.replace(old, new)
    return repo_url


def get_computer_name():
    return platform.node()

COMPUTER_NAME  = get_computer_name()

# Check to see if you are on one of Jons Computers
#
IS_OWNER = COMPUTER_NAME in ['BakerStreet', 'Hyrule', 'Ooo']

if IS_OWNER:
    IBEIS_REPOS_URLS = [fix_repo_url(repo, 'https', 'ssh')
                         for repo in IBEIS_REPOS_URLS]
