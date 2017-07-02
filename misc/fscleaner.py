import os
import utool as ut
from os.path import basename, join, split  # NOQA

app_dpath = ut.truepath('~/fsclean_indexes')
ut.ensurepath(app_dpath)


root = '/media/joncrall/media'


class Path(ut.NiceRepr):
    @property
    @ut.memoize
    def abspath(self):
        return join(self.r, self.n)

    def __nice__(self):
        return (self.r, self.n)

    def __eq__(self, other):
        return self.abspath == other.abspath

    def __hash__(self):
        return hash(self.abspath)

    @property
    @ut.memoize
    def depth(self):
        return self.abspath.count(os.path.sep)


class File(Path):
    def __init__(self, r, f):
        self.r = r
        self.n = f
        self.duplicates = set()

    @property
    @ut.memoize
    def hashid(self):
        stride = 16
        return ut.get_file_hash(self.abspath, stride=stride)

    @property
    @ut.memoize
    def nbytes(self):
        return ut.get_file_nBytes(self.abspath)

    @property
    def f(self):
        return self.n


class Dir(Path):
    def __init__(self, r, d):
        self.r = r
        self.n = d
        self.files = []
        self.dirs = []
        self.is_empty = None

    def ls(self):
        return ut.ls(self.abspath)

    @property
    def d(self):
        return self.n


def walklevel(some_dir, level=1):
    if level is None:
        yield from os.walk(some_dir)
    else:
        some_dir = some_dir.rstrip(os.path.sep)
        assert os.path.isdir(some_dir)
        num_sep = some_dir.count(os.path.sep)
        for root, dirs, files in os.walk(some_dir):
            yield root, dirs, files
            num_sep_this = root.count(os.path.sep)
            if num_sep + level <= num_sep_this:
                del dirs[:]


class Index(object):

    def __init__(index):
        index.files = {}
        index.dirs = {}
        index.root = None
        index.cwd = None

    def cd(self, to=None):
        if to is None:
            self.cwd = self.root
        else:
            self.cwd = self[join(self.cwd.abspath, to)]

    def ls(index):
        return [d.n for d in index.cwd.dirs]

    def __getitem__(self, key):
        return self.dirs[key]

    def add_dir(index, d):
        index.dirs[d.abspath] = d
        index._register_child(d)

    def add_file(index, f):
        index.files[f.abspath] = f
        index._register_child(f)

    def _register_child(index, p):
        parent = index.dirs.get(p.r, None)
        if parent is not None:
            if isinstance(p, File):
                parent.files.append(p)
            elif isinstance(p, Dir):
                parent.dirs.append(p)
            else:
                assert False, 'bad type {}'.format(p)
        else:
            assert index.root is None
            index.root = p

    def find_duplicates(index):
        # fpaths = list(index.files.keys())
        files = list(index.files.values())
        print('Grouping {} files'.format(len(files)))
        grouped = ut.group_items(files, [f.nbytes for f in files])
        print('Found {} groups'.format(len(grouped)))
        potential_dups = {k: v for k, v in grouped.items() if len(v) > 1}
        print('Found {} potential dups by nbytes'.format(len(potential_dups)))

        GB = 2 ** 30  # NOQA
        MB = 2 ** 20  # NOQA
        max_bytes = 10 * MB
        min_bytes = 64 * MB

        duplicates = []
        for k, fs in ut.ProgIter(potential_dups.items(), freq=1):
            names = [f.n for f in fs]
            if ut.allsame(names):
                # Don't do big files yet
                if k < max_bytes and k > min_bytes:
                    if ut.allsame([f.hashid for f in fs]):
                        duplicates.extend(fs)
                        for f1, f2 in ut.combinations(fs, 2):
                            f1.duplicates.add(f2)
                            f2.duplicates.add(f1)

        def dpath_similarity(index, dpath1, dpath2):
            d1 = index[dpath1]
            d2 = index[dpath2]
            set1 = {f.hashid for f in ut.ProgIter(d1.files)}
            set2 = {f.hashid for f in ut.ProgIter(d2.files)}
            # n_isect = len(set1.intersection(set2))
            size1, size2 = map(len, (set1, set2))
            # minsize = min(size1, size2)
            # sim_measures = (n_isect, n_isect / minsize)
            return ut.set_overlaps(set1, set2)
            # return sim_measures

        similarities = {}
        r_to_dup = ut.group_items(duplicates, [p.r for p in duplicates])
        for dpath, dups in r_to_dup.items():
            # Check to see if the duplicates all point to the same dir
            f = dups[0]  # NOQA
            common_dpath = set.intersection(*[
                {_.r for _ in f.duplicates} for f in dups])

            for other in common_dpath:
                sim_measures = dpath_similarity(index, dpath, other)
                similarities[(dpath, other)] = sim_measures

        print(ut.repr4(similarities, si=True, nl=2))

        # Directory groups, that all link to the same other directory should
        # probably be merged.

    def index_root(index, root, level=None):
        p = Dir(*split(root))
        index.add_dir(p)
        ignore_dnames = {'$RECYCLE.BIN', '.Trash-1000'}

        for r, ds, fs in ut.ProgIter(walklevel(root, level=level), freq=100):
            parent = index[r]
            if len(ds) == 0 and len(fs) == 0:
                parent.is_empty = True

            for d in list(ds):
                if d in ignore_dnames:
                    ds.remove(d)
                else:
                    p = Dir(r, d)
                    index.add_dir(p)

            for f in fs:
                p = File(r, f)
                index.add_file(p)
        return index


def main():
    index1 = Index().index_root('/media/joncrall/store/Recordings')
    index2 = Index().index_root('/media/joncrall/backup/Recordings')
    index3 = Index().index_root('/media/joncrall/media/Recordings')


    paths1 = list(index1.files.keys())
    paths2 = list(index2.files.keys())
    paths3 = list(index3.files.keys())

    hashes1 = [ut.get_file_hash(p, stride=1024 * 100) for p in paths1]
    hashes1 = [ut.get_file_hash(p, stride=1024 * 100) for p in paths1]
