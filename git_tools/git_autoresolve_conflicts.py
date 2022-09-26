"""
Dangerous script. Tries to automatically resolve conflicts by just taking one
or the other. By default just takes the first one.
"""


def git_list_unmerged_files(repo):
    # git diff --name-only --diff-filter=U --relative
    unmerged_fpaths = repo.git.diff('--name-only', '--diff-filter=U', '--relative').split('\n')
    return unmerged_fpaths


def autoresolve(which='option1', force=False):
    import git
    repo = git.Repo()
    unmerged_fpaths = git_list_unmerged_files(repo)
    for fpath in unmerged_fpaths:
        resolve_path(fpath, which, force=force)
    if not force:
        repo.git.add(*unmerged_fpaths)


def resolve_path(fpath, which, force):
    """
    b = xdev.RegexBuilder.coerce()
    b.named_field('.' + b.nongreedy, 'commit1')
    b.named_field('.' + b.nongreedy, 'option1')
    """
    import pathlib
    import re
    unresolved_pat = re.compile(
        r'^<<<<<<< (?P<commit1>.*?)$\n' +
        r'(?P<option1>.*?)' +
        r'^=======$\n' +
        r'(?P<option2>.*?)' +
        r'^>>>>>>> (?P<commit2>.*?)$\n'
        , flags=re.MULTILINE | re.DOTALL)

    fpath = pathlib.Path(fpath)
    text = fpath.read_text()

    parts = []

    prev = 0
    match = unresolved_pat.search(text, pos=prev)
    while match:
        start, stop = match.span()
        groups = match.groupdict()
        parts.append(text[prev:start])
        # How do we want to try and resolve?
        parts.append(groups[which])
        prev = stop
        match = unresolved_pat.search(text, pos=prev)
    parts.append(text[prev:])

    resolved = ''.join(parts)

    if force:
        print(f'\nResolution for: fpath={fpath}')
        import xdev as xd
        print(xd.difftext(text, resolved, colored=1, context_lines=10))
    else:
        fpath.write_text(text)


def main():
    import argparse
    parser = argparse.ArgumentParser()
    parser.add_argument('--which', default='option1', choices=['option1', 'option2'])
    parser.add_argument('--force', action='store_true')
    args = parser.parse_args()
    config = args.__dict__
    autoresolve(**config)


if __name__ == '__main__':
    """
    CommandLine:
        python ~/local/git_tools/git_autoresolve_conflicts.py
    """
    main()
