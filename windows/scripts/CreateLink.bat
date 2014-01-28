
@echo off

for %%F in (%1) do echo %%~nxF
@echo on

MKLINK /D %~nx1 %1
pause
