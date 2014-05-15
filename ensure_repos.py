#!/usr/bin/env python
from __future__ import absolute_import, division, print_function
import sys
import util_git


PULL    = '--pull' in sys.argv
DEVELOP = '--develop' in sys.argv
CHECK   = '--nocheck' not in sys.argv


# Get IBEIS git repository URLS and their local path
ibeis_repo_urls = util_git.IBEIS_REPOS_URLS
ibeis_repo_dirs = util_git.get_repo_dirs(ibeis_repo_urls, util_git.CODE_DIR)


def checkout_ibeis_repos():
    """ Checkout IBEIS repos out if they don't exist """
    util_git.checkout_repos(ibeis_repo_urls, ibeis_repo_dirs)


def pull_ibeis_repos():
    """ Pull IBEIS repos """
    util_git.pull_repos(ibeis_repo_dirs)


def setup_develop_ibeis_repos():
    """ Install with setuptools using the develop flag """
    util_git.setup_develop_repos(ibeis_repo_dirs)


if __name__ == '__main__':
    if CHECK:
        checkout_ibeis_repos()
    if PULL:
        pull_ibeis_repos()
    if DEVELOP:
        setup_develop_ibeis_repos()
