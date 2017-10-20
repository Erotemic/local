#!/usr/bin/env python
# -*- coding: utf-8 -*-
from __future__ import print_function, unicode_literals
import os
import git
import email.utils
import ubelt as ub


def print_exc(exc_info=None):
    """
    Example:
        >>> try:
        >>>     raise Exception('foobar')
        >>> except Exception as ex:
        >>>     import sys
        >>>     exc_info = sys.exc_info()
        >>>     print_exc(exc_info)
    """
    import sys
    import traceback
    if exc_info is None:
        exc_info = sys.exc_info()
    tbtext = ''.join(traceback.format_exception(*exc_info))

    colored = False
    if colored:
        import ubelt as ub
        def color_text(text):
            ub.color_text(text)
        def color_pytb(text):
            return ub.highlight_code(text, lexer_name='pytb', stripall=True)
    else:
        def color_text(text):
            return text
        def color_pytb(text):
            return text

    lines = [
        '',
        color_text('┌───────────'),
        color_text('│ EXCEPTION:'),
        '',
        color_pytb(tbtext),
        color_text('└───────────'),
        ''
    ]
    text = '\n'.join(lines)
    print(text)


class Streak(ub.NiceRepr):
    def __init__(self, child, _streak=None):
        # If child is None, then this is the future-most streak
        self.child = child
        if _streak is None:
            _streak = []
        self._streak = _streak

    def __iter__(self):
        return iter(self._streak)

    def __nice__(self):
        abbrev = 8
        num = len(self)
        if num == 0:
            return 'num={}'.format(num)
        elif num == 1:
            return 'num={}, {}'.format(num, self.start.hexsha[:abbrev])
        elif num >= 2:
            return 'num={}, {}^..{}'.format(
                num, self.start.hexsha[:abbrev], self.stop.hexsha[:abbrev])

    def __len__(self):
        return len(self._streak)

    def append(self, commit):
        self._streak.append(commit)

    @property
    def before_start(self):
        assert len(self.start.parents) == 1
        return self.start.parents[0]

    @property
    def after_stop(self):
        return self.child

    @property
    def start(self):
        return self._streak[-1]

    @property
    def stop(self):
        return self._streak[0]


def find_chain(head, authors=None):
    """
    Find a chain of commits starting at the HEAD.  If `authors` is specified
    the commits must be from one of these authors.

    The term chain is used in the graph-theory sense. It is a list of commits
    where all non-endpoint commits have exactly one parent and one child.

    Args:
        head (git.Commit): starting point
        authors (set): valid authors

    Example:
        >>> # assuming you are in a git repo
        >>> chain = find_chain(git.Repo().head.commit)
    """
    chain = []
    commit = head
    while len(commit.parents) == 1:
        if authors is not None and commit.author.name not in authors:
            break
        chain.append(commit)
        commit = commit.parents[0]
    return chain


def find_streaks(chain, authors, timedelta=None):
    """
    Given a chain, finds subchains (called streaks) that have the same author
    and are within a timedelta threshold of each other.

    Args:
        chain (list of commits): from `find_chain`
        authors (set): valid authors
        timedelta (float): minimum time between commits in seconds
    """
    if len(chain) == 0:
        raise ValueError('No continuous commits exist')

    # Find contiguous streaks
    streaks = []
    streak_ids = []

    def continues_streak(streak, commit):
        if commit.author.name not in authors:
            return False
        if len(streak) == 0:
            return True
        if streak.start.message == commit.message:
            if timedelta is not None:
                # only continue on streaks within the timedelta
                datetime1 = streak.stop.authored_datetime
                datetime2 = commit.authored_datetime
                if timedelta == 'sameday':
                    date1 = datetime1.date()
                    date2 = datetime2.date()
                    if date1 == date2:
                        return True
                else:
                    if abs(datetime2 - datetime1).seconds < timedelta:
                        return True
        return False

    LEN_THRESH = 2
    child = None
    streak = Streak(child, [])
    for commit in chain:
        if continues_streak(streak, commit):
            streak.append(commit)
        else:
            # Streak is broken
            if len(streak) < LEN_THRESH:
                streak_ids.extend([None] * max(1, len(streak)))
            else:
                streaks.append(streak)
                streak_ids.extend([len(streaks)] * len(streak))
            child = commit
            streak = Streak(child, [])
    return streaks


def checkout_temporary_branch(repo, suffix='-temp-script-branch'):
    """
    Changes to a temporary branch so we don't messup anything on the main one.

    If the temporary branch exists, it is deleted, so make sure you choose your
    suffix so that it never conflicts with any real branches.
    """
    orig_branchname = repo.active_branch.name
    if orig_branchname.endswith(suffix):
        raise Exception('Already in temp branch {}'.format(orig_branchname))
    temp_branchname = repo.active_branch.name + suffix
    print('Switching to temporary branch: {}'.format(temp_branchname))

    try:
        repo.git.checkout('HEAD', b=temp_branchname)
    except git.GitCommandError as ex:
        err = str(ex)
        if 'branch named' in err and 'already exists' in err:
            print('... but it already exists')
            print('... deleting old temporary branch')
            # Delete the old temp branch
            repo.git.branch(D=temp_branchname)
            repo.git.checkout('HEAD', b=temp_branchname)
        else:
            raise
    assert repo.active_branch.name == temp_branchname
    return temp_branchname


def commits_between(repo, start, stop):
    """
    Args:
        start (git.Commit): toplogically (chronologically) first commit
        stop (git.Commit): toplogically (chronologically) last commit

    Returns:
        list of git.Commit: between commits

    References:
        https://stackoverflow.com/questions/18679870/list-commits-between-2-commit-hashes-in-git
        https://stackoverflow.com/questions/462974/what-are-the-differences-between-double-dot-and-triple-dot-in-git-com

    Warning:
        this gets messy any node on the path between <start> and <stop> has
        more than one parent that is not on a path between <start> and <stop>

    Notes:
        As a prefix: the carrot (^A) removes commits reachable from A.
        As a suffix: the carrot (A^) references the 1st parent of A
        Furthermore:
            (A^n) references the n-th parent of A
            (A~n) references the n-th ancestor of A
            The tilde and carrot can be chained.
            A^^ = A~2 = the grandparent of A

        Reachable means everything in the past.

        PAST...............................PRESENT
        <p1> -- <start> -- <A> -- <B> -- <stop>
                /
        <p2> __/

    Example:
        >>> repo = git.Repo()
        >>> stop = repo.head.commit
        >>> start = stop.parents[0].parents[0].parents[0].parents[0]
        >>> commits = commits_between(repo, start, stop)
        >>> assert commits[0] == start
        >>> assert commits[-1] == stop
        >>> assert len(commits) == 4
    """
    import binascii
    argstr = '{start}^..{stop}'.format(start=start, stop=stop)
    hexshas = repo.git.rev_list(argstr).splitlines()
    binshas = [binascii.unhexlify(h) for h in hexshas]
    commits = [git.Commit(repo, b) for b in binshas]
    return commits


class RollbackError(Exception):
    pass


def _squash_between(repo, start, stop, dry=False):
    """
    inplace squash between, use external function that sets up temp branches to
    use this directly from the commandline.
    """
    assert len(start.parents) == 1
    assert start.authored_datetime < stop.authored_datetime
    assert repo.is_ancestor(ancestor_rev=start, rev=stop)

    # Do RFC2822
    # ISO_8601 = '%Y-%m-%d %H:%M:%S %z'  # NOQA
    # ts_start = start.authored_datetime.strftime(ISO_8601)
    # ts_stop = stop.authored_datetime.strftime(ISO_8601)
    ts_start = email.utils.format_datetime(start.authored_datetime)
    ts_stop = email.utils.format_datetime(stop.authored_datetime)

    # if ts_start.split()[0:4] == ts_stop.split()[0:4]:
    if start.authored_datetime.date() == stop.authored_datetime.date():
        ts_stop_short = ' '.join(ts_stop.split()[4:])
    else:
        ts_stop_short = ts_stop

    # Construct a new message
    commits = commits_between(repo, start, stop)
    messages = [commit.message for commit in commits]
    # messages = [commit.message for commit in streak._streak]
    unique_messages = ub.unique(messages)
    new_msg = '\n'.join(unique_messages)
    if new_msg == 'wip\n':
        new_msg = new_msg.strip('\n') + ' - '
    new_msg += 'Squashed {} commits from <{}> to <{}>\n'.format(
        len(commits), ts_start, ts_stop_short)

    print(' * Creating new commit with message:')
    print(new_msg)

    old_head = repo.commit('HEAD')
    assert (stop == old_head or repo.is_ancestor(ancestor_rev=stop,
                                                 rev=old_head))

    if not dry:
        # ------------------
        # MODIFICATION LOGIC
        # ------------------
        # Go back in time to the sequence stopping point
        repo.git.reset(stop.hexsha, hard=True)
        # Undo commits from start to stop by softly reseting to just before the start
        before_start = start.parents[0]
        print(' * reseting to before <start>')
        repo.git.reset(before_start.hexsha, soft=True)

        # Commit the changes in a new squashed commit and presever authored date
        print(' * creating one commit with all modifications up to <stop>')
        repo.index.commit(new_msg, author_date=ts_stop)

        # If <stop> was not the most recent commit, we need to take those back on
        if stop != old_head:
            # Copy commits following the end of the streak in front of our new commit
            print(' * fixing up the head')
            try:
                # above_commits = commits_between(repo, stop, old_head)
                # print('above_commits = {}'.format(ub.repr2(above_commits, si=True)))
                above = stop.hexsha + '..' + old_head.hexsha
                # above = streak.child.hexsha + '..' + old_head
                repo.git.cherry_pick(above, allow_empty=True)
            except git.GitCommandError:
                print('ERROR: need to roll back')
                raise
        else:
            print(' * already at the head, no need to fix')


def squash_streaks(authors, timedelta='sameday', inplace=False,
                   auto_rollback=True, dry=False):
    """
    Squashes consecutive commits with the same message that occurred on the
    same day.

    Args:
        inplace (bool): if True changes will be applied directly to the current
            branch otherwise a temporary branch will be created. Then you must
            manually reset the current branch to this branch and delete the
            temp branch.
    """
    # authors = {'joncrall', 'Jon Crall'}

    repo = git.Repo(os.getcwd())
    orig_branch_name = repo.active_branch.name

    head = repo.commit('HEAD')

    chain = find_chain(head, authors=authors)
    print('Found chain of length %r' % (len(chain)))

    streaks = find_streaks(chain, authors=authors, timedelta=timedelta)
    print('Found %r streaks' % (len(streaks)))

    # Switch to a temp branch before we start working
    if not dry:
        temp_branchname = checkout_temporary_branch(repo, '-squash-temp')
    else:
        temp_branchname = None

    try:
        for streak in ub.ProgIter(streaks, 'squashing', verbose=3):
            print('Squashing streak = %r' % (str(streak),))
            # Start is the commit further back in time
            _squash_between(repo, streak.start, streak.stop, dry=dry)
    except Exception as ex:
        print_exc(ex)
        print('ERROR: squash_streaks failed.')
        if not dry and auto_rollback:
            print('ROLLING BACK')
            repo.git.checkout(orig_branch_name)
            # repo.git.branch(D=temp_branchname)
        print('You can debug the difference with:')
        print('    gitk {} {}'.format(orig_branch_name, temp_branchname))
        return

    if dry:
        print('Finished. did nothing')
    elif inplace:
        # Copy temp branch back over original
        repo.git.checkout(orig_branch_name)
        repo.git.reset(temp_branchname, hard=True)
        repo.git.branch(D=temp_branchname)
        print('Finished. Now you should force push the branch back to the server')
    else:
        # Go back to the original branch
        repo.git.checkout(orig_branch_name)
        print('Finished')
        print('The squashed branch is: {}'.format(temp_branchname))
        print('To automatically accept changes run with --inplace')
        print('You can inspect the difference with:')
        print('    gitk {} {}'.format(orig_branch_name, temp_branchname))
        print('Finished. Now you must manually clean this branch up.')


# commandline entry point
def git_squash_streaks():
    """
    git-squash-streaks

    Usage:
        TODO
    """
    print('git_squash_streaks')

    inplace = ub.argflag('--inplace')
    auto_rollback = not ub.argflag('--no-rollback')
    authors = ub.argval('--authors', default=None)

    # Do a dry-run by default
    dry = True
    if ub.argflag(('--force', '-f')):
        dry = False
    if ub.argflag(('--dry-run', '--dry', '-n')):
        dry = True

    if dry:
        print('DRY RUN')

    if authors is None:
        authors = {git.Git().config('user.name')}
        # HACK: for me. todo user alias
        # SEE: .mailmap file to auto extract?
        # https://git-scm.com/docs/git-shortlog#_mapping_authors
        """
        # .mailmap
        # Proper Name <proper@email.xx> Commit Name <commit@email.xx>
        Jon Crall <jon.crall@kitware.com> joncrall <jon.crall@kitware.com>
        Jon Crall <jon.crall@kitware.com> jon.crall <jon.crall@kitware.com>
        Jon Crall <jon.crall@kitware.com> Jon Crall <erotemic@gmail.com>
        Jon Crall <jon.crall@kitware.com> joncrall <erotemic@gmail.com>
        Jon Crall <jon.crall@kitware.com> joncrall <crallj@rpi.edu>
        Jon Crall <jon.crall@kitware.com> Jon Crall <crallj@rpi.edu>
        """
        if {'joncrall', 'Jon Crall', 'jon.crall'}.intersection(authors):
            authors.update({'joncrall', 'Jon Crall'})
    else:
        authors = {a.strip() for a in authors.split(',')}

    print('authors = {!r}'.format(authors))
    squash_streaks(authors=authors, inplace=inplace,
                   auto_rollback=auto_rollback, dry=dry)

    if dry:
        print('Finished the dry run. Use -f to force')

if __name__ == '__main__':
    git_squash_streaks()
