#/usr/bin/env python
import utool as ut


def write_default_ipython_profile():
    """
    CommandLine:
        python -c "import utool as ut; ut.vd(ut.unixpath('~/.ipython/profile_default'))"
        python -c "import utool as ut; ut.editfile(ut.unixpath('~/.ipython/profile_default/ipython_config.py'))"

    References:
        http://2sn.org/python/ipython_config.py
    """
    dpath = ut.unixpath('~/.ipython/profile_default')
    ut.ensuredir(dpath, info=True, verbose=True)
    ipy_config_fpath = ut.unixjoin(dpath, 'ipython_config.py')
    ipy_config_text = ut.codeblock(
        '''
        c = get_config()  # NOQA
        c.InteractiveShellApp.exec_lines = []
        c.InteractiveShellApp.exec_lines.append('from __future__ import division')
        c.InteractiveShellApp.exec_lines.append('from __future__ import print_function')
        c.InteractiveShellApp.exec_lines.append('from __future__ import with_statement')
        c.InteractiveShellApp.exec_lines.append('from __future__ import absolute_import')
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
        except ValueError as ex:
            print('Warning: Value Error: %s' % str(ex))
            pass
        c.InteractiveShellApp.exec_lines.append('%load_ext autoreload')
        c.InteractiveShellApp.exec_lines.append('%autoreload 2')
        c.InteractiveShellApp.exec_lines.append('%pylab qt4')
        c.InteractiveShellApp.exec_lines.append('import numpy as np')
        c.InteractiveShellApp.exec_lines.append('import utool as ut')
        c.InteractiveShellApp.exec_lines.append('import plottool as pt')
        #c.InteractiveShell.autoindent = True
        #c.InteractiveShell.colors = 'LightBG'
        #c.InteractiveShell.confirm_exit = False
        #c.InteractiveShell.deep_reload = True
        c.InteractiveShell.editor = 'gvim'
        #c.InteractiveShell.xmode = 'Context'
        '''
    )
    ut.write_to(ipy_config_fpath, ipy_config_text)


def main():
    write_default_ipython_profile()


if __name__ == '__main__':
    """
    CommandLine:
        python ~/local/init/init_ipython_config.py
        python local/init/init_ipython_config.py
        python init_ipython_config.py
    """
    main()
