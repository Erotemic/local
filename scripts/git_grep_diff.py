#!/usr/bin/env python
import git
import re
from os.path import exists
import ubelt as ub

colorize = ub.color_text


class GrepMatch(object):
    def __init__(self, match, linex, text_slice, fpath=None):
        self.match = match
        self.linex = linex
        self.text_slice = text_slice
        self.fpath = fpath

    def highlighted_line(self):
        color = 'red'
        start = self.match.start() - self.text_slice.start
        end = self.match.end() - self.text_slice.start
        text = self.match.string
        line = text[self.text_slice]
        colored_part = colorize(line[start:end], color)
        highlighted_line = line[:start] + colored_part + line[end:]
        return highlighted_line

    def highlighted(self):
        if self.fpath is None:
            fpath = '<text>'
        else:
            fpath = self.fpath
        prefix = colorize(fpath, 'darkgray') + colorize(': ', 'turquoise')
        return prefix + self.highlighted_line()


def grep_text(pattern, text, fpath=None):
    import numpy as np
    # This is also the cumulative sum of line lengths
    newline_pos = [m.start() for m in re.finditer('\n', text)]
    newline_pos += [len(text)]
    newline_pos = np.array(newline_pos)

    for match in re.finditer(pattern, text):
        # matched line index
        linex = np.where(match.start() < newline_pos)[0][0:1][0]
        # Find the text-index of the start of the matched line
        if linex > 0:
            line_start = newline_pos[linex - 1] + 1
        else:
            line_start = 0
        # Find the text-index of the end of the matched line
        line_end = newline_pos[linex]
        text_slice = slice(line_start, line_end)
        gmatch = GrepMatch(match, linex, text_slice, fpath=fpath)
        yield gmatch


class GitRepo(git.Repo):
    def modified_files(repo):
        diff = repo.git.diff(name_only=True)
        modified_fpaths = diff.split('\n')
        return modified_fpaths

    def grep_diff(repo, pattern, inverse=False):
        matching_fpaths = []
        print('Matching Files:')
        fpath_list = [f for f in repo.modified_files() if exists(f)]
        for fpath in fpath_list:
            text = repo.git.diff(fpath)
            matches = list(grep_text(pattern, text, fpath))

            if inverse:
                if not matches:
                    matching_fpaths.append(fpath)
            else:
                if matches:
                    for gmatch in matches:
                        print(gmatch.highlighted())
                    matching_fpaths.append(fpath)

        print('Total files matched = {}'.format(len(matching_fpaths)))
        print(ub.indent('\n'.join(matching_fpaths), ' * '))


def main(argv):
    """
    Developer:
        >>> import sys
        >>> sys.path.append('/home/joncrall/local/scripts')
        >>> from git_grep_diff import *
        >>> argv = ['dummy', 'module']
    """

    if len(argv) <= 1:
        print('argv = {!r}'.format(argv))
        raise ValueError('must specify a pattern to match')

    pattern = argv[-1]
    inverse = ('-v' in argv)

    repo = GitRepo('.')
    repo.grep_diff(pattern, inverse=inverse)


if __name__ == '__main__':
    r"""
    CommandLine:
        export PYTHONPATH=$PYTHONPATH:/home/joncrall/local/scripts
        python ~/local/scripts/git_grep_diff.py
    """
    import sys
    main(sys.argv)

# repo = GitRepo('.')
# repo.grep_diff('plugin', inverse=True)
# """
# Do git add --patch on each of these
# git add --patch sprokit/conf/sprokit-macro-python.cmake sprokit/src/bindings/python/processes/CMakeLists.txt sprokit/src/bindings/python/schedulers/CMakeLists.txt sprokit/src/bindings/python/test/python/modules/CMakeLists.txt
# """
