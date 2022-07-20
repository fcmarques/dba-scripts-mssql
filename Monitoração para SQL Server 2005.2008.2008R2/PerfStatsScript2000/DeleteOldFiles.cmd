@echo off
REM Delete Files older than 2 days

%cd%\DeleteOldLogs.exe /D:%cd%\Output /N:2 /R /T