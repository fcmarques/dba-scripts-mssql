----------------------------------------------------------------------
------------------ CODE ONLY BELOW ------------------
----------------------------------------------------------------------

use master;
go

if object_id('dbo.fn_getProcessData') > 0
 drop function dbo.fn_getProcessData;
go

create function dbo.fn_getProcessData (
 @activeOnly   bit = 0,  -- If set (1), we return information on active requests only...
 @includeSqlText  bit = 0,  -- If set (1), we return the full sql text for the available sql_handle's...
 @includeQueryPlan bit = 0   -- If set (1), we return the XML query plan for the available plan handle's...
)
returns @retTable table (
 sessionId int,
 requestId int,
 requestStartTime datetime,
 requestStatus nvarchar(60),
 requestCommand nvarchar(32),
 sqlHandle varbinary(64),
 planHandle varbinary(64),
 dbName nvarchar(256),
 blockingSessionId smallint,
 waitType nvarchar(120),
 waitTime int,
 lastWaitType nvarchar(120),
 waitResource nvarchar(512),
 openTranCount int,
 openResultSetCount int,
 percentComplete real,
 requestCpuTime int,
 requestElapsedTime int,
 requestReads bigint,
 requestWrites bigint,
 requestLogicalReads bigint,
 requestRowCount bigint,
 requestQueryMemory int,
 sessionStatus nvarchar(60),
 loginTime datetime,
 hostName nvarchar(256),
 programName nvarchar(256),
 loginName nvarchar(256),
 originalLoginName nvarchar(256),
 sessionLastRequestStartTime datetime,
 sessionLastRequestEndTime datetime,
 sessionReads bigint,
 sessionWrites bigint,
 sessionLogicalReads bigint,
 sessionRowCount bigint,
 connectTime datetime,
 netTransport nvarchar(80),
 connectionPacketReads int,
 connectionPacketWrites int,
 netPacketSize int,
 clientNetAddress varchar(48),
 connectionMostRecentSqlHandle varbinary(64),
 sessionCpuTime int,
 sessionMemUsage int,
 sessionScheduledTime int,
 sessionElapsedTime int,
 clientInterface nvarchar(64),
 contextInfo varbinary(128),
 authScheme nvarchar(80),
 connectionLastRead datetime,
 connectionLastWrite datetime,
 sqlText nvarchar(max),
 queryPlan xml
)
as
/*
-- All information for all sessions
select * from master.dbo.fn_getProcessData(default,0,0)

-- Only data for currently active requests...
select * from master.dbo.fn_getProcessData(1,1,1);

*/
begin

if @activeOnly > 0
 insert @retTable (sessionId,requestId,requestStartTime,requestStatus,requestCommand,sqlHandle,planHandle,dbName,blockingSessionId,waitType,waitTime,
    lastWaitType,waitResource,openTranCount,openResultSetCount,percentComplete,requestCpuTime,requestElapsedTime,requestReads,requestWrites,
    requestLogicalReads,requestRowCount,requestQueryMemory,sessionStatus,loginTime,hostName,programName,loginName,originalLoginName,
    sessionLastRequestStartTime,sessionLastRequestEndTime,sessionReads,sessionWrites,sessionLogicalReads,sessionRowCount,connectTime,
    netTransport,connectionPacketReads,connectionPacketWrites,netPacketSize,clientNetAddress,connectionMostRecentSqlHandle,sessionCpuTime,
    sessionMemUsage,sessionScheduledTime,sessionElapsedTime,clientInterface,contextInfo,authScheme,connectionLastRead,connectionLastWrite)
 select coalesce(s.session_id, r.session_id, c.session_id) as sessionId, r.request_id as requestId, r.start_time as requestStartTime, r.status as requestStatus,
   r.command as requestCommand, r.sql_handle as sqlHandle, r.plan_handle as planHandle, isnull(db_name(r.database_id),'N/A') as dbName,
   r.blocking_session_id as blockingSessionId, r.wait_type as waitType, r.wait_time as waitTime, r.last_wait_type as lastWaitType,
   r.wait_resource as waitResource,r.open_transaction_count as openTranCount, r.open_resultset_count as openResultSetCount,
   r.percent_complete as percentComplete, r.cpu_time as requestCpuTime, r.total_elapsed_time as requestElapsedTime,
   r.reads as requestReads, r.writes as requestWrites, r.logical_reads as requestLogicalReads, r.row_count as requestRowCount,
   r.granted_query_memory as requestQueryMemory,
   s.status as sessionStatus, s.login_time as loginTime, s.host_name as hostName, s.program_name as programName,
   s.login_name as loginName, s.original_login_name as originalLoginName,
   s.last_request_start_time as sessionLastRequestStartTime, s.last_request_end_time as sessionLastRequestEndTime,
   s.reads as sessionReads, s.writes as sessionWrites, s.logical_reads as sessionLogicalReads, s.row_count as sessionRowCount,
   c.connect_time as connectTime, c.net_transport as netTransport, c.num_reads as connectionPacketReads, c.num_writes as connectionPacketWrites,
   c.net_packet_size as netPacketSize, c.client_net_address as clientNetAddress, c.most_recent_sql_handle as connectionMostRecentSqlHandle,
   s.cpu_time as sessionCpuTime, s.memory_usage as sessionMemUsage, s.total_scheduled_time as sessionScheduledTime,
   s.total_elapsed_time as sessionElapsedTime, s.client_interface_name as clientInterface, s.context_info as contextInfo,
   c.auth_scheme as authScheme, c.last_read as connectionLastRead, c.last_write as connectionLastWrite
 from sys.dm_exec_sessions s with(nolock)
 join sys.dm_exec_connections c with(nolock)
 on  s.session_id = c.session_id
 and  c.session_id > 50
 join sys.dm_exec_requests r with(nolock)
 on  s.session_id = r.session_id
 and  r.session_id > 50
 where s.session_id > 50
 
else
 insert @retTable (sessionId,requestId,requestStartTime,requestStatus,requestCommand,sqlHandle,planHandle,dbName,blockingSessionId,waitType,waitTime,
     lastWaitType,waitResource,openTranCount,openResultSetCount,percentComplete,requestCpuTime,requestElapsedTime,requestReads,requestWrites,
     requestLogicalReads,requestRowCount,requestQueryMemory,sessionStatus,loginTime,hostName,programName,loginName,originalLoginName,
     sessionLastRequestStartTime,sessionLastRequestEndTime,sessionReads,sessionWrites,sessionLogicalReads,sessionRowCount,connectTime,
     netTransport,connectionPacketReads,connectionPacketWrites,netPacketSize,clientNetAddress,connectionMostRecentSqlHandle,sessionCpuTime,
     sessionMemUsage,sessionScheduledTime,sessionElapsedTime,clientInterface,contextInfo,authScheme,connectionLastRead,connectionLastWrite)
 select coalesce(s.session_id, r.session_id, c.session_id) as sessionId, r.request_id as requestId, r.start_time as requestStartTime, r.status as requestStatus,
   r.command as requestCommand, r.sql_handle as sqlHandle, r.plan_handle as planHandle, isnull(db_name(r.database_id),'N/A') as dbName,
   r.blocking_session_id as blockingSessionId, r.wait_type as waitType, r.wait_time as waitTime, r.last_wait_type as lastWaitType,
   r.wait_resource as waitResource,r.open_transaction_count as openTranCount, r.open_resultset_count as openResultSetCount,
   r.percent_complete as percentComplete, r.cpu_time as requestCpuTime, r.total_elapsed_time as requestElapsedTime,
   r.reads as requestReads, r.writes as requestWrites, r.logical_reads as requestLogicalReads, r.row_count as requestRowCount,
   r.granted_query_memory as requestQueryMemory,
   s.status as sessionStatus, s.login_time as loginTime, s.host_name as hostName, s.program_name as programName,
   s.login_name as loginName, s.original_login_name as originalLoginName,
   s.last_request_start_time as sessionLastRequestStartTime, s.last_request_end_time as sessionLastRequestEndTime,
   s.reads as sessionReads, s.writes as sessionWrites, s.logical_reads as sessionLogicalReads, s.row_count as sessionRowCount,
   c.connect_time as connectTime, c.net_transport as netTransport, c.num_reads as connectionPacketReads, c.num_writes as connectionPacketWrites,
   c.net_packet_size as netPacketSize, c.client_net_address as clientNetAddress, c.most_recent_sql_handle as connectionMostRecentSqlHandle,
   s.cpu_time as sessionCpuTime, s.memory_usage as sessionMemUsage, s.total_scheduled_time as sessionScheduledTime,
   s.total_elapsed_time as sessionElapsedTime, s.client_interface_name as clientInterface, s.context_info as contextInfo,
   c.auth_scheme as authScheme, c.last_read as connectionLastRead, c.last_write as connectionLastWrite
 from sys.dm_exec_sessions s with(nolock)
 left join sys.dm_exec_connections c with(nolock)
 on  s.session_id = c.session_id
 and  c.session_id > 50
 left join sys.dm_exec_requests r with(nolock)
 on  s.session_id = r.session_id
 and  r.session_id > 50
 where s.session_id > 50

if @includeSqlText > 0
 update r
 set  r.sqlText = t.text
 from @retTable r
 outer apply sys.dm_exec_sql_text(isnull(r.sqlHandle,r.connectionMostRecentSqlHandle)) t
 where isnull(r.sqlHandle,r.connectionMostRecentSqlHandle) is not null;

if @includeQueryPlan > 0
 update r
 set  r.queryPlan = t.query_plan
 from @retTable r
 outer apply sys.dm_exec_query_plan(r.planHandle) t
 where r.planHandle is not null;

return;
end
go

use master
go

if object_id('dbo.sp_who2k5') > 0
 drop procedure dbo.sp_who2k5
go

create procedure dbo.sp_who2k5
 @activeOnly   bit = null,  -- If set (1), we return information on active requests only...
 @includeSqlText  bit = 0,  -- If set (1), we return the full sql text for the available sql_handle's...
 @includeQueryPlan bit = 0   -- If set (1), we return the XML query plan for the available plan handle's...
as
/*


NOTE: This procedure requires the following modules:

 1) master.dbo.fn_getProcessData()
 
*/
set nocount on;

-- Print some usage data for usability if needed...
if @activeOnly is null begin
 print 'USAGE: ';
 print '    exec dbo.sp_who2k5 @activeOnly, @includeSqlText, @includeQueryPlan;';
 print '';
 print '    @activeOnly - If set (1), we return information on active requests only';
 print '    @includeSqlText - If set (1), we return the full sql text for the available sql_handles';
 print '    @includeQueryPlan - If set (1), we return the XML query plan for the available plan handles';
 print '';
 print '    Wrapper procedure around the UDF master.dbo.fn_getProcessData() - accepts exact same arguments.';
 print '';
end

-- Format as needed...
select @activeOnly = case when @activeOnly > 0 then @activeOnly else 0 end;

-- Get the response...
select sessionId,blockingSessionId,requestStatus,dbName,waitType,waitTime,lastWaitType,requestCommand,loginName,originalLoginName,
  openTranCount,openResultSetCount,percentComplete,requestCpuTime,requestElapsedTime,requestReads,requestWrites,waitResource,
  requestId,requestStartTime,requestLogicalReads,requestRowCount,requestQueryMemory,sessionStatus,loginTime,hostName,programName,
  sessionLastRequestStartTime,sessionLastRequestEndTime,sessionReads,sessionWrites,sessionLogicalReads,sessionRowCount,connectTime,
  netTransport,connectionPacketReads,connectionPacketWrites,netPacketSize,clientNetAddress,connectionMostRecentSqlHandle,sessionCpuTime,
  sessionMemUsage,sessionScheduledTime,sessionElapsedTime,clientInterface,contextInfo,authScheme,connectionLastRead,connectionLastWrite,
  planHandle,sqlHandle,queryPlan,sqlText
from master.dbo.fn_getProcessData(@activeOnly, @includeSqlText, @includeQueryPlan);

GO