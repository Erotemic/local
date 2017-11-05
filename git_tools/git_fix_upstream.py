import git


def git_fix_upstream(remote, dry=False):
    repo = git.Repo()
    branch = repo.active_branch.name

    assert remote in [m.name for m in repo.remotes]

    comment_fmt = 'git branch -u --set-upstream-to={remote}/{branch} {branch}'
    command = comment_fmt.format(remote=remote, branch=branch)
    if dry:
        print(command)
    else:
        import ubelt as ub
        ub.cmd(command, verbose=2)

    # TODO:
    # if the command fails simply add the right lines to .git/config
    '''
    [branch "dev/detection_chips"]
        remote = origin
        merge = refs/heads/dev/detection_chips
    '''

if __name__ == '__main__':
    r"""
    python ~/local/git_tools/git_fix_upstream.py Erotemic -n
    """
    import argparse
    parser = argparse.ArgumentParser(description='git-xadd add files to non-working branches')
    parser.add_argument('remote', nargs=1, help='the desired upstream remote (e.g. origin)')
    parser.add_argument(*('-n', '--dry'), action='store_true', default=False, help='dry run')
    args = parser.parse_args()

    git_fix_upstream(args.remote[0], args.dry)
