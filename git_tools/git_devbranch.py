#!/usr/bin/env python
"""
A git tool for handling the dev/<version> branch patterns

See the GitDevbranchConfig for functionality
"""
import git
import ubelt as ub
import scriptconfig as scfg
from packaging.version import LegacyVersion
from packaging.version import parse as Version


@scfg.dataconf
class GitDevbranchConfig:
    """
    A git tool for handling the dev/<version> branch patterns
    """
    command = scfg.Value(None, choices=['update', 'clean'], help='the command', position=1)
    repo_dpath = scfg.Value('.', help='location of the repo')


COMMANDS = {}


def _register_command(name):
    def _wrap(func):
        COMMANDS[name] = func
        return func
    return _wrap


def dev_branches(repo):
    branch_infos = []
    for line in repo.git.branch('-r').split('\n'):
        line = line.strip().split('->')[-1].strip()
        for remote in repo.remotes:
            if line.startswith(remote.name):
                info = {
                    'remote': remote,
                    'branch_name': line.lstrip(remote.name + '/'),
                    'full_name': line,
                }
                branch_infos.append(info)

    for branch in repo.branches:
        info = {
            'remote': None,
            'branch': branch,
            'branch_name': branch.name,
            'datetime': branch.commit.committed_datetime,
        }
        branch_infos.append(info)

    dev_infos = []
    for info in branch_infos:
        if info['branch_name'].startswith('dev/'):
            vstr = info['branch_name'].split('/')[-1]
            info['version'] = Version(vstr)
            if not isinstance(info['version'], LegacyVersion):
                dev_infos.append(info)

    versioned_dev_branches = sorted(dev_infos, key=lambda x: x['version'])
    return versioned_dev_branches


@_register_command('update')
def update_dev_branch(repo):
    versioned_dev_branches = dev_branches(repo)

    version = max(versioned_dev_branches, key=lambda x: x['version'])['version']
    final_cand = [d for d in versioned_dev_branches if d['version'] == version]

    latest = None
    for c in final_cand:
        if c.get('branch', None) is not None:
            latest = c['branch']
    # Need to fetch from remote
    if latest is None:
        info = final_cand[-1]
        print('info = {}'.format(ub.repr2(info, nl=1)))
        print('Latest seems to be on a remote')
        info['branch_name']
        repo.git.checkout(info['branch_name'])
        # raise NotImplementedError
    else:
        # dev_branches = [b for b in repo.branches if b.name.startswith('dev/')]
        # branch_versions = sorted(dev_branches, key=lambda x: Version(x.name.split('/')[-1]))
        # latest = branch_versions[-1]
        if repo.active_branch.name == latest.name:
            print('Already on the latest dev branch')
        else:
            print('repo.active_branch = {!r}'.format(repo.active_branch))
            print('latest = {!r}'.format(latest))
            repo.git.checkout(latest.name)


@_register_command('clean')
def clean_dev_branches(repo):
    versioned_dev_branches = dev_branches(repo)
    versioned_branch_names = list(ub.unique([b['branch_name'] for b in versioned_dev_branches]))
    keep_last = 5
    remove_branches = versioned_branch_names[0:-keep_last]
    repo.git.branch(*remove_branches, '-D')


def main():
    config = GitDevbranchConfig.cli()
    repo = git.Repo(config['repo_dpath'])
    command = COMMANDS[config['command']]
    command(repo)


if __name__ == '__main__':
    """
    CommandLine:
        python ~/local/git_tools/git_devbranch.py
    """
    main()
