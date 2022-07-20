<<<<<<< HEAD
USE CentralDB
GO

SELECT
	dfg.InstanceName,
	dfg.DBName,
	sl.Environment,
	dfg.DateAdded,
	dfgp.DBUsedSpaceInMB AS PreviousDBUsedSpaceInMB,
	dfg.DBUsedSpaceInMB AS LastDBUsedSpaceInMB,
	dfg.DBUsedSpaceInMB - dfgp.DBUsedSpaceInMB as DeltaDBUsedSpaceInMB,
	(dfg.DBUsedSpaceInMB / dfgp.DBUsedSpaceInMB * 100) - 100 as DeltaDBUsedSpaceInPct
FROM DB.DatabaseInfo dfg
INNER JOIN(
	SELECT 
		InstanceName,
		DBName,
		MAX(DateAdded) MaxDateAdded
	FROM DB.DatabaseInfo
	--WHERE InstanceName = 'RIACHU_FIN'
	GROUP BY InstanceName, DBName) dfgm ON dfg.InstanceName = dfgm.InstanceName 
										   AND dfg.DBName = dfgm.DBName 
										   AND dfg.DateAdded = dfgm.MaxDateAdded
INNER JOIN(
	SELECT
		InstanceName, 
		DBName,
		DateAdded,
		DBUsedSpaceInMB 
	FROM DB.DatabaseInfo) dfgp ON dfgp.InstanceName = dfg.InstanceName 
								  AND dfgp.DBName = dfg.DBName 
								  AND CAST(dfgp.DateAdded AS date) = DATEADD(dd,-7,CAST(dfg.DateAdded as DATE))
INNER JOIN svr.ServerList sl on sl.ServerName = dfg.ServerName and sl.InstanceName = dfg.InstanceName
ORDER BY DeltaDBUsedSpaceInMB DESC
=======
USE CentralDB
GO

SELECT
	dfg.InstanceName,
	dfg.DBName,
	sl.Environment,
	dfg.DateAdded,
	dfgp.DBUsedSpaceInMB AS PreviousDBUsedSpaceInMB,
	dfg.DBUsedSpaceInMB AS LastDBUsedSpaceInMB,
	dfg.DBUsedSpaceInMB - dfgp.DBUsedSpaceInMB as DeltaDBUsedSpaceInMB,
	(dfg.DBUsedSpaceInMB / dfgp.DBUsedSpaceInMB * 100) - 100 as DeltaDBUsedSpaceInPct
FROM DB.DatabaseInfo dfg
INNER JOIN(
	SELECT 
		InstanceName,
		DBName,
		MAX(DateAdded) MaxDateAdded
	FROM DB.DatabaseInfo
	--WHERE InstanceName = 'RIACHU_FIN'
	GROUP BY InstanceName, DBName) dfgm ON dfg.InstanceName = dfgm.InstanceName 
										   AND dfg.DBName = dfgm.DBName 
										   AND dfg.DateAdded = dfgm.MaxDateAdded
INNER JOIN(
	SELECT
		InstanceName, 
		DBName,
		DateAdded,
		DBUsedSpaceInMB 
	FROM DB.DatabaseInfo) dfgp ON dfgp.InstanceName = dfg.InstanceName 
								  AND dfgp.DBName = dfg.DBName 
								  AND CAST(dfgp.DateAdded AS date) = DATEADD(dd,-7,CAST(dfg.DateAdded as DATE))
INNER JOIN svr.ServerList sl on sl.ServerName = dfg.ServerName and sl.InstanceName = dfg.InstanceName
ORDER BY DeltaDBUsedSpaceInMB DESC
>>>>>>> d4022b1c698892c56d61a9072b03678cdc0fa4fe
