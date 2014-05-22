from __future__ import absolute_import, division, print_function
import meta_util_git as mu

mu.set_userid('Erotemic', ['Hyrule', 'BakerStreet', 'Ooo'])

# USER DEFINITIONS
HOME_DIR = mu.unixpath('~')
CODE_DIR = mu.unixpath('~/code')
LATEX_DIR = mu.unixpath('~/latex')
BUNDLE_DPATH = mu.unixpath('~/local/vim/vimfiles/bundle')


LOCAL_URLS, LOCAL_REPOS = mu.repo_list([
    'git@hyrule.cs.rpi.edu.com:local.git',
], HOME_DIR)


LATEX_REPOS_URLS, LATEX_REPOS = mu.repo_list([
    'https://hyrule.cs.rpi.edu.com:crall-lab-notebook.git',
    'https://hyrule.cs.rpi.edu.com:crall-candidacy-2013.git',

], LATEX_DIR)


# Non local project repos
IBEIS_REPOS_URLS, IBEIS_REPOS = mu.repo_list([
    'https://github.com/Erotemic/utool.git',
    'https://github.com/Erotemic/guitool.git',
    'https://github.com/Erotemic/plottool.git',
    'https://github.com/Erotemic/vtool.git',
    'https://github.com/Erotemic/hesaff.git',
    'https://github.com/Erotemic/ibeis.git',
    'https://github.com/bluemellophone/pyrf.git',
], CODE_DIR)


TPL_REPOS_URLS, TPL_REPOS = mu.repo_list([
    'https://github.com/Erotemic/opencv',
    'https://github.com/Erotemic/flann',
], CODE_DIR)

CODE_REPO_URLS = IBEIS_REPOS_URLS + TPL_REPOS_URLS
CODE_REPOS = IBEIS_REPOS + TPL_REPOS


VIM_REPO_URLS, VIM_REPOS = mu.repo_list([
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
], BUNDLE_DPATH)

VIM_REPOS_WITH_SUBMODULES = [
    'jedi-vim',
    'syntastic',
]


# Local project repositories
PROJECT_REPOS = LOCAL_REPOS + CODE_REPOS + LATEX_REPOS
