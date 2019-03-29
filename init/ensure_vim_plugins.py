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
from os.path import basename
from os.path import commonprefix
from os.path import dirname
from os.path import exists
from os.path import split
from os.path import splitext
import sys
import os
from os.path import join


def grab_zipped_url(url):
    import ubelt as ub
    def unzip_file(zip_fpath, force_commonprefix=True, output_dir=None,
                   prefix=None, dryrun=False, overwrite=None, verbose=1):
        import zipfile
        zip_file = zipfile.ZipFile(zip_fpath)
        if output_dir is None:
            output_dir  = dirname(zip_fpath)
        archive_namelist = zip_file.namelist()

        # force extracted components into a subdirectory if force_commonprefix is
        if prefix is not None:
            output_dir = join(output_dir, prefix)
            ub.ensuredir(output_dir)

        archive_basename, ext = splitext(basename(zip_fpath))
        if force_commonprefix and commonprefix(archive_namelist) == '':
            # use the archivename as the default common prefix
            output_dir = join(output_dir, archive_basename)
            ub.ensuredir(output_dir)

        for member in archive_namelist:
            (dname, fname) = split(member)
            dpath = join(output_dir, dname)
            ub.ensuredir(dpath)
            if verbose:
                print('Unarchive ' + fname + ' in ' + dpath)

            if not dryrun:
                if overwrite is False:
                    if exists(join(output_dir, member)):
                        continue
                zip_file.extract(member, path=output_dir)
        zip_file.close()

        # hack
        return join(output_dir, archive_basename)

    zip_fpath = ub.grabdata(url)
    dpath = unzip_file(zip_fpath)
    return dpath


def ensure_ctags_win32():
    """

    import netharn as nh
    closer = nh.export.closer.Closer()

    closer.add_dynamic(ut.unzip_file)
    # closer.expand(['utool']) # FIXME

    print(closer.current_sourcecode())
    """
    import ubelt as ub
    import shutil

    # dpath = ut.grab_zipped_url('http://prdownloads.sourceforge.net/ctags/ctags58.zip')
    """
    TODO: Download the zipfile, then unzip and take ONLY the
    file ctags58/ctags58/ctags.exe and move it somewhere in the path
    the best place might be C;\ProgFiles\Git\mingw64\bin

    ALSO:
    make a win setup file

    Downloads fonts from https://www.dropbox.com/sh/49h1ht1e2t7dlbj/AACzVIDrfn1GkImP5l_C3Vtia?dl=1
    """

    ctags_fname = 'ctags.exe'
    dpath = grab_zipped_url('http://prdownloads.sourceforge.net/ctags/ctags58.zip')
    ctags_src = join(dpath, ctags_fname)

    # We need to copy the ctags executable into the mingw bin directory
    # (so it is on our PATH)
    candidates = ub.find_path('mingw*bin')
    if len(candidates) == 0:
        raise Exception('Could not find mingw')
    else:
        copydir = candidates[0]

    def find_mingw_bin():
        pathdirs = ub.find_path('')  # list all directories in PATH
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
    shutil.copy2(ctags_src, ctags_dst)
    #ub.cmd(ctags_exe)
    #xdev.view_directory(dpath)


def ensuredir(path):
    if not os.path.exists(path):
        os.makedirs(os.path.normpath(path))


def ensure_nongit_plugins():
    try:
        import ubelt as ub
        import REPOS1
        BUNDLE_DPATH = REPOS1.BUNDLE_DPATH
        for url in REPOS1.VIM_NONGIT_PLUGINS:
            fpath = grab_zipped_url(url, download_dir=BUNDLE_DPATH)
            if fpath.endswith('.vba'):
                cmd_ = 'vim ' + fpath + ' -c "so % | q"'
                ub.cmd(cmd_, verbose=3)
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

    import REPOS1
    import util_git1
    from meta_util_git1 import get_repo_dirs
    from meta_util_git1 import cd

    BUNDLE_DPATH = REPOS1.BUNDLE_DPATH
    ensuredir(BUNDLE_DPATH)
    VIM_REPOS_WITH_SUBMODULES = REPOS1.VIM_REPOS_WITH_SUBMODULES
    VIM_REPO_URLS = REPOS1.VIM_REPO_URLS
    VIM_REPO_DIRS = get_repo_dirs(VIM_REPO_URLS, BUNDLE_DPATH)
    # All modules in the bundle dir (even if not listed)
    import os
    BUNDLE_DIRS = [join(BUNDLE_DPATH, name)
                   for name in os.listdir(BUNDLE_DPATH)]

    cd(BUNDLE_DPATH)

    print('VIM_REPO_DIRS = {!r}'.format(VIM_REPO_DIRS))
    print('VIM_REPO_URLS = {!r}'.format(VIM_REPO_URLS))
    # util_git1.checkout_repos(VIM_REPO_URLS, VIM_REPO_DIRS)
    import ubelt as ub
    for repodir, repourl in zip(VIM_REPO_DIRS, VIM_REPO_URLS):
        print('[git] checkexist: ' + repodir)
        if not exists(repodir):
            cd(dirname(repodir))
            ub.cmd('git clone ' + repourl, verbose=3)

    __NOT_GIT_REPOS__ = []
    __BUNDLE_REPOS__  = []

    for repodir in BUNDLE_DIRS:
        # Mark which repos do not have .git dirs
        if not util_git1.is_gitrepo(repodir):
            __NOT_GIT_REPOS__.append(repodir)
        else:
            __BUNDLE_REPOS__.append(repodir)

    if ub.argflag('--pull'):
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

    # Hack for nerd fonts
    # """
    # cd ~/local/vim/vimfiles/bundle
    # # git clone https://github.com/ryanoasis/nerd-fonts.git --depth 1
    # https://github.com/ryanoasis/nerd-fonts/blob/master/patched-fonts/Inconsolata/complete/Inconsolata%20Nerd%20Font%20Complete.otf
    # https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/Inconsolata/complete/Inconsolata%20Nerd%20Font%20Complete.otf
    # """

    # HACK FOR JEDI

    import os
    for repo in VIM_REPOS_WITH_SUBMODULES:
        cd(join(BUNDLE_DPATH, repo))
        command = 'git submodule update --init --recursive'
        try:
            import ubelt as ub
            ub.cmd(command, verbose=2)
        except Exception:
            os.system(command)


if __name__ == '__main__':
    """
    CommandLine:
        python ~/local/init/ensure_vim_plugins.py
    """
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
