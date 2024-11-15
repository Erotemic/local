"""
Adapted from ~/code/geowatch/dev/maintain/find_git_bloat.sh

TODO:
    - [ ] Move to git-well

References:
    .. [SO13403069] https://stackoverflow.com/questions/13403069/how-to-find-out-which-files-take-up-the-most-space-in-git-repo
"""
#!/usr/bin/env python3
import scriptconfig as scfg
import ubelt as ub


class FindBloatConfig(scfg.DataConfig):
    repo_dpath = scfg.Value('.', help='path to the repo')
    size_thresh = scfg.Value('20MiB', help='flag files larger than this size')
    io_workers = scfg.Value(10, help='number of IO worker threads')
    yes = scfg.Value(False, isflag=True, help='if True then dont ask before rewriting')


def find_git_root(dpath):
    cwd = ub.Path(dpath).resolve()
    parts = cwd.parts
    for i in reversed(range(0, len(parts))):
        p = ub.Path(*parts[0:i])
        cand = p / '.git'
        if cand.exists():
            return p
    return None


def main(cmdline=1, **kwargs):
    """
    Example:
        >>> # xdoctest: +SKIP
        >>> cmdline = 0
        >>> kwargs = dict()
        >>> main(cmdline=cmdline, **kwargs)
    """
    config = FindBloatConfig.cli(cmdline=cmdline, data=kwargs, strict=True)
    import rich
    import os
    import git as pygit
    import pint
    import pandas as pd
    import rich.prompt
    import shlex
    ureg = pint.UnitRegistry()

    rich.print('config = ' + ub.urepr(config, nl=1))
    root_dpath = find_git_root(config.repo_dpath)
    # Find the repo root.
    repo = pygit.Repo(os.fspath(root_dpath))

    out = repo.git.rev_list(all=True, objects=True)
    rows = []
    for line in ub.ProgIter(out.split('\n'), desc='parse lines'):
        parts = line.split(' ')
        objid = parts[0]
        if len(parts) > 1:
            relpath = parts[1]
        else:
            relpath = None
        rows.append({
            'object_id': objid,
            'path': relpath,
        })

    jobs = ub.JobPool(mode='thread', max_workers=config.io_workers)

    for row in ub.ProgIter(rows, desc='submit populate size'):
        job = jobs.submit(repo.git.cat_file, '-s', row['object_id'])
        job.row = row

    for job in jobs.as_completed(desc='collect populate size'):
        sizestr = job.result()
        job.row['size'] = int(sizestr)

    rows = sorted(rows, key=lambda r: -r['size'])

    byte_thresh = ureg.parse_expression(config.size_thresh).to('bytes').m
    big_rows = [r for r in rows if r['size'] > byte_thresh]

    for row in big_rows:
        log_output = repo.git.log('--all', find_object=row['object_id'])
        commit_id = log_output.split('\n')[0].split(' ')[1]
        repo.git.log(find_object=row['object_id'])
        row['commit_id'] = commit_id

    big_df = pd.DataFrame(big_rows)
    rich.print(big_df)

    if len(big_rows) == 0:
        print('No big rows found')
        rows_df = pd.DataFrame(rows)
        # import xdev
        # rows_df['size'] = rows_df['size'].apply(xdev.byte_str)
        rich.print(rows_df)
    else:
        all_commits = [r['commit_id'] for r in big_rows]
        if len(all_commits) == 1:
            common_base = all_commits[0]
        else:
            common_base = repo.git.merge_base('--all', *all_commits)
        print('common_base = {}'.format(ub.urepr(common_base, nl=1)))

        ans = config.yes or rich.prompt.Confirm.ask('Purge these files from the repo and rewrite history?')
        if ans:
            big_paths = [r['path'] for r in big_rows]
            big_paths_str = ' '.join([shlex.quote(p) for p in big_paths])
            command = ub.codeblock(
                rf'''
                env FILTER_BRANCH_SQUELCH_WARNING=1 \
                  git filter-branch -f --prune-empty --index-filter '
                    git rm -rf --cached --ignore-unmatch -- {big_paths_str}
                  ' {common_base}..HEAD
                ''')
            ub.cmd(command, system=True, verbose=3)
            print('History has been rewritten. You may have to force push / prune')


if __name__ == '__main__':
    """

    CommandLine:
        python ~/local/git_tools/git_find_bloat.py
        python -m git_find_bloat
    """
    main()
