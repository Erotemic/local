:: cd %1
:: @echo off
NirCMD exec hide ipython qtconsole ^
--autocall 2 ^
--colors=Linux ^
--pylab=qt ^
--ConsoleWidget.font_size=9 ^
--ConsoleWidget.font_family="Mono Dyslexic" 

::^
:b: --profile default 
:: @echo on
