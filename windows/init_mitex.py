#/usr/bin/env python
import utool as ut


def clean_mitex():
    # if mitex does not install correctly
    install_dir = 'C:\Program Files (x86)\MiKTeX 2.9'
    ut.delete(install_dir)

if __name__ == '__main__':
    """
    python %USERPROFILE%/local/windows/init_mitex.py
    """
    assert ut.WIN32
    url = 'http://mirrors.ctan.org/systems/win32/miktex/setup/basic-miktex-2.9.5105.exe'
    fpath = ut.grab_file_url(url)
    ut.cmd(fpath)
