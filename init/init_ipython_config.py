#!/usr/bin/env python
"""
DEPRICATED. THIS IS NOW A SYMLINK


"""
from os.path import join
import ubelt as ub


def setup_extensions():
    """
    code

    git clone https://github.com/ipython-contrib/IPython-notebook-extensions.git
    cd IPython-notebook-extensions
    sudo python setup.py install

    sudo pip install jupyter
    sudo pip install ipython-extensions

    Jupyter setup is such a pain

    Graphical Config editor
    https://github.com/ipython-contrib/IPython-notebook-extensions/wiki/config-extension
    """


def write_default_ipython_profile():
    """
    CommandLine:
        python ~/local/init/init_ipython_config.py

        python -c "import xdev, ubelt; xdev.startfile(ubelt.truepath('~/.ipython/profile_default'))"
        python -c "import xdev, ubelt; xdev.editfile(ubelt.truepath('~/.ipython/profile_default/ipython_config.py'))"

    References:
        http://2sn.org/python/ipython_config.py
    """
    dpath = ub.expandpath('~/.ipython/profile_default')
    ub.ensuredir(dpath)
    ipy_config_fpath = join(dpath, 'ipython_config.py')
    ipy_config_text = ub.codeblock(
        r'''
        # STARTBLOCK
        import six
        c = get_config()  # NOQA
        c.InteractiveShellApp.exec_lines = []
        if six.PY2:
            future_line = (
                'from __future__ import absolute_import, division, print_function, with_statement, unicode_literals')
            c.InteractiveShellApp.exec_lines.append(future_line)
            # Fix sip versions
            try:
                import sip
                # http://stackoverflow.com/questions/21217399/pyqt4-qtcore-qvariant-object-instead-of-a-string
                sip.setapi('QVariant', 2)
                sip.setapi('QString', 2)
                sip.setapi('QTextStream', 2)
                sip.setapi('QTime', 2)
                sip.setapi('QUrl', 2)
                sip.setapi('QDate', 2)
                sip.setapi('QDateTime', 2)
                if hasattr(sip, 'setdestroyonexit'):
                    sip.setdestroyonexit(False)  # This prevents a crash on windows
            except ImportError as ex:
                pass
            except ValueError as ex:
                print('Warning: Value Error: %s' % str(ex))
                pass
        c.InteractiveShellApp.exec_lines.append('%load_ext autoreload')
        c.InteractiveShellApp.exec_lines.append('%autoreload 2')
        #c.InteractiveShellApp.exec_lines.append('%pylab qt4')
        c.InteractiveShellApp.exec_lines.append('import numpy as np')
        c.InteractiveShellApp.exec_lines.append('import ubelt as ub')
        c.InteractiveShellApp.exec_lines.append('import xdev')
        c.InteractiveShellApp.exec_lines.append('import pandas as pd')
        c.InteractiveShellApp.exec_lines.append('pd.options.display.max_columns = 40')
        c.InteractiveShellApp.exec_lines.append('pd.options.display.width = 160')
        c.InteractiveShellApp.exec_lines.append('pd.options.display.max_rows = 20')
        c.InteractiveShellApp.exec_lines.append('pd.options.display.float_format = lambda x: \'%.4f\' % (x,)')
        c.InteractiveShellApp.exec_lines.append('import networkx as nx')
        c.InteractiveShellApp.exec_lines.append('from os.path import *')
        c.InteractiveShellApp.exec_lines.append('from six.moves import cPickle as pickle')
        #c.InteractiveShellApp.exec_lines.append('if \'verbose\' not in vars():\\n    verbose = True')
        import ubelt as ub
        c.InteractiveShellApp.exec_lines.append(ub.codeblock(
            """
            class classproperty(property):
                def __get__(self, cls, owner):
                    return classmethod(self.fget).__get__(None, owner)()
            class vim(object):
                @classproperty
                def focus(cls):
                    from vimtk.cplat_ctrl import Window
                    Window.find('GVIM').focus()
                @classproperty
                def copy(cls):
                    import time
                    from vimtk.cplat_ctrl import Window
                    gvim_window = Window.find('GVIM')
                    gvim_window.focus()
                    import vimtk
                    import IPython
                    ipy = IPython.get_ipython()
                    lastline = ipy.history_manager.input_hist_parsed[-2]
                    vimtk.cplat.copy_text_to_clipboard(lastline)
                    from vimtk import xctrl
                    xctrl.XCtrl.do(
                        ('focus', 'GVIM'),
                        ('key', 'ctrl+v'),
                        ('focus', 'x-terminal-emulator.X-terminal-emulator')
                    )
            """
        ))
        #c.InteractiveShell.autoindent = True
        #c.InteractiveShell.colors = 'LightBG'
        #c.InteractiveShell.confirm_exit = False
        #c.InteractiveShell.deep_reload = True
        c.InteractiveShell.editor = 'gvim'
        #c.InteractiveShell.xmode = 'Context'
        # ENDBOCK
        '''
    )
    with open(ipy_config_fpath, 'w') as file:
        file.write(ipy_config_text + '\n')


if __name__ == '__main__':
    """
    CommandLine:
        python ~/local/init/init_ipython_config.py
    """
    write_default_ipython_profile()
