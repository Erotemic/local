# Download latest by parsing webpage
import utool as ut
from os.path import join
# from six.moves import urllib  #NOQA
import urllib2
headers = { 'User-Agent' : 'Mozilla/5.0' }
req = urllib2.Request(r'https://cmake.org/download/', None, headers)
page = urllib2.urlopen(req)
page_str = page.read()
page_str = ut.ensure_unicode(page_str)

next = False
lines = page_str.split('\n')
for index, x in enumerate(lines):
    if next:
        print(x)
        import parse
        url_suffix = parse.parse('{foo}href="{href}"{other}', x)['href']
        url = r'https://cmake.org' + url_suffix
        break
    if 'Linux x86_64' in x:
        next = True
url = url.replace('.sh', '.tar.gz')
cmake_unzipped_fpath = ut.grab_zipped_url(url)
install_prefix = ut.unixpath('~')
for dname in ['bin', 'doc', 'man', 'share']:
    install_dst = join(install_prefix, dname)
    install_src = join(cmake_unzipped_fpath, dname)
    # FIXME: this broke
    #ut.util_path.copy(install_src, install_dst)
    # HACK AROUND IT
    from os.path import dirname
    cmd = str('cp -r "' + install_src + '" "' + dirname(install_dst) + '"')
    print(cmd)
    ut.cmd(cmd)
    #os.system(cmd)
print(cmake_unzipped_fpath)
