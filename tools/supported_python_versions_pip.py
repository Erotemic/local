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



def summarize_package_availability(package_name):
    """
    TODO:
        for each released version of the package we want to know

        * For source distros:
            * Does it need to be compiled?
            * What are is the min (or max?) python version
        * For binaries:
            * What python version, arch, and os targets are available.

    Ignore:
        package_name = 'scipy'
        package_name = 'kwarray'
        package_name = 'ubelt'

    """
    # import parse
    # import pandas as pd
    # import math
    import ubelt as ub
    url = "https://pypi.org/pypi/{}/json".format(package_name)
    resp = requests.get(url)
    assert resp.status_code == 200

    pypi_package_data = json.loads(resp.text)

    all_releases = pypi_package_data['releases']
    available_releases = {
        version: [item for item in items if not item['yanked']]
        for version, items in all_releases.items()
    }

    version_to_availability = ub.ddict(list)
    for version, items in available_releases.items():
        avail_for = version_to_availability[version]
        for item in items:
            packagetype = item['packagetype']
            if packagetype == 'sdist':
                avail_for.append(item['requires_python'])
            elif packagetype == 'bdist_wheel':
                avail_for.append(item['python_version'])
            else:
                raise KeyError(packagetype)
        version_to_availability[version] = set(avail_for)
    print('version_to_availability = {}'.format(ub.repr2(version_to_availability, nl=1)))


def minimum_cross_python_versions(package_name):
    """
    package_name = 'scipy'
    """
    import parse
    import ubelt as ub
    import pandas as pd
    import math
    url = "https://pypi.org/pypi/{}/json".format(package_name)
    resp = requests.get(url)
    assert resp.status_code == 200

    pypi_package_data = json.loads(resp.text)

    available_releases = pypi_package_data['releases']
    only_consider_bdist = False
    for version, items in available_releases.items():
        for item in items:
            if not item['yanked']:
                if item['packagetype'] == 'bdist_wheel':
                    only_consider_bdist = True
                    break

    # Is there a grammer modification to make that can make one pattern that captures both cases?
    # wheen_name_parser = parse.Parser('{distribution}-{version}(-{build_tag})?-{python_tag}-{abi_tag}-{platform_tag}.whl')
    wheel_name_parser1 = parse.Parser('{distribution}-{version}-{build_tag}-{python_tag}-{abi_tag}-{platform_tag}.whl')
    wheel_name_parser2 = parse.Parser('{distribution}-{version}-{python_tag}-{abi_tag}-{platform_tag}.whl')

    simplified_available = {}
    for version, items in available_releases.items():
        simple = []
        for item in items:
            info2 = ub.dict_diff(item, {
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
            if not item['yanked']:
                if only_consider_bdist and item['packagetype'] != 'bdist_wheel':
                    continue
                from dateutil.parser import parse
                dt = parse(item['upload_time_iso_8601'])
                filename = item['filename']
                result = wheel_name_parser1.parse(filename) or wheel_name_parser2.parse(filename)
                if result is not None:
                    # result.named['python_tag']
                    for k in ['platform_tag', 'abi_tag']:
                        item[k] = info2[k] = result.named[k]

                info2['upload_time'] = dt.isoformat()
                simple.append(info2)
        simplified_available[version] = simple

    # simplified_available = ub.sorted_vals(simplified_available, key=lambda x: parse(x[0]['upload_time']))
    print('simplified_available = {}'.format(ub.repr2(simplified_available, nl=-1, sort=0)))
    print('only_consider_bdist = {!r}'.format(only_consider_bdist))

    python_vstrings = ['2.7', '3.4', '3.5', '3.6', '3.7', '3.8', '3.9', '3.10']
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

    rows = []
    for version, items in available_releases.items():
        for item in items:
            if not item['yanked']:
                if item['packagetype'] == 'bdist_wheel':
                    # For binary wheels
                    python_version = item.get('python_version', None)
                    if python_version is not None:
                        cp_codes = {'cp{}{}'.format(*v.split('.')): v for v in python_vstrings}
                        cp_codes.update({'cp{}_{}'.format(*v.split('.')): v for v in [
                            '3.10']})
                        pyver = cp_codes.get(python_version)
                        if pyver is None and python_version == 'py2.py3':
                            pyver = '2.7'
                        if pyver is not None:
                            # TODO: need to get the arch the binary targets
                            # ensure minimum versions cover as many arches as
                            # possible
                            if all(c not in version for c in ['rc', 'a', 'b']):
                                rows.append({
                                    'version': version,
                                    'pyver': pyver,
                                    'has_sig': item['has_sig'],
                                    'packagetype': item['packagetype'],
                                    'platform_tag': item['platform_tag'],
                                    'abi_tag': item['abi_tag'],
                                })
                else:
                    # else:
                    # For "universal" wheels
                    python_req = item['requires_python']
                    if python_req is None:
                        if item['python_version'] == 'py2.py3':
                            python_req = '2.7'
                    if python_req is not None:
                        reqspec = ReqPythonVersionSpec(python_req)
                        pyver = reqspec.highest_explicit().vstring
                        if all(c not in version for c in ['rc', 'a', 'b']):
                            rows.append({
                                'version': version,
                                'pyver': pyver,
                                'has_sig': item['has_sig'],
                                'packagetype': item['packagetype'],
                                'platform_tag': 'any',
                            })
    table = pd.DataFrame(rows)
    chosen_minimum_for = {}

    if 1:
        # Special cases
        # Actually toml is not in the stdlib, but tomllib is.
        # if package_name == 'toml':
        #     chosen_minimum_for['3.10'] = 'stdlib[0.10.2]'
        pass

    # For each version of python find the "best" minimum package
    if len(table) == 0:
        print('available_releases = {}'.format(ub.repr2(available_releases, nl=3)))
        raise Exception('Did not find data to populate version table')

    for pyver, subdf in sorted(table.groupby('pyver'), key=lambda x: LooseVersion(x[0])):
        print('--- pyver = {!r} --- '.format(pyver))
        # print(subdf)
        version_to_support = dict(list(subdf.groupby('version')))

        cand_to_score = {}
        version_to_support = ub.sorted_keys(version_to_support, key=LooseVersion)
        for cand, support in version_to_support.items():
            score = 0
            # we like supporting most platforms
            # try:
            platforms = support['platform_tag'].unique()
            # except KeyError as ex:
            #     print('support = {}'.format(ub.repr2(support, nl=1)))
            #     print(f'skip ex={ex}')
            #     pass
            if 1:
                platforms = platforms[~pd.isnull(platforms)]
                # This is a slick bit of python
                groups = ub.group_items(platforms, key=lambda x: (
                    ((not isinstance(x, str) and 'nan') or
                     ('win' in x and 'win32') or
                     ('linux' in x and 'linux') or
                     ('osx' in x and 'osx') or
                     'other')
                ))
                assert not groups.pop('nan', None)
                # We care about some OS more than others
                score += 213 * ('any' in groups)
                score += 113 * ('linux' in groups)
                score += 71 * ('win' in groups)
                score += 53 * ('osx' in groups)
                score += 2 * ('other' in groups)
                if 'other' in groups:
                    print('warning: unhandled other groups = {!r}'.format(groups))

                # Diversity score
                score += sum(ub.map_vals(lambda x: math.log(len(x)), groups).values())

                score += len(platforms)
                # we like signatures
                score += support['has_sig'].mean() * 6.28318
                cand_to_score[cand] = score

        cand_to_score = ub.sorted_vals(cand_to_score)
        cand_to_score = ub.sorted_keys(cand_to_score, key=LooseVersion)
        # This is a proxy metric, but a pretty good one in 2021
        max_score = max(cand_to_score.values())
        best_cand = min([
            cand for cand, score in cand_to_score.items()
            if score == max_score
        ], key=LooseVersion)
        print('cand_to_score = {}'.format(ub.repr2(cand_to_score, nl=1)))
        print('best_cand = {!r}'.format(best_cand))
        chosen_minimum_for[pyver] = best_cand
    print('chosen_minimum_for = {}'.format(ub.repr2(chosen_minimum_for, nl=1)))

    # TODO logic:
    # FOR EACH PYTHON VERSION
    # find the minimum version that will work with that Python version.
    # show that
    print('available_for_python = {}'.format(ub.repr2(available_for_python, nl=1)))

    print(sorted(available_for_python.keys()))

    python_versions = sorted(chosen_minimum_for, key=LooseVersion)
    lines = []
    for cur_pyver, next_pyver in ub.iter_window(python_versions, 2):
        pkg_ver = chosen_minimum_for[cur_pyver]
        if not pkg_ver.startswith('stdlib'):
            line = f"{package_name}>={pkg_ver:<8}  ; python_version < '{next_pyver}' and python_version >= '{cur_pyver}'    # Python {cur_pyver}"
            lines.append(line)
        else:
            line = f"# {package_name}>={pkg_ver:<8} is in the stdlib for python_version < '{next_pyver}' and python_version >= '{cur_pyver}'    # Python {cur_pyver}"
            lines.append(line)
    # last
    cur_pyver = python_versions[-1]
    pkg_ver = chosen_minimum_for[cur_pyver]
    if not pkg_ver.startswith('stdlib'):
        line =     f"{package_name}>={pkg_ver:<8}  ;                            python_version >= '{cur_pyver}'    # Python {cur_pyver}+"
        lines.append(line)
    else:
        line = f"# {package_name}>={pkg_ver:<8} is in the stdlib for python_version < '{next_pyver}' and python_version >= '{cur_pyver}'    # Python {cur_pyver}"
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
        python ~/local/tools/supported_python_versions_pip.py numpy
        python ~/local/tools/supported_python_versions_pip.py scipy
        python ~/local/tools/supported_python_versions_pip.py kwimage
        python ~/local/tools/supported_python_versions_pip.py kwcoco
        python ~/local/tools/supported_python_versions_pip.py line_profiler
    """
    import fire
    fire.Fire(minimum_cross_python_versions)
