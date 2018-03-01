# Download latest by parsing webpage
import os
from os.path import join, splitext, basename
import glob
import requests


def get_latest_cmake_url():
    html = requests.get(r'https://cmake.org/download/').content
    page_str = html.decode('utf8')

    # from six.moves import urllib  #NOQA
    # headers = { 'User-Agent' : 'Mozilla/5.0' }
    # req = urllib2.Request(r'https://cmake.org/download/', None, headers)
    # page = urllib2.urlopen(req)
    # import utool as ut

    # https://cmake.org/files/v3.9/cmake-3.9.0-Linux-x86_64.tar.gz

    next = False
    lines = page_str.split('\n')
    for index, x in enumerate(lines):
        if next:
            print(x)
            if 'Linux' not in x:
                next = False
                continue
            import parse
            url_suffix = parse.parse('{foo}href="{href}"{other}', x)['href']
            url = r'https://cmake.org' + url_suffix
            print('url_suffix = {!r}'.format(url_suffix))
            print('url.replace = {!r}'.format(url.replace))
            break
        if '<td>Linux x86_64</td>' in x:
            print('x = {!r}'.format(x))
            print('NEXT')
            next = True
    url = url.replace('.sh', '.tar.gz')
    return url


def main():
    # url_override = 'https://cmake.org/files/v3.8/cmake-3.8.2-Linux-x86_64.tar.gz'
    url_override = None
    if url_override is not None:
        url = url_override
    else:
        url = get_latest_cmake_url()

    dname = splitext(basename(url))[0].replace('.tar', '')

    install_prefix = join(os.path.expanduser('~'), '.local')
    tmpdir = join(os.path.expanduser('~'), 'tmp', 'cmake', dname)
    os.makedirs(install_prefix, exist_ok=True)
    os.makedirs(tmpdir, exist_ok=True)
    os.chdir(tmpdir)

    os.system('wget ' + url)
    os.system('tar -xf cmake-*.tar.gz')

    cmake_unzipped_fpath = sorted(glob.glob('cmake-*'))[0]
    for dname in ['bin', 'doc', 'man', 'share']:
        install_dst = join(install_prefix, dname)
        install_src = join(cmake_unzipped_fpath, dname)
        # HACK AROUND IT
        from os.path import dirname
        cmd = str('cp -r "' + install_src + '" "' + dirname(install_dst) + '"')
        print(cmd)
        os.system(cmd)
    print(cmake_unzipped_fpath)


if __name__ == '__main__':
    r"""
    CommandLine:
        python ~/local/build_scripts/init_cmake_latest.py
    """
    main()
