param(
	[string]$SQLInst="RSQLADM\MAPS",
	[string]$Centraldb="CentralDB"
	)
[System.Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.SMO') | out-null
[System.Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.ConnectionInfo') | out-null
[System.Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.SqlWmiManagement') | out-null

$cn = new-object system.data.sqlclient.sqlconnection(“server=$SQLInst;database=$CentralDB;Integrated Security=true;”);
$cn.Open()
$cmd = $cn.CreateCommand()
# Fetch Server list into the Data source from Srv.ServerList Table from CentralDB
$query = "SELECT DISTINCT ServerName, InstanceName FROM [Svr].[ServerList] WHERE SQLPing = 'True' AND (PingSnooze IS NULL OR PingSnooze <= GETDATE()) AND ((MaintStart IS NULL) or (MaintEnd IS NULL) or (GETDATE() NOT BETWEEN MaintStart AND MaintEnd ))"
$cmd.CommandText = $query
$reader = $cmd.ExecuteReader()
while($reader.Read()) {
 
   	# Get ServerName and InstanceName from CentralDB
	$server = $reader['ServerName']
	$instance = $reader['InstanceName']
	$dateping = Get-Date

	# Open connection table PingStatus
	$cnlog = new-object system.data.sqlclient.sqlconnection(“server=$SQLInst;database=$CentralDB;Integrated Security=true;”);
	$cnlog.Open()
	$cmdlog = $cnlog.CreateCommand()
	$querylog = "INSERT INTO Inst.PingStatus VALUES('{0}','{1}','{2}','{3}','{4}')" 

	#Increase the Count if you are having timeout and getting false positives
	if(test-connection -computername $Server -count 3 -delay 1 -quiet)
	{
		# Check SQL Services are running or not
		$res = new-object Microsoft.SqlServer.Management.Common.ServerConnection($instance)
		$resp = $false
			if ($res.ProcessID -ne $null) {
			$resp = $true
    			}

    		If (!$resp) {
		# Write table PingStatus connection fail
		$cmdlog.CommandText = $querylog -f $server,$instance,1,0,$dateping
		$cmdlog.ExecuteNonQuery()
				
		Send-MailMessage -To "fabio.marques@riachuelo.com.br" -From "ntsvcs@riachuelo.com.br" -SmtpServer "10.1.0.38" -Subject "CentralDB: Unable to connect to $instance" -body "Unable to connect to $instance Instance. Please make sure if you are able to RDP to the box and Check SQL Services. "
		}
		else{
			# Write table PingStatus connection success
			$cmdlog.CommandText = $querylog -f $server,$instance,1,1,$dateping
			$cmdlog.ExecuteNonQuery()
		}
	}
	else {
		# Write table PingStatus ping fail success
		$cmdlog.CommandText = $querylog -f $server,$instance,0,0,$dateping
		$cmdlog.ExecuteNonQuery()
		Send-MailMessage -To "fabio.marques@riachuelo.com.br" -From "ntsvcs@riachuelo.com.br" -SmtpServer "10.1.0.38" -Subject "CentralDB: Unable to ping $server" -body "Unable to ping $server Server. Please make sure if you are able to RDP to the box and Check SQL Services. "
	}
	$cnlog.close()
}