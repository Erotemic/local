#!/usr/bin/env python
# PYTHON_ARGCOMPLETE_OK
# -*- coding: utf-8 -*-
"""
Requirements:
    pip install ubelt
    pip install GitPython
"""
from __future__ import print_function, unicode_literals
import sys
import re
import os
import git
import warnings
import email.utils
import ubelt as ub
import itertools as it


EXPERIMENTAL_PSEUDO_CHAIN = 0
EXPERIMENTAL_REBASE = 0


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
    import traceback
    if exc_info is None:
        exc_info = sys.exc_info()

    tbtext = ''.join(traceback.format_exception(*exc_info))

    colored = False
    if colored:
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


def find_pseudo_chain(head, oldest_commit=None, preserve_tags=True):
    """
    Finds start and end points that can be safely squashed between

    Example:
        >>> import sys, ubelt
        >>> sys.path.append(ubelt.expandpath('~/local/git_tools'))
        >>> from git_squash_streaks import *  # NOQA
        >>> repo = git.Repo()
        >>> head = repo.commit('HEAD')
        >>> pseudo_chain = find_pseudo_chain(head)
    """
    import networkx as nx

    graph = git_nx_graph(head, oldest_commit, preserve_tags=preserve_tags)
    # for idx, node in enumerate(nx.dfs_preorder_nodes(graph)):
    #     print('{}, {!r}'.format(idx, graph.nodes[node]['commit'].message))

    sinks = {node for node in graph.nodes if len(graph.succ[node]) == 0}
    sources = {node for node in graph.nodes if len(graph.pred[node]) == 0}
    assert len(sources) == 1
    assert len(sinks) == 1

    source = ub.peek(sources)
    sink = ub.peek(sinks)

    # all_paths = list(nx.all_simple_paths(graph, source, sink))
    # all_paths = list(map(ub.oset, all_paths))
    # common_path = ub.oset.intersection(*all_paths)

    ugraph = nx.to_undirected(graph)

    # These are all the commits that break chains

    branchy_bunches = [cc for cc in nx.algorithms.connectivity.k_edge_components(ugraph, 2) if len(cc) > 1]

    collapsed = nx.algorithms.connectivity.edge_augmentation.collapse(graph, branchy_bunches)
    uncollapsed = ub.invert_dict(collapsed.graph['mapping'], unique_vals=False)
    collapsed_nodes = [k for k, v in uncollapsed.items() if len(v) > 1]

    # Having a start and endpoint for each branchy section will let us treat
    # the rest of the git history as a chain and operate within it
    bunch_terminals = []
    for node in collapsed_nodes:
        terminals = []
        collapsed_group = uncollapsed[node]
        children = collapsed.pred[node]
        parents = collapsed.succ[node]

        assert len(children) <= 1
        assert len(parents) <= 1

        for child in children:
            candidate_s = uncollapsed[child]
            found = []
            for u, v in it.product(collapsed_group, candidate_s):
                if ugraph.has_edge(u, v):
                    found.append(u)
            assert len(found) == 1
            terminals.append(found[0])

        for parent in parents:
            candidate_t = uncollapsed[parent]
            found = []
            for u, v in it.product(collapsed_group, candidate_t):
                if ugraph.has_edge(u, v):
                    found.append(u)
            assert len(found) == 1
            terminals.append(found[0])
        bunch_terminals.append(terminals)

    # There should be exactly one path between the start and the first terminal
    # Likewise, if we skip all nodes between terminals a and b, there should
    # only be one path "our pseudo-chain" between them
    src = source
    pseudo_chain_parts = []
    for terminal_a, terminal_b in bunch_terminals:
        dst = terminal_a
        all_paths = list(nx.all_simple_paths(graph, src, dst))
        assert len(all_paths) == 1
        path = all_paths[0]
        pseudo_chain_parts.append(path)
        src = terminal_b
    # Finally link to the sink
    dst = sink
    all_paths = list(nx.all_simple_paths(graph, src, dst))
    assert len(all_paths) == 1
    path = all_paths[0]
    pseudo_chain_parts.append(path)

    repo = head.repo
    pseudo_chain = [repo.commit(sha) for sha in ub.flatten(pseudo_chain_parts)]
    return pseudo_chain


def git_nx_graph(head, oldest_commit, preserve_tags=False):
    """
    Example:
        >>> import sys, ubelt
        >>> sys.path.append(ubelt.expandpath('~/local/git_tools'))
        >>> from git_squash_streaks import *  # NOQA
        >>> #head = git.Repo().head.commit
        >>> repo = git.Repo()
        >>> head = repo.commit('HEAD')
        >>> oldest_commit = 'master'
        >>> oldest_commit = None
        >>> graph = git_nx_graph(head, oldest_commit)

    """
    repo = head.repo

    if oldest_commit:
        stop_object = repo.commit(oldest_commit)
    else:
        stop_object = None

    if preserve_tags:
        tags = head.repo.tags
        if isinstance(preserve_tags, (set, list, tuple)):
            tags = {tag for tag in tags if tag.name in preserve_tags}
        tagged_hexshas = {tag.commit.hexsha for tag in tags}
    else:
        tagged_hexshas = set()

    def neighbors(s):
        return iter(s.parents)

    def git_dfs_edges(source, depth_limit=None):
        nodes = [source]
        visited = set()
        if depth_limit is None:
            depth_limit = float('inf')
        for start in nodes:
            if start.hexsha in visited:
                continue
            visited.add(start.hexsha)
            stack = [(start, depth_limit, neighbors(start))]
            while stack:
                parent, depth_now, children = stack[-1]
                try:
                    child = next(children)
                    if stop_object is not None and stop_object.hexsha == parent.hexsha:
                        continue

                    if preserve_tags:
                        # If we are preserving tags, break the chain once we find one
                        if parent.hexsha in tagged_hexshas:
                            break
                    yield parent, child
                    if child.hexsha not in visited:
                        visited.add(child.hexsha)
                        if depth_now > 1:
                            stack.append((child, depth_now - 1, neighbors(child)))
                except StopIteration:
                    stack.pop()

    source = head
    edges = list(git_dfs_edges(source))

    import networkx as nx
    graph = nx.DiGraph()
    for e1, e2 in edges:
        graph.add_node(e1.hexsha, commit=e1)
        graph.add_node(e2.hexsha, commit=e2)
        graph.add_edge(e1.hexsha, e2.hexsha)

    if 0:
        nx.set_node_attributes(graph, values='', name='label')
        for node in graph.nodes:
            node_data = graph.nodes[node]
            node_data['commit'] = repo.commit(node)
            node_data['label'] = node_data['commit'].message[0:10]
        import kwplot
        kwplot.autompl()
        from graphid.util import show_nx
        show_nx(graph, layoutkw={'prog': 'dot'}, with_labels=False, arrow_width=1, fnum=1)
        nx.draw_networkx(graph)

    return graph


def find_chain(head, authors=None, preserve_tags=True, oldest_commit=None):
    """
    Find a chain of commits starting at the HEAD.  If `authors` is specified
    the commits must be from one of these authors.

    The term chain is used in the graph-theory sense. It is a list of commits
    where all non-endpoint commits have exactly one parent and one child.

    TODO:
        - [ ] allow a chain to include branches if all messages on all branches
              conform to the chain pattern (e.g. wip)


        def search(node, current_path):
            if current_path:
                pass

            child_paths = []
            for parent in node.parents:
                path = search(parent, current_path)
                child_paths.append(path)

            if len(child_paths) == 0:
                pass
            if len(child_paths) == 1:
                # normal one parent case
                pass
            else:
                pass
                # Branching case
                # ACCEPT THE BRANCHING PATHS IF:
                #  * PARENT OF ALL PATHS HAVE A COMMON ENDPOINT
                #  * HANDLE CASE WHERE PATHS OVERLAPS

    Args:
        head (git.Commit): starting point

        authors (set): valid authors

        preserve_tags (bool, default=True): if True the chain is not allowed
            to extend past any tags. If a set, then we will not procede past
            any tag with a name in the set.

    Example:
        >>> # assuming you are in a git repo
        >>> chain = find_chain(git.Repo().head.commit)
    """
    chain = []
    commit = head

    repo = head.repo

    if oldest_commit is not None:
        stop_object = repo.commit(oldest_commit)
    else:
        stop_object = None

    if preserve_tags:
        tags = head.repo.tags
        if isinstance(preserve_tags, (set, list, tuple)):
            tags = {tag for tag in tags if tag.name in preserve_tags}
        tagged_hexshas = {tag.commit.hexsha for tag in tags}
    else:
        tagged_hexshas = set()

    while len(commit.parents) <= 1:

        if authors is not None and commit.author.name not in authors:
            break
        if len(commit.parents) == 0:
            # Hmm it seems that including the initial commit in a chain causes
            # problems, issue a warning
            warnings.warn(ub.codeblock(
                '''
                This script contains a known issue, where the initial commit is
                not included when it "should" be part of a streak.

                To squash the entire branch, use the following workaround:
                    git branch -m master old_master
                    git checkout --orphan master
                    git commit -am "initial commit"
                    git branch -D old_master
                '''))

            break

        if stop_object is not None:
            if stop_object == commit:
                print('Stop chain at stop_object = {!r}'.format(stop_object))
                break

        if preserve_tags:
            # If we are preserving tags, break the chain once we find one
            if commit.hexsha in tagged_hexshas:
                break

        chain.append(commit)
        if len(commit.parents) > 0:
            commit = commit.parents[0]
        else:
            break

    return chain


def find_streaks(chain, authors=None, timedelta='sameday', pattern=None):
    """
    Given a chain, finds subchains (called streaks) that have the same author
    and are within a timedelta threshold of each other.

    Args:
        chain (list of commits): from `find_chain`
        authors (set): valid authors
        timedelta (float or str): minimum time between commits in seconds
            or a categorical value such as 'sameday' or 'alltime'
        pattern (str): instead of squashing messages with the same name, squash
            only if they match this pattern (Default: None), None means
            the consecutive messages should match.
    """
    if len(chain) == 0:
        raise ValueError('No continuous commits exist')

    if timedelta is None:
        timedelta = 'none'

    def matches_time(streak, commit):
        if timedelta == 'alltime' or str(timedelta).lower() == 'none':
            return True
        elif timedelta is not None:
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
        else:
            raise ValueError('timedelta = {!r}'.format(timedelta))

    def matches_message(streak, commit):
        if pattern is None:
            flag = streak.start.message == commit.message
            # flag |= streak.start.message.strip() == commit.message.strip()
        else:
            flag = re.match(pattern, commit.message) is not None
        return flag

    def continues_streak(streak, commit):
        if authors is not None:
            if commit.author.name not in authors:
                return False

        if len(commit.parents) > 1:
            return False

        if len(streak) == 0:
            return True

        if matches_message(streak, commit):
            if matches_time(streak, commit):
                return True
        return False

    LEN_THRESH = 2
    # Find contiguous streaks
    streaks = []

    # New fixed logic, with lookahead, much easier to follow.
    prev = None
    streak = None

    # Look at each commit and its successor
    for commit, next_commit in ub.iter_window(it.chain(chain, [None]), size=2):
        print('CHECK commit.message = {!r}, {!r}'.format(commit.message, commit))
        if streak is None:
            streak = Streak(prev, [])
            streak.append(commit)
            if next_commit is not None and continues_streak(streak, next_commit):
                # If the next commit will start a streak, then initialize
                print(ub.color_text('... new candidate streak, len={}'.format(len(streak)), 'yellow'))
            else:
                # Don't even bother unless we will start a streak
                print(ub.color_text('... no streak', 'red'))
                streak = None
        else:
            # If we have started a streak, then this commit MUST continue
            # the current streak because we already checked it last
            # iteration when it was the next commit.
            streak.append(commit)
            print(ub.color_text('... add to streak, len={}'.format(len(streak)), 'blue'))

            # Check if the next commit will break the streak, and either
            # accept or reject the current streak
            if next_commit is None or not continues_streak(streak, next_commit):
                if len(streak) < LEN_THRESH:
                    print(ub.color_text('... Next commit breaks streak of len {}, reject'.format(len(streak)), 'red'))
                else:
                    print(ub.color_text('... Next commit breaks streak of len {}, accept'.format(len(streak)), 'green'))
                    streaks.append(streak)
                streak = None
        prev = commit
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
        https://stackoverflow.com/questions/18679870/commits-between-2-hashes
        https://stackoverflow.com/questions/462974/diff-double-and-triple-dot

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


def _squash_between(repo, start, stop, dry=False, verbose=True):
    """
    inplace squash between, use external function that sets up temp branches to
    use this directly from the commandline.
    """
    if len(start.parents) != 1:
        raise AssertionError('cant handle')
    # assert start.authored_datetime < stop.authored_datetime
    if not repo.is_ancestor(ancestor_rev=start, rev=stop):
        raise AssertionError('cant handle')

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
    summary = '\n'.join(unique_messages)
    if summary == 'wip\n':
        summary = summary.strip('\n')

    if False:
        new_msg = '{} - Squashed {} commits from <{}> to <{}>\n'.format(
            summary, len(commits), ts_start, ts_stop_short)
    else:
        new_msg = '{} - Squashed {} commits'.format(summary.strip(), len(commits))

    if verbose:
        print(' * Creating new commit with message:')
        print(new_msg)

    old_head = repo.commit('HEAD')
    if (stop != old_head and not repo.is_ancestor(ancestor_rev=stop, rev=old_head)):
        raise Exception('stop={} is not an ancestor of old_head={}'.format(
            stop, old_head))

    if not dry:
        # ------------------
        # MODIFICATION LOGIC
        # ------------------
        # Go back in time to the sequence stopping point
        repo.git.reset(stop.hexsha, hard=True)
        # Undo commits from start to stop by softly reseting to just before the start
        before_start = start.parents[0]
        if verbose:
            print(' * reseting to before <start>: {}'.format(before_start.hexsha))
        repo.git.reset(before_start.hexsha, soft=True)

        # Commit the changes in a new squashed commit and presever authored date
        if verbose:
            print(' * creating one commit with all modifications up to <stop>')
        repo.index.commit(new_msg, author_date=ts_stop)

        # If <stop> was not the most recent commit, we need to take those back on
        if stop != old_head:
            # Copy commits following the end of the streak in front of our new commit
            if verbose:
                print(' * fixing up the head')
            try:
                above = stop.hexsha + '..' + old_head.hexsha
                if 0:
                    above_commits = commits_between(repo, stop, old_head)
                    print('above_commits = {}'.format(ub.repr2(above_commits, si=True)))
                    print('above = {!r}'.format(above))

                if EXPERIMENTAL_REBASE:
                    # above = streak.child.hexsha + '..' + old_head
                    # repo.git.cherry_pick(above, allow_empty=True, mainline=1)

                    # git rebase --onto master topicA topicB
                    # git rebase --onto <current> <stop> <old_head>
                    repo.git.rebase(stop, old_head, preserve_merges=True, onto='HEAD')

                    # git rebase --preserve-merges --onto dev/0.9.2-squash-temp 52f34a11b837d27f9979d002391c0d8d6bee4957 9e2c03c0df13d9ce3c74aa0ff619abe21afe51b1

                    # repo.git.rebase(above, allow_empty=True, mainline=1)
                else:
                    # Fixme, do this with rebase to preserve merges?
                    repo.git.cherry_pick(above, allow_empty=True)
                # sys.exit(1)
            except git.GitCommandError:
                print('ERROR: need to roll back')
                raise
        else:
            if verbose:
                print(' * already at the head, no need to fix')


def do_tags(verbose=True, inplace=False, dry=True, auto_rollback=False):
    if verbose:
        if dry:
            print('squashing streaks (DRY RUN)')
        else:
            print('squashing streaks')
        # print('authors = {!r}'.format(authors))

    # If you are in a repo subdirectory, find the repo root
    cwd = os.getcwd()
    repodir = cwd
    while True:
        if os.path.exists(os.path.join(repodir, '.git')):
            break
        newpath = os.path.dirname(repodir)
        if newpath == repodir:
            raise git.exc.InvalidGitRepositoryError(cwd)
        repodir = newpath

    repo = git.Repo(repodir)
    orig_branch_name = repo.active_branch.name

    # head = repo.commit('HEAD')
    info = ub.cmd('git tag -l --sort=v:refname', verbose=3)

    info2 = ub.cmd('git show-ref --tags', verbose=3)
    tag_to_hash = {}
    for line in info2['out'].splitlines():
        if line:
            hashtext, tags = line.split(' ')
            tag = tags.replace('refs/tags/', '')
            tag_to_hash[tag] = hashtext
    print('tag_to_hash = {!r}'.format(tag_to_hash))

    tag_order = [line for line in info['out'].splitlines() if line]
    custom_streaks = list(ub.iter_window(tag_order, 2))
    print('Forcing hacked steaks')
    print('custom_streaks = {!r}'.format(custom_streaks))

    streaks = []
    for custom_streak in custom_streaks:
        print('custom_streak = {!r}'.format(custom_streak))
        assert len(custom_streak) == 2
        hash_a = tag_to_hash[custom_streak[0]]
        hash_b = tag_to_hash[custom_streak[1]]
        a = repo.commit(hash_a)
        b = repo.commit(hash_b)
        if repo.is_ancestor(ancestor_rev=a, rev=b):
            a, b = b, a
        # assert repo.is_ancestor(ancestor_rev=b, rev=a)
        streak = Streak(a, _streak=[a, b])

        if len(streak.start.parents) != 1:
            print('WARNING: cannot include streak = {!r}'.format(streak))
            continue
        # assert start.authored_datetime < stop.authored_datetime
        if not repo.is_ancestor(ancestor_rev=streak.start, rev=streak.stop):
            print('WARNING: cannot include streak = {!r}'.format(streak))
            continue
            # raise AssertionError('cant handle')
        streaks.append(streak)

    if verbose:
        print('Found {!r} streaks'.format(len(streaks)))

    # Switch to a temp branch before we start working
    if not dry:
        temp_branchname = checkout_temporary_branch(repo, '-squash-temp')
    else:
        temp_branchname = None

    try:
        for streak in ub.ProgIter(streaks, 'squashing', verbose=3 * verbose):
            if verbose:
                print('Squashing streak = %r' % (str(streak),))
            # Start is the commit further back in time
            _squash_between(repo, streak.start, streak.stop, dry=dry,
                            verbose=verbose)
    except Exception:
        print_exc(sys.exc_info())
        print('ERROR: squash_streaks failed.')
        if not dry and auto_rollback:
            print('ROLLING BACK')
            repo.git.checkout(orig_branch_name)
            # repo.git.branch(D=temp_branchname)
        print('You can debug the difference with:')
        print('    gitk {} {}'.format(orig_branch_name, temp_branchname))
        return

    if dry:
        if verbose:
            print('Finished. did nothing')
    elif inplace:
        # Copy temp branch back over original
        repo.git.checkout(orig_branch_name)
        repo.git.reset(temp_branchname, hard=True)
        repo.git.branch(D=temp_branchname)
        if verbose:
            print('Finished. Now you should force push the branch back to the server')
    else:
        # Go back to the original branch
        repo.git.checkout(orig_branch_name)
        if verbose:
            print('Finished')
            print('The squashed branch is: {}'.format(temp_branchname))
            print('You can inspect the difference with:')
            print('    gitk {} {}'.format(orig_branch_name, temp_branchname))
            print('Finished. Now you must manually clean this branch up.')
            print('Or, to automatically accept changes run with --inplace')


def squash_streaks(authors, timedelta='sameday', pattern=None,
                   inplace=False,
                   auto_rollback=True, dry=False, verbose=True,
                   custom_streak=None, preserve_tags=True, oldest_commit=None):
    """
    Squashes consecutive commits that meet a specified criteiron.

    Args:
        authors (set): "level-set" of authors who's commits can be squashed
            together.

        timedelta (str or int): strategy mode or max number of seconds to
            determine how far appart two commits can be before they are
            squashed. (Default: 'sameday').
            Valid values: ['sameday', 'alltime', 'none', <n_seconds:float>]

        pattern (str): instead of squashing messages with the same name, squash
            only if they match this pattern (Default: None). Default of None
            means that squash two commits if they have the same message.

        inplace (bool): if True changes will be applied directly to the current
            branch otherwise a temporary branch will be created. Then you must
            manually reset the current branch to this branch and delete the
            temp branch. (Default: False)

        auto_rollback (bool): if True the repo will be reset to a clean state
            if any errors occur. (Default: True)

        dry (bool): if True this only executes a dry run, that prints the
            chains that would be squashed (Default: False)

        verbose (bool, default=True): verbosity flag

        custom_streak(tuple): hack, specify two commits to explicitly squash
            only this streak is used. We do not automatically check for others.

        preserve_tags (bool, default=True): if True the chain is not allowed
            to extend past any tags. If a set, then we will not procede past
            any tag with a name in the set.

        oldest_commit (str, default=None): if specified we will only squash
            commits toplogically after this commit in the graph.
    """
    if verbose:
        if dry:
            print('squashing streaks (DRY RUN)')
        else:
            print('squashing streaks')
        print('authors = {!r}'.format(authors))

    # If you are in a repo subdirectory, find the repo root
    cwd = os.getcwd()
    repodir = cwd
    while True:
        if os.path.exists(os.path.join(repodir, '.git')):
            break
        newpath = os.path.dirname(repodir)
        if newpath == repodir:
            raise git.exc.InvalidGitRepositoryError(cwd)
        repodir = newpath

    repo = git.Repo(repodir)
    orig_branch_name = repo.active_branch.name

    head = repo.commit('HEAD')

    if custom_streak:
        print('custom_streak = {!r}'.format(custom_streak))
        print('Forcing hacked steak')

        assert len(custom_streak) == 2
        a = repo.commit(custom_streak[0])
        b = repo.commit(custom_streak[1])
        if repo.is_ancestor(ancestor_rev=a, rev=b):
            a, b = b, a
        # assert repo.is_ancestor(ancestor_rev=b, rev=a)
        streaks = [Streak(a, _streak=[a, b])]
    else:

        if EXPERIMENTAL_PSEUDO_CHAIN:
            chain = find_pseudo_chain(
                    head,
                    preserve_tags=preserve_tags,
                    oldest_commit=oldest_commit)
        else:
            chain = find_chain(head, authors=authors, preserve_tags=preserve_tags,
                               oldest_commit=oldest_commit)

        if verbose:
            # ISO_8601 = '%Y-%m-%d %H:%M:%S %z'  # NOQA
            # ts_start = start.authored_datetime.
            # print(ub.repr2([(c.message.strip(), c.author.name, c.authored_datetime.strftime(ISO_8601)) for c in chain]))
            # print(ub.repr2(chain, nl=1))
            print('Found chain of length {!r}'.format(len(chain)))

        streaks = find_streaks(chain, authors=authors, timedelta=timedelta,
                               pattern=pattern)
    if verbose:
        print('Found %r streaks' % (len(streaks)))
        # sys.exit(0)

    # Switch to a temp branch before we start working
    if not dry:
        temp_branchname = checkout_temporary_branch(repo, '-squash-temp')
    else:
        temp_branchname = None

    try:
        for streak in ub.ProgIter(streaks, 'squashing', verbose=3 * verbose):
            if verbose:
                print('Squashing streak = %r' % (str(streak),))
            # Start is the commit further back in time
            # print('streak = {!r}'.format(streak))
            # print('streak.start = {!r}, {}'.format(streak.start, streak.start.message))
            _squash_between(repo, streak.start, streak.stop, dry=dry,
                            verbose=verbose)
    except Exception:
        print_exc(sys.exc_info())
        print('ERROR: squash_streaks failed.')
        if not dry and auto_rollback:
            print('ROLLING BACK')
            repo.git.checkout(orig_branch_name)
            # repo.git.branch(D=temp_branchname)
        print('You can debug the difference with:')
        print('    gitk {} {}'.format(orig_branch_name, temp_branchname))
        return

    if dry:
        if verbose:
            print('Finished. did nothing')
    elif inplace:
        # Copy temp branch back over original
        repo.git.checkout(orig_branch_name)
        repo.git.reset(temp_branchname, hard=True)
        repo.git.branch(D=temp_branchname)
        if verbose:
            print('Finished. Now you should force push the branch back to the server')
    else:
        # Go back to the original branch
        repo.git.checkout(orig_branch_name)
        if verbose:
            print('Finished')
            print('The squashed branch is: {}'.format(temp_branchname))
            print('You can inspect the difference with:')
            print('    gitk {} {}'.format(orig_branch_name, temp_branchname))
            print('Finished. Now you must manually clean this branch up.')
            print('Or, to automatically accept changes run with --inplace')


def _autoparse_desc(func):
    try:
        # TODO: can we autogenerate the entire argument parser from the
        # docstring? or at least sectinons of it?
        # Parse docstrings for help strings
        from xdoctest import docscrape_google as scrape
        docstr = func.__doc__
        help_dict = {}
        for argdict in scrape.parse_google_args(docstr):
            help_dict[argdict['name']] = argdict['desc']
        description = scrape.split_google_docblocks(docstr)[0][1][0].strip()
        description = description.replace('\n', ' ')
    except ImportError:
        from collections import defaultdict
        help_dict = defaultdict(lambda: '')
        description = ''
    return description, help_dict


# commandline entry point
def git_squash_streaks():
    """
    git-squash-streaks

    Usage:
        See argparse
    """
    import argparse
    try:
        import argcomplete
    except Exception:
        argcomplete = None
    description, help_dict = _autoparse_desc(squash_streaks)

    parser = argparse.ArgumentParser(description=description)
    parser.add_argument(*('--timedelta',), type=str,
                        help=help_dict['timedelta'])

    parser.add_argument(*('--custom_streak',), nargs=2,
                        help='hack to specify one custom streak: older newer')

    parser.add_argument(*('--pattern',), type=str,
                        help=help_dict['pattern'])

    parser.add_argument(*('--tags',), action='store_true', help='experimental')

    parser.add_argument(*('--no-preserve-tags',), dest='preserve_tags',
                        action='store_false', help=help_dict['preserve_tags'])

    parser.add_argument(*('--oldest-commit',), dest='oldest_commit',
                        help=help_dict['oldest_commit'])

    parser.add_argument(*('--inplace',), action='store_true',
                        help=help_dict['inplace'])

    parser.add_argument(*('--auto-rollback',), action='store_true',
                        dest='auto_rollback', help=help_dict['auto_rollback'])

    parser.add_argument('--authors', type=str,
                        help=(help_dict['authors'] +
                              ' Only squash commits from these authors. '
                              ' Set to <config> to use your git config'))

    group = parser.add_mutually_exclusive_group()
    group.add_argument(*('-n', '--dry'), dest='dry', action='store_true',
                        help=help_dict['dry'])
    group.add_argument(*('-f', '--force'), dest='dry', action='store_false',
                        help='opposite of --dry')

    group = parser.add_mutually_exclusive_group()
    group.add_argument(*('-v', '--verbose'), dest='verbose', action='store_const',
                       const=1, help='verbosity flag flag')
    group.add_argument(*('-q', '--quiet'), dest='verbose', action='store_const',
                       const=0, help='suppress output')

    # parser.add_argument(*('--inplace',), action='store_true',
    #                     help=help_dict['inplace'])

    parser.set_defaults(
        tags=False,
        inplace=False,
        preserve_tags=True,
        auto_rollback=False,
        authors=None,
        pattern=None,
        timedelta='sameday',
        dry=True,
        verbose=True,
    )
    if argcomplete:
        argcomplete.autocomplete(parser)
    args = parser.parse_args()

    # Postprocess args
    ns = args.__dict__.copy()

    if ns.pop('tags'):
        do_tags()
        return

    try:
        ns['timedelta'] = float(ns['timedelta'])
    except ValueError:
        ns['timedelta'] = str(ns['timedelta']).lower()
        valid_timedelta_categories = ['sameday', 'alltime', 'none']
        if ns['timedelta'] not in valid_timedelta_categories:
            raise ValueError('timedelta = {}'.format(ns['timedelta']))

    if ns['authors'] is None:
        pass
    elif ns['authors'] == '<user>':
        ns['authors'] = {git.Git().config('user.name')}
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
        if {'joncrall', 'Jon Crall', 'jon.crall'}.intersection(ns['authors']):
            ns['authors'].update({'joncrall', 'Jon Crall'})
    else:
        ns['authors'] = {a.strip() for a in ns['authors'].split(',')}

    print(ub.repr2(ns, nl=1))

    squash_streaks(**ns)

    if ns['dry']:
        if ns['verbose']:
            print('Finished the dry run. Use -f to force')


if __name__ == '__main__':
    """
    Example Usage:

        # Squash between two commits

        git-squash-streaks --custom_streak 7b30a46af68169e3ea38d1f821440f11c25f929f 1dcf7a4ed744feb202e05717e475c1f3bb7ec842

        git-squash-streaks --oldest-commit=master --timedelta=None

        git-squash-streaks --timedelta=None


    """
    git_squash_streaks()
