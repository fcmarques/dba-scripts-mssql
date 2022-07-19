<<<<<<< HEAD
@@echo off

del errors /f /s /q

rd Errors

md Errors

FOR %%A IN (*.SQL) DO ( sqlcmd -S SERVERNAME -d DATABASE1 -U username -P password -i "%%A" -o "Errors\%%AError_DB1.txt" -I )

=======
@@echo off

del errors /f /s /q

rd Errors

md Errors

FOR %%A IN (*.SQL) DO ( sqlcmd -S SERVERNAME -d DATABASE1 -U username -P password -i "%%A" -o "Errors\%%AError_DB1.txt" -I )

>>>>>>> d4022b1c698892c56d61a9072b03678cdc0fa4fe
FOR %%A IN (*.SQL) DO ( sqlcmd -S SERVERNAME -d DATABASE2 -U username -P password -i "%%A" -o "Errors\%%AError_DB2.txt" -I )