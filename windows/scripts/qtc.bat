:: cd %1
:: @echo off
:: NirCMD exec hide ipython qtconsole ^
NirCMD exec hide ipython qtconsole ^
ipython qtconsole ^
--autocall 2 ^
--colors=Linux ^
--pylab=qt ^
--matplotlib qt4 ^
--ConsoleWidget.font_size=9 ^
--ConsoleWidget.font_family="Mono Dyslexic" 
::^
:: :b: --profile default 
:: --profile default 
:: @echo on
