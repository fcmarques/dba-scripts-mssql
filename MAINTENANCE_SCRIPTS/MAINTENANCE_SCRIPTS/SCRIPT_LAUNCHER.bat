@echo off

SET SQLCMDUSER=sa
SET SQLCMDPASSWORD=00000
SET SQLCMDSERVER=LOCALHOST
SET DBAFOLDER=C:\DBACORP

FOR /F "TOKENS=1 DELIMS=/" %%F IN ("%DATE%") do set dd=%%F
FOR /F "TOKENS=2 DELIMS=/" %%G IN ("%DATE%") do set mm=%%G
FOR /F "TOKENS=3 DELIMS=/" %%H IN ("%DATE%") do set yyyy=%%H

SET vardate=%yyyy%%mm%%dd%

SQLCMD -i %DBAFOLDER%\scripts\%1.sql -o %DBAFOLDER%\logs\%1_%vardate%.log