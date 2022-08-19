"""
Mark files for copying, and then execute the copy to a cwd or target later.
"""

import shelve
import os
import scriptconfig as scfg


class CopyMarkConfig(scfg.Config):
    default = {
        'command': scfg.Value(None, position=1),
        'paths': scfg.Value(None, position=2, nargs='+')
    }


def main():
    import ubelt as ub
    config = CopyMarkConfig(cmdline=1)
    cache_dpath = ub.Path.appdir('copymark').ensuredir()
    staging_shelf_fpath = cache_dpath / 'staging.shelf'

    paths = config['paths']

    shelf = shelve.open(os.fspath(staging_shelf_fpath))

    if 'staging' not in shelf:
        staging = []
    else:
        staging = shelf['staging']

    try:
        if config['command'] == 'list':
            print('staging = {}'.format(ub.repr2(staging, nl=1)))

        elif config['command'] == 'mark':
            assert paths is not None
            tostage = [ub.Path(p).resolve() for p in paths]
            staging.extend(tostage)
            shelf['staging'] = list(ub.unique(staging))
        elif config['command'] == 'paste':
            if paths is None:
                dst = ub.Path.cwd()
            else:
                assert len(paths) == 1
                dst = ub.Path(paths[0])
            assert dst.is_dir()

            import shutil
            for p in ub.ProgIter(staging, desc='copy'):
                shutil.copy2(p, dst)

            shelf['staging'] = []
        elif config['command'] == 'clear':
            shelf['staging'] = []
        else:
            raise Exception

    finally:
        shelf.close()


if __name__ == '__main__':
    """
    CommandLine:
        python ~/local/tools/copy_mark.py clear
        DPATH1=$(mktemp -d)
        DPATH2=$(mktemp -d)
        cd $DPATH1
        echo "foo" > foo
        echo "bar" > bar
        python ~/local/tools/copy_mark.py mark foo bar
        python ~/local/tools/copy_mark.py list
        cd $DPATH2
        python ~/local/tools/copy_mark.py paste
    """
    main()
