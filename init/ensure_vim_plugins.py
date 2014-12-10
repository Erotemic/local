#!/usr/bin/env python
"""
Executable script that ensure local vim plugins

CommandLine:
    lc

    python -c "import os, sys; os.system(sys.executable + ' ' + os.path.expanduser('~/local/init/ensure_vim_plugins')"
    python init/ensure_vim_plugins.py
"""
from __future__ import absolute_import, division, print_function
import sys
import os
from os.path import join
from meta_util_git1 import cd
import util_git1


def ensure_ctags_win32():
    import os
    import utool as ut
    from os.path import join
    dpath = ut.grab_zipped_url('http://prdownloads.sourceforge.net/ctags/ctags58.zip')
    ctags_fname = 'ctags.exe'
    ctags_src = join(dpath,ctags_fname)
    def find_mingw_bin():
        pathdirs = os.environ['PATH'].split(';')
        copydir = None
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

if sys.platform.startswith('win32'):
    try:
        ensure_ctags_win32()
    except Exception as ex:
        pass


if __name__ == '__main__':
    PULL = '--pull' in sys.argv

    BUNDLE_DPATH = util_git1.BUNDLE_DPATH
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

    # TODO:
    # jedi git submodule init
    # jedi git submodule update
