#!/usr/bin/env python
"""
Executable script that ensure local vim plugins

CommandLine:
    lc

    python -c "import os, sys; os.system(sys.executable + ' ' + os.path.expanduser('~/local/init/ensure_vim_plugins')"
    python init/ensure_vim_plugins.py
    python ~/local/init/ensure_vim_plugins.py
    python %USERPROFILE%/local/init/ensure_vim_plugins.py
"""
from __future__ import absolute_import, division, print_function, unicode_literals
import sys
import os
from os.path import join
from meta_util_git1 import cd
import util_git1


def ensure_ctags_win32():
    import utool as ut
    from os.path import join
    dpath = ut.grab_zipped_url('http://prdownloads.sourceforge.net/ctags/ctags58.zip')
    """
    TODO: Download the zipfile, then unzip and take ONLY the
    file ctags58/ctags58/ctags.exe and move it somewhere in the path
    the best place might be C;\ProgFiles\Git\mingw64\bin

    ALSO:
    make a win setup file

    Downloads fonts from https://www.dropbox.com/sh/49h1ht1e2t7dlbj/AACzVIDrfn1GkImP5l_C3Vtia?dl=1
    """

    ctags_fname = 'ctags.exe'
    ctags_src = join(dpath, ctags_fname)
    def find_mingw_bin():
        pathdirs = ut.get_path_dirs()
        copydir = None
        # hueristic for finding mingw bin
        for pathdir in pathdirs:
            pathdir_ = pathdir.lower()
            ismingwbin = (pathdir_.find('mingw') > -1 and pathdir_.endswith('bin'))
            if ismingwbin:
                issmaller = (copydir is None or len(pathdir) < len(copydir))
                if issmaller:
                    copydir = pathdir
        return copydir
    copydir = find_mingw_bin()
    ctags_dst = join(copydir, ctags_fname)
    ut.copy(ctags_src, ctags_dst, overwrite=False)
    #ut.cmd(ctags_exe)
    #ut.view_directory(dpath)


def ensuredir(path):
    if not os.path.exists(path):
        os.makedirs(os.path.normpath(path))


def ensure_nongit_plugins():
    try:
        import utool as ut
        import REPOS1
        BUNDLE_DPATH = util_git1.BUNDLE_DPATH
        for url in REPOS1.VIM_NONGIT_PLUGINS:
            fpath = ut.grab_zipped_url(url, download_dir=BUNDLE_DPATH)
            if fpath.endswith('.vba'):
                cmd_ = 'vim ' + fpath + ' -c "so % | q"'
                ut.cmd(cmd_)
            print('url = %r' % (url,))
    except ImportError:
        print('Cant do nongit plugins without utool')


def main():
    # sudo apt-get install -y exuberant-ctags
    if sys.platform.startswith('win32'):
        try:
            ensure_ctags_win32()
        except Exception:
            print('failed to get ctags.exe for win32')
            pass

    PULL = '--pull' in sys.argv

    BUNDLE_DPATH = util_git1.BUNDLE_DPATH
    ensuredir(BUNDLE_DPATH)
    VIM_REPOS_WITH_SUBMODULES = util_git1.VIM_REPOS_WITH_SUBMODULES
    VIM_REPO_URLS = util_git1.VIM_REPO_URLS
    VIM_REPO_DIRS = util_git1.get_repo_dirs(VIM_REPO_URLS, BUNDLE_DPATH)
    # All modules in the bundle dir (even if not listed)
    BUNDLE_DIRS = [join(BUNDLE_DPATH, name) for name in os.listdir(BUNDLE_DPATH)]

    cd(BUNDLE_DPATH)

    util_git1.checkout_repos(VIM_REPO_URLS, VIM_REPO_DIRS)

    __NOT_GIT_REPOS__ = []
    __BUNDLE_REPOS__  = []

    for repodir in BUNDLE_DIRS:
        # Mark which repos do not have .git dirs
        if not util_git1.is_gitrepo(repodir):
            __NOT_GIT_REPOS__.append(repodir)
        else:
            __BUNDLE_REPOS__.append(repodir)

    if PULL:
        util_git1.pull_repos(__BUNDLE_REPOS__, VIM_REPOS_WITH_SUBMODULES)

    ensure_nongit_plugins()

    # Print suggestions for removing nonbundle repos
    if len(__NOT_GIT_REPOS__) > 0:
        print('Please fix these nongit repos: ')
        print('\n'.join(__NOT_GIT_REPOS__))
        print('maybe like this: ')
        clutterdir = util_git1.unixpath('~/local/vim/vimfiles/clutter')
        suggested_cmds = (
            ['mkdir ' + clutterdir] +
            ['mv ' + util_git1.unixpath(dir_) + ' ' + clutterdir for dir_ in __NOT_GIT_REPOS__])
        print('\n'.join(suggested_cmds))


if __name__ == '__main__':
    main()
    #PULL = '--pull' in sys.argv

    #BUNDLE_DPATH = util_git1.BUNDLE_DPATH
    #VIM_REPOS_WITH_SUBMODULES = util_git1.VIM_REPOS_WITH_SUBMODULES
    #VIM_REPO_URLS = util_git1.VIM_REPO_URLS
    #VIM_REPO_DIRS = util_git1.get_repo_dirs(VIM_REPO_URLS, BUNDLE_DPATH)
    ## All modules in the bundle dir (even if not listed)
    #BUNDLE_DIRS = [join(BUNDLE_DPATH, name) for name in os.listdir(BUNDLE_DPATH)]

    #cd(BUNDLE_DPATH)

    #util_git1.checkout_repos(VIM_REPO_URLS, VIM_REPO_DIRS)

    #__NOT_GIT_REPOS__ = []
    #__BUNDLE_REPOS__  = []

    #for repodir in BUNDLE_DIRS:
    #    # Mark which repos do not have .git dirs
    #    if not util_git1.is_gitrepo(repodir):
    #        __NOT_GIT_REPOS__.append(repodir)
    #    else:
    #        __BUNDLE_REPOS__.append(repodir)

    #if PULL:
    #    util_git1.pull_repos(__BUNDLE_REPOS__, VIM_REPOS_WITH_SUBMODULES)

    ## Print suggestions for removing nonbundle repos
    #if len(__NOT_GIT_REPOS__) > 0:
    #    print('Please fix these nongit repos: ')
    #    print('\n'.join(__NOT_GIT_REPOS__))
    #    print('maybe like this: ')
    #    clutterdir = util_git1.unixpath('~/local/vim/vimfiles/clutter')
    #    suggested_cmds = (
    #        ['mkdir ' + clutterdir] +
    #        ['mv ' + util_git1.unixpath(dir_) + ' ' + clutterdir for dir_ in __NOT_GIT_REPOS__])
    #    print('\n'.join(suggested_cmds))

    # TODO:
    # jedi git submodule init
    # jedi git submodule update
