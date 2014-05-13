from __future__ import absolute_import, division, print_function
import sys
import os
from os.path import expanduser

__REPOS__ = map(expanduser, [
    '~/code/opencv',
    '~/code/flann',
    #'~/latex/crall-lab-notebook',
    #'~/latex/crall-candidacy-2013',
    '~/local',
    '~/code/hesaff',
    '~/code/ibeis',
    '~/code/pyrf',
])


def _gitcmd(repo, command):
    print()
    print("************")
    print(repo)
    os.chdir(repo)
    os.system(command)
    print("************")


def gg_command(command):
    for repo in __REPOS__:
        _gitcmd(repo, command)


if __name__ == '__main__':
    locals_ = locals()
    command = sys.argv[1]
    # Apply command to all repos
    gg_command(command)
