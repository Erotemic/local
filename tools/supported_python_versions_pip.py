"""
https://github.com/wimglenn/johnnydep
"""
import json
from distutils.version import LooseVersion
import requests


# def foo():
#     import johnnydep
#     dist = johnnydep.JohnnyDist(package_name)
#     print(dist.serialise(fields=args.fields, format=args.output_format, recurse=args.recurse))


class ReqPythonVersionSpec:
    """
    For python_version specs in requirements files

    Example:
        pattern = '>=2.7, !=3.0.*, !=3.1.*, !=3.2.*, !=3.3.*, !=3.4.*'
        other = '3.7.2'
        reqspec = ReqPythonVersionSpec(pattern)
        reqspec.highest_explicit()
        reqspec.matches('2.6')
        reqspec.matches('2.7')
    """
    def __init__(self, pattern):
        self.pattern = pattern
        self.parts = pattern.split(',')
        self.constraints = []
        for part in self.parts:
            try:
                oppat, partpat = part.split('=')
                opsuf = '='
            except Exception:
                try:
                    oppat, partpat = part.split('<')
                    opsuf = '<'
                except Exception:
                    oppat, partpat = part.split('>')
                    opsuf = '>'
            opstr = (oppat + opsuf).strip()
            idx = None
            if '.*' in partpat:
                verpat_parts = partpat.split('.')
                idx = verpat_parts.index('*')
                partpat.split('.')
                partver = LooseVersion('.'.join(verpat_parts[0:idx]))
            else:
                partver = LooseVersion(partpat)
            self.constraints.append({
                'opstr': opstr,
                'idx': idx,
                'partver': partver,
            })

    def highest_explicit(self):
        return max(c['partver'] for c in self.constraints if c['opstr'] == '>=')

    def matches(self, other):
        flag = True
        for constraint in self.constraints:
            idx = constraint['idx']
            pyver_ = LooseVersion('.'.join(other.split('.')[0:idx]))
            partver = constraint['partver']
            opstr = constraint['opstr']
            try:
                if opstr == '>':
                    flag &= pyver_ > partver
                elif opstr == '<':
                    flag &= pyver_ < partver
                if opstr == '>=':
                    flag &= pyver_ >= partver
                elif opstr == '<=':
                    flag &= pyver_ <= partver
                elif opstr == '!=':
                    flag &= pyver_ != partver
                elif opstr == '==':
                    flag &= pyver_ == partver
                else:
                    raise KeyError(opstr)
            except Exception:
                print('partver = {!r}'.format(partver))
                print('pyver_ = {!r}'.format(pyver_))
                raise

        return flag


def minimum_cross_python_versions(package_name):
    url = "https://pypi.org/pypi/%s/json" % (package_name,)
    resp = requests.get(url)
    assert resp.status_code == 200

    pypi_package_data = json.loads(resp.text)
    import ubelt as ub

    available_releases = pypi_package_data['releases']
    simplified_available = {}
    for version, infos in available_releases.items():
        simple = []
        for info in infos:
            info2 = ub.dict_diff(info, {
                'digests',
                'upload_time_iso_8601',
                'upload_time',
                'md5_digest',
                'has_sig',
                'downloads',
                'comment_text',
                'size',
                'filename',
                'url',
                'yanked',
                'yanked_reason',
            })
            if not info['yanked']:
                from dateutil.parser import parse
                dt = parse(info['upload_time_iso_8601'])
                info2['upload_time'] = dt.isoformat()
                simple.append(info2)
        simplified_available[version] = simple

    # simplified_available = ub.sorted_vals(simplified_available, key=lambda x: parse(x[0]['upload_time']))
    print('simplified_available = {}'.format(ub.repr2(simplified_available, nl=-1, sort=0)))
    # attempt_python_versions = [
    #     '2.7.0',
    #     '3.4.0',
    #     '3.5.0',
    #     '3.6.0',
    #     '3.7.0',
    #     '3.8.0',
    #     '3.9.0',
    #     '3.10.0',
    # ]

    import ubelt as ub
    available_for_python = ub.ddict(set)

    # import ubelt as ub
    # available_for_python = ub.ddict(set)
    # for version, items in pypi_package_data['releases'].items():
    #     for item in items:
    #         if not item['yanked']:
    #             python_req = item['requires_python']
    #             available_for_python[python_req].add(version)

    # earliest_for = {}
    # for python_req, available in available_for_python.items():
    #     if python_req is not None:
    #         # For each python version get the earliest compatible version of the lib
    #         earliest = sorted(available, key=LooseVersion)[0]
    #         assert python_req.startswith('>=')
    #         python_req = python_req[2:]
    #         earliest_for[python_req] = earliest

    import ubelt as ub
    available_for_python = ub.ddict(set)
    for version, items in pypi_package_data['releases'].items():
        for item in items:
            if not item['yanked']:
                python_req = item['requires_python']
                if python_req is not None:
                    reqspec = ReqPythonVersionSpec(python_req)
                    pyver = reqspec.highest_explicit().vstring
                    if all(c not in version for c in ['rc', 'a', 'b']):
                        available_for_python[pyver].add(version)
                    # for pyver in attempt_python_versions:
                    #     if reqspec.matches(pyver):
                    #         available_for_python[pyver].add(version)

    # TODO logic:
    # FOR EACH PYTHON VERSION
    # find the minimum version that will work with that Python version.
    # show that

    earliest_for = {}
    for python_req, available in available_for_python.items():
        if python_req is not None:
            # For each python version get the earliest compatible version of the lib
            try:
                earliest = sorted(available, key=LooseVersion)[0]
            except Exception:
                print('available = {!r}'.format(available))
                raise
            # print('python_req = {!r}'.format(python_req))
            # assert python_req.startswith('>=')
            earliest_for[python_req] = earliest

    python_versions = sorted(earliest_for, key=LooseVersion)
    lines = []
    for cur_pyver, next_pyver in ub.iter_window(python_versions, 2):
        pkg_ver = earliest_for[cur_pyver]
        line = f"{package_name}>={pkg_ver:<8}  ; python_version < '{next_pyver}' and python_version >= '{cur_pyver}'    # Python {cur_pyver}"
        lines.append(line)
    # last
    cur_pyver = python_versions[-1]
    pkg_ver = earliest_for[cur_pyver]
    line =     f"{package_name}>={pkg_ver:<8}  ;                            python_version >= '{cur_pyver}'    # Python {cur_pyver}+"
    lines.append(line)
    text = '\n'.join(lines[::-1])
    print(text)


def demo():
    package_name = 'ipykernel'
    package_name = 'IPython'
    # minimum_cross_python_versions(package_name)

    package_name = 'nbconvert'
    package_name = 'jupyter_core'
    package_name = 'pytest'
    package_name = 'pytest_cov'
    package_name = 'pytest'
    package_name = 'jinja2'
    package_name = 'nbconvert'
    package_name = 'attrs'
    package_name = 'jupyter_core'
    package_name = 'nbclient'
    package_name = 'jsonschema'
    package_name = 'numexpr'
    package_name = 'networkx'
    package_name = 'coverage'
    package_name = 'pandas'
    package_name = 'numpy'
    package_name = 'scipy'
    minimum_cross_python_versions(package_name)


if __name__ == '__main__':
    """
    CommandLine:
        python ~/local/tools/supported_python_versions_pip.py scipy
    """
    import fire
    fire.Fire(minimum_cross_python_versions)
