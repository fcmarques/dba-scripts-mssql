/* Script to Detect CPU Consumers */

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

 	
--The script will find the Top CPU Consumer Queries for the duration of @WaitDelay
DECLARE @WaitDelay varchar(16)='00:00:05.000'

SET NOCOUNT ON
USE tempdb
IF OBJECT_ID('__ExecQStats_1') IS NOT NULL DROP TABLE tempdb.dbo.__ExecQStats_1
IF OBJECT_ID('__ExecQStats_2') IS NOT NULL DROP TABLE tempdb.dbo.__ExecQStats_2
IF OBJECT_ID('__SpinStats_before') IS NOT NULL DROP TABLE tempdb.dbo.__SpinStats_before
IF OBJECT_ID('__SpinStats_after') IS NOT NULL DROP TABLE tempdb.dbo.__SpinStats_after



SELECT name 
	, spins
	, backoffs
INTO __SpinStats_before
FROM sys.dm_os_spinlock_stats

SELECT 
   qs.total_elapsed_time
  ,qs.execution_count
  ,qs.total_worker_time
  ,CAST(qs.total_elapsed_time / 1000 AS FLOAT) / CAST(qs.execution_count as FLOAT) as avg_cpu_time_ms
  ,qs.statement_start_offset
  ,qs.statement_end_offset
  ,qs.sql_handle
  ,qs.plan_handle 
INTO __ExecQStats_1
FROM sys.dm_exec_query_stats qs
WHERE qs.execution_count>0


WAITFOR DELAY @WaitDelay;

SELECT name 
	, spins
	, backoffs
INTO __SpinStats_after
FROM sys.dm_os_spinlock_stats


SELECT 
  qs.total_elapsed_time
  ,qs.execution_count
  , qs.total_worker_time
  ,CAST(qs.total_elapsed_time / 1000 AS FLOAT) / CAST(qs.execution_count as FLOAT) as avg_cpu_time_ms
  ,qs.statement_start_offset
  ,qs.statement_end_offset
  ,qs.sql_handle
  ,qs.plan_handle 
INTO __ExecQStats_2
FROM sys.dm_exec_query_stats qs
WHERE qs.execution_count>0
ORDER BY total_elapsed_time DESC


select 
	CAST(qs.total_worker_time / 1000 as FLOAT) / CAST(qs.execution_count AS FLOAT) as avg_cpu_time_ms
	,total_elapsed_time
	,total_worker_time
	,execution_count
	,SUBSTRING(qt.text,qs.statement_start_offset/2
    ,(case when qs.statement_end_offset = -1 
			then len(convert(nvarchar(max), qt.text)) * 2 
			else qs.statement_end_offset end -qs.statement_start_offset)/2
	  ) as query_text
	,db_name(qt.dbid) as database_name
    ,CAST(qp.query_plan AS XML) query_plan
from
(
select 
	(e2.total_elapsed_time - ISNULL(e1.total_elapsed_time ,0)) as total_elapsed_time
	,(e2.total_worker_time - ISNULL(e1.total_worker_time ,0)) as total_worker_time
	,(e2.execution_count - ISNULL(e1.execution_count ,0)) as execution_count
	,e2.statement_start_offset
    ,e2.statement_end_offset
    ,e2.sql_handle sql_handle2
    ,e1.sql_handle sql_handle1
    ,e2.plan_handle plan_handle2
    ,e1.plan_handle plan_handle1
from __ExecQStats_1 e1 right outer join __ExecQStats_2 e2 
	ON e1.plan_handle=e2.plan_handle AND e1.sql_handle = e2.sql_handle 
AND e1.statement_end_offset=e2.statement_end_offset AND e1.statement_start_offset=e2.statement_start_offset 
) as qs
cross apply sys.dm_exec_sql_text(qs.sql_handle2) as qt
cross apply sys.dm_exec_text_query_plan(qs.plan_handle2,statement_start_offset, statement_end_offset) AS qp
WHERE execution_count > 0
order by total_worker_time desc
go




SELECT name
	, spins
	, backoffs
FROM 
(
	SELECT a.name
		, a.spins - b.spins AS spins
		, a.backoffs - b.backoffs AS backoffs
	FROM __SpinStats_after a
	FULL OUTER JOIN  __SpinStats_before b
		ON b.name = a.name
) spin
WHERE spins > 0
ORDER BY backoffs DESC

IF OBJECT_ID('__ExecQStats_1') IS NOT NULL DROP TABLE tempdb.dbo.__ExecQStats_1
IF OBJECT_ID('__ExecQStats_2') IS NOT NULL DROP TABLE tempdb.dbo.__ExecQStats_2
IF OBJECT_ID('__SpinStats_before') IS NOT NULL DROP TABLE  tempdb.dbo.__SpinStats_before
IF OBJECT_ID('__SpinStats_after') IS NOT NULL DROP TABLE  tempdb.dbo.__SpinStats_after


