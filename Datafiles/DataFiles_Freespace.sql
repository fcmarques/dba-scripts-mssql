<<<<<<< HEAD
USE master
GO

SELECT NAME = left(a.NAME, 15)
	,FILENAME = left(a.FILENAME, 30)
	,a.FILEID
	,[FILE_SIZE_MB] = convert(DECIMAL(12, 2), round(a.size / 128.000, 2))
	,[SPACE_USED_MB] = convert(DECIMAL(12, 2), round(fileproperty(a.NAME, 'SpaceUsed') / 128.000, 2))
	,[FREE_SPACE_MB] = convert(DECIMAL(12, 2), round((a.size - fileproperty(a.NAME, 'SpaceUsed')) / 128.000, 2))
INTO #temp_db_free_space
FROM dbo.sysfiles a
WHERE 0 = 1

EXEC sp_MSforeachdb '
use ?
insert into  #temp_db_free_space
select
NAME = left(a.NAME,15),
FILENAME = left(a.FILENAME,30),
a.FILEID,
[FILE_SIZE_MB] = 
convert(decimal(12,2),round(a.size/128.000,2)),
[SPACE_USED_MB] =
convert(decimal(12,2),round(fileproperty(a.name,''SpaceUsed'')/128.000,2)),
[FREE_SPACE_MB] =
convert(decimal(12,2),round((a.size-fileproperty(a.name,''SpaceUsed''))/128.000,2)) 
from
dbo.sysfiles a
'

SELECT *
FROM #temp_db_free_space
ORDER BY 1
	,2

DROP TABLE #temp_db_free_space
=======
USE master
GO

SELECT NAME = left(a.NAME, 15)
	,FILENAME = left(a.FILENAME, 30)
	,a.FILEID
	,[FILE_SIZE_MB] = convert(DECIMAL(12, 2), round(a.size / 128.000, 2))
	,[SPACE_USED_MB] = convert(DECIMAL(12, 2), round(fileproperty(a.NAME, 'SpaceUsed') / 128.000, 2))
	,[FREE_SPACE_MB] = convert(DECIMAL(12, 2), round((a.size - fileproperty(a.NAME, 'SpaceUsed')) / 128.000, 2))
INTO #temp_db_free_space
FROM dbo.sysfiles a
WHERE 0 = 1

EXEC sp_MSforeachdb '
use ?
insert into  #temp_db_free_space
select
NAME = left(a.NAME,15),
FILENAME = left(a.FILENAME,30),
a.FILEID,
[FILE_SIZE_MB] = 
convert(decimal(12,2),round(a.size/128.000,2)),
[SPACE_USED_MB] =
convert(decimal(12,2),round(fileproperty(a.name,''SpaceUsed'')/128.000,2)),
[FREE_SPACE_MB] =
convert(decimal(12,2),round((a.size-fileproperty(a.name,''SpaceUsed''))/128.000,2)) 
from
dbo.sysfiles a
'

SELECT *
FROM #temp_db_free_space
ORDER BY 1
	,2

DROP TABLE #temp_db_free_space
>>>>>>> d4022b1c698892c56d61a9072b03678cdc0fa4fe
