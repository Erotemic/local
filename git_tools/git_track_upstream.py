#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
Requirements:
    pip install GitPython

A quick script that executes
``git branch --set-upstream-to=<remote>/<branch> <branch>``
with sensible defaults
"""
import git as pygit
import ubelt as ub


def find_git_root(dpath):
    cwd = dpath.resolve()
    parts = cwd.parts

    for i in reversed(range(0, len(parts))):
        p = ub.Path(*parts[0:i])
        cand = p / '.git'
        if cand.exists():
            return p

    return None


def main():
    dpath = ub.Path('.')
    repo_root = find_git_root(dpath)

    if repo_root is None:
        raise Exception('Could not find git repo')

    # Find the repo root.
    import os
    repo = pygit.Repo(os.fspath(repo_root))

    assert not repo.active_branch.is_remote()
    assert repo.active_branch.is_valid()
    tracking_branch = repo.head.reference.tracking_branch()
    print('tracking_branch = {}'.format(ub.repr2(tracking_branch, nl=1)))

    if tracking_branch is not None:
        print('tracking_branch is already set. Doing nothing.')
    else:
        print('tracking branch is not set. Attempt to find sensible defaults')
        branch = repo.active_branch
        unique_infos = unique_remotes_with_branch(repo, branch)
        if len(unique_infos) != 1:
            raise Exception('Sensible defaults are ambiguous. Giving up')
        # remote = unique_infos[0]['remote']
        valid_refs = unique_infos[0]['valid_refs']
        assert len(valid_refs) == 1
        ref = valid_refs[0]
        print('Chose sensible default tracking ref = {!r}'.format(ref))
        repo.active_branch.set_tracking_branch(ref)


def unique_remotes_with_branch(repo, branch):
    available_remotes = repo.remotes
    remote_infos = {}
    for remote in available_remotes:
        valid_refs = []
        for ref in remote.refs:
            if ref.name[len(ref.remote_name):].lstrip('/') == branch.name:
                valid_refs.append(ref)
        if not valid_refs:
            continue
        info = {'remote': remote, 'name': remote.name, 'valid_refs': valid_refs}
        remote_infos[remote.name] = info
        ref_urls = tuple(sorted(set(ub.flatten(list(remote.urls) for ref in remote.refs))))
        info['ref_urls'] = ref_urls

    groups = ub.group_items(remote_infos.values(), key=lambda x: x['ref_urls'])
    unique_infos = []
    for key, group in groups.items():
        chosen = sorted(group, key=lambda x: ((0 if x['name'] == 'origin' else 1), x['name']))[0]
        unique_infos.append(chosen)

    return unique_infos


if __name__ == '__main__':
    """
    CommandLine:
        python ~/local/git_tools/git_track_upstream.py
    """
    main()
