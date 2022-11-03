#!/usr/bin/env python3
import ubelt as ub
import scriptconfig as scfg
from rich.prompt import Confirm


class CleanEmptyDirConfig(scfg.DataConfig):
    """
    Recursively walk the entire directory and find any nested set of folders
    that has no files, and delete them.
    """
    dpath = scfg.Value('.', position=1, help='The directory to check')
    yes = scfg.Value(False, help='If set to true assume yes to all prompts', isflag=1)


def main():
    config = CleanEmptyDirConfig.cli()
    dpath = ub.Path(config['dpath'])

    dpath = ub.Path('.').absolute()

    # First count the number of files in each directory
    path_to_num = ub.ddict(lambda: 0)

    prog = ub.ProgIter(dpath.walk(followlinks=False))
    for r, ds, fs in prog:
        prog.set_extra(f'walking: {r}')
        node = r.relative_to(dpath)
        path_to_num[node] += len(fs)

    # Accumulate the number of files at each level.
    path_to_nested_num = ub.ddict(lambda: 0)
    for node, value in ub.ProgIter(path_to_num.items()):
        parts = node.parts
        path_to_nested_num[node] += value
        for i in reversed(range(len(parts))):
            ancestor = ub.Path(*parts[:i])
            path_to_nested_num[ancestor] += value

    # These directories have no file and no decendents with files
    # We can remove the entire tree
    nofile_dirs = {k for k, v in path_to_nested_num.items() if v == 0}

    print(f'Found {len(nofile_dirs)} empty directories')
    print('nofile_dirs = {}'.format(ub.repr2(nofile_dirs, nl=1)))

    if not nofile_dirs:
        print('No empty directories')
    else:
        # Restrict to only the base directories that can be removed recursively
        nofile_base_dirs = set()
        for d in nofile_dirs:
            if d.parent not in nofile_dirs:
                nofile_base_dirs.add(d)
        ans = config['yes'] or Confirm.ask(f'Recursively remove {len(nofile_base_dirs)} directories?')
        if ans:
            for d in ub.ProgIter(nofile_base_dirs, desc='deleting empty dirs'):
                d.delete()
        else:
            print('did nothing')


if __name__ == '__main__':
    """
    CommandLine:
        python ~/local/scripts/clean_empty_dirs.py
    """
    main()
