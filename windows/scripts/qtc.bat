:: @echo off
cd %USERPROFILE%\code\ibeis

nircmd.exe exec hide ^
 ipython qtconsole ^
 --colors=Linux ^
 --pylab=qt4 ^
 --matplotlib qt4 ^
 --gui=qt4 ^
 --ConsoleWidget.font_size=9 ^
 --ConsoleWidget.font_family="Mono Dyslexic" 

:: --gui=qt
:: --editor=gvim
 :: --matplotlib qt4 ^
 :: --pylab=qt ^
:: cd %1
:: NirCMD exec hide ipython qtconsole ^
::^
:: :b: --profile default 
:: --profile default 
 :: --autocall 2
:: @echo on
