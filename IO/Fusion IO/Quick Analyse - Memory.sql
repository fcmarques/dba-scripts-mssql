/* Script to Report Memory Usage */

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

IF OBJECT_ID('tempdb..#memory_samples') IS NOT NULL DROP TABLE #memory_samples
CREATE TABLE #memory_samples
(
	server_name NVARCHAR(MAX)
	, memory_category NVARCHAR(MAX)
	, memory_kb BIGINT
	, sample_number INT
	, sample_time DATETIME
)

/* Collect samples */
DECLARE @SampleNumber INT 
DECLARE @SampleTime DATETIME
SET @SampleNumber = 0

WHILE @SampleNumber <= @NumSamples BEGIN

	SELECT @SampleTime = GETUTCDATE();

	INSERT INTO #memory_samples
	(
		server_name
		, memory_category
		, memory_kb
		, sample_number
		, sample_time
	)
	SELECT 
	    @@SERVERNAME AS server_name
	  , RTRIM(counter_name) AS memory_category
	  , cntr_value as memory_kb
		, @SampleNumber
		, @SampleTime
	FROM sys.dm_os_performance_counters
	WHERE counter_name LIKE '%Memory%(KB)%'
	  AND [object_name] LIKE '%Memory%Manager%'
	
	IF @NumSamples > 0 WAITFOR DELAY @SampleDelay;

	SET @SampleNumber = @SampleNumber + 1
END

/* Find restart data of SQL Server */
DECLARE @LastRestart DATETIME
SELECT @LastRestart = create_date
FROM sys.databases
WHERE database_id = 2

/* Output the result */
SELECT 
    A.server_name
  , A.memory_category
  , A.memory_kb AS memory_kb
	, A.sample_number
	, A.sample_time 
	, DATEDIFF(second, ISNULL(B.sample_time, @LastRestart), A.sample_time) AS sample_duration_s
FROM #memory_samples A
LEFT JOIN #memory_samples B
  ON B.memory_category = A.memory_category
  AND B.sample_number = A.sample_number - 1
WHERE A.memory_category NOT LIKE '%Target%Server%Memory%'
  AND A.memory_category NOT LIKE '%Maximum%Workspace%Memory%'
  AND A.memory_category NOT LIKE '%Total%Server%Memory%'
  AND (A.sample_number > 0 OR @NumSamples = 0)

/* Clean up objects */
IF OBJECT_ID('tempdb..#memory_samples') IS NOT NULL DROP TABLE #memory_samples
