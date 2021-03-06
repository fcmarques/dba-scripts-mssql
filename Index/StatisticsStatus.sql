SELECT ss.NAME AS SchemaName
	,st.NAME AS TableName
	,s.NAME AS IndexName
	,STATS_DATE(s.id, s.indid) AS 'Statistics Last Updated'
	,s.rowcnt AS 'Row Count'
	,s.rowmodctr AS 'Number Of Changes'
	,CAST((CAST(s.rowmodctr AS DECIMAL(28, 8)) / CAST(s.rowcnt AS DECIMAL(28, 2)) * 100.0) AS DECIMAL(28, 2)) AS '% Rows Changed'
FROM sys.sysindexes s
INNER JOIN sys.tables st ON st.[object_id] = s.[id]
INNER JOIN sys.schemas ss ON ss.[schema_id] = st.[schema_id]
WHERE s.id > 100
	AND s.indid > 0
	AND s.rowcnt >= 500
ORDER BY '% Rows Changed' DESC
	,SchemaName
	,TableName
	,IndexName
