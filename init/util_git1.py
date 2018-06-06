#!/usr/bin/env python
"""
Used by
$HOME/local/homelinks/helpers/git_helpers.sh
"""
from __future__ import absolute_import, division, print_function
import sys
import re
import os
from six.moves import zip
from os.path import exists, join, dirname, split, isdir
import REPOS1
import meta_util_git1 as mu  # NOQA
from meta_util_git1 import get_repo_dirs, get_repo_dname, unixpath, ChdirContext  # NOQA

PROJECT_REPOS    = REPOS1.PROJECT_REPOS
IBEIS_REPOS_URLS = REPOS1.IBEIS_REPOS_URLS
CODE_DIR         = REPOS1.CODE_DIR
VIM_REPO_URLS    = REPOS1.VIM_REPO_URLS
BUNDLE_DPATH     = REPOS1.BUNDLE_DPATH
VIM_REPOS_WITH_SUBMODULES = REPOS1.VIM_REPOS_WITH_SUBMODULES


class Repo(object):
    """
    Handles a Python module repository
    """
    def __init__(repo, url=None, dpath=None, modname=None, pythoncmd=None,
                 code_dir=None):
        # modname might need to be called egg?
        if url is not None and '.git@' in url:
            # parse out specific branch
            repo.default_branch = url.split('@')[-1]
            url = '@'.join(url.split('@')[:-1])
        else:
            repo.default_branch = None
        repo.url = url
        repo._modname = None
        if modname is None:
            modname = []
        repo._modname_hints = modname if isinstance(modname, list) else [modname]
        repo.dpath = None
        if pythoncmd is None:
            import sys
            pythoncmd = sys.executable
        repo.pythoncmd = pythoncmd

        if dpath is None and repo.url is not None and code_dir is not None:
            dpath = join(code_dir, repo.reponame)
        if dpath is not None:
            repo.dpath = dpath.replace('\\', '/')

    def owner(repo):
        url_parts = re.split('[/:]', repo.url)
        owner = url_parts[-2]
        return owner

    def change_url_format(repo, out_type='ssh'):
        """ Changes the url format for committing """
        url = repo.url
        url_parts = re.split('[/:]', url)
        in_type = url_parts[0]
        url_fmts = {
            'https': ('.com/', 'https://'),
            'ssh':   ('.com:', 'git@'),
        }
        url_fmts['git'] = url_fmts['ssh']
        new_repo_url = url
        for old, new in zip(url_fmts[in_type], url_fmts[out_type]):
            new_repo_url = new_repo_url.replace(old, new)
        # Inplace change
        repo.url = new_repo_url
        print('new format repo.url = {!r}'.format(repo.url))

    @property
    def reponame(repo):
        if repo.dpath is not None:
            from os.path import basename
            reponame = basename(repo.dpath)
        elif repo.url is not None:
            url_parts = re.split('[/:]', repo.url)
            reponame = url_parts[-1].replace('.git', '')
        elif repo._modname_hints:
            reponame = repo._modname_hints[0]
        else:
            raise Exception('No way to infer (or even guess) repository name!')
        return reponame

    def issue(repo, command, sudo=False, dry=False, error='raise', return_out=False):
        """
        issues a command on a repo

        Example:
            >>> # DISABLE_DOCTEST
            >>> repo = dirname(ut.get_modpath(ut, prefer_pkg=True))
            >>> command = 'git status'
            >>> sudo = False
            >>> result = repocmd(repo, command, sudo)
            >>> print(result)
        """
        WIN32 = sys.platform.startswith('win32')
        if WIN32:
            assert not sudo, 'cant sudo on windows'
        if command == 'short_status':
            return repo.short_status()
        command_list = [command]
        cmdstr = '\n        '.join([cmd_ for cmd_ in command_list])
        if not dry:
            import ubelt as ub
            print('+--- *** repocmd(%s) *** ' % (cmdstr,))
            print('repo=%s' % ub.color_text(repo.dpath, 'yellow'))
        verbose = True
        with repo.chdir_context():
            ret = None
            for count, cmd in enumerate(command_list):
                if dry:
                    print(cmd)
                    continue
                if not sudo or WIN32:
                    cmdinfo = ub.cmd(cmd, verbout=True)
                    out, err, ret = ub.take(cmdinfo, ['out', 'err', 'ret'])
                else:
                    out, err, ret = ub.cmd('sudo ' + cmd)
                if verbose > 1:
                    print('ret(%d) = %r' % (count, ret,))
                if ret != 0:
                    if error == 'raise':
                        raise Exception('Failed command %r' % (cmd,))
                    elif error == 'return':
                        return out
                    else:
                        raise ValueError('unknown flag error=%r' % (error,))
                if return_out:
                    return out
        if not dry:
            print('L____')

    def _new_remote_url(repo, host=None, user=None, reponame=None, fmt=None):
        if reponame is None:
            reponame = repo.reponame
        if host is None:
            host = 'github.com'
        if fmt is None:
            fmt = 'ssh'
        if host == 'github.com':
            assert user is not None, 'github needs a user'
        url_fmts = {
            'https': ('https://', '/'),
            'ssh':   ('git@', ':'),
        }
        prefix, sep = url_fmts[fmt]
        user_ = '' if user is None else user + '/'
        parts = [prefix, host, sep, user_, reponame, '.git']
        parts = [p for p in parts if p is not None]
        url = ''.join(parts)
        return url

    def clone(repo, recursive=False):
        print('[git] check repo exists at %s' % (repo.dpath))
        if recursive:
            args = '--recursive'
        else:
            args = ''
        if not exists(repo.dpath):
            import ubelt as ub
            os.chdir(dirname(repo.dpath))
            print('repo.default_branch = %r' % (repo.default_branch,))
            if repo.default_branch is not None:
                args += ' -b {}'.format(repo.default_branch)
            ub.cmd('git clone {args} {url}'.format(args=args, url=repo.url),
                   verbose=2)

    def chdir_context(repo, verbose=False):
        return ChdirContext(repo.dpath, verbose=verbose)

    def short_status(repo):
        r"""
        Example:
            >>> repo = Repo(dpath=ut.truepath('.'))
            >>> result = repo.short_status()
            >>> print(result)
        """
        import ubelt as ub
        prefix = repo.dpath
        with ChdirContext(repo.dpath, verbose=False):
            info = ub.cmd('git status', verbose=False)
            out = info['out']
            # parse git status
            is_clean_msg1 = 'Your branch is up-to-date with'
            is_clean_msgs = [
                'nothing to commit, working directory clean',
                'nothing to commit, working tree clean',
            ]
            msg2 = 'nothing added to commit but untracked files present'

            needs_commit_msgs = [
                'Changes to be committed',
                'Changes not staged for commit',
                'Your branch is ahead of',
            ]

            suffix = ''
            if is_clean_msg1 in out and any(msg in out for msg in is_clean_msgs):
                suffix += ub.color_text('is clean', 'blue')
            if msg2 in out:
                suffix += ub.color_text('has untracked files', 'yellow')
            if any(msg in out for msg in needs_commit_msgs):
                suffix += ub.color_text('has changes', 'red')
        print(prefix + ' ' + suffix)

    def is_gitrepo(repo):
        gitdir = join(repo.dpath, '.git')
        return exists(gitdir) and isdir(gitdir)


def gitcmd(repo, command):
    try:
        import utool as ut
    except ImportError:
        print()
        print("************")
        try:
            print('repo=%s' % ut.color_text(repo.dpath, 'yellow'))
        except Exception:
            print('repo = %r ' % (repo,))
        os.chdir(repo)
        if command.find('git') != 0 and command != 'gcwip':
            command = 'git ' + command
        os.system(command)
        print("************")
    else:
        repo_ = Repo(dpath=repo)
        repo_.issue(command)


def gg_command(command):
    """ Runs a command on all of your PROJECT_REPOS """
    for repo in PROJECT_REPOS:
        if exists(repo) and exists(join(repo, '.git')):
            gitcmd(repo, command)
        else:
            print('No checkout for {}'.format(repo))


def clone_repos():
    for repodir, repourl in zip(PROJECT_REPOS, REPOS1.PROJECT_URLS):
        print('[git] checkexist: ' + repodir)
        if not exists(repodir):
            # repo = Repo(url=repourl, dpath=repodir)
            # if repo.owner() in :
            #     pass
            # repo.clone()
            mu.cd(dirname(repodir))
            mu.cmd('git clone ' + repourl)


# def clone_repos_(repo_urls, repo_dirs=None, checkout_dir=None):
#     """ Checkout every repo in repo_urls into checkout_dir """
#     # Check out any repo you dont have
#     if checkout_dir is not None:
#         repo_dirs = mu.get_repo_dirs(checkout_dir)
#     assert repo_dirs is not None, 'specify checkout dir or repo_dirs'
#     for repodir, repourl in zip(repo_dirs, repo_urls):
#         print('[git] checkexist: ' + repodir)
#         if not exists(repodir):
#             mu.cd(dirname(repodir))
#             mu.cmd('git clone ' + repourl)


def setup_develop_repos(repo_dirs):
    """ Run python installs """
    for repodir in repo_dirs:
        print('Installing: ' + repodir)
        mu.cd(repodir)
        assert exists('setup.py'), 'cannot setup a nonpython repo'
        mu.cmd('python setup.py develop')


def pull_repos(repo_dirs, repos_with_submodules=[]):
    for repodir in repo_dirs:
        print('Pulling: ' + repodir)
        mu.cd(repodir)
        assert exists('.git'), 'cannot pull a nongit repo'
        mu.cmd('git pull')
        reponame = split(repodir)[1]
        if reponame in repos_with_submodules or\
           repodir in repos_with_submodules:
            repos_with_submodules
            mu.cmd('git submodule init')
            mu.cmd('git submodule update')


def is_gitrepo(repo_dir):
    gitdir = join(repo_dir, '.git')
    return exists(gitdir) and isdir(gitdir)


if __name__ == '__main__':
    varargs = sys.argv[1:]
    if len(varargs) == 1 and varargs[0] == 'clone_repos':
        clone_repos()
    else:
        varargs2 = []
        for a in varargs:
            # hack
            if a == '==':
                break
            varargs2.append(a)

        command = ' '.join(varargs2)
        # Apply command to all repos
        gg_command(command)
