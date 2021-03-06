##################################################################
#
#  Name:      ServerInformation.ps1
#  Author:    Omid Afzalalghom
#  Date:      07/10/2015
#  Requires:  PS Version 2, SQL Tools.
#  Revisions: v 0.1
##################################################################

#Requires –Version 2.0 

#Import the sqlps module to allow use of invoke-sqlcmd.    
Import-Module “sqlps” -DisableNameChecking -WarningAction SilentlyContinue 

#Assign variable values.
$inst = $args[0]
$dir = $args[1]
$reports = "$($args[1])Reports\Temp"
    
TRY{
    $ErrorActionPreference = "Stop";

    $memOS = invoke-sqlcmd –ServerInstance $inst -Query "SELECT CEILING(physical_memory_in_bytes/1073741824.) FROM sys.dm_os_sys_info;"  | %{'{0}' -f $_[0]}
    $memSQLMax = invoke-sqlcmd –ServerInstance $inst -Query "SELECT CEILING(CAST(value AS INT)/1024.) FROM sys.configurations WHERE name = 'max server memory (MB)';"  | %{'{0}' -f $_[0]}
    $memSQLCurr = invoke-sqlcmd –ServerInstance $inst -Query "SELECT CEILING(cntr_value/1048576.) FROM sys.dm_os_performance_counters WHERE counter_name = 'Total Server Memory (KB)';"  | %{'{0}' -f $_[0]}
    $memTokenStore = invoke-sqlcmd –ServerInstance $inst -Query "SELECT SUM(single_pages_kb + multi_pages_kb)/1024 MB FROM sys.dm_os_memory_clerks WHERE type = 'USERSTORE_TOKENPERM' AND single_pages_kb + multi_pages_kb > 8;"  | %{'{0}' -f $_[0]}
     
    $NetBiosName = invoke-sqlcmd –ServerInstance $inst -Query "SELECT CONVERT(sysname, SERVERPROPERTY ('ComputerNamePhysicalNetBIOS'));" | %{'{0}' -f $_[0]}
    $MachineName = invoke-sqlcmd –ServerInstance $inst -Query "SELECT CONVERT(sysname, SERVERPROPERTY ('MachineName'));" | %{'{0}' -f $_[0]}	 
    $ServerName = invoke-sqlcmd –ServerInstance $inst -Query "SELECT @@SERVERNAME;"	| %{'{0}' -f $_[0]} 
    $InstanceName = invoke-sqlcmd –ServerInstance $inst -Query "SELECT ISNULL(CONVERT(sysname, SERVERPROPERTY ('InstanceName')), 'Default');" | %{'{0}' -f $_[0]}	 
    $Edition = invoke-sqlcmd –ServerInstance $inst -Query "SELECT CONVERT(sysname, SERVERPROPERTY ('Edition'));" | %{'{0}' -f $_[0]}	 
    $ProductVersionName = invoke-sqlcmd –ServerInstance $inst -Query "SELECT SUBSTRING(@@VERSION, 1, (PATINDEX('%)%', @@VERSION)));" | %{'{0}' -f $_[0]}
    $ProductLevel = invoke-sqlcmd –ServerInstance $inst -Query "SELECT CONVERT(sysname, SERVERPROPERTY ('ProductLevel'));" | %{'{0}' -f $_[0]}	  	
    $ProductVersion = invoke-sqlcmd –ServerInstance $inst -Query "SELECT CONVERT(sysname, SERVERPROPERTY ('ProductVersion'));" | %{'{0}' -f $_[0]}	    
    $Reboot = invoke-sqlcmd –ServerInstance $inst -Query "SELECT sqlserver_start_time FROM sys.dm_os_sys_info;"	| %{'{0}' -f $_[0]} 
    $Clustered = invoke-sqlcmd –ServerInstance $inst -Query "SELECT CONVERT(sysname, SERVERPROPERTY ('IsClustered'));"	| %{'{0}' -f $_[0]} 
    $FullText = invoke-sqlcmd –ServerInstance $inst -Query "SELECT CONVERT(sysname, SERVERPROPERTY ('IsFullTextInstalled'));"	| %{'{0}' -f $_[0]}  	
    $Authentication = invoke-sqlcmd –ServerInstance $inst -Query "SELECT  CASE WHEN CONVERT(sysname, SERVERPROPERTY ('IsIntegratedSecurityOnly')) = 1 THEN 'Windows' ELSE 'Mixed' END;"	| %{'{0}' -f $_[0]}  		
    $ProcessID = invoke-sqlcmd –ServerInstance $inst -Query "SELECT CONVERT(sysname, SERVERPROPERTY ('ProcessID'));" | %{'{0}' -f $_[0]} 
    $Collation = invoke-sqlcmd –ServerInstance $inst -Query "SELECT CONVERT(sysname, SERVERPROPERTY ('Collation'));" | %{'{0}' -f $_[0]} 
    $MaxWorkers = invoke-sqlcmd –ServerInstance $inst -Query "SELECT max_workers_count FROM sys.dm_os_sys_info;" | %{'{0}' -f $_[0]} 
    $CurrWorkers = invoke-sqlcmd –ServerInstance $inst -Query "SELECT SUM(current_workers_count)  FROM sys.dm_os_schedulers;" | %{'{0}' -f $_[0]} 		        
     
    $CPUproperty = "Name","CurrentClockSpeed","MaxClockSpeed","NumberOfCores"
    $cpu = Get-WmiObject Win32_Processor -ComputerName $MachineName -Property  $CPUproperty | Select-Object -Property $CPUproperty | sort -unique 

    $comp = Get-WmiObject -class Win32_ComputerSystem -ComputerName $MachineName | 
                                Select-Object -Property NumberOfLogicalProcessors, NumberOfProcessors, Manufacturer, Model  

    $power = Get-WmiObject -Class Win32_PowerPlan -ComputerName $MachineName -Namespace root\cimv2\power -fi "isactive = 'true'"| select-object ElementName

    $os = Get-WmiObject Win32_OperatingSystem -ComputerName $MachineName | select Caption, OSArchitecture

    $bios = Get-WmiObject Win32_bios -ComputerName $MachineName |select-object Manufacturer, Name, Version
           
    #Is hyperthreading enabled?
    if ($comp.NumberOfProcessors * $cpu.NumberOfCores -lt $comp.NumberOfLogicalProcessors)
        {$HT = "Enabled"}
    else {$HT = "Disabled"}
 
#Write custom table to temporary text file.
@"
"Item", "Value"
"Manufacturer","$($comp.Manufacturer)"
"Model","$($comp.Model)"
"CPU Type","$($cpu.Name)"
"Physical Processors","$($comp.NumberOfProcessors)"
"Cores Per Processor","$($cpu.NumberOfCores)"
"Total Logical Processors","$($comp.NumberOfLogicalProcessors)"
"Current Clock Speed","$($cpu.CurrentClockSpeed)"
"Max Clock Speed","$($cpu.MaxClockSpeed)"
"Power Plan","$($power.ElementName)"
"Hyperthreading","$($HT)"
"OS","$($os.Caption)"
"OS Architecture","$($os.OSArchitecture)"
"BIOS Manufacturer","$($bios.Manufacturer)"
"BIOS Name","$($bios.Name)"
"BIOS Version","$($bios.Version)"
"Physical Memory (GB)","$($memOS)"
"Max SQL Memory (GB)","$($memSQLMax)"
"Current SQL Memory (GB)","$($memSQLCurr)"
"TokenPermStore (MB)","$($memTokenStore)"
"NetBios Name","$($NetBiosName)"
"Machine Name","$($MachineName)"
"Server Name","$($ServerName)"
"Instance Name","$($InstanceName)"
"Version Name","$($ProductVersionName)"
"Edition","$($Edition)"
"Product Level","$($ProductLevel)"
"Product Version","$($ProductVersion)"
"SQL Server Last Rebooted","$($Reboot)"
"Is Clustered","$($Clustered)"
"Is Full-Text Installed","$($FullText)"
"Authentication","$($Authentication)"
"ProcessID","$($ProcessID)"
"Collation","$($Collation)"
"Max Workers","$($MaxWorkers)"
"Current Workers","$($CurrWorkers)"
"@ | Out-File "$reports\temp.txt"  

    #Export text file to CSV file.
    $txt = Import-Csv "$reports\temp.txt" 
    write-output $txt |Export-Csv -NoTypeInformation  -Path "$reports\ServerInformation.csv"   
     
    #Remove temporary text file. 
    get-childitem -path "$reports\temp.txt" | remove-item
  
  }
CATCH { 
       Write-output "$(Get-Date –f G) - Error: ServerInformation.ps1 - $($_.Exception.Message)" | out-file -filepath "$dir\ErrorLog.txt" -append
    } 