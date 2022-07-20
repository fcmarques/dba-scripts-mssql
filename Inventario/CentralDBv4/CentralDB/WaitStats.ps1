###################################################################################################################################
<# Based on Allen White, Collen Morrow, Erin Stellato's and Jonathan Kehayias Scripts for SQL Inventory and Baselining
https://www.simple-talk.com/sql/database-administration/let-powershell-do-an-inventory-of-your-servers/
http://colleenmorrow.com/2012/04/23/the-importance-of-a-sql-server-inventory/
http://www.sqlservercentral.com/articles/baselines/94657/ 
https://www.simple-talk.com/sql/performance/a-performance-troubleshooting-methodology-for-sql-server/#>
######################################################################################################################################
param(
	[string]$SQLInst="RSQLADM\MAPS",
	[string]$Centraldb="CentralDB",
	[string]$LogPath="D:\CentralDB\Errorlog\WaitStatslog.log"
	)
$ScriptDirectory = Split-Path $MyInvocation.MyCommand.Path
. (Join-Path $ScriptDirectory Functions.ps1)
######################################################################################################################################

#http://poshtips.com/measuring-elapsed-time-in-powershell/
$ElapsedTime = [System.Diagnostics.Stopwatch]::StartNew()
write-log -Message "Script Started at $(get-date)" -NoConsoleOut -Clobber -Path $LogPath
######################################################################################################################################
#Fucntion to get Server list info
function GetServerListInfo($svr, $inst) {
# Create an ADO.Net connection to the instance
$cn = new-object system.data.SqlClient.SqlConnection("Data Source=$inst;Integrated Security=SSPI;Initial Catalog=master");
$s = new-object (‘Microsoft.SqlServer.Management.Smo.Server’) $cn
$RunDt = Get-Date -format G
################################################## Missing Indexes #################################################################
try 
{ 
$ErrorActionPreference = "Stop"; #Make all errors terminating
$CITbl = “[Inst].[MissingIndexes]”
$query= "Select ('$Svr') as ServerName, ('$inst') as InstanceName, DB_Name(mid.database_id) as DBName, OBJECT_SCHEMA_NAME(mid.[object_id], mid.database_id) as SchemaName, 
	mid.statement as MITable,migs.avg_total_user_cost * (migs.avg_user_impact / 100.0) * (migs.user_seeks + migs.user_scans) AS improvement_measure, 
  'CREATE INDEX [IDX'
  + '_' + LEFT (PARSENAME(mid.statement, 1), 32) + ']'
  + ' ON ' + mid.statement 
  + ' (' + ISNULL (mid.equality_columns,'') 
    + CASE WHEN mid.equality_columns IS NOT NULL AND mid.inequality_columns IS NOT NULL THEN ',' ELSE '' END 
    + ISNULL (mid.inequality_columns, '')
  + ')' 
  + ISNULL (' INCLUDE (' + mid.included_columns + ')', '') AS create_index_statement,
  migs.group_handle, migs.unique_compiles, migs.user_seeks, migs.last_user_seek, migs.avg_total_user_cost, migs.avg_user_impact, ('$RunDt') as DateAdded
FROM sys.dm_db_missing_index_groups mig
INNER JOIN sys.dm_db_missing_index_group_stats migs ON migs.group_handle = mig.index_group_handle
INNER JOIN sys.dm_db_missing_index_details mid ON mig.index_handle = mid.index_handle
WHERE migs.avg_total_user_cost * (migs.avg_user_impact / 100.0) * (migs.user_seeks + migs.user_scans) > 100000
ORDER BY migs.avg_total_user_cost * migs.avg_user_impact * (migs.user_seeks + migs.user_scans) DESC"

$da = new-object System.Data.SqlClient.SqlDataAdapter ($query, $cn)
$dt = new-object System.Data.DataTable
$da.fill($dt) | out-null
#$cn.Close()
Write-DataTable -ServerInstance $SQLInst -Database $Centraldb -TableName $CITbl -Data $dt
}    
catch 
	{ 
        $ex = $_.Exception 
	write-log -Message "$ex.Message on $Svr While collecting Missing Indexes "  -NoConsoleOut -Path $LogPath 
	} finally{
   		$ErrorActionPreference = "Continue"; #Reset the error action pref to default
	}
################################################## Wait Stats #################################################################
try
{
$ErrorActionPreference = "Stop"; #Make all errors terminating
$CITbl = “[Inst].[WaitStats]”
$query= ";WITH [Waits] AS
         (SELECT [wait_type], [wait_time_ms] / 1000.0 AS [WaitS],
            ([wait_time_ms] - [signal_wait_time_ms]) / 1000.0 AS [ResourceS],
            [signal_wait_time_ms] / 1000.0 AS [SignalS],
            [waiting_tasks_count] AS [WaitCount],
            100.0 * [wait_time_ms] / SUM ([wait_time_ms]) OVER() AS [Percentage],
            ROW_NUMBER() OVER(ORDER BY [wait_time_ms] DESC) AS [RowNum]
         FROM sys.dm_os_wait_stats
         WHERE [wait_type] NOT IN ('CLR_SEMAPHORE', 'LAZYWRITER_SLEEP', 'RESOURCE_QUEUE', 'SLEEP_TASK',
        'SLEEP_SYSTEMTASK', 'SQLTRACE_BUFFER_FLUSH', 'WAITFOR', 'LOGMGR_QUEUE',
        'CHECKPOINT_QUEUE', 'REQUEST_FOR_DEADLOCK_SEARCH', 'XE_TIMER_EVENT', 'BROKER_TO_FLUSH',
        'BROKER_TASK_STOP', 'CLR_MANUAL_EVENT', 'CLR_AUTO_EVENT', 'DISPATCHER_QUEUE_SEMAPHORE',
        'FT_IFTS_SCHEDULER_IDLE_WAIT', 'XE_DISPATCHER_WAIT', 'XE_DISPATCHER_JOIN', 'BROKER_EVENTHANDLER',
        'TRACEWRITE', 'FT_IFTSHC_MUTEX', 'SQLTRACE_INCREMENTAL_FLUSH_SLEEP', 'DIRTY_PAGE_POLL', 'HADR_FILESTREAM_IOMGR_IOCOMPLETION')
         )
 SELECT ('$Svr') as ServerName, ('$inst') as InstanceName, 
         [W1].[wait_type] AS [WaitType], 
         CAST ([W1].[WaitS] AS DECIMAL(14, 2)) AS [Wait_S],
         CAST ([W1].[ResourceS] AS DECIMAL(14, 2)) AS [Resource_S],
         CAST ([W1].[SignalS] AS DECIMAL(14, 2)) AS [Signal_S],
         [W1].[WaitCount] AS [WaitCount],
         CAST ([W1].[Percentage] AS DECIMAL(4, 2)) AS [Percentage],
         CAST (([W1].[WaitS] / [W1].[WaitCount]) AS DECIMAL (14, 4)) AS [AvgWait_S],
         CAST (([W1].[ResourceS] / [W1].[WaitCount]) AS DECIMAL (14, 4)) AS [AvgRes_S],
         CAST (([W1].[SignalS] / [W1].[WaitCount]) AS DECIMAL (14, 4)) AS [AvgSig_S], ('$RunDt') as DateAdded
      FROM [Waits] AS [W1]
      INNER JOIN [Waits] AS [W2]
         ON [W2].[RowNum] <= [W1].[RowNum]
      GROUP BY [W1].[RowNum], [W1].[wait_type], [W1].[WaitS], 
         [W1].[ResourceS], [W1].[SignalS], [W1].[WaitCount], [W1].[Percentage]
      HAVING SUM ([W2].[Percentage]) - [W1].[Percentage] < 95"
$da = new-object System.Data.SqlClient.SqlDataAdapter ($query, $cn)
$dt = new-object System.Data.DataTable
$da.fill($dt) | out-null
#$cn.Close()
Write-DataTable -ServerInstance $SQLInst -Database $Centraldb -TableName $CITbl -Data $dt
}    
catch 
	{ 
        $ex = $_.Exception 
	write-log -Message "$ex.Message on $Svr While collecting Wait Stats "  -NoConsoleOut -Path $LogPath 
	} finally{
   		$ErrorActionPreference = "Continue"; #Reset the error action pref to default
	}
}
######################################################################################################################################
$cn = new-object system.data.sqlclient.sqlconnection(“server=$SQLInst;database=$CentralDB;Integrated Security=true;”);
$cn.Open()
$cmd = $cn.CreateCommand()
$query = " Select Distinct ServerName, InstanceName from [Svr].[ServerList] where Baseline = 'True';"
$cmd.CommandText = $query
#$null = $cmd.ExecuteNonQuery()
$reader = $cmd.ExecuteReader()
while($reader.Read()) {
 
   	# Get ServerName and InstanceName from CentralDB
	$server = $reader['ServerName']
	$instance = $reader['InstanceName']
    	$result = gwmi -query "select StatusCode from Win32_PingStatus where Address = '$server'"
       	$responds = $false
	# If the machine responds break out of the result loop and indicate success
    	if ($result.statuscode -eq 0) {
        	$responds = $true
    	}
    	If ($responds) {
        # Calling funtion and passing server and instance parameters
		GetServerListInfo $server $instance
 
    	}
    	else {
 	# Let the user know we couldn't connect to the server
		write-log -Message "$server Server did not respond" -NoConsoleOut -Path  $LogPath
       	}
 
}
write-log -Message "Script Ended at $(get-date)" -NoConsoleOut -Path $LogPath
write-log -Message "Total Elapsed Time: $($ElapsedTime.Elapsed.ToString())" -NoConsoleOut -Path $LogPath