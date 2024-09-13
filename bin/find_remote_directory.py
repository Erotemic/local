#!/usr/bin/env python3
"""
"""
import scriptconfig as scfg
import ubelt as ub


class FindRemoteDirectoryCLI(scfg.DataConfig):
    """
    Search for ways to access a remote path based on the local filesystem with
    some sshfs mount to the remote. Prints a clickable link that lets you view
    it in your local file explorer.
    """

    path = scfg.Value(None, position=1, help=ub.paragraph(
        '''
        absolute path on the remote
        '''))

    remote = scfg.Value(None, position=2, help=ub.paragraph(
        '''
        name of the remote.
        '''))

    hub_dpath = scfg.Value('~/remote', help=ub.paragraph(
        '''
        Location where we expect sshfs remotes to be mounted.
        Mountpoints should be in this folder and follow the convention where
        the directory name of the mountpoint is the remote name itself.
        (i.e. the mount point should be <hub_dpath> / <remote>).

        Ignored if remote_dpath is set.
        '''))

    remote_dpath = scfg.Value(None, help=ub.paragraph(
        '''
        If set override the hub_dpath / remote convention and specify exactly
        where to find the remote mountpoint on the local filesystem.
        '''))

    autoswap = scfg.Value(True, isflag=True, help=ub.paragraph(
        '''
        if True, swap path and remote if hueristics detect they were given in
        the wrong order.
        '''))

    force_directory = scfg.Value(True, isflag=True, help=ub.paragraph(
        '''
        if True, files are interpreted as their parent directory
        '''))

    @classmethod
    def main(cls, cmdline=1, **kwargs):
        """
        Example:
            >>> # xdoctest: +SKIP
            >>> from access_remote_directory import *  # NOQA
            >>> cmdline = 0
            >>> kwargs = dict()
            >>> cls = FindRemoteDirectoryCLI
            >>> cls.main(cmdline=cmdline, **kwargs)
        """
        import rich
        from rich.markup import escape
        config = cls.cli(cmdline=cmdline, data=kwargs, strict=True)
        rich.print('config = ' + escape(ub.urepr(config, nl=1)))

        if config.autoswap:
            if '/' in str(config.remote) and '/' not in str(config.path):
                print('detected incorrect input order, fixing')
                config.path, config.remote = config.remote, config.path

        sshfs_mount_table = find_remote_mounts()

        remote_candidates = []
        if config.remote_dpath is None:
            sshfs_hub_dpath = ub.Path(config.hub_dpath).expanduser()
            if not sshfs_hub_dpath.exists():
                raise NotADirectoryError(f'Expected remote hubpoint: {sshfs_hub_dpath} does not exist')
            if config.remote:
                remote_candidates.append(sshfs_hub_dpath / config.remote)
            else:
                print('Remote not specified. Checking all sshfs mounts')
                remote_candidates = []
                for row in sshfs_mount_table:
                    remote_candidates.append(ub.Path(row['path']))
        else:
            remote_candidates = [ub.Path(config.remote_dpath)]

        candidates = []
        for remote_dpath in remote_candidates:
            if not remote_dpath.exists():
                raise NotADirectoryError(f'Expected mountpoint for remote: {remote_dpath} does not exist')

            remote_path = ub.Path(config.path)
            if remote_path.parts[0] == '/':
                suffix = ub.Path(*remote_path.parts[1:])
                candidates.append(remote_dpath / 'root' / suffix)
                candidates.append(remote_dpath / suffix)
                max_depth = len(suffix.parts)
            else:
                candidates.append(remote_dpath / remote_path)
                max_depth = len(ub.Path(remote_path).parts)

        print(f'candidates = {ub.urepr(candidates, nl=1)}')

        final_shortlist = []
        fallback_shortlist = []
        for candidate in candidates:
            flag = False
            if candidate.exists():
                if config.force_directory and candidate.is_file():
                    # hack to use the directory instead of the file
                    flag = True
                    final_shortlist.append(candidate.parent)
                else:
                    flag = True
                    final_shortlist.append(candidate)
            if not flag:
                fallback_shortlist.append(candidate)

        if len(final_shortlist) == 0:
            msg = ('Could not find a reasonable candidate for the path on the remote')
            import warnings
            warnings.warn(msg)
            # raise FileNotFoundError(msg)
        else:
            print('Found local path to:')
            for cand in final_shortlist:
                rich.print(f'[link={cand}]{cand}[/link]')

        found_fallbacks = []
        for path in fallback_shortlist:
            fallback_path = find_existing_prefix(path, max_depth)
            found_fallbacks.append(fallback_path)

        if found_fallbacks:
            print('Found fallback paths:')
            for cand in found_fallbacks:
                rich.print(f'[link={cand}]{cand}[/link]')


def find_remote_mounts():
    """
    Find a list of remotes that are mounted to the local filesystem

    References:
        https://askubuntu.com/questions/491595/how-can-i-view-all-the-folders-currently-mounted-through-sshfs

    TODO:
        - [ ] Add CIFS support
    """
    lines = ub.Path('/etc/mtab').read_text().strip().split('\n')
    found = []
    for line in lines:
        name, path, fs, options, dumpbit, passbit = line.split(' ')
        name = name.strip(':')
        row = {
            'name': name,
            'path': path,
        }
        if fs == 'fuse.sshfs':
            found.append(row)
    return found


def find_existing_prefix(path, max_depth=None):
    parts = path.parts
    if max_depth is None:
        max_depth = len(parts)

    start_index = len(parts) - max_depth

    for index in reversed(range(start_index, len(parts))):
        subpath = ub.Path(*parts[:index])
        if subpath.exists():
            return subpath

__cli__ = FindRemoteDirectoryCLI

if __name__ == '__main__':
    """

    CommandLine:
        python ~/code/erotemic/bin/access_remote_directory.py
        access_remote_directory
    """
    __cli__.main()
