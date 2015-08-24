

"""
cd %HOME%
mkdir tmp
cd tmp

wget http://www.woogerworks.com/files/cockatrice.weeklybuilds/Cockatrice-WindowsClient.exe
Cockatrice-WindowsClient.exe
"""


def install_ansicon():
    """ lets windows console display ansii
    References:
        http://www.liferay.com/web/igor.spasic/blog/-/blogs/enable-ansi-colors-in-windows-command-prompt

    """
    #http://adoxa.altervista.org/ansicon/dl.php?f=ansicon
    pass


def install_cockatrice():
    cockatrice_url = 'http://www.woogerworks.com/files/cockatrice.weeklybuilds/Cockatrice-WindowsClient.exe'
    import utool as ut
    fpath = ut.grab_file_url(cockatrice_url)
    # run setup script
    ut.cmd(fpath)
    # press enter a few times
    import win32com.client as w32
    shell = w32.Dispatch("WScript.Shell")
    shell.AppActivate('Cockatrice Setup')
    shell.SendKeys("{ENTER}")
    shell.SendKeys("{ENTER}")
    shell.SendKeys("{ENTER}")
    shell.SendKeys("{ENTER}")

    # need msvcp120.dll

    #https://www.microsoft.com/en-us/download/details.aspx?id=40784

    #import win32gui
    #import win32api
    #import win32con

    #def window_handle(Title):
    #    hwnd = win32gui.FindWindowEx(0, 0, 0, Title)
    #    return hwnd

    #def click_btn(hwnd, Button):
    #    hbutton = win32gui.FindWindowEx(hwnd, 0, "Button", Button)
    #    if hbutton != 0:
    #        win32api.PostMessage(hbutton, win32con.WM_LBUTTONDOWN, 0, 0)
    #        win32api.PostMessage(hbutton, win32con.WM_LBUTTONUP, 0, 0)
    #        return True
    #    return None

    #click_btn(hwnd, "&Install")

    #window_title = 'Cockatrice Setup'
    #hwnd = win32gui.FindWindowEx(0, 0, 0, window_title)
    #assert hwnd != 0
    #btnHnd= win32gui.FindWindowEx(hwnd, 0 , "Button", "Cancel")
    #print(btnHnd)
    #btnHnd= win32gui.FindWindowEx(hwnd, 0 , "Button", "Next")
    #print(btnHnd)
    #btnHnd= win32gui.FindWindowEx(hwnd, 0 , "Button", "")
    #button_name = 'Next'
    #hbutton = win32gui.FindWindowEx(hwnd, 0, "Button", button_name)
    #assert hbutton != 0, 'could not find button'

