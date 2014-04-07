@echo off
nircmd.exe exec hide ^
 ipython qtconsole ^
 --colors=Linux ^
 --pylab=qt ^
 --matplotlib qt4 ^
 --ConsoleWidget.font_size=9 ^
 --ConsoleWidget.font_family="Mono Dyslexic" ^
 --autocall 2


:: cd %1
:: NirCMD exec hide ipython qtconsole ^
::^
:: :b: --profile default 
:: --profile default 
@echo on
