#!/usr/bin/env python
import os
from os.path import expanduser

bundledir = expanduser('~/local/vim/vimfiles/bundle')
os.chdir(bundledir)

vim_repos = os.listdir(bundledir)

for repo in vim_repos:
    os.chdir(repo)
    os.system('git pull')
    os.chdir('..')
