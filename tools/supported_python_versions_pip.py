import json
import requests


def minimum_cross_python_versions(package_name):
    from distutils.version import LooseVersion
    url = "https://pypi.org/pypi/%s/json" % (package_name,)
    resp = requests.get(url)
    assert resp.status_code == 200

    pypi_package_data = json.loads(resp.text)
    attempt_python_versions = [
        '2.7.0',
        '3.4.0',
        '3.5.0',
        '3.6.0',
        '3.7.0',
        '3.8.0',
        '3.9.0',
        '3.10.0',
    ]

    import ubelt as ub
    available_for_python = ub.ddict(set)

    import ubelt as ub
    available_for_python = ub.ddict(set)
    for version, items in pypi_package_data['releases'].items():
        for item in items:
            if not item['yanked']:
                python_req = item['requires_python']
                print('version = {!r}'.format(version))
                print('python_req = {!r}'.format(python_req))
                if python_req is not None:
                    for pyver in attempt_python_versions:
                        pyver_ = LooseVersion(pyver)
                        flag = True
                        for part in python_req.split(','):
                            a, verpat = part.split('=')

                            # HACK
                            if '.*' in verpat:
                                verpat_parts = verpat.split('.')
                                x = verpat_parts.index('*')
                                verpat.split('.')
                                pyver_ = LooseVersion('.'.join(pyver.split('.')[0:x]))
                                partver = LooseVersion('.'.join(verpat_parts[0:x]))
                            else:
                                partver = LooseVersion(verpat)
                            opstr = (a + '=').strip()
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
                        if flag:
                            available_for_python[pyver].add(version)

    # TODO logic:
    # FOR EACH PYTHON VERSION
    # find the minimum version that will work with that Python version.
    # show that

    earliest_for = {}
    for python_req, available in available_for_python.items():
        if python_req is not None:
            # For each python version get the earliest compatible version of the lib
            earliest = sorted(available, key=LooseVersion)[0]
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
    line =     f"{package_name}>={pkg_ver:<8}  ;                             python_version >= '{cur_pyver}'    # Python {cur_pyver}+"
    lines.append(line)
    text = '\n'.join(lines[::-1])
    print(text)


package_name = 'IPython'
package_name = 'ipykernel'
minimum_cross_python_versions(package_name)

package_name = 'nbconvert'
package_name = 'jinja2'
package_name = 'jupyter_core'
package_name = 'pytest'
package_name = 'pytest_cov'
package_name = 'pytest'
minimum_cross_python_versions(package_name)
