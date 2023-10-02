import textwrap
c = get_config()  # NOQA
c.InteractiveShellApp.exec_lines = []
# if six.PY2:
#     future_line = (
#         'from __future__ import absolute_import, division, print_function, with_statement, unicode_literals')
#     c.InteractiveShellApp.exec_lines.append(future_line)
#     # Fix sip versions
#     try:
#         import sip
#         # http://stackoverflow.com/questions/21217399/pyqt4-qtcore-qvariant-object-instead-of-a-string
#         sip.setapi('QVariant', 2)
#         sip.setapi('QString', 2)
#         sip.setapi('QTextStream', 2)
#         sip.setapi('QTime', 2)
#         sip.setapi('QUrl', 2)
#         sip.setapi('QDate', 2)
#         sip.setapi('QDateTime', 2)
#         if hasattr(sip, 'setdestroyonexit'):
#             sip.setdestroyonexit(False)  # This prevents a crash on windows
#     except ImportError:
#         pass
#     except ValueError as ex:
#         print('Warning: Value Error: %s' % str(ex))


c.InteractiveShellApp.exec_lines.append('%load_ext autoreload')
c.InteractiveShellApp.exec_lines.append('%autoreload 2')
#c.InteractiveShellApp.exec_lines.append('%pylab qt4')
c.InteractiveShellApp.exec_lines.append(textwrap.dedent(
    '''
    # https://stackoverflow.com/questions/70766518/how-to-change-ipython-error-highlighting-color
    try:
        from IPython.core import ultratb
        ultratb.VerboseTB._tb_highlight = "bg:ansired"
    except Exception:
        print("Error patching background color for tracebacks, they'll be the ugly default instead")
    try:
        import numpy as np
    except ImportError:
        ...
    try:
        import ubelt as ub
    except ImportError:
        ...
    try:
        import xdev
        import xdev as xd
    except ImportError:
        ...
    ''').strip())


# c.InteractiveShellApp.exec_lines.append('import xdev')
# c.InteractiveShellApp.exec_lines.append('import pandas as pd')
# c.InteractiveShellApp.exec_lines.append('pd.options.display.max_columns = 40')
# c.InteractiveShellApp.exec_lines.append('pd.options.display.width = 160')
# c.InteractiveShellApp.exec_lines.append('pd.options.display.max_rows = 20')
# c.InteractiveShellApp.exec_lines.append('pd.options.display.float_format = lambda x: \'%.4f\' % (x,)')
# c.InteractiveShellApp.exec_lines.append('import networkx as nx')
c.InteractiveShellApp.exec_lines.append('from os.path import *')
c.InteractiveShellApp.exec_lines.append('import pathlib')
c.InteractiveShellApp.exec_lines.append('from pathlib import Path')

try:
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
except ImportError:
    pass
#c.InteractiveShell.autoindent = True
#c.InteractiveShell.colors = 'LightBG'
#c.InteractiveShell.confirm_exit = False
#c.InteractiveShell.deep_reload = True
# c.InteractiveShell.editor = 'gvim'
#c.InteractiveShell.xmode = 'Context'
# ENDBOCK
