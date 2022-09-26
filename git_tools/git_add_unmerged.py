#!/usr/bin/env python
import ubelt as ub


def _cmd(command):
    info = ub.cmd(command, check=True, shell=True, verbose=3)
    return info


def main():

    # not working
    # https://stackoverflow.com/questions/33733453/get-changed-files-using-gitpython
    # import git as gitpython
    # import os
    # dpath = os.getcwd()
    # print('dpath = {!r}'.format(dpath))
    # pygit = gitpython.Repo(dpath)

    # info = _cmd("git ls-files -u  | awk '{print $4}' | sort | uniq")
    # info = _cmd("git ls-files --modified -u  | awk '{print $4}' | sort | uniq")

    info = _cmd('git diff --name-only --diff-filter=U')
    fpaths = [line for line in info['out'].split('\n') if line]
    print('fpaths = {!r}'.format(fpaths))

    resolved = True
    unresolved = []

    import re

    unresolved_patterns = [
        '^>>>>>>> ',
        '^<<<<<<< HEAD',
        '^=======$'
    ]

    for fpath in fpaths:
        text = ub.Path(fpath).read_text()
        pat = '|'.join(unresolved_patterns)
        match = re.search(pat, text, flags=re.MULTILINE)
        if match is not None:
            resolved = False
            print('fpath = {!r}'.format(fpath))
            print('match = {!r}'.format(match))
            print('ERROR: file is still unresolved')

    if not resolved:
        raise Exception('files are not resolved {!r}'.format(unresolved))

    do_add = True
    do_continue = 0
    if do_add:
        if fpaths:
            _cmd(["git",  "add", ] + fpaths)

        if do_continue:
            # This will cause a non-zero ret code
            ub.cmd("git rebase --continue", shell=True)
        else:
            print('Run:')
            print('git rebase --continue')


if __name__ == '__main__':
    """
    CommandLine:
        python ~/local/scripts/git-add-unmerged.py && git rebase --continue
    """
    main()
