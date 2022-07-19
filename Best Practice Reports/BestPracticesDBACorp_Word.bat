<<<<<<< HEAD
@ECHO OFF
SET ThisScriptsDirectory=%~dp0
SET PowerShellScriptPath=%ThisScriptsDirectory%BestPracticesDBACorp_Word.ps1
PowerShell -NoProfile -ExecutionPolicy Bypass -Command "& {Start-Process PowerShell -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File ""%PowerShellScriptPath%"" -templatepath "D:\Cloud\Dropbox\Scripts\SQL Server\Best Practice Reports\DBACorp_Modelo.dot" ' -Verb RunAs }";
=======
@ECHO OFF
SET ThisScriptsDirectory=%~dp0
SET PowerShellScriptPath=%ThisScriptsDirectory%BestPracticesDBACorp_Word.ps1
PowerShell -NoProfile -ExecutionPolicy Bypass -Command "& {Start-Process PowerShell -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File ""%PowerShellScriptPath%"" -templatepath "D:\Cloud\Dropbox\Scripts\SQL Server\Best Practice Reports\DBACorp_Modelo.dot" ' -Verb RunAs }";
>>>>>>> d4022b1c698892c56d61a9072b03678cdc0fa4fe
pause