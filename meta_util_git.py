from __future__ import absolute_import, division, print_function
from os.path import expanduser, normpath, realpath, join
import os
import textwrap
from itertools import izip
import platform


def get_computer_name():
    return platform.node()


def get_repo_dirs(repo_urls, checkout_dir):
    repo_dirs = [join(checkout_dir, get_repo_dname(url)) for url in repo_urls]
    return repo_dirs


def get_repo_dname(repo_url):
    """ Break url into a dirname """
    slashpos = repo_url.rfind('/')
    colonpos = repo_url.rfind(':')
    if slashpos != -1 and slashpos > colonpos:
        pos = slashpos
    else:
        pos = colonpos
    repodir = repo_url[pos + 1:].replace('.git', '')
    return repodir


USER_ID = None
IS_USER = False


def set_userid(userid, owned_computers):
    # Check to see if you are on one of Jons Computers
    global IS_USER
    global USER_ID
    USER_ID = userid
    IS_USER = get_computer_name() in owned_computers


def truepath(path):
    return normpath(realpath(expanduser(path)))


def unixpath(path):
    return truepath(path).replace('\\', '/')


def cd(dir_):
    dir_ = truepath(dir_)
    print('> cd ' + dir_)
    os.chdir(dir_)


format_dict = {
    'https': ('.com/', 'https://'),
    'ssh':   ('.com:', 'git@'),
}


def fix_repo_url(repo_url, in_type='https', out_type='ssh', format_dict=format_dict):
    """ Changes the repo_url format """
    for old, new in izip(format_dict[in_type], format_dict[out_type]):
        repo_url = repo_url.replace(old, new)
    return repo_url


def repo_list(*args):
    if len(args) < 1:
        return url_list(*args)
    elif len(args) == 2:
        repo_urls = url_list(args[0])
        checkout_dir = args[1]
        repo_dirs = map(unixpath, get_repo_dirs(repo_urls, checkout_dir))
        return repo_urls, repo_dirs


def url_list(*args):
    """ Output is gaurenteed to be a list of paths """
    url_list = args
    if len(args) == 1:
        # There is one argument
        arg = args[0]
        if isinstance(arg, (str, unicode)):
            if arg.find('\n') == -1:
                # One string long
                url_list = [arg]
            else:
                # One multiline string
                url_list = textwrap.dedent(arg).strip().split('\n')
        else:
            url_list = arg

    def userid_in(path):
        return IS_USER is not None and\
            path.find(USER_ID) != -1

    if IS_USER:
        url_list = [path if userid_in(path) else fix_repo_url(path, 'https', 'ssh')
                     for path in url_list]
    return map(unixpath, url_list)


def cmd(command):
    print('> ' + command)
    os.system(command)
