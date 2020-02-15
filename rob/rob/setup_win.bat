:: USERDOMAIN=Ooo

MKLINK /D Dropbox C:\Users\jon.crall\Dropbox

CreateShortcut "C:\Program Files (x86)\Cisco\Cisco AnyConnect Secure Mobility Client\vpnui.exe" %STARTUP%

CreateShortcut %PORT_KEYS%\%USERDOMAIN%\ssh_priv.ppk %STARTUP%

AddToPath %PORT_APPS%\putty
export GIT_SSH=plink.exe
