#!/usr/bin/env python
import git
import re


class GitRepo(git.Repo):
    def modified_files(repo):
        diff = repo.git.diff(name_only=True)
        modified_fpaths = diff.split('\n')
        return modified_fpaths

    def grep_diff(repo, pattern, inverse=False):
        matching_fpaths = []
        print('Matching Files:')
        fpath_list = repo.modified_files()
        for fpath in fpath_list:
            diff_text = repo.git.diff(fpath)
            flag = re.search(pattern, diff_text) is not None
            if inverse:
                flag = not flag
            if flag:
                print(fpath)
                matching_fpaths.append(fpath)
        print('Total files matched = {}'.format(len(matching_fpaths)))


repo = GitRepo('.')
repo.grep_diff('plugin', inverse=True)

"""
Do git add --patch on each of these

git add --patch sprokit/conf/sprokit-macro-python.cmake sprokit/src/bindings/python/processes/CMakeLists.txt sprokit/src/bindings/python/schedulers/CMakeLists.txt sprokit/src/bindings/python/test/python/modules/CMakeLists.txt
"""
