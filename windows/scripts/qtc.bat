:: cd %1
:: @echo off
:: NirCMD exec hide ipython qtconsole ^
ipython qtconsole ^
--autocall 2 ^
--colors=Linux ^
--pylab=auto ^
--ConsoleWidget.font_size=9 ^
--ConsoleWidget.font_family="Mono Dyslexic"  ^
--profile default 
:: @echo on
