/* Script to Detect Bottlenecks about databases on a system */

/* Copyright 2013 Fusion-io, Inc. */
 
/*
 *  This program is free software; you can redistribute it and/or modify it under the terms of the 
 *  GNU General Public License version 2 as published by the Free Software Foundation;
 *  This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; 
 *  without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  
 *  See the GNU General Public License v2 for more details.
 * 
 *  A copy of the GNU General Public License v2 can be found at: http://www.gnu.org/licenses/old-licenses/gpl-2.0.html  
 *  You should have received a copy of the GNU General Public License along with this program; if not, write to the 
 *  Free Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA. 
 */


/* How long between each sample */
DECLARE @SampleDelay VARCHAR(16) 
SET @SampleDelay ='00:00:01.000'

/* How many samples to acquire. If set to zero, will report since last stat reset */
DECLARE @NumSamples INT
SET @NumSamples = 0

/* -------------------------------------- */

/* Initial magic chants */
SET NOCOUNT ON


IF OBJECT_ID('tempdb..#io_samples') IS NOT NULL DROP TABLE #io_samples
CREATE TABLE #io_samples
(
	  file_id BIGINT
	, [file] NVARCHAR(255)
	, allocated_space_mb DECIMAL(16,3)
	, used_space_mb DECIMAL(16,3)
	, file_type NVARCHAR(255)
	, read_operations BIGINT
	, read_kb BIGINT
	, read_latency_ms DECIMAL(16,3)
	, write_operations BIGINT
	, write_kb BIGINT
	, write_latency_ms DECIMAL(16,3)
	, server_name NVARCHAR(MAX)
	, database_id INT
	, database_name NVARCHAR(MAX)
	, mount_point NVARCHAR(MAX)
	, file_group NVARCHAR(MAX)
	, [file_name] NVARCHAR(MAX)
  , num_VLF BIGINT
	, sample_number INT
	, sample_time DATETIME
)
CREATE UNIQUE CLUSTERED INDEX CIX ON #io_samples (sample_number, database_id, file_id)

DECLARE @SampleNumber INT 
DECLARE @SampleTime DATETIME
SET @SampleNumber = 0

/* Sample @SampleNumber + 1 times (the first sample is the baseline) */
WHILE @SampleNumber <= @NumSamples BEGIN

	SELECT @SampleTime = GETUTCDATE();
	INSERT #io_samples (
	    sample_number
    , sample_time
	  , file_id
		, database_id 
		, read_operations
		, read_kb
		, read_latency_ms
		, write_operations
		, write_kb
		, write_latency_ms
	)
	SELECT
	    @SampleNumber
		, @SampleTime 
	  , vfs.file_id
		, vfs.database_id
		, num_of_reads AS read_operations
		, num_of_bytes_read / 1000 AS read_kb
		, io_stall_read_ms AS read_latency_ms
		, num_of_writes AS write_operations
		, num_of_bytes_written / 1000 AS write_kb
		, io_stall_write_ms AS write_latency_ms
	FROM sys.dm_io_virtual_file_stats(NULL, NULL) vfs
	
	IF @NumSamples > 0 WAITFOR DELAY @SampleDelay;

	SET @SampleNumber = @SampleNumber + 1
END


/* We have to gather data about each file by calling into some obscure APIs 
   Allocate the structure to hold our data
*/
IF OBJECT_ID('tempdb..#datafile_info') IS NOT NULL DROP TABLE #datafile_info
CREATE TABLE #datafile_info (
  database_id BIGINT 
	, file_id BIGINT
	, num_VLF BIGINT
	, used_space_mb DECIMAL(16,3)
	, file_group NVARCHAR(255)
)
INSERT INTO #datafile_info (database_id, file_id)
SELECT database_id, file_id FROM sys.master_files

/* Holding table for the VLF data we will gather */
IF OBJECT_ID('tempdb..#log_VLF') IS NOT NULL DROP TABLE #log_VLF
CREATE TABLE #log_VLF (
    recovery_unit BIGINT
	, file_id BIGINT
	, file_size BIGINT
	, start_offset BIGINT
	, seq_no BIGINT
	, [status] BIGINT
	, parity BIGINT
	, create_LSN BIGINT
)

IF CAST(SERVERPROPERTY('productversion') AS NVARCHAR(50)) LIKE '10.%' 
   OR CAST(SERVERPROPERTY('productversion') AS NVARCHAR(50)) LIKE '9.%'  BEGIN
	/* SQL 2005-2008R2 does have recovery_unit column */
	ALTER TABLE #log_VLF DROP COLUMN recovery_unit
END

/* Holding table for used space */
IF OBJECT_ID('tempdb..#used_space') IS NOT NULL DROP TABLE #used_space
CREATE TABLE #used_space
(
	file_id BIGINT
  , used_space_mb BIGINT
)
/* Holding table for filegroup information */
IF OBJECT_ID('tempdb..#db_filegroups') IS NOT NULL DROP TABLE #db_filegroups
CREATE TABLE #db_filegroups
(
	file_id BIGINT
	, [file_group] NVARCHAR(255)
)


/* Now loop through every database to gather data via DBCC */
DECLARE @db_name NVARCHAR(255)
DECLARE @db_id BIGINT
DECLARE @sql NVARCHAR(4000)
DECLARE c_db CURSOR FOR SELECT name, database_id FROM sys.databases
OPEN c_db


FETCH NEXT FROM c_db INTO @db_name, @db_id
WHILE @@FETCH_STATUS = 0 BEGIN

	/* Gather info on how many VLF are in each database */
	SET @sql = 'DBCC LOGINFO(<db_id>) WITH NO_INFOMSGS'
	SET @sql = REPLACE(@sql, '<db_id>', CAST(@db_id AS VARCHAR))
	INSERT INTO #log_VLF EXECUTE (@sql)

	UPDATE #datafile_info
	SET num_vlf = (SELECT COUNT(*) FROM #log_VLF)
	WHERE database_id = @db_id
		AND file_id = 2 /* Log file */
	TRUNCATE TABLE #log_VLF

	/* Gather space used (must be in context of the DB to query for this */
	SET @sql = 'USE <db_name> SELECT file_id, FILEPROPERTY(name, ''SpaceUsed'') / 128.0 FROM sys.database_files'
	SET @sql = REPLACE(@sql, '<db_name>', @db_name)
	INSERT INTO #used_space EXECUTE (@sql)
	
	UPDATE fi 
	SET used_space_mb = us.used_space_mb
	FROM #datafile_info fi
	JOIN #used_space us 
	  ON fi.file_id = us.file_id
		AND fi.database_id = @db_id
	TRUNCATE TABLE #used_space

	/* Gather info on filegroups (again, needs to be in context for data to query) */
	SET @sql = 'USE <db_name>
	            SELECT file_id, ds.name FROM sys.database_files f 
	            JOIN sys.data_spaces ds ON ds.data_space_id = f.data_space_id'
	SET @sql = REPLACE(@sql, '<db_name>', @db_name)
	INSERT INTO #db_filegroups EXECUTE (@sql)

	UPDATE fi 
	SET file_group = fg.file_group
	FROM #datafile_info fi
	JOIN #db_filegroups fg 
	  ON fi.file_id = fg.file_id
		AND fi.database_id = @db_id
	TRUNCATE TABLE #db_filegroups

	FETCH NEXT FROM c_db INTO @db_name, @db_id
END
CLOSE c_db
DEALLOCATE c_db

/* Find restart data of SQL Server */
DECLARE @LastRestart DATETIME
SELECT @LastRestart = create_date
FROM sys.databases
WHERE database_id = 2

/* Enrich the samples with more details */
UPDATE S
SET server_name = @@SERVERNAME
  , database_name = db.name
  , mount_point = LEFT(mf.physical_name
				, LEN(mf.physical_name) - CHARINDEX('\', REVERSE(mf.physical_name))) 
	, file_type = mf.type_desc
	, [file] = mf.name 
	, [file_name] = RIGHT(mf.physical_name, CHARINDEX('\', REVERSE(mf.physical_name)) - 1)
	, num_VLF = fi.num_VLF
	, file_group = fi.file_group
	, allocated_space_mb = mf.size / 128.0 
	, used_space_mb = fi.used_space_mb
FROM #io_samples S
LEFT JOIN sys.databases db ON S.database_id = db.database_id
LEFT JOIN sys.master_files mf ON S.file_id = mf.file_id AND S.database_id = mf.database_id
LEFT JOIN #datafile_info fi ON fi.file_id = S.file_id AND fi.database_id = S.database_id

/* Output the final result */
SELECT
    A.server_name
	, A.database_name
	, A.file_group
	, A.file_type
	, A.num_VLF
	, A.[file]
	, A.allocated_space_mb
	, A.used_space_mb
	, A.read_operations - ISNULL(B.read_operations, 0) AS read_operations
	, A.read_kb - ISNULL(B.read_kb,0) AS read_kb
	, CAST((A.read_kb - ISNULL(B.read_kb, 0)) 
	    / NULLIF((A.read_operations - ISNULL(B.read_operations,0)),0) AS DECIMAL(16,0)) AS read_block_size_avg_kb
	, CAST((A.read_latency_ms - ISNULL(B.read_latency_ms, 0)) 
	    / NULLIF((A.read_operations - ISNULL(B.read_operations, 0)), 0) AS DECIMAL(16,3)) AS read_latency_avg_ms
	, (A.read_operations - ISNULL(B.read_operations, 0))
	  / ISNULL(DATEDIFF(second, B.sample_time, A.sample_time)
		   , DATEDIFF(second, @LastRestart, A.sample_time)) AS read_avg_IOPS
	, A.write_operations - ISNULL(B.write_operations, 0) AS write_operations
	, A.write_kb - ISNULL(B.write_kb, 0) AS write_kb
	, CAST((A.write_kb - ISNULL(B.write_kb, 0)) 
	    / NULLIF((A.write_operations - ISNULL(B.write_operations, 0)), 0) AS DECIMAL(16,0)) AS write_block_size_avg_kb
	, CAST((A.write_latency_ms - ISNULL(B.write_latency_ms, 0)) 
	    / NULLIF((A.write_operations - ISNULL(B.write_operations, 0)), 0) AS DECIMAL(16,3)) AS write_latency_avg_ms
	, (A.write_operations - ISNULL(B.write_operations, 0))
	  / ISNULL(DATEDIFF(second, B.sample_time, A.sample_time)
		   , DATEDIFF(second, @LastRestart, A.sample_time)) AS write_avg_IOPS
	, CAST(100 * CAST((A.read_operations - ISNULL(B.read_operations, 0)) AS FLOAT) 
		   / ((A.write_operations - ISNULL(B.write_operations, 0)) 
		   + (A.read_operations - ISNULL(B.read_operations, 0))) AS INT) AS read_percent
	, A.mount_point
	, A.sample_number
	, A.sample_time
	, ISNULL(DATEDIFF(second, B.sample_time, A.sample_time)
	  , DATEDIFF(second, @LastRestart, A.sample_time)) AS sample_duration_s
  , A.[file_name]

FROM #io_samples A
LEFT JOIN #io_samples B
ON B.file_id = A.file_id
AND B.database_id = A.database_id
AND B.sample_number = A.sample_number - 1
WHERE (A.sample_number > 0 OR @NumSamples = 0)
ORDER BY sample_number, A.database_name, A.file_group

/* Clean up allocated objects */
IF OBJECT_ID('tempdb..#datafile_info') IS NOT NULL DROP TABLE #datafile_info
IF OBJECT_ID('tempdb..#io_samples') IS NOT NULL DROP TABLE #io_samples
IF OBJECT_ID('tempdb..#log_space') IS NOT NULL DROP TABLE #log_VLF
IF OBJECT_ID('tempdb..#used_space') IS NOT NULL DROP TABLE #used_space
IF OBJECT_ID('tempdb..#log_VLF') IS NOT NULL DROP TABLE #log_VLF
IF OBJECT_ID('tempdb..#db_filegroups') IS NOT NULL DROP TABLE #db_filegroups


