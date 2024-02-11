#!/usr/bin/env python
"""
Looks at the `git_*.{sh,ph}` scripts and makes corresponding `git-*` scripts
"""
import ubelt as ub
import os
import stat


SCRIPT_HEADER = ub.codeblock(
    r'''
    #!/usr/bin/env bash
    # References:
    # https://stackoverflow.com/questions/59895/getting-the-source-directory-of-a-bash-script-from-within

    SOURCE="${BASH_SOURCE[0]}"
    while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
      DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
      SOURCE="$(readlink "$SOURCE")"
      [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
    done

    DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
    ''')

SCRIPT_FOOTER_FMT = '$DIR/../{fname} "$@"'


def setup_git_scripts():
    try:
        this_fpath = ub.Path(__file__)
    except NameError:
        # Hard code the name of this file for IPython usage
        # Update if necessary. Generally unused in real environments
        this_fpath = ub.Path('~/local/git_tools/_setup_git_scripts.py').expand()

    src_dpath = this_fpath.parent
    dst_dpath = src_dpath / 'scripts'

    known_scripts = set(dst_dpath.ls())

    git_sh_scripts = list(src_dpath.glob('git_*.sh'))
    git_py_scripts = list(src_dpath.glob('git_*.py'))
    github_py_scripts = list(src_dpath.glob('github_*.py'))
    git_scripts = git_py_scripts + git_sh_scripts + github_py_scripts

    wrote_scripts = set()
    for fpath in git_scripts:
        fname = fpath.name
        script_text = (SCRIPT_HEADER + '\n\n' +
                       SCRIPT_FOOTER_FMT.format(fname=fname) + '\n')

        new_fname = fpath.stem.replace('_', '-')
        new_fpath = dst_dpath / new_fname
        if new_fpath in known_scripts:
            print('update existing script {!r}'.format(new_fname))
        else:
            print('writing new script {!r}'.format(new_fname))
        wrote_scripts.add(new_fpath)
        new_fpath.write_text(script_text)

        # chmod +x the files
        os.chmod(new_fpath, new_fpath.stat().st_mode | stat.S_IEXEC)
        os.chmod(fpath, fpath.stat().st_mode | stat.S_IEXEC)

    unknown_scripts = known_scripts - wrote_scripts
    if unknown_scripts:
        print(f'unknown_scripts={unknown_scripts}')

    # Stage the new scripts?


if __name__ == '__main__':
    r"""
    CommandLine:
        python ~/local/git_tools/_setup_git_scripts.py
    """
    setup_git_scripts()
