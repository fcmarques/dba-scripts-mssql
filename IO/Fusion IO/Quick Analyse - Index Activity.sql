/* Script to report on index activity (used to estimate I/O consumption) */

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


DECLARE @SampleNumber INT 
DECLARE @SampleTime DATETIME
SET @SampleNumber = 0

IF OBJECT_ID('tempdb..#index_samples') IS NOT NULL DROP TABLE #index_samples
CREATE TABLE #index_samples
(
    sample_number INT
	, sample_time DATETIME 
	, database_id BIGINT
	, table_id BIGINT
	, index_id BIGINT
	, index_type_desc NVARCHAR(255)
	, estimated_operations BIGINT
	, range_scan_count BIGINT
	, singleton_lookup_count BIGINT
	, lob_fetch_in_pages BIGINT
	, row_overflow_fetch_in_pages BIGINT
	, page_lock_count BIGINT
	, row_lock_count BIGINT
	, index_depth BIGINT
	, page_count BIGINT
)

WHILE @SampleNumber <= @NumSamples BEGIN

	SELECT @SampleTime = GETUTCDATE();

	INSERT INTO #index_samples (
	    sample_number
		, sample_time
		, database_id
		, table_id
		, index_id
		, index_type_desc
		, estimated_operations
		, range_scan_count
		, singleton_lookup_count
		, lob_fetch_in_pages
		, row_overflow_fetch_in_pages
		, page_lock_count
		, row_lock_count
		, index_depth
		, page_count
	)
	SELECT
		  @SampleNumber
		, @SampleTime
	  , os.database_id
		, os.object_id
		, os.index_id
		, ps.index_type_desc 
		, CASE 
			WHEN ps.index_type_desc IN ('HEAP', 'CLUSTERED INDEX', 'NONCLUSTERED INDEX') THEN
				page_lock_count + ISNULL(lob_fetch_in_pages, 0) + ISNULL(row_overflow_fetch_in_pages, 0)
			WHEN ps.index_type_desc IN ('PRIMARY XML INDEX', 'XML INDEX') THEN
				singleton_lookup_count
			WHEN ps.index_type_desc = 'SPATIAL INDEX' THEN
				singleton_lookup_count
			ELSE	
				NULL /* Should not happen */
			END AS estimated_operations
		, range_scan_count
		, singleton_lookup_count
		, lob_fetch_in_pages
		, row_overflow_fetch_in_pages
		, page_lock_count
		, row_lock_count
		, index_depth
		, page_count
	FROM sys.dm_db_index_operational_stats(NULL, NULL, NULL, NULL) os
	JOIN sys.dm_db_index_physical_stats(NULL, NULL, NULL, NULL, NULL) ps
		ON ps.database_id = os.database_id
		AND ps.object_id = os.object_id
		AND ps.index_id = os.index_id
		AND ps.partition_number = os.partition_number
	JOIN sys.databases db
		ON db.database_id = os.database_id
	WHERE ps.page_count > (128 * 100) /* Not really interested in things less than 100MB */

	IF @NumSamples > 0 WAITFOR DELAY @SampleDelay;

	SET @SampleNumber = @SampleNumber + 1
END

/* Find restart data of SQL Server */
DECLARE @LastRestart DATETIME
SELECT @LastRestart = create_date
FROM sys.databases
WHERE database_id = 2

/* Output results*/
SELECT 
  @@SERVERNAME AS server_name  
  , db.name AS database_name  
	, OBJECT_NAME(A.table_id, A.database_id) table_name 
	, A.page_count / 128 AS table_size_mb
	, A.estimated_operations - ISNULL(B.estimated_operations, 0) AS estimated_operations
	, (A.estimated_operations - ISNULL(B.estimated_operations, 0)) * 8 AS estimated_bytes_read_kb 
	, (A.estimated_operations - ISNULL(B.estimated_operations, 0))
	  / ISNULL(DATEDIFF(second, B.sample_time, A.sample_time)
		   , DATEDIFF(second, @LastRestart, A.sample_time)) AS estimated_IOPS
	, A.sample_number
	, ISNULL(DATEDIFF(second, B.sample_time, A.sample_time)
	  , DATEDIFF(second, @LastRestart, A.sample_time)) AS sample_duration_s
FROM #index_samples A
LEFT JOIN #index_samples B 
  ON B.database_id = A.database_id
 AND B.table_id = B.table_id
 AND B.index_id = B.index_id
 AND B.sample_number = A.sample_number - 1
LEFT JOIN sys.databases db 
  ON A.database_id = db.database_id
WHERE (A.sample_number > 0 OR @NumSamples = 0)


IF OBJECT_ID('tempdb..#index_samples') IS NOT NULL DROP TABLE #index_samples
