set logFilename=exec_%DATE:~6,4%%DATE:~3,2%%DATE:~0,2%%TIME:~0,2%%TIME:~3,2%%TIME:~6,2%
for %f in (*.sql) do sqlcmd /S <servername> /d <dbname> /E /i "%f" > %logFilename%.log