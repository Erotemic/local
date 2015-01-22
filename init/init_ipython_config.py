#/usr/bin/env python
import utool as ut


def write_default_ipython_profile():
    """
    References:
        http://2sn.org/python/ipython_config.py
    """
    ipy_config_fpath = ut.unixpath('~/.ipython/profile_default/ipython_config.py')
    ipy_config_text = ut.codeblock(
        '''
        c = get_config()  # NOQA
        c.InteractiveShellApp.exec_lines = []
        c.InteractiveShellApp.exec_lines.append('from __future__ import division')
        c.InteractiveShellApp.exec_lines.append('from __future__ import print_function')
        c.InteractiveShellApp.exec_lines.append('from __future__ import with_statement')
        c.InteractiveShellApp.exec_lines.append('from __future__ import absolute_import')
        c.InteractiveShellApp.exec_lines.append('%load_ext autoreload')
        c.InteractiveShellApp.exec_lines.append('%autoreload 2')
        c.InteractiveShellApp.exec_lines.append('%pylab qt')
        c.InteractiveShellApp.exec_lines.append('import numpy as np')
        c.InteractiveShellApp.exec_lines.append('import utool as ut')
        '''
    )
    ut.write_to(ipy_config_fpath, ipy_config_text)


def main():
    write_default_ipython_profile()


if __name__ == '__main__':
    """
    CommandLine:
        python ~/local/init/init_ipython_config.py
    """
    main()
