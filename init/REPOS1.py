"""
A list of my personally used repositories

CommandLine:
    lc
    python ~/local/init/ensure_repos.py
    python init/ensure_vim_plugins.py
    python ~/local/init/ensure_vim_plugins.py
"""
from __future__ import absolute_import, division, print_function
from os.path import expanduser, expandvars
import os
from meta_util_git1 import set_userid, repo_list
from collections import defaultdict

try:
    import ubelt as ub
except ImportError:
    pass

# Local project repositories
PROJECT_REPOS = []
PROJECT_URLS = []


# New more configurable stuff
# These will populate PROJECT_REPOS and PROJECT_URLS
config_fpaths = [
    expanduser('~/code/erotemic/homelinks/repos.txt'),
    expanduser('~/internal/repos.txt'),
    expanduser('~/local/repos.txt'),
]


set_userid(userid='Erotemic',
           owned_computers=['Hyrule', 'BakerStreet', 'Ooo', 'calculex', 'acidilia'],
           permitted_repos=['pyrf', 'detecttools', 'pygist'])

# USER DEFINITIONS
HOME_DIR     = expanduser('~')
CODE_DIR     = expanduser('~/code')
LATEX_DIR    = expanduser('~/latex')
BUNDLE_DPATH = expanduser('~/local/vim/vimfiles/bundle')


"""
sudo add-apt-repository ppa:pgolm/the-silver-searcher
sudo apt-get update
sudo apt-get install the-silver-searcher


https://github.com/rentalcustard/exuberant-ctags.git
cd exuberant-ctags
./configure
make -j9
sudo make install
"""

"""
CommandLine;
    # install vim plugins
    python ~/local/init/ensure_vim_plugins.py
    python ~/local/init/ensure_vim_plugins.py --pull
    # update vim plugins
"""

VIM_REPO_URLS, VIM_REPOS = repo_list([
    'https://github.com/VundleVim/Vundle.vim.git',
    'https://github.com/chrisbra/unicode.vim.git',

    #'https://github.com/dbarsam/vim-vimtweak.git',
    #'https://github.com/bling/vim-airline.git',
    'https://github.com/tell-k/vim-autopep8.git',
    'https://github.com/davidhalter/jedi-vim.git',
    'https://github.com/ervandew/supertab.git',
    'https://github.com/mhinz/vim-startify.git',
    'https://github.com/scrooloose/nerdcommenter.git',
    'https://github.com/scrooloose/nerdtree.git',
    'https://github.com/scrooloose/syntastic.git',
    # 'https://github.com/kien/rainbow_parentheses.vim.git',
    #'https://github.com/fholgado/minibufexpl.vim.git',

    'https://github.com/sjl/badwolf.git',
    # 'https://github.com/morhetz/gruvbox.git',
    # 'https://github.com/29decibel/codeschool-vim-theme.git',
    # 'https://github.com/vim-scripts/phd.git',

    'https://github.com/vim-scripts/taglist.vim.git',  # ctags
    'https://github.com/majutsushi/tagbar.git',
    'https://github.com/honza/vim-snippets.git',
    'https://github.com/altercation/vim-colors-solarized.git',
    # 'https://github.com/drmingdrmer/vim-syntax-markdown.git',
    # 'https://github.com/plasticboy/vim-markdown.git',
    'https://github.com/google/vim-searchindex.git',
    'https://github.com/tpope/vim-markdown.git',

    'https://github.com/jmcantrell/vim-virtualenv.git',
    'https://github.com/Lokaltog/vim-powerline.git',

    'https://github.com/LaTeX-Box-Team/LaTeX-Box.git',

    # 'https://github.com/tpope/vim-fugitive.git',

    #'https://github.com/ggreer/the_silver_searcher.git'  # Ag
    # FOR SNIP MATE
    #'https://github.com/tomtom/tlib_vim.git',
    #'https://github.com/MarcWeber/vim-addon-mw-utils.git',
    #'https://github.com/garbas/vim-snipmate.git',
    #'https://github.com/honza/vim-snippets.git',

    'https://github.com/SirVer/ultisnips.git',

    'https://github.com/Erotemic/vimtk.git',

    # 'https://github.com/Erotemic/vim-quickopen-tvio.git',
    # 'https://github.com/docunext/closetag.vim.git',

    # 'https://github.com/jeetsukumaran/vim-buffergator.git',

    'https://github.com/vim-scripts/AnsiEsc.vim.git',
    # 'https://github.com/ivanov/vim-ipython.git',

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

    # 'https://github.com/ryanoasis/vim-devicons.git',  # pain to get fonts
    # 'https://github.com/ryanoasis/nerd-fonts.git',  # not really a plugin
], BUNDLE_DPATH)

VIM_NONGIT_PLUGINS = [
    #'http://www.drchip.org/astronaut/vim/vbafiles/AnsiEsc.vba.gz'
]

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


def _parse_custom_urls():
    dpath_to_url = defaultdict(list)

    seen = set([])
    for fpath in config_fpaths:
        if os.path.exists(fpath):
            for line in open(fpath, 'r').read().splitlines():
                line = line.strip()
                if line and not line.startswith('#'):
                    parts = line.split(' ')
                    # Allow text files to specify url and dpath
                    # default to code dir if dpath not given
                    if len(parts) == 1:
                        url = parts[0]
                        dpath = CODE_DIR
                    else:
                        assert len(parts) == 2
                        url, dpath = parts
                        dpath = expandvars(expanduser(dpath))

                        # try:
                        #     os.makedirs(dpath, exist_ok=True)
                        # except Exception:
                        #     ub.ensuredir(dpath)
                        if not os.path.exists(dpath):
                            os.makedirs(dpath)

                    if (dpath, url) in seen:
                        continue
                    seen.add((dpath, url))
                    dpath_to_url[dpath].append(url)
    return dpath_to_url


def update_urls():
    global PROJECT_URLS
    global PROJECT_REPOS
    for dpath, urls in _parse_custom_urls().items():
        print('urls = {!r}'.format(urls))
        repos_urls, repos = repo_list(urls, dpath)

        PROJECT_URLS += repos_urls
        PROJECT_REPOS += repos


update_urls()
# print('PROJECT_URLS = {!r}'.format(PROJECT_URLS))
try:
    print('PROJECT_REPOS = {}'.format(ub.repr2(PROJECT_REPOS)))
except NameError:
    pass
