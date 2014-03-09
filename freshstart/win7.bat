:: This sets up the bare windows7 system
:: with my basic preferences

:: Installed drivers
:: Installed chrome
:: Installed dropbox

:: Dropbox

"https://github.com/Erotemic/local/archive/master.zip"

set HOME=%USERPROFILE%
set APP_PATH=%HOME%\local\apps
set PATH=%APP_PATH%;%PATH%

:: Install Drivers

:: Install WGET
:: http://gnuwin32.sourceforge.net/packages/wget.htm
set WGET=%APP_PATH%\wget.exe


:: Install GVIM
set GVIM_EXE="ftp://ftp.vim.org/pub/vim/pc/gvim74.exe"

:: TrueCrypt

:: Install Python 
wget "http://www.python.org/ftp/python/2.7.6/python-2.7.6.msi"
wget "http://www.python.org/ftp/python/2.7.6/python-2.7.6.msi.asc"

md5sum python-2.7.6.msi > tmppymd5
set /p PYMD5_VAL= < tmppymd5
del tmppymd5

set PYMD5=ac54e14f7ba180253b9bae6635d822ea *python-2.7.6.msi

if "%PYMD5%" NEQ "%PYMD5_VAL%" (
    echo "md5 failed" 
    goto :exit_fail
    ) else (
    echo "md5 passed"
    )

gpg --keyserver keys.gnupg.net
gpg --recv-keys 7D9DC8D2 :: martin v lowis's key

:: -----BEGIN PGP SIGNATURE-----
:: Version: GnuPG v2.0.14 (MingW32)

:: iEYEABECAAYFAlJ/0PoACgkQavBT8H2dyNKXVACbBkw9kPevZWyo9232MRlNZ8z1
:: 9/IAn0Weq/jnKXpxb0kcPaKZvgq5ALH2
:: =nGuj
:: -----END PGP SIGNATURE-----

:: Install GIT

:: Install 7zip

:: Install MinGW

:: Install AutoHotKey
set AHK_URL="http://l.autohotkey.net/AutoHotkey_L_Install.exe"

:: Install Chrome

:: Install Steam

:: Install Windows Updates

:: FileZilla

:: WinSplit Revolution

:: Install Spotify
::
:: Install RapidEE
::
:: Install Cisco VPN
::
::
:: Install Other:
:: Sumatra
:: VLC
:: Audacity
:: PS
:: GhostScript
:: Microsoft Security Essentials
:: Zotero
:: Dia
:: Flux
:: Inno Setup 5
:: LibreOffice
:: MiTeX 2.9
:: PeerBlock
:: Reaper
:: Skype
:: StarCraft2
:: GnuWin32?
:: Github?

:exit_success
echo "SUCCESS"

:exit_fail
echo "FAILURE!"
