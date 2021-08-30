

def permission_histogram():
    import os
    import stat
    import pathlib
    import ubelt as ub

    @ub.memoize
    def parse_mode(st_mode):
        perms = {
            'owner': {
                'read': (st_mode & stat.S_IRUSR) > 0,
                'write': (st_mode & stat.S_IWUSR) > 0,
                'execute': (st_mode & stat.S_IXUSR) > 0,
            },
            'group': {
                'read': (st_mode & stat.S_IRGRP) > 0,
                'write': (st_mode & stat.S_IWGRP) > 0,
                'execute': (st_mode & stat.S_IXGRP) > 0,
            },
            'other': {
                'read': (st_mode & stat.S_IROTH) > 0,
                'write': (st_mode & stat.S_IWOTH) > 0,
                'execute': (st_mode & stat.S_IXOTH) > 0,
            }
        }
        return perms

    def path_info(path):
        st_mode = path.stat().st_mode

        info = {
            'owner': path.owner(),
            'group': path.group(),
            'perms': parse_mode(st_mode),
        }
        return info

    hist = ub.ddict(lambda: 0)

    prog = ub.ProgIter(desc='walking directory')
    prog.begin()

    root_dpath = pathlib.Path('.')
    for r, ds, fs in os.walk(root_dpath):
        curr_dpath = root_dpath / r
        for fname in fs:
            fpath = curr_dpath / fname
            info = path_info(fpath)
            key = repr(info)
            if key not in hist:
                prog.ensure_newline()
                print('new key = {}'.format(ub.repr2(info, nl=2)))
            hist[key] += 1
            prog.step()

        for dname in ds:
            dpath = curr_dpath / dname
            info = path_info(dpath)
            key = repr(info)
            if key not in hist:
                prog.ensure_newline()
                print('new key = {}'.format(ub.repr2(info, nl=2)))
            hist[key] += 1
            prog.step()

    prog.end()
    print('hist = {!r}'.format(hist))


if __name__ == '__main__':
    """
    CommandLine:
        python ~/local/tools/permission_histogram.py
    """
    permission_histogram()
