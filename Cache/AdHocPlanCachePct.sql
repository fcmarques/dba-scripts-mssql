<<<<<<< HEAD
-- If your adhoc plan cache is 20-30% of total Plan Cache, you should turn on the Optimize for Ad Hoc Workloads
SELECT AdHoc_Plan_MB, Total_Cache_MB,
		AdHoc_Plan_MB*100.0 / Total_Cache_MB AS 'AdHoc %'
FROM (
SELECT SUM(CASE 
			WHEN objtype = 'adhoc'
			THEN cast(size_in_bytes as bigint)
			ELSE 0 END) / 1048576.0 AdHoc_Plan_MB,
        SUM(cast(size_in_bytes as bigint)) / 1048576.0 Total_Cache_MB 
=======
-- If your adhoc plan cache is 20-30% of total Plan Cache, you should turn on the Optimize for Ad Hoc Workloads
SELECT AdHoc_Plan_MB, Total_Cache_MB,
		AdHoc_Plan_MB*100.0 / Total_Cache_MB AS 'AdHoc %'
FROM (
SELECT SUM(CASE 
			WHEN objtype = 'adhoc'
			THEN cast(size_in_bytes as bigint)
			ELSE 0 END) / 1048576.0 AdHoc_Plan_MB,
        SUM(cast(size_in_bytes as bigint)) / 1048576.0 Total_Cache_MB 
>>>>>>> d4022b1c698892c56d61a9072b03678cdc0fa4fe
FROM sys.dm_exec_cached_plans) T