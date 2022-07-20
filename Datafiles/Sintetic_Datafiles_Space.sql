<<<<<<< HEAD
WITH dbfiles
AS (
	SELECT 
		Db_name() AS database_name, Cast((f.size / 128.0) AS DECIMAL(15, 2)) AS [Total Size in MB], 
		Cast(f.size / 128.0 - Cast(Fileproperty(f.NAME, 'SpaceUsed') AS INT) / 128.0 AS DECIMAL(15, 2)) AS [Available Space In MB]
	FROM sys.database_files AS f WITH (NOLOCK)
	LEFT JOIN sys.data_spaces AS fg WITH (NOLOCK)
		ON f.data_space_id = fg.data_space_id
	WHERE f.type = 0
	)
SELECT 
	database_name, Sum([total size in mb]) AS [Total Size in MB], 
	Sum([available space in mb]) AS [Available Space In MB], 100 - (Sum([available space in mb]) / Sum([total size in mb]) * 100) AS [Pct Used], 
	CASE 
		WHEN Sum([total size in mb]) > 1000000 THEN 'VLDB'
		WHEN Sum([total size in mb]) BETWEEN 100000	AND 1000000 THEN 'LDB'
		WHEN Sum([total size in mb]) < 100000 THEN 'SDB'
	END AS [DB Category]
FROM dbfiles
GROUP BY database_name
OPTION (RECOMPILE);
=======
WITH dbfiles
AS (
	SELECT 
		Db_name() AS database_name, Cast((f.size / 128.0) AS DECIMAL(15, 2)) AS [Total Size in MB], 
		Cast(f.size / 128.0 - Cast(Fileproperty(f.NAME, 'SpaceUsed') AS INT) / 128.0 AS DECIMAL(15, 2)) AS [Available Space In MB]
	FROM sys.database_files AS f WITH (NOLOCK)
	LEFT JOIN sys.data_spaces AS fg WITH (NOLOCK)
		ON f.data_space_id = fg.data_space_id
	WHERE f.type = 0
	)
SELECT 
	database_name, Sum([total size in mb]) AS [Total Size in MB], 
	Sum([available space in mb]) AS [Available Space In MB], 100 - (Sum([available space in mb]) / Sum([total size in mb]) * 100) AS [Pct Used], 
	CASE 
		WHEN Sum([total size in mb]) > 1000000 THEN 'VLDB'
		WHEN Sum([total size in mb]) BETWEEN 100000	AND 1000000 THEN 'LDB'
		WHEN Sum([total size in mb]) < 100000 THEN 'SDB'
	END AS [DB Category]
FROM dbfiles
GROUP BY database_name
OPTION (RECOMPILE);
>>>>>>> d4022b1c698892c56d61a9072b03678cdc0fa4fe
