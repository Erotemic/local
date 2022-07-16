def main():
    import git
    repo = git.Repo('.')

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

    # repo.git.fetch()

    for branch in repo.branches:
        info = {
            'remote': None,
            'branch': branch,
            'branch_name': branch.name,
            'datetime': branch.commit.committed_datetime,
        }
        branch_infos.append(info)

    recent_branches = sorted([b for b in branch_infos if 'datetime' in b], key=lambda x: x['datetime'])
    import ubelt as ub
    print('recent_branches = {}'.format(ub.repr2(recent_branches, nl=1)))
    # [::-1]

    from packaging.version import parse as Version
    dev_infos = []
    for info in branch_infos:
        if info['branch_name'].startswith('dev/'):
            vstr = info['branch_name'].split('/')[-1]
            info['version'] = Version(vstr)
            dev_infos.append(info)

    version = max(dev_infos, key=lambda x: x['version'])['version']
    final_cand = [d for d in dev_infos if d['version'] == version]

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


if __name__ == '__main__':
    """
    CommandLine:
        python ~/local/git_tools/git_update_branch.py
    """
    main()
