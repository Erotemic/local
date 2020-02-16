:: Applies all updates d conversions from unix to windows
python %USERPROFILE%\local\ensure_vim_plugins.py --quick %*
python %USERPROFILE%\local\windows\updatescripts\translate_windows_aliases.py --force
REM call %USERPROFILE%\local\windows\updatescripts\update_vimfile_symlink.bat
