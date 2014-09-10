:: https://github.com/Erotemic/local
:: 
::WGET
:: https://www.gnu.org/software/wget/
:: This sets up the bare windows8 system
:: with my basic preferences
:: "https://github.com/Erotemic/local/archive/master.zip"
call %USERPROFILE%\batrc.bat

:: Write bat file\
cd %LOCAL_DIR%
mkdir %PATH_DIR%
mkdir %BAT_DIR%
cd %BAT_DIR%


echo cd %LOCAL_DIR% > %BAT_DIR%\loc.bat
echo cd %HOME% > %BAT_DIR%\home.bat


:: TEST 
echo "testing loc.bat"
call loc.bat


:: Install Drivers
::------------------------------------------
:: Install WGET
:: http://gnuwin32.sourceforge.net/packages/wget.htm

cd %HOME%/local
mkdir tmp
cd %HOME%/local/tmp

:: Install 7zip

:: INSTALL MSYS2
cd %HOME%\Downloads
7z x msys2-base-x86_64-20140216.tar.xz
7z x msys2-base-x86_64-20140216.tar
move msys64 %PATH_DIR%

:: Install GVIM
set GVIM_EXE="ftp://ftp.vim.org/pub/vim/pc/gvim74.exe"
%BIN_DIR%\wget.exe %GVIM_EXE%


:: TrueCrypt

:: Install Python 
wget "http://www.python.org/ftp/python/2.7.6/python-2.7.6.msi"
wget "http://www.python.org/ftp/python/2.7.6/python-2.7.6.msi.asc"
set PYMD5=ac54e14f7ba180253b9bae6635d822ea *python-2.7.6.msi

md5sum python-2.7.6.msi > tmppymd5
set /p PYMD5_VAL= < tmppymd5
del tmppymd5

if "%PYMD5%" NEQ "%PYMD5_VAL%" (goto :end)

gpg --keyserver keys.gnupg.net
gpg --recv-keys 7D9DC8D2 :: martin v lowis's key

:: -----BEGIN PGP SIGNATURE-----
:: Version: GnuPG v2.0.14 (MingW32)

:: iEYEABECAAYFAlJ/0PoACgkQavBT8H2dyNKXVACbBkw9kPevZWyo9232MRlNZ8z1
:: 9/IAn0Weq/jnKXpxb0kcPaKZvgq5ALH2
:: =nGuj
:: -----END PGP SIGNATURE-----

:: Install GIT


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
:: Dropbox
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
