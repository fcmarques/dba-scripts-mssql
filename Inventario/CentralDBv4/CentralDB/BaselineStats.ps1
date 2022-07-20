############################################################################################################################################################
<# CrazyDBA.COM (CentralDB) - Based on Allen White, Colleen Morrow, Erin Stellato, Jonathan Kehayias and Ed Wilsons Scripts for SQL Inventory and Baselining
https://www.simple-talk.com/sql/database-administration/let-powershell-do-an-inventory-of-your-servers/
http://colleenmorrow.com/2012/04/23/the-importance-of-a-sql-server-inventory/
http://www.sqlservercentral.com/articles/baselines/94657/ 
https://www.simple-talk.com/sql/performance/a-performance-troubleshooting-methodology-for-sql-server/
http://blogs.technet.com/b/heyscriptingguy/archive/2011/07/28/use-performance-counter-sets-and-powershell-to-ease-baselining.aspx
http://www.youtube.com/watch?v=Y8IbadEHoPg #>
######################################################################################################################################
param(
	[string]$SQLInst="RSQLADM\MAPS",
	[string]$Centraldb="CentralDB",
	[string]$LogPath="D:\CentralDB\Errorlog\BaselineStatslog.log"
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
################################################## Instance Baseline Stats #################################################################
$result = new-object Microsoft.SqlServer.Management.Common.ServerConnection($inst)
$responds = $false
if ($result.ProcessID -ne $null) {
    $responds = $true
    }  
If ($responds) {
try
{
$ErrorActionPreference = "Stop"; #Make all errors terminating
$CITbl = “[Inst].[InsBaselineStats]”
$query= "DECLARE @CounterPrefix NVARCHAR(30)
SET @CounterPrefix = CASE
    WHEN @@SERVICENAME = 'MSSQLSERVER'
    THEN 'SQLServer:'
    ELSE 'MSSQL$'+@@SERVICENAME+':'
    END;
-- Capture the first counter set
SELECT CAST(1 AS INT) AS collection_instance ,
      [OBJECT_NAME] ,
      counter_name ,
      instance_name ,
      cntr_value ,
      cntr_type ,
      CURRENT_TIMESTAMP AS collection_time
INTO #perf_counters_init
FROM sys.dm_os_performance_counters
WHERE (( OBJECT_NAME = @CounterPrefix+'Buffer Manager' AND counter_name = 'Page life expectancy') 
	OR ( OBJECT_NAME = @CounterPrefix+'Buffer Manager' AND counter_name = 'Lazy Writes/sec')
	OR ( OBJECT_NAME = @CounterPrefix+'Buffer Manager' AND counter_name = 'Page reads/sec')
	OR ( OBJECT_NAME = @CounterPrefix+'Buffer Manager' AND counter_name = 'Page writes/sec')
	OR ( OBJECT_NAME = @CounterPrefix+'Databases' AND counter_name = 'Log Growths')
	OR ( OBJECT_NAME = @CounterPrefix+'Buffer Manager' AND counter_name = 'Free list stalls/sec')							 
	OR ( OBJECT_NAME = @CounterPrefix+'General Statistics' AND counter_name = 'User Connections')
	OR ( OBJECT_NAME = @CounterPrefix+'Locks' AND counter_name = 'Lock Waits/sec')
	OR ( OBJECT_NAME = @CounterPrefix+'Locks' AND counter_name = 'Number of Deadlocks/sec')
	OR ( OBJECT_NAME = @CounterPrefix+'Databases' AND counter_name = 'Transactions/sec')
	OR ( OBJECT_NAME = @CounterPrefix+'Access Methods' AND counter_name = 'Forwarded Records/sec')  
	OR ( OBJECT_NAME = @CounterPrefix+'Access Methods' AND counter_name = 'Index Searches/sec')
	OR ( OBJECT_NAME = @CounterPrefix+'Access Methods' AND counter_name = 'Full Scans/sec')
	OR ( OBJECT_NAME = @CounterPrefix+'SQL Statistics' AND counter_name = 'Batch Requests/sec')
	OR ( OBJECT_NAME = @CounterPrefix+'SQL Statistics' AND counter_name = 'SQL Compilations/sec')
	OR ( OBJECT_NAME = @CounterPrefix+'SQL Statistics' AND counter_name = 'SQL Re-Compilations/sec')
	OR ( OBJECT_NAME = @CounterPrefix+'Latches' AND counter_name = 'Latch Waits/sec')
	OR ( OBJECT_NAME = @CounterPrefix+'General Statistics' AND counter_name = 'Processes Blocked')
	OR ( OBJECT_NAME = @CounterPrefix+'Locks' AND counter_name = 'Lock Wait Time (ms)')
	OR ( OBJECT_NAME = @CounterPrefix+'Memory Manager' AND counter_name = 'Memory Grants Pending')
	OR ( OBJECT_NAME = @CounterPrefix+'Access Methods'AND counter_name = 'Page Splits/sec') ) 
	AND (instance_name = '' or instance_name = '_Total') 
-- Wait on Second between data collection
WAITFOR DELAY '00:00:01'
-- Capture the second counter set
SELECT CAST(2 AS INT) AS collection_instance ,
       OBJECT_NAME ,
       counter_name ,
       instance_name ,
       cntr_value ,
       cntr_type ,
       CURRENT_TIMESTAMP AS collection_time
INTO #perf_counters_second
FROM sys.dm_os_performance_counters
WHERE (( OBJECT_NAME = @CounterPrefix+'Buffer Manager' AND counter_name = 'Page life expectancy') 
	OR ( OBJECT_NAME = @CounterPrefix+'Buffer Manager' AND counter_name = 'Lazy Writes/sec')
	OR ( OBJECT_NAME = @CounterPrefix+'Buffer Manager' AND counter_name = 'Page reads/sec')
	OR ( OBJECT_NAME = @CounterPrefix+'Buffer Manager' AND counter_name = 'Page writes/sec')
	OR ( OBJECT_NAME = @CounterPrefix+'Databases' AND counter_name = 'Log Growths')
	OR ( OBJECT_NAME = @CounterPrefix+'Buffer Manager' AND counter_name = 'Free list stalls/sec')							 
	OR ( OBJECT_NAME = @CounterPrefix+'General Statistics' AND counter_name = 'User Connections')
	OR ( OBJECT_NAME = @CounterPrefix+'Locks' AND counter_name = 'Lock Waits/sec')
	OR ( OBJECT_NAME = @CounterPrefix+'Locks' AND counter_name = 'Number of Deadlocks/sec')
	OR ( OBJECT_NAME = @CounterPrefix+'Databases' AND counter_name = 'Transactions/sec')
	OR ( OBJECT_NAME = @CounterPrefix+'Access Methods' AND counter_name = 'Forwarded Records/sec')  
	OR ( OBJECT_NAME = @CounterPrefix+'Access Methods' AND counter_name = 'Index Searches/sec')
	OR ( OBJECT_NAME = @CounterPrefix+'Access Methods' AND counter_name = 'Full Scans/sec')
	OR ( OBJECT_NAME = @CounterPrefix+'SQL Statistics' AND counter_name = 'Batch Requests/sec')
	OR ( OBJECT_NAME = @CounterPrefix+'SQL Statistics' AND counter_name = 'SQL Compilations/sec')
	OR ( OBJECT_NAME = @CounterPrefix+'SQL Statistics' AND counter_name = 'SQL Re-Compilations/sec')
	OR ( OBJECT_NAME = @CounterPrefix+'Latches' AND counter_name = 'Latch Waits/sec')
	OR ( OBJECT_NAME = @CounterPrefix+'General Statistics' AND counter_name = 'Processes Blocked')
	OR ( OBJECT_NAME = @CounterPrefix+'Locks' AND counter_name = 'Lock Wait Time (ms)')
	OR ( OBJECT_NAME = @CounterPrefix+'Memory Manager' AND counter_name = 'Memory Grants Pending')
	OR ( OBJECT_NAME = @CounterPrefix+'Access Methods'AND counter_name = 'Page Splits/sec') ) 
	AND (instance_name = '' or instance_name = '_Total') 
--Jeremiah Nellis
select 
	('$Svr') as ServerName, ('$inst') as InstanceName,  --getdate() as RunDate,
	[Forwarded Records/sec] as FwdRecSec,
	[Full Scans/sec] as FlScansSec,
	[Index Searches/sec] as IdxSrchsSec,
    	[Page Splits/sec] as PgSpltSec,
	[Free list stalls/sec] as FreeLstStallsSec,
	[Lazy writes/sec] as LzyWrtsSec,
	[Page life expectancy] as PgLifeExp,
	[Page reads/sec] as PgRdSec,
	[Page writes/sec] as PgWtSec,
	[Log Growths] LogGrwths,
	[Transactions/sec] as TranSec,
	[Processes blocked] as BlkProcs,
	[User Connections] as UsrConns,
	[Latch Waits/sec] as LatchWtsSec,
	[Lock Wait Time (ms)] as LckWtTime,
	[Lock Waits/sec] as LckWtsSec,
	[Number of Deadlocks/sec] as DeadLockSec,
	[Memory Grants Pending] as MemGrnts,
	[Batch Requests/sec] as BatReqSec,
	[SQL Compilations/sec] as SQLCompSec,
	[SQL Re-Compilations/sec] as SQLReCompSec
   -- add your additional counters here
From (SELECT  s.counter_name ,
        CASE WHEN i.cntr_type = 272696576
          THEN s.cntr_value - i.cntr_value
          WHEN i.cntr_type = 65792 THEN s.cntr_value
        END AS cntr_value
FROM #perf_counters_init AS i
  JOIN  #perf_counters_second AS s
    ON i.collection_instance + 1 = s.collection_instance
      AND i.OBJECT_NAME = s.OBJECT_NAME
      AND i.counter_name = s.counter_name
      AND i.instance_name = s.instance_name) as SourceTable
Pivot
(
Max(cntr_value)
For [counter_name] in (
		[Forwarded Records/sec],
		[Full Scans/sec],
		[Index Searches/sec],
		[Page Splits/sec],
		[Free list stalls/sec],
		[Lazy writes/sec],
		[Page life expectancy],
		[Page reads/sec],
		[Page writes/sec],
		[Log Growths],
		[Transactions/sec],
		[Processes blocked],
		[User Connections],
		[Latch Waits/sec],
		[Lock Wait Time (ms)],
		[Lock Waits/sec],
		[Number of Deadlocks/sec],
		[Memory Grants Pending],
		[Batch Requests/sec],
		[SQL Compilations/sec],
		[SQL Re-Compilations/sec]
		 -- add the same additional counters here
    ) 
) as PivotTable
-- Cleanup tables
DROP TABLE #perf_counters_init
DROP TABLE #perf_counters_second"

$da = new-object System.Data.SqlClient.SqlDataAdapter ($query, $cn)
$dt = new-object System.Data.DataTable
$da.fill($dt) | out-null
#$cn.Close()

Write-DataTable -ServerInstance $SQLInst -Database $Centraldb -TableName $CITbl -Data $dt
} 
catch 
	{ 
        $ex = $_.Exception 
	write-log -Message "$ex.Message on $inst While collecting Instance Baseline Stats "  -NoConsoleOut -Path $LogPath
	} finally{
   		$ErrorActionPreference = "Continue"; #Reset the error action pref to default
	}
}
else {
             
              write-log -Message "SQL Server DB Engine is not Installed or Started or inaccessible on $inst"  -NoConsoleOut -Path $LogPath
     }
################################################## Server Baseline Stats ################################################################# 
try
{
$ErrorActionPreference = "Stop"; #Make all errors terminating
$Date= Get-Date -format G
$CITbl = “[Svr].[SvrBaselineStats]”

#Processor Counters

$Proc = get-Counter -Counter '\Processor(_total)\% Processor Time'-computername $svr
$PctProcTm=$proc.counterSamples[0].CookedValue

$ProcQ = get-Counter -Counter '\System\Processor Queue Length' -computername $svr
$ProcQLen = $ProcQ.counterSamples[0].CookedValue

#Disk Counters

$dskRd = get-Counter -Counter '\PhysicalDisk(_total)\Avg. Disk sec/Read' -computername $svr
$AvDskRd = $dskRd.counterSamples[0].CookedValue

$dskWt = get-Counter -Counter '\PhysicalDisk(_total)\Avg. Disk sec/Write' -computername $svr
$AvDskWt = $dskWt.counterSamples[0].CookedValue

$dskQ = get-Counter -Counter '\PhysicalDisk(_total)\Avg. Disk Queue Length' -computername $svr
$AvDskQLen = $dskQ.counterSamples[0].CookedValue

#Memory Counters

$AvlMB = get-Counter -Counter '\Memory\Available MBytes' -computername $svr
$AvailMB = $AvlMB.counterSamples[0].CookedValue

$PgFl = get-Counter -Counter '\Paging File(_total)\% Usage' -computername $svr
$PgFlUsg = $PgFl.counterSamples[0].CookedValue

$dt = get-Counter -computername $svr | select @{n="ServerName";e={$svr}}, @{n="InstanceName";e={$inst}}, @{Name="RunDate"; Expression = {$Date}}, 
	@{Name="PctProcTm"; Expression = {$PctProcTm}}, @{Name="ProcQLen"; Expression = {$ProcQLen}},@{Name="AvDskRd"; Expression = {$AvDskRd}},
	@{Name="AvDskWt"; Expression = {$AvDskWt}},@{Name="AvDskQLen"; Expression = {$AvDskQLen}}, @{Name="AvailMB"; Expression = {$AvailMB}},
 	 @{Name="PgFlUsg"; Expression = {$PgFlUsg}} | out-datatable
Write-DataTable -ServerInstance $SQLInst -Database $Centraldb -TableName $CITbl -Data $dt
}    
catch 
	{ 
        $ex = $_.Exception 
	write-log -Message "$ex.Message on $Svr While collecting Server Baseline Stats "  -NoConsoleOut -Path $LogPath
	} finally{
   		$ErrorActionPreference = "Continue"; #Reset the error action pref to default
	}
}#EndFunction
######################################################################################################################################
$cn = new-object system.data.sqlclient.sqlconnection(“server=$SQLInst;database=$CentralDB;Integrated Security=true;”);
$cn.Open()
$cmd = $cn.CreateCommand()
$query = " Select Distinct ServerName, InstanceName from [Svr].[ServerList] where Baseline='True';"
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