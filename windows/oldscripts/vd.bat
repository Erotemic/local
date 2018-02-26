@echo off
IF "%1"=="" GOTO open_here
ELSE GOTO open_there
:open_here
    explorer "%cd%
    GOTO eof
:open_there
    explorer "%1"
    GOTO eof
:eof
@echo on
