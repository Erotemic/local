#!/usr/bin/env python3
"""
Used by
$HOME/local/homelinks/helpers/git_helpers.sh
"""
import sys
import re
import os
from os.path import exists, join, dirname, split, isdir
import REPOS1


def cd(dir_):
    from os.path import expanduser, normpath, realpath
    dir_ = normpath(realpath(expanduser(dir_)))
    print('> cd ' + dir_)
    os.chdir(dir_)


def oscmd(command):
    """ Builtin Python Operating System Command """
    print('> ' + command)
    os.system(command)


class ChdirContext:
    """
    References:
        http://www.astropython.org/snippet/2009/10/chdir-context-manager
    """
    def __init__(self, dpath=None, stay=False, verbose=None):
        if verbose is None:
            verbose = True
        self.verbose = verbose
        self.stay = stay
        self.dpath = dpath
        self.curdir = os.getcwd()

    def __enter__(self):
        if self.dpath is not None:
            if self.verbose:
                print('[path.push] Change directory to %r' % (self.dpath,))
            os.chdir(self.dpath)
        return self

    def __exit__(self, type_, value, trace):
        if not self.stay:
            if self.verbose:
                print('[path.pop] Change directory to %r' % (self.curdir,))
            os.chdir(self.curdir)
        if trace is not None:
            if self.verbose:
                print('[util_path] Error in chdir context manager!: ' + str(value))
            return False  # return a falsey value on error


class Repo:
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
            pythoncmd = sys.executable
        repo.pythoncmd = pythoncmd

        if dpath is None and repo.url is not None and code_dir is not None:
            dpath = join(code_dir, repo.reponame)
        if dpath is not None:
            dpath = os.fspath(dpath)
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
            >>> repo = dirname(dirname(ub.__file__))
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
            for count, command in enumerate(command_list):
                if dry:
                    print(command)
                    continue
                if not sudo or WIN32:
                    cmdinfo = ub.cmd(command, verbose=1)
                    out, err, ret = ub.take(cmdinfo, ['out', 'err', 'ret'])
                else:
                    out, err, ret = ub.cmd('sudo ' + command)
                if verbose > 1:
                    print('ret(%d) = %r' % (count, ret,))
                if ret != 0:
                    if error == 'raise':
                        raise Exception('Failed command %r' % (command,))
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
            >>> repo = Repo(dpath=ub.truepath('.'))
            >>> result = repo.short_status()
            >>> print(result)
        """
        import ubelt as ub
        prefix = repo.dpath
        info = ub.cmd('git status', verbose=False, cwd=repo.dpath)
        out = info['out']
        out = out.replace('-', ' ')
        # parse git status
        is_clean_msg1 = 'Your branch is up to date with'
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

        branch_name = ub.cmd('git rev-parse --abbrev-ref HEAD', cwd=repo.dpath).stdout.strip()
        suffix += f' branch: {branch_name}'
        print(prefix + ' ' + suffix)

    def is_gitrepo(repo):
        gitdir = join(repo.dpath, '.git')
        return exists(gitdir) and isdir(gitdir)


def gitcmd(repo, command):
    try:
        import ubelt as ub
    except ImportError:
        print()
        print('WARNING: NO UBELT')
        print("************")
        try:
            print('repo=%s' % ub.color_text(repo.dpath, 'yellow'))
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


def bashcmd(repo, command):
    try:
        import ubelt as ub
    except ImportError:
        print()
        print('WARNING: NO UBELT')
        print("************")
        try:
            print('repo=%s' % ub.color_text(repo.dpath, 'yellow'))
        except Exception:
            print('repo = %r ' % (repo,))
        os.chdir(repo)
        os.system(command)
        print("************")
    else:
        ub.cmd(command, shell=True, cwd=repo, verbose=3)
        # repo_ = Repo(dpath=repo)
        # repo_.issue(command)


def gg_command(command):
    """ Runs a command on all of your PROJECT_REPOS """
    errors = []
    for repo in REPOS1.PROJECT_REPOS:
        try:
            if exists(repo) and exists(join(repo, '.git')):
                gitcmd(repo, command)
            else:
                raise Exception('No checkout for {}'.format(repo))
        except Exception as ex:
            errors.append((repo, ex))

    if errors:
        print('There were {} errors'.format(len(errors)))
        for repo, ex in errors:
            print('ex = {!r} in {!r}'.format(ex, repo))


def run_bash_command_in_repos(command):
    """ Runs a command on all of your PROJECT_REPOS """
    errors = []
    for repo in REPOS1.PROJECT_REPOS:
        try:
            if exists(repo) and exists(join(repo, '.git')):
                bashcmd(repo, command)
            else:
                raise Exception('No checkout for {}'.format(repo))
        except Exception as ex:
            errors.append((repo, ex))

    if errors:
        print('There were {} errors'.format(len(errors)))
        for repo, ex in errors:
            print('ex = {!r} in {!r}'.format(ex, repo))


def clone_repos():
    for repodir, repourl in zip(REPOS1.PROJECT_REPOS, REPOS1.PROJECT_URLS):
        print('[git] checkexist: ' + repodir)
        if not exists(repodir):
            # repo = Repo(url=repourl, dpath=repodir)
            # if repo.owner() in :
            #     pass
            # repo.clone()
            cd(dirname(repodir))
            oscmd('git clone ' + repourl)


def install_repos():
    import pathlib
    for repodir, repourl in zip(REPOS1.PROJECT_REPOS, REPOS1.PROJECT_URLS):
        print('[git] checkexist: ' + repodir)
        repodir = pathlib.Path(repodir)
        if (repodir / 'pyproject.toml').exists():
            # repo = Repo(url=repourl, dpath=repodir)
            # if repo.owner() in :
            #     pass
            # repo.clone()
            cd(repodir)
            oscmd('pip install -e .')


def dev_status():
    """
    Build a table to indicate how far development has gotten to get an
    indication of when we need to make a new release.
    """
    import ubelt as ub
    import parse
    import kwutil
    import git
    shortstat_pattern = parse.Parser('{num_files:d} files changed, {num_inserts:d} insertions(+), {num_deletes:d} deletions(-)')
    rows = []
    for repodir, repourl in zip(ub.ProgIter(REPOS1.PROJECT_REPOS), REPOS1.PROJECT_URLS):
        repo = git.Repo(repodir)
        row = {
            'repodir': repodir,
            'repo_name': ub.Path(repodir).name,
        }
        try:
            candidate_target_branches = []
            for branch in repo.branches:
                if branch.name in {'main', 'master'}:
                    candidate_target_branches.append(branch)

            if len(candidate_target_branches) > 1:
                raise NotImplementedError("both main and master exist, todo: determine which one is used or default to main")
            elif len(candidate_target_branches) == 0:
                raise NotImplementedError("no default branch")

            main_branch = candidate_target_branches[0]

            # https://stackoverflow.com/questions/2528111/how-can-i-calculate-the-number-of-lines-changed-between-two-commits-in-git
            out = ub.cmd(f'git diff {main_branch.name}..{repo.active_branch.name} --shortstat', cwd=repodir)
            result = shortstat_pattern.parse(out.stdout.strip())
            if result is None:
                shortstats = {
                    'num_files': 0,
                    'num_inserts': 0,
                    'num_deletes': 0,
                }
            else:
                shortstats = result.named

            # https://stackoverflow.com/questions/50452866/how-to-show-date-and-time-of-a-commit-by-hash
            active_date = kwutil.datetime.coerce(repo.active_branch.commit.committed_datetime)
            main_date = kwutil.datetime.coerce(main_branch.commit.committed_datetime)

            branch_delta = active_date - main_date
            total_delta = kwutil.datetime.coerce('now') - main_date

            # https://stackoverflow.com/questions/26413617/how-can-i-count-number-of-commits-between-two-branches
            out = ub.cmd(f'git rev-list --count {repo.active_branch.name}  ^{main_branch}', cwd=repodir)
            num_commits = int(out.stdout.strip())

            row.update({
                'main_branch': main_branch.name,
                'dev_branch': repo.active_branch.name,
                'dev_date': active_date,
                'dev_delta': branch_delta,
                'total_delta': total_delta,
                'main_date': main_date,
                'num_commits': num_commits,
                **shortstats
            })
            # print(f'{ub.urepr(row, nl=0)}')
        except Exception as ex:
            raise
            row['ex'] = ex
        rows.append(row)
    import pandas as pd
    df = pd.DataFrame(rows)
    df['num_changes'] = df['num_inserts'] + df['num_deletes']

    df = df.sort_values('total_delta')
    df = df.sort_values('num_changes')

    is_developing = df['main_branch'] != df['dev_branch']
    display_df = df.drop(['dev_date', 'main_branch', 'repodir'], axis=1)

    if 1:
        display_df['main_date'] = display_df['main_date'].map(lambda x: x.date())
        display_df['dev_delta'] = display_df['dev_delta'].map(lambda x: kwutil.timedelta.coerce(x).format(unit='day', precision=1))
        display_df['total_delta'] = display_df['total_delta'].map(lambda x: kwutil.timedelta.coerce(x).format(unit='day', precision=1))

    developing_df = display_df[is_developing]
    nonreleased_df = display_df[~is_developing]

    import rich
    rich.print(nonreleased_df.to_string())
    rich.print(developing_df.to_string())


def setup_develop_repos(repo_dirs):
    """ Run python installs """
    for repodir in repo_dirs:
        print('Installing: ' + repodir)
        cd(repodir)
        assert exists('setup.py') or exists('pyproject.toml'), 'cannot setup a nonpython repo'
        oscmd('python setup.py develop')


def pull_repos(repo_dirs, repos_with_submodules=[]):
    for repodir in repo_dirs:
        print('Pulling: ' + repodir)
        cd(repodir)
        assert exists('.git'), 'cannot pull a nongit repo'
        oscmd('git pull')
        reponame = split(repodir)[1]
        if reponame in repos_with_submodules or\
           repodir in repos_with_submodules:
            repos_with_submodules
            oscmd('git submodule init')
            oscmd('git submodule update')


def is_gitrepo(repo_dir):
    gitdir = join(repo_dir, '.git')
    return exists(gitdir) and isdir(gitdir)


def main():
    varargs = sys.argv[1:]

    if len(varargs) == 1 and varargs[0] == 'clone_repos':
        clone_repos()
    elif len(varargs) == 1 and varargs[0] == 'install_repos':
        install_repos()
    elif len(varargs) == 1 and varargs[0] == 'dev_status':
        dev_status()
    elif varargs[0] in {'cmd', 'command'}:
        assert len(varargs) > 1
        run_bash_command_in_repos(varargs[1:])
    elif len(varargs) == 1 and varargs[0] == 'list':
        for repodir, repourl in zip(REPOS1.PROJECT_REPOS, REPOS1.PROJECT_URLS):
            try:
                import ubelt as ub
                repodir = ub.Path(repodir).shrinkuser()
            except Exception:
                ...
            print(f'- {{"dpath": {repodir}, "url": {repourl}}}')
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


if __name__ == '__main__':
    """
    python ~/local/init/util_git1.py list
    python ~/local/init/util_git1.py clone_repos
    python ~/local/init/util_git1.py dev_status
    """
    main()
