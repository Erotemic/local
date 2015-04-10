#/usr/bin/env python
import utool as ut


def clean_mitex():
    # if mitex does not install correctly
    install_dir = 'C:\Program Files (x86)\MiKTeX 2.9'
    ut.delete(install_dir)


def install_mathtools():
    """

    wget http://mirrors.ctan.org/install/macros/latex/contrib/mathtools.tds.zip
    mkdir tmp2
    #7z x -o"tmp2" mathtools.tds.zip
    7z x -o"C:/Program Files (x86)/MiKTeX 2.9" mathtools.tds.zip

    """
    pass


if __name__ == '__main__':
    """
    python %USERPROFILE%/local/windows/init_mitex.py
    """
    assert ut.WIN32
    url = 'http://mirrors.ctan.org/systems/win32/miktex/setup/basic-miktex-2.9.5105.exe'
    fpath = ut.grab_file_url(url)
    ut.cmd(fpath)



