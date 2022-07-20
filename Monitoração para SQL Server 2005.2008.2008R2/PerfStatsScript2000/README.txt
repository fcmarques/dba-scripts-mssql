*** Deleteoldlogs - V1.0 by Guilherme Carnevale
Usage: DeleteOldFiles /D:[Directory] /N:[Number of days old] /R{recurse subdirs} /F:[FileName]{ex10#} /T{Clean blank folders}

Examples: 
DeleteOldFiles /D:D:\logs /N:3 /R 
 - Delete all files inside folder d:\logs that are older than 3 days, including in subdirectories.


DeleteOldFiles /D:D:\logs /N:7 /F:ex10#
 - Delete all files inside folder d:\logs that are older than 7 days that start with ex10.


DeleteOldFiles /D:D:\logs /N:15 /R /T
 - Delete all files inside folder d:\logs that are older than 15 days including in subdirectories and delete subdirectories with 0 files.


Question/Suggestions to: gcarneva@microsoft.com
 

