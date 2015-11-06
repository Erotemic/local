"""
A list of my personally used repositories

CommandLine:
    lc
    python init/ensure_vim_plugins.py
    python ~/local/init/ensure_vim_plugins.py
"""
from __future__ import absolute_import, division, print_function
from meta_util_git1 import set_userid, unixpath, repo_list


set_userid(userid='Erotemic',
           owned_computers=['Hyrule', 'BakerStreet', 'Ooo'],
           permitted_repos=['pyrf', 'detecttools', 'pygist'])

# USER DEFINITIONS
HOME_DIR     = unixpath('~')
CODE_DIR     = unixpath('~/code')
LATEX_DIR    = unixpath('~/latex')
BUNDLE_DPATH = unixpath('~/local/vim/vimfiles/bundle')


# Non local project repos
IBEIS_REPOS_URLS, IBEIS_REPOS = repo_list([
    'https://github.com/bluemellophone/pyrf.git',
    'https://github.com/bluemellophone/detecttools.git',
    #'https://github.com/hjweide/pygist.git',
    'https://github.com/Erotemic/hesaff.git',
    'https://github.com/Erotemic/vtool.git',
    'https://github.com/Erotemic/plottool.git',
    'https://github.com/Erotemic/guitool.git',
    'https://github.com/Erotemic/utool.git',
    #'https://github.com/aweinstock314/cyth.git',
    'https://github.com/bluemellophone/ibeis_cnn.git',
    'https://github.com/Erotemic/ibeis.git',

    #'https://github.com/Theano/Theano.git'

    #'https://github.com/bluemellophone/gzc-server.git',
    #'https://github.com/bluemellophone/gzc-client.git',

], CODE_DIR)


TPL_REPOS_URLS, TPL_REPOS = repo_list([
    #'https://github.com/Erotemic/opencv',
    'https://github.com/Erotemic/flann',
], CODE_DIR)

CODE_REPO_URLS = TPL_REPOS_URLS + IBEIS_REPOS_URLS
CODE_REPOS = TPL_REPOS + IBEIS_REPOS


LOCAL_URLS, LOCAL_REPOS = repo_list([
    'git@hyrule.cs.rpi.edu.com:local.git',
], HOME_DIR)


LATEX_REPO_TUP = repo_list([
    'git@hyrule.cs.rpi.edu.com:crall-lab-notebook.git',
    'git@hyrule.cs.rpi.edu.com:crall-candidacy-2015.git',
    'git@hyrule.cs.rpi.edu.com:crall-candidacy-2015.git',

], LATEX_DIR)
LATEX_REPOS_URLS, LATEX_REPOS = LATEX_REPO_TUP


"""
sudo add-apt-repository ppa:pgolm/the-silver-searcher
sudo apt-get update
sudo apt-get install the-silver-searcher
"""

"""
CommandLine;
    # install vim plugins
    python ~/local/init/ensure_vim_plugins.py
    # update vim plugins
"""

VIM_REPO_URLS, VIM_REPOS = repo_list([
    #'https://github.com/dbarsam/vim-vimtweak.git',
    #'https://github.com/bling/vim-airline.git',
    'https://github.com/davidhalter/jedi-vim.git',
    'https://github.com/ervandew/supertab.git',
    'https://github.com/mhinz/vim-startify.git',
    'https://github.com/scrooloose/nerdcommenter.git',
    'https://github.com/scrooloose/nerdtree.git',
    'https://github.com/scrooloose/syntastic.git',
    'https://github.com/kien/rainbow_parentheses.vim.git',
    #'https://github.com/fholgado/minibufexpl.vim.git',
    'https://github.com/vim-scripts/taglist.vim.git',
    'https://github.com/honza/vim-snippets.git',
    'https://github.com/altercation/vim-colors-solarized.git',

    'https://github.com/tpope/vim-fugitive.git',

    #'https://github.com/ggreer/the_silver_searcher.git'  # Ag
    # FOR SNIP MATE
    #'https://github.com/tomtom/tlib_vim.git',
    #'https://github.com/MarcWeber/vim-addon-mw-utils.git',
    #'https://github.com/garbas/vim-snipmate.git',
    #'https://github.com/honza/vim-snippets.git',

    'https://github.com/SirVer/ultisnips.git',
    'https://github.com/tpope/vim-markdown.git',
    'https://github.com/Erotemic/vim-quickopen-tvio.git',
    'https://github.com/docunext/closetag.vim.git',

    'https://github.com/jeetsukumaran/vim-buffergator.git',

    #'https://github.com/terryma/vim-multiple-cursors.git',
    #'https://github.com/tpope/vim-repeat.git',
    #'https://github.com/tpope/vim-sensible.git',
    #'https://github.com/tpope/vim-surround.git',
    #'https://github.com/tpope/vim-unimpaired.git',
    #'https://github.com/vim-scripts/Conque-Shell.git',
    #'https://github.com/vim-scripts/csv.vim.git',
    #'https://github.com/vim-scripts/highlight.vim.git',
    #'https://github.com/vim-scripts/grep.vim.git',

    ###'https://github.com/klen/python-mode.git'
    ###'https://github.com/Valloric/YouCompleteMe.git',
    ###'https://github.com/koron/minimap-vim.git',
    #'https://github.com/severin-lemaignan/vim-minimap.git',
    ###'https://github.com/zhaocai/GoldenView.Vim.git',
], BUNDLE_DPATH)

VIM_REPOS_WITH_SUBMODULES = [
    'jedi-vim',  # jedi, python setup.py build develop
    'syntastic',
    #'YouCompleteMe'  #git submodule update --init --recursive
]

# mkdir ycm_build
# cd ycm_build
# set CMAKE_C_COMPILER=gcc
# cmake -G "MinGW Makefiles" ../third_party/ycmd/cpp
# make ycm_support_libs

# Local project repositories
#PROJECT_REPOS = LATEX_REPOS + LOCAL_REPOS + CODE_REPOS
PROJECT_REPOS = LOCAL_REPOS + CODE_REPOS
