#!/usr/bin/env python
from __future__ import absolute_import, division, print_function
import sys
import util_git1
import REPOS1

# Get IBEIS git repository URLS and their local path
ibeis_repo_urls = REPOS1.CODE_REPO_URLS
ibeis_repo_dirs = REPOS1.CODE_REPOS


def checkout_ibeis_repos():
    """ Checkout IBEIS repos out if they don't exist """
    util_git1.checkout_repos(ibeis_repo_urls, ibeis_repo_dirs)


def pull_ibeis_repos():
    """ Pull IBEIS repos """
    util_git1.pull_repos(ibeis_repo_dirs)


def setup_develop_ibeis_repos():
    """ Install with setuptools using the develop flag """
    util_git1.setup_develop_repos(ibeis_repo_dirs)


if __name__ == '__main__':
    if '--nocheck' not in sys.argv:
        checkout_ibeis_repos()
        util_git1.checkout_repos(*REPOS1.LATEX_REPO_TUP)
    if '--pull' in sys.argv:
        pull_ibeis_repos()
    if '--develop' in sys.argv:
        setup_develop_ibeis_repos()
