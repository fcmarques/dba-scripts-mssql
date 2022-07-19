<<<<<<< HEAD
﻿

Set-StrictMode -Version 2.0
try
{
	Add-Type -AssemblyName System.IO.Compression.FileSystem -ErrorAction Stop
}
catch
{
	Write-Warning "Could not add the zip .net type. Please zip the files manually"
}

#Region Functions

function Zip-Directory
{
	[CmdletBinding()]
	Param (
		[Parameter(Mandatory = $True)]
		[string]$DestinationFileName,
		[Parameter(Mandatory = $True)]
		[string]$SourceDirectory,
		[Parameter(Mandatory = $False)]
		[string]$CompressionLevel = "Optimal",
		[Parameter(Mandatory = $False)]
		[switch]$IncludeParentDir
	)
	$CompressionLevel = [System.IO.Compression.CompressionLevel]::$CompressionLevel
	[System.IO.Compression.ZipFile]::CreateFromDirectory($SourceDirectory, $DestinationFileName, $CompressionLevel, $IncludeParentDir)
}

function Invoke-Sqlcmd2
{
	
	[CmdletBinding(DefaultParameterSetName = 'Query')]
	[OutputType([System.Management.Automation.PSCustomObject], [System.Data.DataRow], [System.Data.DataTable], [System.Data.DataTableCollection], [System.Data.DataSet])]
	param (
		[Parameter(Position = 0,
				   Mandatory = $true,
				   ValueFromPipeline = $true,
				   ValueFromPipelineByPropertyName = $true,
				   ValueFromRemainingArguments = $false,
				   HelpMessage = 'SQL Server Instance required...')]
		[Alias('Instance', 'Instances', 'ComputerName', 'Server', 'Servers')]
		[ValidateNotNullOrEmpty()]
		[string[]]$ServerInstance,
		[Parameter(Position = 1,
				   Mandatory = $false,
				   ValueFromPipelineByPropertyName = $true,
				   ValueFromRemainingArguments = $false)]
		[string]$Database,
		[Parameter(Position = 2,
				   Mandatory = $true,
				   ValueFromPipelineByPropertyName = $true,
				   ValueFromRemainingArguments = $false,
				   ParameterSetName = 'Query')]
		[string]$Query,
		[Parameter(Position = 2,
				   Mandatory = $true,
				   ValueFromPipelineByPropertyName = $true,
				   ValueFromRemainingArguments = $false,
				   ParameterSetName = "File")]
		[ValidateScript({ Test-Path $_ })]
		[string]$InputFile,
		[Parameter(Position = 3,
				   Mandatory = $false,
				   ValueFromPipelineByPropertyName = $true,
				   ValueFromRemainingArguments = $false,
				   ParameterSetName = "Query")]
		[Parameter(Position = 3,
				   Mandatory = $false,
				   ValueFromPipelineByPropertyName = $true,
				   ValueFromRemainingArguments = $false,
				   ParameterSetName = "File")]
		[System.Management.Automation.PSCredential]$Credential,
		[Parameter(Position = 4,
				   Mandatory = $false,
				   ValueFromPipelineByPropertyName = $true,
				   ValueFromRemainingArguments = $false)]
		[Int32]$QueryTimeout = 600,
		[Parameter(Position = 5,
				   Mandatory = $false,
				   ValueFromPipelineByPropertyName = $true,
				   ValueFromRemainingArguments = $false)]
		[Int32]$ConnectionTimeout = 15,
		[Parameter(Position = 6,
				   Mandatory = $false,
				   ValueFromPipelineByPropertyName = $true,
				   ValueFromRemainingArguments = $false)]
		[ValidateSet("DataSet", "DataTable", "DataRow", "PSObject", "SingleValue")]
		[string]$As = "DataRow",
		[Parameter(Position = 7,
				   Mandatory = $false,
				   ValueFromPipelineByPropertyName = $true,
				   ValueFromRemainingArguments = $false)]
		[System.Collections.IDictionary]$SqlParameters,
		[Parameter(Position = 8,
				   Mandatory = $false)]
		[switch]$AppendServerInstance
	)
	
	Begin
	{
		if ($InputFile)
		{
			$filePath = $(Resolve-Path $InputFile).path
			$Query = [System.IO.File]::ReadAllText("$filePath")
		}
		
		Write-Verbose "Running Invoke-Sqlcmd2 with ParameterSet '$($PSCmdlet.ParameterSetName)'.  Performing query '$Query'"
		
		If ($As -eq "PSObject")
		{
			#This code scrubs DBNulls.  Props to Dave Wyatt
			$cSharp = @'
                using System;
                using System.Data;
                using System.Management.Automation;

                public class DBNullScrubber
                {
                    public static PSObject DataRowToPSObject(DataRow row)
                    {
                        PSObject psObject = new PSObject();

                        if (row != null && (row.RowState & DataRowState.Detached) != DataRowState.Detached)
                        {
                            foreach (DataColumn column in row.Table.Columns)
                            {
                                Object value = null;
                                if (!row.IsNull(column))
                                {
                                    value = row[column];
                                }

                                psObject.Properties.Add(new PSNoteProperty(column.ColumnName, value));
                            }
                        }

                        return psObject;
                    }
                }
'@
			
			Try
			{
				Add-Type -TypeDefinition $cSharp -ReferencedAssemblies 'System.Data', 'System.Xml' -ErrorAction stop
			}
			Catch
			{
				If (-not $_.ToString() -like "*The type name 'DBNullScrubber' already exists*")
				{
					Write-Warning "Could not load DBNullScrubber.  Defaulting to DataRow output: $_"
					$As = "Datarow"
				}
			}
		}
		
	}
	Process
	{
		foreach ($SQLInstance in $ServerInstance)
		{
			Write-Verbose "Querying ServerInstance '$SQLInstance'"
			
			if ($Credential)
			{
				$ConnectionString = "Server={0};Database={1};User ID={2};Password={3};Trusted_Connection=False;Connect Timeout={4}" -f $SQLInstance, $Database, $Credential.UserName, $Credential.GetNetworkCredential().Password, $ConnectionTimeout
			}
			else
			{
				$ConnectionString = "Server={0};Database={1};Integrated Security=True;Connect Timeout={2}" -f $SQLInstance, $Database, $ConnectionTimeout
			}
			
			$conn = New-Object System.Data.SqlClient.SQLConnection
			$conn.ConnectionString = $ConnectionString
			Write-Debug "ConnectionString $ConnectionString"
			
			#Following EventHandler is used for PRINT and RAISERROR T-SQL statements. Executed when -Verbose parameter specified by caller 
			if ($PSBoundParameters.ContainsKey('Verbose'))
			{
				$conn.FireInfoMessageEventOnUserErrors = $true
				$handler = [System.Data.SqlClient.SqlInfoMessageEventHandler] { Write-Verbose "$($_)" }
				$conn.add_InfoMessage($handler)
			}
			
			Try
			{
				$conn.Open()
			}
			Catch
			{
				Write-Error $_
				continue
			}
			
			$cmd = New-Object system.Data.SqlClient.SqlCommand($Query, $conn)
			$cmd.CommandTimeout = $QueryTimeout
			
			if ($SqlParameters -ne $null)
			{
				$SqlParameters.GetEnumerator() |
				ForEach-Object {
					If ($_.Value -ne $null)
					{ $cmd.Parameters.AddWithValue($_.Key, $_.Value) }
					Else
					{ $cmd.Parameters.AddWithValue($_.Key, [DBNull]::Value) }
				} > $null
			}
			
			$ds = New-Object system.Data.DataSet
			$da = New-Object system.Data.SqlClient.SqlDataAdapter($cmd)
			
			[void]$da.fill($ds)
			$conn.Close()
			
			if ($AppendServerInstance)
			{
				#Basics from Chad Miller
				$Column = new-object Data.DataColumn
				$Column.ColumnName = "ServerInstance"
				$ds.Tables[0].Columns.Add($Column)
				Foreach ($row in $ds.Tables[0])
				{
					$row.ServerInstance = $SQLInstance
				}
			}
			
			switch ($As)
			{
				'DataSet'
				{
					$ds
				}
				'DataTable'
				{
					$ds.Tables
				}
				'DataRow'
				{
					$ds.Tables[0]
				}
				'PSObject'
				{
					#Scrub DBNulls - Provides convenient results you can use comparisons with
					#Introduces overhead (e.g. ~2000 rows w/ ~80 columns went from .15 Seconds to .65 Seconds - depending on your data could be much more!)
					foreach ($row in $ds.Tables[0].Rows)
					{
						[DBNullScrubber]::DataRowToPSObject($row)
					}
				}
				'SingleValue'
				{
					$ds.Tables[0] | Select-Object -ExpandProperty $ds.Tables[0].Columns[0].ColumnName
				}
			}
		}
	}
} #Invoke-Sqlcmd2


Function Remove-Comma
{
	
	param ([parameter(position = 0, Mandatory = $true)]
		[string]$text)
	if ($text.substring(0, 1) -eq ",")
	{
		$text = $text.substring(1, $text.length - 1)
	}
	if ($text.substring($text.length - 1, 1) -eq ",")
	{
		$text = $text.substring(0, $text.length - 1)
	}
	
	Write-Output $text
	
}

#Region from SQLPSX
function Get-SqlServer
{
	param (
		[Parameter(Position = 0, Mandatory = $true)]
		[string]$sqlserver,
		[Parameter(Position = 1, Mandatory = $false)]
		[string]$username,
		[Parameter(Position = 2, Mandatory = $false)]
		[string]$password,
		[Parameter(Position = 3, Mandatory = $false)]
		[string]$StatementTimeout = 0
	)
	#When $sqlserver passed in from the SMO Name property, brackets
	#are automatically inserted which then need to be removed
	$sqlserver = $sqlserver -replace "\[|\]"
	
	Write-Verbose "Get-SqlServer $sqlserver"
	
	if ($Username -and $Password)
	{ $con = new-object ("Microsoft.SqlServer.Management.Common.ServerConnection") $sqlserver, $username, $password }
	else
	{ $con = new-object ("Microsoft.SqlServer.Management.Common.ServerConnection") $sqlserver }
	
	$con.Connect()
	$server = new-object ("Microsoft.SqlServer.Management.Smo.Server") $con
	#Some operations might take longer than the default timeout of 600 seconnds (10 minutes). Set new default to unlimited
	$server.ConnectionContext.StatementTimeout = $StatementTimeout
	$server.SetDefaultInitFields([Microsoft.SqlServer.Management.SMO.StoredProcedure], "IsSystemObject")
	$server.SetDefaultInitFields([Microsoft.SqlServer.Management.SMO.Table], "IsSystemObject")
	$server.SetDefaultInitFields([Microsoft.SqlServer.Management.SMO.View], "IsSystemObject")
	$server.SetDefaultInitFields([Microsoft.SqlServer.Management.SMO.UserDefinedFunction], "IsSystemObject")
	#trap { "Check $SqlServer Name"; continue} $server.ConnectionContext.Connect() 
	Write-Output $server
	
} #Get-SqlServer

function Get-SqlConnection
{
	[cmdletbinding()]
	param (
		[Parameter(Position = 0, Mandatory = $true)]
		[string]$sqlserver,
		[Parameter(Position = 1, Mandatory = $false)]
		[string]$username,
		[Parameter(Position = 2, Mandatory = $false)]
		[string]$password
	)
	
	Write-Verbose "Get-SqlConnection $sqlserver"
	
	if ($Username -and $Password)
	{ $con = new-object ("Microsoft.SqlServer.Management.Common.ServerConnection") $sqlserver, $username, $password }
	else
	{ $con = new-object ("Microsoft.SqlServer.Management.Common.ServerConnection") $sqlserver }
	
	$con.Connect()
	
	Write-Output $con
	
} #Get-ServerConnection

#EndRegion from SQLPSX
Function Write-Log
{
	
	[CmdletBinding()]
	Param
	(
		[Parameter(Mandatory = $true, Position = 1)]
		[ValidateNotNullOrEmpty()]
		[String]$path,
		[Parameter(Mandatory = $true, Position = 2)]
		[ValidateNotNullOrEmpty()]
		[String]$Message,
		[Parameter(Mandatory = $true, Position = 3)]
		[String]$ErrorLogFileName,
		[Parameter(Mandatory = $false, Position = 4)]
		[ValidateNotNullOrEmpty()]
		[Switch]$Error,
		[Parameter(Mandatory = $false, Position = 5)]
		[ValidateNotNullOrEmpty()]
		[Switch]$TerminatedError
		
		
	)
	
	try
	{
		
		if (!(Test-Path $path))
		{
			New-Item -Path $path -ItemType Directory -ErrorAction stop | Out-Null
		}
		
		$Fullpath = "$($path)\$($ErrorLogFileName).log"
		
		if ($PSBoundParameters.ContainsKey('Verbose'))
		{
			$Message = "[verbose]$($TimeStamp) - $($Message)"
			Write-Verbose $Message
		}
		
		if ($PSBoundParameters.ContainsKey('Error'))
		{
			$Message = "[Error]$($TimeStamp) - $($Message)"
			Write-Warning  $Message
		}
		
		if ($PSBoundParameters.ContainsKey('TerminatedError'))
		{
			$Message = "[Terminated Error]$($TimeStamp) $($Message)"
			$Message | out-file -FilePath $Fullpath -Append
			Throw "$($Message)"
			
		}
		$Message | out-file -FilePath $Fullpath -Append
	}
	catch
	{
		Throw "Error processing the log file. Script terminated $($_.Exception.Message)"
	}
	
	
}
`

Function Get-SQLWmiInfo
{
	
	param (
		[Parameter(Position = 0, Mandatory = $true)]
		[string]$MachineName
	)
	
	[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.SqlWmiManagement") | out-null
	$SQLWmi = New-Object ('Microsoft.SqlServer.Management.Smo.Wmi.ManagedComputer') $MachineName
	Write-output $SQLWmi
}

#EndRegion Functions

#Region Assembly

if ([Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.SMO") -eq $null -or ([System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.ConnectionInfo") -eq $null))
{
	Throw "SMO not avaliable"
}

#EndRegion Assembly

#Region Variables


$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Definition
$PSScriptRoot = $scriptRoot

$ArrayVLF = @()
#parameter
$PathForOutputFiles = "$($scriptRoot)\output"


$FileName = $null
$ErrorActionPreference = "Stop"
$VerbosePreference = "Continue"

$Global:TimeStamp = Get-Date -Format "MM-dd-yyyy hh:mm:ss"

$PathWriteLog = "$($scriptRoot)\Log"
$ErrorLogfileName = "LOG_General_$(Get-Date -Format 'yyyyMMdd_hhmmss').log"

try
{
	if (!(Test-Path $PathWriteLog))
	{
		New-Item -Path $PathWriteLog -ItemType Directory -ErrorAction stop | Out-Null
	}
}
catch
{
	Write-Error    "Could not create the path $($PathWriteLog). Aborting script.."
	Throw
}


if (-not ((New-Object Security.Principal.WindowsPrincipal ([Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)))
{
	Write-Log -Message "You must run Windows PowerShell as Administrator - Elevated Mode" -path $PathWriteLog -ErrorLogFileName $ErrorLogfileName -verbose
	Throw
}


if (!(Test-Path "$PSScriptRoot\InstanceNames.txt"))
{
	"YourInstanceName1", "Server\YourInstanceName2" |
	Out-File "$PSScriptRoot\InstanceNames.txt"
	Write-Log "Please fill the file $PSScriptRoot\InstanceNames.txt with the name of the SQL Server Instances" -path $PathWriteLog -ErrorLogFileName $ErrorLogfileName -verbose
	Return
	
}


try
{
	$instancesNames = Get-Content "$PSScriptRoot\InstanceNames.txt" -ErrorAction 'Stop'
}
catch
{
	"YourInstanceName1", "Server\YourInstanceName2" |
	Out-File "$PSScriptRoot\InstanceNames.txt"
	Write-Log  "Please fill the file $PSScriptRoot\InstanceNames.txt with the name of the SQL Server Instances" -path $PathWriteLog -ErrorLogFileName $ErrorLogfileName -verbose
	Return
}

if ($instancesNames -contains "YourInstanceName1" -or $instancesNames -contains "Server\YourInstanceName2")
{
	Write-log   "Please fill the file $PSScriptRoot\InstanceNames.txt with the name of the SQL Server Instances" -path $PathWriteLog -ErrorLogFileName $ErrorLogfileName -verbose
	Return
}

Write-Log -Message "Checking for Connection in the instances and if current account is SA" -path $PathWriteLog -ErrorLogFileName $ErrorLogfileName -verbose
$TestedInstanceName = @()
try
{
	$instancesNames |
	ForEach-Object {
		try
		{
			$con = Get-SqlConnection -sqlserver $_ -verbose:$false -ea stop
			if ($con)
			{
				if ($con.FixedServerRoles -like "*SysAdmin*")
				{
					$TestedInstanceName += $_
				}
				else
				{
					Write-log -Message "User is not SYSADM on the instance $($_). This Instace will be skipped." -path $PathWriteLog -ErrorLogFileName $ErrorLogfileName -verbose
				}
			}
			else
			{
				Write-log -Message "Could not connect to the instance $($_)" -path $PathWriteLog -ErrorLogFileName $ErrorLogfileName -verbose
			}
		}
		catch
		{
			Write-Log -Message "Could not connect to the instance $($_)" -path $PathWriteLog -ErrorLogFileName $ErrorLogfileName -verbose
		}
	}
}
catch
{
	Write-Log -Message "An error occcurred. Please run the script again" -path $PathWriteLog -ErrorLogFileName $ErrorLogfileName -Error -TerminatedError
}



#EndRegion Variables



if (!(Test-Path $pathForOutputFiles))
{
	try
	{
		New-Item -Path $pathForOutputFiles -ItemType Directory -ErrorAction stop | Out-Null
	}
	catch
	{
		Write-Warning  "Could not create the path $($pathForOutputFiles). Aborting script.."
		Throw
	}
	
}

$InputFile = $null


$TestedInstanceName |
ForEach-Object {
	
	$PathForOutputFiles = "$($scriptRoot)\output"
	$SQLWmiInstanceName = ""
	$ArrayServerProperties = @()
	$ArrayDatabaseProperties = @()
	$PsObjectDatabaseProperties = $null
	$ArrayDatabaseFiles = @()
	$ArraySQLAgent = @()
	$ArrayOtherChecks = @()
	
	
	$splitedInstanceName = $_ -split "\\"
	$MachineName = $splitedInstanceName[0]
	$InstanceName = $splitedInstanceName[1]
	
	$createdpath = $true
	
	if ($InstanceName)
	{
		if (!(Test-Path "$($PathForOutputFiles)\$($MachineName)_$($InstanceName)"))
		{
			try
			{
				New-Item -ItemType directory -Path "$($PathForOutputFiles)\$($MachineName)_$($InstanceName)" | Out-Null
			}
			catch
			{
				Write-log  "Could not create the $($PathForOutputFiles)\$($MachineName)_$($InstanceName) path - Skipping the instance check" -path $PathWriteLog -ErrorLogFileName $ErrorLogfileName -verbose
				$createdpath = $false
				
			}
			
		}
		$PathForOutputFiles = "$($PathForOutputFiles)\$($MachineName)_$($InstanceName)"
		$FileName = "$($PathForOutputFiles)\$($MachineName)_$($InstanceName)_"
		$FullInstanceName = "$($MachineName)\$InstanceName"
		$SQLWmiInstanceName = $InstanceName
		$ErrorLogfileName = "$($MachineName)_$($InstanceName)_BestPractices_$(Get-Date -Format 'yyyyMMdd_hhmmss')"
		$CSVNames = "$($MachineName)_$($InstanceName)"
		
		
	}
	else
	{
		
		if (!(Test-Path "$($PathForOutputFiles)\$($MachineName)"))
		{
			try
			{
				New-Item -ItemType directory -Path "$($PathForOutputFiles)\$($MachineName)" | Out-Null
			}
			catch
			{
				Write-Log "Could not create the $($PathForOutputFiles)\$($MachineName) path - Skipping the instance check" -path $PathWriteLog -ErrorLogFileName $ErrorLogfileName -verbose
				$createdpath = $false
				
			}
		}
		
		$PathForOutputFiles = "$($PathForOutputFiles)\$($MachineName)"
		
		$FileName = "$($PathForOutputFiles)\$($MachineName)_"
		$FullInstanceName = $MachineName
		$SQLWmiInstanceName = 'MSSQLSERVER'
		$ErrorLogfileName = "$($MachineName)_BestPractices_$(Get-Date -Format 'yyyyMMdd_hhmmss')"
		$CSVNames = "$($MachineName)"
	}
	If ($createdpath)
	{
		Write-log -Message "Starting gathering" -path $PathWriteLog -ErrorLogFileName $ErrorLogfileName -verbose
		
		
		Try
		{
			Get-ChildItem -Path "$($PathForOutputFiles)\$($CSVNames)*.csv" |
			Remove-Item -Force
		}
		catch
		{
			Write-Log -Error "Could not remove the old csv files from Instance $($FullInstanceName) . : Error $($_.Exception.Message) " -path $PathWriteLog -ErrorLogFileName $ErrorLogfileName -TerminatedError
		}
		
		
		try
		{
			
			$Server = Get-SqlServer -sqlserver $FullInstanceName
			Write-Log -Message "Connection Successfully instance - $($FullInstanceName)" -path $PathWriteLog -ErrorLogFileName $ErrorLogfileName -verbose
		}
		catch
		{
			Write-Log -Error "Error connecting on instance  $($FullInstanceName) : Error $($_.Exception.Message)" -path $PathWriteLog -ErrorLogFileName $ErrorLogfileName
		}
		
		Write-Log -Message "Trying to connect on WMI" -path $PathWriteLog -ErrorLogFileName $ErrorLogfileName -verbose
		
		#Connecting on WMI
		Try
		{
			$SQLWmi = Get-SQLWmiInfo -MachineName $MachineName
			Write-Log -Message "Connection Successfully on WMI" -path $PathWriteLog -ErrorLogFileName $ErrorLogfileName -verbose
			
		}
		catch
		{
			Write-Log -Error "Cound not connect on  WMI Properties : Error $($_.Exception.Message)" -path $PathWriteLog -ErrorLogFileName $ErrorLogfileName
			
		}
		
		Write-Log -Message "Trying to connect to instance - $($FullInstanceName) " -path $PathWriteLog -ErrorLogFileName $ErrorLogfileName -verbose
		
		
		#Removing the last csv if it exists
		Write-Log -Message "Removing the olds csv files..." -path $PathWriteLog -ErrorLogFileName $ErrorLogfileName
		
		
		#Region Instance Name
		New-Object psobject -property @{ 'InstanceName' = $FullInstanceName } |
		Select InstanceName |
		Export-Csv -force -NoClobber -NoTypeInformation -Path "$($FileName)InstanceName.csv"
		
		
		#EndRegion Instance name 
		
		#Region Check 1 SQL Server version and edition: report if earlier than SQL 2008
		
		Write-Log -Message "Checking the SQL Server Edition...." -path $PathWriteLog -ErrorLogFileName $ErrorLogfileName
		
		$FQDN = ([System.Net.NetworkInformation.IPGlobalProperties]::GetIPGlobalProperties() | Select HostName, DomainName)
		$SQLVersionHigherThan10 = $true
		
		
		$SQL = " select serverproperty('productversion') version, serverproperty('productlevel') level , serverproperty('edition') edition"
		$ServerSQL = Invoke-Sqlcmd2 -ServerInstance $FullInstanceName -Query $SQL
		
		if ($ServerSQL.Version.Substring(0, 2) -like "*9*" -or $ServerSQL.Version.Substring(0, 2) -like "*8*")
		{
			$SQLVersionHigherThan10 = $false
			if ($ServerSQL.Version.Substring(0, 2) -like "*9*")
			{
				$SQLVersion = 9
			}
			else
			{
				$SQLVersion = 8
			}
			try
			{
				New-Object PSobject -Property @{
					'Machine Name' = $MachineName
					'Net Bios Name' = "$($FQDN.HostName).$($FQDN.HostName)"
					'Product Version' = "$($ServerSQL.version);Yellow"
					'Product Level' = $ServerSQL.level
					'Product Edition' = $ServerSQL.edition
				} |
				Select-Object 	@{ N = "Machine Name"; E = { $_."Machine Name" } },
							  @{ N = "Net Bios Name"; E = { $_."Net Bios Name" } },
							  @{ N = "Product Version"; E = { $_."Product Version" } },
							  @{ N = "Product Level"; E = { $_."Product Level" } },
							  @{ N = "Product Edition"; E = { $_."Product Edition" } } |
				Export-Csv -force -NoClobber -NoTypeInformation -Path "$($FileName)SQLEdition.csv"
			}
			catch
			{
				Write-Log -Error "Could not generate the SQLEdition.csv file. : Error $($_.Exception.Message) " -path $PathWriteLog -ErrorLogFileName $ErrorLogfileName
			}
		}
		else
		{
			$SQLVersion = $Server.Version.Major
			Try
			{
				New-Object PSobject -Property @{
					'Machine Name' = $MachineName
					'Net Bios Name' = "$($FQDN.HostName).$($FQDN.HostName)"
					'Product Version' = if ([int]$Server.Version.Major -lt 10) { "$($Server.VersionString);Yellow" }
					else { $Server.VersionString }
					'Product Level' = $Server.productLevel
					'Product Edition' = $Server.edition
					'Is Clustered' = $Server.IsClustered
				} |
				Select-Object 	@{ N = "Machine Name"; E = { $_."Machine Name" } },
							  @{ N = "Net Bios Name"; E = { $_."Net Bios Name" } },
							  @{ N = "Product Version"; E = { $_."Product Version" } },
							  @{ N = "Product Level"; E = { $_."Product Level" } },
							  @{ N = "Product Edition"; E = { $_."Product Edition" } },
							  @{ N = "Is Clustered"; E = { $_."Is Clustered" } } |
				Export-Csv -force -NoClobber -NoTypeInformation -Path "$($FileName)SQLEdition.csv"
			}
			catch
			{
				Write-Log -Error "Could not generate the SQLEdition.csv file. : Error $($_.Exception.Message) " -path $PathWriteLog -ErrorLogFileName $ErrorLogfileName
			}
		}
		
		#EndRegion Check 1 SQL Server version and edition: report if earlier than SQL 2008
		
		
		#Region Check 2 Server Protocols and Port (WMI) - TCPIP
		
		Write-Log -Message "Checking the SQL Server Protocols TCPIP...." -path $PathWriteLog -ErrorLogFileName $ErrorLogfileName
		
		$SQLWmiProtocols = $SQLWmi.ServerInstances["$SQLWmiInstanceName"]
		If ($SQLWmiProtocols)
		{
			
			$TCPIP = @{
				'Protocol Name' = 'TCP'
				'Is Enabled' = $SQLWmiProtocols.serverprotocols['Tcp'].IsEnabled
				'Has Multiple IP Addresses' = $SQLWmiProtocols.serverprotocols['Tcp'].HasMultiIPAddresses
				'Port SQL Server listening' = $SQLWmiProtocols.serverprotocols['Tcp'].IPAddresses['IPAll'].IPAddressProperties[1].Value
			}
			New-Object PSOBJECT -Property $TCPIP |
			Select 	@{ N = 'Protocol Name'; E = { $_."Protocol Name" } },
				   @{ N = 'Is Enabled'; E = { $_."Is Enabled" } },
				   @{ N = 'Has Multiple IP Addresses'; E = { $_."Has Multiple IP Addresses" } },
				   @{ N = 'Port SQL Server listening'; E = { $_."Port SQL Server listening" } } |
			Export-Csv -force -NoClobber -NoTypeInformation -Path "$($FileName)TCPIP.csv"
		}
		else
		{
			
			Write-Log -Error "Could not generate the Server Protocols csv files. " -path $PathWriteLog -ErrorLogFileName $ErrorLogfileName
		}
		
		#EndRegion Check 2 Server Protocols and Port (WMI) - TCPIP	
		
		
		#Region Output xp_msver
		try
		{
			Invoke-Sqlcmd2 -ServerInstance $FullInstanceName -Database master -Query "exec xp_msver" |
			Select 	@{ N = 'Property Name'; E = { $_.Name } },
				   @{ N = 'Value'; E = { $_.Character_value } } |
			Export-Csv -force -NoClobber -NoTypeInformation -Path "$($FileName)xpmsver.csv"
		}
		catch
		{
			Write-Log -Error "Could not generate the xpmsver.csv file. : Error $($_.Exception.Message) " -path $PathWriteLog -ErrorLogFileName $ErrorLogfileName
		}
		
		#EndRegion Output xp_msver
		
		#Region SQL Server Configuration 
		
		Write-Log -Message "Checking the SQL Server Configuration...." -path $PathWriteLog -ErrorLogFileName $ErrorLogfileName -verbose
		Try
		{
			Invoke-Sqlcmd2 -ServerInstance $FullInstanceName -Database master -Query "sp_configure" |
			Select @{ N = 'Configuration Name'; E = { $_.name } },
				   @{ N = 'Configuration Value'; E = { $_.config_value } },
				   @{ N = 'Run Value'; E = { $_.run_value } } |
			Export-Csv -force -NoClobber -NoTypeInformation -Path "$($FileName)ServerConfiguration.csv"
			
		}
		catch
		{
			
		}
		#EndRegion SQL Server Configuration 
		
		#Region SQL Server service account member of local Administrators
		
		Try
		{
			if (!($InstanceName))
			{
				$ServiceSearch = "MSSQLSERVER"
			}
			else
			{
				$ServiceSearch = "MSSQL`$$($instancename)"
			}
			$SQLWMIService = $SQLWmi.Services[$ServiceSearch]
			if ($SQLWMIService)
			{
				$isAdministrator = (&{ net localgroup administrators } |
				Where { $_ -eq ($SQLWMIService.ServiceAccount -split "\\")[1] })
				Write-Log -Message "Checking SQL Service Account ...." -path $PathWriteLog -ErrorLogFileName $ErrorLogfileName -verbose
				New-Object psobject -Property @{
					'Service Account' = $SQLWMIService.ServiceAccount
					'Start Mode' = $SQLWMIService.StartMode
					'Is Local Administrator' = if ($isAdministrator) { "True;Red" }
					else { "False" }
					'Startup Parameters' = $SQLWMIService.StartupParameters -replace ";", "|"
				} |
				Select 	@{ N = 'Service Account'; E = { $_."Service Account" } },
					   @{ N = 'Start Mode'; E = { $_."Start Mode" } },
					   @{ N = 'Is Local Administrator'; E = { $_."Is Local Administrator" } },
					   @{ N = 'Startup Parameters'; E = { $_."Startup Parameters" } } |
				Export-Csv -force -NoClobber -NoTypeInformation -Path "$($FileName)ServiceAccount.csv"
			}
		}
		catch
		{
			Write-Log -Error "Could not generate the Service Account.csv file : Error $($_.Exception.Message) " -path $PathWriteLog -ErrorLogFileName $ErrorLogfileName
		}
		#EndRegion SQL Server service account member of local Administrators
		
		#Region Page File
		Try
		{
			Write-Log -Message "Checking Page File Settings ...." -path $PathWriteLog -ErrorLogFileName $ErrorLogfileName -verbose
			
			$issue = ""
			$PageFileSize = (Get-WmiObject -ComputerName $MachineName -Class Win32_PageFileUsage).AllocatedBaseSize/1MB
			$PageFileAutomatic = (Get-WmiObject -ComputerName $MachineName -Class Win32_computersystem | select  @{ N = 'AutomaticManagedPagefile'; E = { $_."AutomaticManagedPagefile" } }).AutomaticManagedPagefile
			New-Object psobject -Property @{
				"Managed Page File" = if ($PageFileAutomatic) { "$($PageFileAutomatic);Red"; $issue += "Pagefile setting should be manually set and with a maximum value of 16 GB " }
				else { $PageFileAutomatic }
				"Size (MB)" = if ($PageFileSize -gt 16) { "$($PageFileSize);Red"; $issue += "Pagefile setting should be set with a maximum value of 16 GB" }
				else { $PageFileSize }
			} |
			Select 	@{ N = 'Managed Page File'; E = { $_."Managed Page File" } },
				   @{ N = 'Size (MB)'; E = { $_."Size (MB)" } },
				   @{
				N = 'Issue'; E = {
					if ($issue) { "$($issue);RED" }
					else { "No Issues" }
				}
			} |
			Export-Csv -force -NoClobber -NoTypeInformation -Path "$($FileName)PageFile.csv"
			
			
		}
		catch
		{
			Write-Log -Error "Could not generate the Page File.csv file : Error $($_.Exception.Message) " -path $PathWriteLog -ErrorLogFileName $ErrorLogfileName
		}
		#EndRegion Page File
		
		
		#Check Something
		#Just to explain the color alghoritm
		try
		{
			Write-Log -Message "Checking Something ...." -path $PathWriteLog -ErrorLogFileName $ErrorLogfileName -verbose
			
			New-Object psobject -property @{
				"Checking Something Red" = 'Something Red - not good;RED'
				"Checking Something Yellow" = 'Something Yellow - not too bad;Yellow'
				"Checking Something Green" = 'Something Green - good;Green'
			} |
			Export-Csv -force -NoClobber -NoTypeInformation -Path "$($FileName)CheckSomething.csv"
			
		}
		catch
		{
			Write-Log -Error "Could not generate the CheckSomething.csv file : Error $($_.Exception.Message) " -path $PathWriteLog -ErrorLogFileName $ErrorLogfileName
			
		}
		
		
		########################################
		#
		#
		#  Your Checks Here
		#
		########################################
		
		Write-Log -Message "Gathering Finished " -path $PathWriteLog -ErrorLogFileName $ErrorLogfileName -verbose
		
		#Region Zipping Files
		$PathForOutputZipFile = "$($PathForOutputFiles)\Zip"
		if (!(Test-Path "$($PathForOutputZipFile)"))
		{
			try
			{
				New-Item -ItemType directory -Path "$($PathForOutputZipFile)" | Out-Null
			}
			catch
			{
				Write-Log -Message "Could not create the $($PathForOutputZipFile) for zip files  " -path $PathWriteLog -ErrorLogFileName $ErrorLogfileName -verbose
				
			}
		}
		try
		{
			Remove-Item -Path "$($PathForOutputZipFile)\$($csvnames)_BestPractices.zip" -ErrorAction SilentlyContinue -Force
			
			Zip-Directory -DestinationFileName "$($PathForOutputZipFile)\$($csvnames)_BestPractices.zip" -SourceDirectory "$($PathForOutputFiles)"
			Write-Log -Message "Zip File at $($FileName)BestPractices.zip" -path $PathWriteLog -ErrorLogFileName $ErrorLogfileName -verbose
			
		}
		catch
		{
			if ($_.exception -notlike "*because it is being used by another process*")
			{
				Write-Log -Message "Could not zip the files. Please  do it manually.  " -path $PathWriteLog -ErrorLogFileName $ErrorLogfileName -verbose
			}
			else
			{
				Write-Log -Message "Zip File at $($FileName)BestPractices.zip" -path $PathWriteLog -ErrorLogFileName $ErrorLogfileName -verbose
				
			}
			
		}
		
		#EndRegion Zipping Files
		
		
		
	}
	else
	{
		Write-Log -Error "Could not create the path to export the data : " -path $PathWriteLog -ErrorLogFileName $ErrorLogfileName
	}
	
}

=======
﻿

Set-StrictMode -Version 2.0
try
{
	Add-Type -AssemblyName System.IO.Compression.FileSystem -ErrorAction Stop
}
catch
{
	Write-Warning "Could not add the zip .net type. Please zip the files manually"
}

#Region Functions

function Zip-Directory
{
	[CmdletBinding()]
	Param (
		[Parameter(Mandatory = $True)]
		[string]$DestinationFileName,
		[Parameter(Mandatory = $True)]
		[string]$SourceDirectory,
		[Parameter(Mandatory = $False)]
		[string]$CompressionLevel = "Optimal",
		[Parameter(Mandatory = $False)]
		[switch]$IncludeParentDir
	)
	$CompressionLevel = [System.IO.Compression.CompressionLevel]::$CompressionLevel
	[System.IO.Compression.ZipFile]::CreateFromDirectory($SourceDirectory, $DestinationFileName, $CompressionLevel, $IncludeParentDir)
}

function Invoke-Sqlcmd2
{
	
	[CmdletBinding(DefaultParameterSetName = 'Query')]
	[OutputType([System.Management.Automation.PSCustomObject], [System.Data.DataRow], [System.Data.DataTable], [System.Data.DataTableCollection], [System.Data.DataSet])]
	param (
		[Parameter(Position = 0,
				   Mandatory = $true,
				   ValueFromPipeline = $true,
				   ValueFromPipelineByPropertyName = $true,
				   ValueFromRemainingArguments = $false,
				   HelpMessage = 'SQL Server Instance required...')]
		[Alias('Instance', 'Instances', 'ComputerName', 'Server', 'Servers')]
		[ValidateNotNullOrEmpty()]
		[string[]]$ServerInstance,
		[Parameter(Position = 1,
				   Mandatory = $false,
				   ValueFromPipelineByPropertyName = $true,
				   ValueFromRemainingArguments = $false)]
		[string]$Database,
		[Parameter(Position = 2,
				   Mandatory = $true,
				   ValueFromPipelineByPropertyName = $true,
				   ValueFromRemainingArguments = $false,
				   ParameterSetName = 'Query')]
		[string]$Query,
		[Parameter(Position = 2,
				   Mandatory = $true,
				   ValueFromPipelineByPropertyName = $true,
				   ValueFromRemainingArguments = $false,
				   ParameterSetName = "File")]
		[ValidateScript({ Test-Path $_ })]
		[string]$InputFile,
		[Parameter(Position = 3,
				   Mandatory = $false,
				   ValueFromPipelineByPropertyName = $true,
				   ValueFromRemainingArguments = $false,
				   ParameterSetName = "Query")]
		[Parameter(Position = 3,
				   Mandatory = $false,
				   ValueFromPipelineByPropertyName = $true,
				   ValueFromRemainingArguments = $false,
				   ParameterSetName = "File")]
		[System.Management.Automation.PSCredential]$Credential,
		[Parameter(Position = 4,
				   Mandatory = $false,
				   ValueFromPipelineByPropertyName = $true,
				   ValueFromRemainingArguments = $false)]
		[Int32]$QueryTimeout = 600,
		[Parameter(Position = 5,
				   Mandatory = $false,
				   ValueFromPipelineByPropertyName = $true,
				   ValueFromRemainingArguments = $false)]
		[Int32]$ConnectionTimeout = 15,
		[Parameter(Position = 6,
				   Mandatory = $false,
				   ValueFromPipelineByPropertyName = $true,
				   ValueFromRemainingArguments = $false)]
		[ValidateSet("DataSet", "DataTable", "DataRow", "PSObject", "SingleValue")]
		[string]$As = "DataRow",
		[Parameter(Position = 7,
				   Mandatory = $false,
				   ValueFromPipelineByPropertyName = $true,
				   ValueFromRemainingArguments = $false)]
		[System.Collections.IDictionary]$SqlParameters,
		[Parameter(Position = 8,
				   Mandatory = $false)]
		[switch]$AppendServerInstance
	)
	
	Begin
	{
		if ($InputFile)
		{
			$filePath = $(Resolve-Path $InputFile).path
			$Query = [System.IO.File]::ReadAllText("$filePath")
		}
		
		Write-Verbose "Running Invoke-Sqlcmd2 with ParameterSet '$($PSCmdlet.ParameterSetName)'.  Performing query '$Query'"
		
		If ($As -eq "PSObject")
		{
			#This code scrubs DBNulls.  Props to Dave Wyatt
			$cSharp = @'
                using System;
                using System.Data;
                using System.Management.Automation;

                public class DBNullScrubber
                {
                    public static PSObject DataRowToPSObject(DataRow row)
                    {
                        PSObject psObject = new PSObject();

                        if (row != null && (row.RowState & DataRowState.Detached) != DataRowState.Detached)
                        {
                            foreach (DataColumn column in row.Table.Columns)
                            {
                                Object value = null;
                                if (!row.IsNull(column))
                                {
                                    value = row[column];
                                }

                                psObject.Properties.Add(new PSNoteProperty(column.ColumnName, value));
                            }
                        }

                        return psObject;
                    }
                }
'@
			
			Try
			{
				Add-Type -TypeDefinition $cSharp -ReferencedAssemblies 'System.Data', 'System.Xml' -ErrorAction stop
			}
			Catch
			{
				If (-not $_.ToString() -like "*The type name 'DBNullScrubber' already exists*")
				{
					Write-Warning "Could not load DBNullScrubber.  Defaulting to DataRow output: $_"
					$As = "Datarow"
				}
			}
		}
		
	}
	Process
	{
		foreach ($SQLInstance in $ServerInstance)
		{
			Write-Verbose "Querying ServerInstance '$SQLInstance'"
			
			if ($Credential)
			{
				$ConnectionString = "Server={0};Database={1};User ID={2};Password={3};Trusted_Connection=False;Connect Timeout={4}" -f $SQLInstance, $Database, $Credential.UserName, $Credential.GetNetworkCredential().Password, $ConnectionTimeout
			}
			else
			{
				$ConnectionString = "Server={0};Database={1};Integrated Security=True;Connect Timeout={2}" -f $SQLInstance, $Database, $ConnectionTimeout
			}
			
			$conn = New-Object System.Data.SqlClient.SQLConnection
			$conn.ConnectionString = $ConnectionString
			Write-Debug "ConnectionString $ConnectionString"
			
			#Following EventHandler is used for PRINT and RAISERROR T-SQL statements. Executed when -Verbose parameter specified by caller 
			if ($PSBoundParameters.ContainsKey('Verbose'))
			{
				$conn.FireInfoMessageEventOnUserErrors = $true
				$handler = [System.Data.SqlClient.SqlInfoMessageEventHandler] { Write-Verbose "$($_)" }
				$conn.add_InfoMessage($handler)
			}
			
			Try
			{
				$conn.Open()
			}
			Catch
			{
				Write-Error $_
				continue
			}
			
			$cmd = New-Object system.Data.SqlClient.SqlCommand($Query, $conn)
			$cmd.CommandTimeout = $QueryTimeout
			
			if ($SqlParameters -ne $null)
			{
				$SqlParameters.GetEnumerator() |
				ForEach-Object {
					If ($_.Value -ne $null)
					{ $cmd.Parameters.AddWithValue($_.Key, $_.Value) }
					Else
					{ $cmd.Parameters.AddWithValue($_.Key, [DBNull]::Value) }
				} > $null
			}
			
			$ds = New-Object system.Data.DataSet
			$da = New-Object system.Data.SqlClient.SqlDataAdapter($cmd)
			
			[void]$da.fill($ds)
			$conn.Close()
			
			if ($AppendServerInstance)
			{
				#Basics from Chad Miller
				$Column = new-object Data.DataColumn
				$Column.ColumnName = "ServerInstance"
				$ds.Tables[0].Columns.Add($Column)
				Foreach ($row in $ds.Tables[0])
				{
					$row.ServerInstance = $SQLInstance
				}
			}
			
			switch ($As)
			{
				'DataSet'
				{
					$ds
				}
				'DataTable'
				{
					$ds.Tables
				}
				'DataRow'
				{
					$ds.Tables[0]
				}
				'PSObject'
				{
					#Scrub DBNulls - Provides convenient results you can use comparisons with
					#Introduces overhead (e.g. ~2000 rows w/ ~80 columns went from .15 Seconds to .65 Seconds - depending on your data could be much more!)
					foreach ($row in $ds.Tables[0].Rows)
					{
						[DBNullScrubber]::DataRowToPSObject($row)
					}
				}
				'SingleValue'
				{
					$ds.Tables[0] | Select-Object -ExpandProperty $ds.Tables[0].Columns[0].ColumnName
				}
			}
		}
	}
} #Invoke-Sqlcmd2


Function Remove-Comma
{
	
	param ([parameter(position = 0, Mandatory = $true)]
		[string]$text)
	if ($text.substring(0, 1) -eq ",")
	{
		$text = $text.substring(1, $text.length - 1)
	}
	if ($text.substring($text.length - 1, 1) -eq ",")
	{
		$text = $text.substring(0, $text.length - 1)
	}
	
	Write-Output $text
	
}

#Region from SQLPSX
function Get-SqlServer
{
	param (
		[Parameter(Position = 0, Mandatory = $true)]
		[string]$sqlserver,
		[Parameter(Position = 1, Mandatory = $false)]
		[string]$username,
		[Parameter(Position = 2, Mandatory = $false)]
		[string]$password,
		[Parameter(Position = 3, Mandatory = $false)]
		[string]$StatementTimeout = 0
	)
	#When $sqlserver passed in from the SMO Name property, brackets
	#are automatically inserted which then need to be removed
	$sqlserver = $sqlserver -replace "\[|\]"
	
	Write-Verbose "Get-SqlServer $sqlserver"
	
	if ($Username -and $Password)
	{ $con = new-object ("Microsoft.SqlServer.Management.Common.ServerConnection") $sqlserver, $username, $password }
	else
	{ $con = new-object ("Microsoft.SqlServer.Management.Common.ServerConnection") $sqlserver }
	
	$con.Connect()
	$server = new-object ("Microsoft.SqlServer.Management.Smo.Server") $con
	#Some operations might take longer than the default timeout of 600 seconnds (10 minutes). Set new default to unlimited
	$server.ConnectionContext.StatementTimeout = $StatementTimeout
	$server.SetDefaultInitFields([Microsoft.SqlServer.Management.SMO.StoredProcedure], "IsSystemObject")
	$server.SetDefaultInitFields([Microsoft.SqlServer.Management.SMO.Table], "IsSystemObject")
	$server.SetDefaultInitFields([Microsoft.SqlServer.Management.SMO.View], "IsSystemObject")
	$server.SetDefaultInitFields([Microsoft.SqlServer.Management.SMO.UserDefinedFunction], "IsSystemObject")
	#trap { "Check $SqlServer Name"; continue} $server.ConnectionContext.Connect() 
	Write-Output $server
	
} #Get-SqlServer

function Get-SqlConnection
{
	[cmdletbinding()]
	param (
		[Parameter(Position = 0, Mandatory = $true)]
		[string]$sqlserver,
		[Parameter(Position = 1, Mandatory = $false)]
		[string]$username,
		[Parameter(Position = 2, Mandatory = $false)]
		[string]$password
	)
	
	Write-Verbose "Get-SqlConnection $sqlserver"
	
	if ($Username -and $Password)
	{ $con = new-object ("Microsoft.SqlServer.Management.Common.ServerConnection") $sqlserver, $username, $password }
	else
	{ $con = new-object ("Microsoft.SqlServer.Management.Common.ServerConnection") $sqlserver }
	
	$con.Connect()
	
	Write-Output $con
	
} #Get-ServerConnection

#EndRegion from SQLPSX
Function Write-Log
{
	
	[CmdletBinding()]
	Param
	(
		[Parameter(Mandatory = $true, Position = 1)]
		[ValidateNotNullOrEmpty()]
		[String]$path,
		[Parameter(Mandatory = $true, Position = 2)]
		[ValidateNotNullOrEmpty()]
		[String]$Message,
		[Parameter(Mandatory = $true, Position = 3)]
		[String]$ErrorLogFileName,
		[Parameter(Mandatory = $false, Position = 4)]
		[ValidateNotNullOrEmpty()]
		[Switch]$Error,
		[Parameter(Mandatory = $false, Position = 5)]
		[ValidateNotNullOrEmpty()]
		[Switch]$TerminatedError
		
		
	)
	
	try
	{
		
		if (!(Test-Path $path))
		{
			New-Item -Path $path -ItemType Directory -ErrorAction stop | Out-Null
		}
		
		$Fullpath = "$($path)\$($ErrorLogFileName).log"
		
		if ($PSBoundParameters.ContainsKey('Verbose'))
		{
			$Message = "[verbose]$($TimeStamp) - $($Message)"
			Write-Verbose $Message
		}
		
		if ($PSBoundParameters.ContainsKey('Error'))
		{
			$Message = "[Error]$($TimeStamp) - $($Message)"
			Write-Warning  $Message
		}
		
		if ($PSBoundParameters.ContainsKey('TerminatedError'))
		{
			$Message = "[Terminated Error]$($TimeStamp) $($Message)"
			$Message | out-file -FilePath $Fullpath -Append
			Throw "$($Message)"
			
		}
		$Message | out-file -FilePath $Fullpath -Append
	}
	catch
	{
		Throw "Error processing the log file. Script terminated $($_.Exception.Message)"
	}
	
	
}
`

Function Get-SQLWmiInfo
{
	
	param (
		[Parameter(Position = 0, Mandatory = $true)]
		[string]$MachineName
	)
	
	[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.SqlWmiManagement") | out-null
	$SQLWmi = New-Object ('Microsoft.SqlServer.Management.Smo.Wmi.ManagedComputer') $MachineName
	Write-output $SQLWmi
}

#EndRegion Functions

#Region Assembly

if ([Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.SMO") -eq $null -or ([System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.ConnectionInfo") -eq $null))
{
	Throw "SMO not avaliable"
}

#EndRegion Assembly

#Region Variables


$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Definition
$PSScriptRoot = $scriptRoot

$ArrayVLF = @()
#parameter
$PathForOutputFiles = "$($scriptRoot)\output"


$FileName = $null
$ErrorActionPreference = "Stop"
$VerbosePreference = "Continue"

$Global:TimeStamp = Get-Date -Format "MM-dd-yyyy hh:mm:ss"

$PathWriteLog = "$($scriptRoot)\Log"
$ErrorLogfileName = "LOG_General_$(Get-Date -Format 'yyyyMMdd_hhmmss').log"

try
{
	if (!(Test-Path $PathWriteLog))
	{
		New-Item -Path $PathWriteLog -ItemType Directory -ErrorAction stop | Out-Null
	}
}
catch
{
	Write-Error    "Could not create the path $($PathWriteLog). Aborting script.."
	Throw
}


if (-not ((New-Object Security.Principal.WindowsPrincipal ([Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)))
{
	Write-Log -Message "You must run Windows PowerShell as Administrator - Elevated Mode" -path $PathWriteLog -ErrorLogFileName $ErrorLogfileName -verbose
	Throw
}


if (!(Test-Path "$PSScriptRoot\InstanceNames.txt"))
{
	"YourInstanceName1", "Server\YourInstanceName2" |
	Out-File "$PSScriptRoot\InstanceNames.txt"
	Write-Log "Please fill the file $PSScriptRoot\InstanceNames.txt with the name of the SQL Server Instances" -path $PathWriteLog -ErrorLogFileName $ErrorLogfileName -verbose
	Return
	
}


try
{
	$instancesNames = Get-Content "$PSScriptRoot\InstanceNames.txt" -ErrorAction 'Stop'
}
catch
{
	"YourInstanceName1", "Server\YourInstanceName2" |
	Out-File "$PSScriptRoot\InstanceNames.txt"
	Write-Log  "Please fill the file $PSScriptRoot\InstanceNames.txt with the name of the SQL Server Instances" -path $PathWriteLog -ErrorLogFileName $ErrorLogfileName -verbose
	Return
}

if ($instancesNames -contains "YourInstanceName1" -or $instancesNames -contains "Server\YourInstanceName2")
{
	Write-log   "Please fill the file $PSScriptRoot\InstanceNames.txt with the name of the SQL Server Instances" -path $PathWriteLog -ErrorLogFileName $ErrorLogfileName -verbose
	Return
}

Write-Log -Message "Checking for Connection in the instances and if current account is SA" -path $PathWriteLog -ErrorLogFileName $ErrorLogfileName -verbose
$TestedInstanceName = @()
try
{
	$instancesNames |
	ForEach-Object {
		try
		{
			$con = Get-SqlConnection -sqlserver $_ -verbose:$false -ea stop
			if ($con)
			{
				if ($con.FixedServerRoles -like "*SysAdmin*")
				{
					$TestedInstanceName += $_
				}
				else
				{
					Write-log -Message "User is not SYSADM on the instance $($_). This Instace will be skipped." -path $PathWriteLog -ErrorLogFileName $ErrorLogfileName -verbose
				}
			}
			else
			{
				Write-log -Message "Could not connect to the instance $($_)" -path $PathWriteLog -ErrorLogFileName $ErrorLogfileName -verbose
			}
		}
		catch
		{
			Write-Log -Message "Could not connect to the instance $($_)" -path $PathWriteLog -ErrorLogFileName $ErrorLogfileName -verbose
		}
	}
}
catch
{
	Write-Log -Message "An error occcurred. Please run the script again" -path $PathWriteLog -ErrorLogFileName $ErrorLogfileName -Error -TerminatedError
}



#EndRegion Variables



if (!(Test-Path $pathForOutputFiles))
{
	try
	{
		New-Item -Path $pathForOutputFiles -ItemType Directory -ErrorAction stop | Out-Null
	}
	catch
	{
		Write-Warning  "Could not create the path $($pathForOutputFiles). Aborting script.."
		Throw
	}
	
}

$InputFile = $null


$TestedInstanceName |
ForEach-Object {
	
	$PathForOutputFiles = "$($scriptRoot)\output"
	$SQLWmiInstanceName = ""
	$ArrayServerProperties = @()
	$ArrayDatabaseProperties = @()
	$PsObjectDatabaseProperties = $null
	$ArrayDatabaseFiles = @()
	$ArraySQLAgent = @()
	$ArrayOtherChecks = @()
	
	
	$splitedInstanceName = $_ -split "\\"
	$MachineName = $splitedInstanceName[0]
	$InstanceName = $splitedInstanceName[1]
	
	$createdpath = $true
	
	if ($InstanceName)
	{
		if (!(Test-Path "$($PathForOutputFiles)\$($MachineName)_$($InstanceName)"))
		{
			try
			{
				New-Item -ItemType directory -Path "$($PathForOutputFiles)\$($MachineName)_$($InstanceName)" | Out-Null
			}
			catch
			{
				Write-log  "Could not create the $($PathForOutputFiles)\$($MachineName)_$($InstanceName) path - Skipping the instance check" -path $PathWriteLog -ErrorLogFileName $ErrorLogfileName -verbose
				$createdpath = $false
				
			}
			
		}
		$PathForOutputFiles = "$($PathForOutputFiles)\$($MachineName)_$($InstanceName)"
		$FileName = "$($PathForOutputFiles)\$($MachineName)_$($InstanceName)_"
		$FullInstanceName = "$($MachineName)\$InstanceName"
		$SQLWmiInstanceName = $InstanceName
		$ErrorLogfileName = "$($MachineName)_$($InstanceName)_BestPractices_$(Get-Date -Format 'yyyyMMdd_hhmmss')"
		$CSVNames = "$($MachineName)_$($InstanceName)"
		
		
	}
	else
	{
		
		if (!(Test-Path "$($PathForOutputFiles)\$($MachineName)"))
		{
			try
			{
				New-Item -ItemType directory -Path "$($PathForOutputFiles)\$($MachineName)" | Out-Null
			}
			catch
			{
				Write-Log "Could not create the $($PathForOutputFiles)\$($MachineName) path - Skipping the instance check" -path $PathWriteLog -ErrorLogFileName $ErrorLogfileName -verbose
				$createdpath = $false
				
			}
		}
		
		$PathForOutputFiles = "$($PathForOutputFiles)\$($MachineName)"
		
		$FileName = "$($PathForOutputFiles)\$($MachineName)_"
		$FullInstanceName = $MachineName
		$SQLWmiInstanceName = 'MSSQLSERVER'
		$ErrorLogfileName = "$($MachineName)_BestPractices_$(Get-Date -Format 'yyyyMMdd_hhmmss')"
		$CSVNames = "$($MachineName)"
	}
	If ($createdpath)
	{
		Write-log -Message "Starting gathering" -path $PathWriteLog -ErrorLogFileName $ErrorLogfileName -verbose
		
		
		Try
		{
			Get-ChildItem -Path "$($PathForOutputFiles)\$($CSVNames)*.csv" |
			Remove-Item -Force
		}
		catch
		{
			Write-Log -Error "Could not remove the old csv files from Instance $($FullInstanceName) . : Error $($_.Exception.Message) " -path $PathWriteLog -ErrorLogFileName $ErrorLogfileName -TerminatedError
		}
		
		
		try
		{
			
			$Server = Get-SqlServer -sqlserver $FullInstanceName
			Write-Log -Message "Connection Successfully instance - $($FullInstanceName)" -path $PathWriteLog -ErrorLogFileName $ErrorLogfileName -verbose
		}
		catch
		{
			Write-Log -Error "Error connecting on instance  $($FullInstanceName) : Error $($_.Exception.Message)" -path $PathWriteLog -ErrorLogFileName $ErrorLogfileName
		}
		
		Write-Log -Message "Trying to connect on WMI" -path $PathWriteLog -ErrorLogFileName $ErrorLogfileName -verbose
		
		#Connecting on WMI
		Try
		{
			$SQLWmi = Get-SQLWmiInfo -MachineName $MachineName
			Write-Log -Message "Connection Successfully on WMI" -path $PathWriteLog -ErrorLogFileName $ErrorLogfileName -verbose
			
		}
		catch
		{
			Write-Log -Error "Cound not connect on  WMI Properties : Error $($_.Exception.Message)" -path $PathWriteLog -ErrorLogFileName $ErrorLogfileName
			
		}
		
		Write-Log -Message "Trying to connect to instance - $($FullInstanceName) " -path $PathWriteLog -ErrorLogFileName $ErrorLogfileName -verbose
		
		
		#Removing the last csv if it exists
		Write-Log -Message "Removing the olds csv files..." -path $PathWriteLog -ErrorLogFileName $ErrorLogfileName
		
		
		#Region Instance Name
		New-Object psobject -property @{ 'InstanceName' = $FullInstanceName } |
		Select InstanceName |
		Export-Csv -force -NoClobber -NoTypeInformation -Path "$($FileName)InstanceName.csv"
		
		
		#EndRegion Instance name 
		
		#Region Check 1 SQL Server version and edition: report if earlier than SQL 2008
		
		Write-Log -Message "Checking the SQL Server Edition...." -path $PathWriteLog -ErrorLogFileName $ErrorLogfileName
		
		$FQDN = ([System.Net.NetworkInformation.IPGlobalProperties]::GetIPGlobalProperties() | Select HostName, DomainName)
		$SQLVersionHigherThan10 = $true
		
		
		$SQL = " select serverproperty('productversion') version, serverproperty('productlevel') level , serverproperty('edition') edition"
		$ServerSQL = Invoke-Sqlcmd2 -ServerInstance $FullInstanceName -Query $SQL
		
		if ($ServerSQL.Version.Substring(0, 2) -like "*9*" -or $ServerSQL.Version.Substring(0, 2) -like "*8*")
		{
			$SQLVersionHigherThan10 = $false
			if ($ServerSQL.Version.Substring(0, 2) -like "*9*")
			{
				$SQLVersion = 9
			}
			else
			{
				$SQLVersion = 8
			}
			try
			{
				New-Object PSobject -Property @{
					'Machine Name' = $MachineName
					'Net Bios Name' = "$($FQDN.HostName).$($FQDN.HostName)"
					'Product Version' = "$($ServerSQL.version);Yellow"
					'Product Level' = $ServerSQL.level
					'Product Edition' = $ServerSQL.edition
				} |
				Select-Object 	@{ N = "Machine Name"; E = { $_."Machine Name" } },
							  @{ N = "Net Bios Name"; E = { $_."Net Bios Name" } },
							  @{ N = "Product Version"; E = { $_."Product Version" } },
							  @{ N = "Product Level"; E = { $_."Product Level" } },
							  @{ N = "Product Edition"; E = { $_."Product Edition" } } |
				Export-Csv -force -NoClobber -NoTypeInformation -Path "$($FileName)SQLEdition.csv"
			}
			catch
			{
				Write-Log -Error "Could not generate the SQLEdition.csv file. : Error $($_.Exception.Message) " -path $PathWriteLog -ErrorLogFileName $ErrorLogfileName
			}
		}
		else
		{
			$SQLVersion = $Server.Version.Major
			Try
			{
				New-Object PSobject -Property @{
					'Machine Name' = $MachineName
					'Net Bios Name' = "$($FQDN.HostName).$($FQDN.HostName)"
					'Product Version' = if ([int]$Server.Version.Major -lt 10) { "$($Server.VersionString);Yellow" }
					else { $Server.VersionString }
					'Product Level' = $Server.productLevel
					'Product Edition' = $Server.edition
					'Is Clustered' = $Server.IsClustered
				} |
				Select-Object 	@{ N = "Machine Name"; E = { $_."Machine Name" } },
							  @{ N = "Net Bios Name"; E = { $_."Net Bios Name" } },
							  @{ N = "Product Version"; E = { $_."Product Version" } },
							  @{ N = "Product Level"; E = { $_."Product Level" } },
							  @{ N = "Product Edition"; E = { $_."Product Edition" } },
							  @{ N = "Is Clustered"; E = { $_."Is Clustered" } } |
				Export-Csv -force -NoClobber -NoTypeInformation -Path "$($FileName)SQLEdition.csv"
			}
			catch
			{
				Write-Log -Error "Could not generate the SQLEdition.csv file. : Error $($_.Exception.Message) " -path $PathWriteLog -ErrorLogFileName $ErrorLogfileName
			}
		}
		
		#EndRegion Check 1 SQL Server version and edition: report if earlier than SQL 2008
		
		
		#Region Check 2 Server Protocols and Port (WMI) - TCPIP
		
		Write-Log -Message "Checking the SQL Server Protocols TCPIP...." -path $PathWriteLog -ErrorLogFileName $ErrorLogfileName
		
		$SQLWmiProtocols = $SQLWmi.ServerInstances["$SQLWmiInstanceName"]
		If ($SQLWmiProtocols)
		{
			
			$TCPIP = @{
				'Protocol Name' = 'TCP'
				'Is Enabled' = $SQLWmiProtocols.serverprotocols['Tcp'].IsEnabled
				'Has Multiple IP Addresses' = $SQLWmiProtocols.serverprotocols['Tcp'].HasMultiIPAddresses
				'Port SQL Server listening' = $SQLWmiProtocols.serverprotocols['Tcp'].IPAddresses['IPAll'].IPAddressProperties[1].Value
			}
			New-Object PSOBJECT -Property $TCPIP |
			Select 	@{ N = 'Protocol Name'; E = { $_."Protocol Name" } },
				   @{ N = 'Is Enabled'; E = { $_."Is Enabled" } },
				   @{ N = 'Has Multiple IP Addresses'; E = { $_."Has Multiple IP Addresses" } },
				   @{ N = 'Port SQL Server listening'; E = { $_."Port SQL Server listening" } } |
			Export-Csv -force -NoClobber -NoTypeInformation -Path "$($FileName)TCPIP.csv"
		}
		else
		{
			
			Write-Log -Error "Could not generate the Server Protocols csv files. " -path $PathWriteLog -ErrorLogFileName $ErrorLogfileName
		}
		
		#EndRegion Check 2 Server Protocols and Port (WMI) - TCPIP	
		
		
		#Region Output xp_msver
		try
		{
			Invoke-Sqlcmd2 -ServerInstance $FullInstanceName -Database master -Query "exec xp_msver" |
			Select 	@{ N = 'Property Name'; E = { $_.Name } },
				   @{ N = 'Value'; E = { $_.Character_value } } |
			Export-Csv -force -NoClobber -NoTypeInformation -Path "$($FileName)xpmsver.csv"
		}
		catch
		{
			Write-Log -Error "Could not generate the xpmsver.csv file. : Error $($_.Exception.Message) " -path $PathWriteLog -ErrorLogFileName $ErrorLogfileName
		}
		
		#EndRegion Output xp_msver
		
		#Region SQL Server Configuration 
		
		Write-Log -Message "Checking the SQL Server Configuration...." -path $PathWriteLog -ErrorLogFileName $ErrorLogfileName -verbose
		Try
		{
			Invoke-Sqlcmd2 -ServerInstance $FullInstanceName -Database master -Query "sp_configure" |
			Select @{ N = 'Configuration Name'; E = { $_.name } },
				   @{ N = 'Configuration Value'; E = { $_.config_value } },
				   @{ N = 'Run Value'; E = { $_.run_value } } |
			Export-Csv -force -NoClobber -NoTypeInformation -Path "$($FileName)ServerConfiguration.csv"
			
		}
		catch
		{
			
		}
		#EndRegion SQL Server Configuration 
		
		#Region SQL Server service account member of local Administrators
		
		Try
		{
			if (!($InstanceName))
			{
				$ServiceSearch = "MSSQLSERVER"
			}
			else
			{
				$ServiceSearch = "MSSQL`$$($instancename)"
			}
			$SQLWMIService = $SQLWmi.Services[$ServiceSearch]
			if ($SQLWMIService)
			{
				$isAdministrator = (&{ net localgroup administrators } |
				Where { $_ -eq ($SQLWMIService.ServiceAccount -split "\\")[1] })
				Write-Log -Message "Checking SQL Service Account ...." -path $PathWriteLog -ErrorLogFileName $ErrorLogfileName -verbose
				New-Object psobject -Property @{
					'Service Account' = $SQLWMIService.ServiceAccount
					'Start Mode' = $SQLWMIService.StartMode
					'Is Local Administrator' = if ($isAdministrator) { "True;Red" }
					else { "False" }
					'Startup Parameters' = $SQLWMIService.StartupParameters -replace ";", "|"
				} |
				Select 	@{ N = 'Service Account'; E = { $_."Service Account" } },
					   @{ N = 'Start Mode'; E = { $_."Start Mode" } },
					   @{ N = 'Is Local Administrator'; E = { $_."Is Local Administrator" } },
					   @{ N = 'Startup Parameters'; E = { $_."Startup Parameters" } } |
				Export-Csv -force -NoClobber -NoTypeInformation -Path "$($FileName)ServiceAccount.csv"
			}
		}
		catch
		{
			Write-Log -Error "Could not generate the Service Account.csv file : Error $($_.Exception.Message) " -path $PathWriteLog -ErrorLogFileName $ErrorLogfileName
		}
		#EndRegion SQL Server service account member of local Administrators
		
		#Region Page File
		Try
		{
			Write-Log -Message "Checking Page File Settings ...." -path $PathWriteLog -ErrorLogFileName $ErrorLogfileName -verbose
			
			$issue = ""
			$PageFileSize = (Get-WmiObject -ComputerName $MachineName -Class Win32_PageFileUsage).AllocatedBaseSize/1MB
			$PageFileAutomatic = (Get-WmiObject -ComputerName $MachineName -Class Win32_computersystem | select  @{ N = 'AutomaticManagedPagefile'; E = { $_."AutomaticManagedPagefile" } }).AutomaticManagedPagefile
			New-Object psobject -Property @{
				"Managed Page File" = if ($PageFileAutomatic) { "$($PageFileAutomatic);Red"; $issue += "Pagefile setting should be manually set and with a maximum value of 16 GB " }
				else { $PageFileAutomatic }
				"Size (MB)" = if ($PageFileSize -gt 16) { "$($PageFileSize);Red"; $issue += "Pagefile setting should be set with a maximum value of 16 GB" }
				else { $PageFileSize }
			} |
			Select 	@{ N = 'Managed Page File'; E = { $_."Managed Page File" } },
				   @{ N = 'Size (MB)'; E = { $_."Size (MB)" } },
				   @{
				N = 'Issue'; E = {
					if ($issue) { "$($issue);RED" }
					else { "No Issues" }
				}
			} |
			Export-Csv -force -NoClobber -NoTypeInformation -Path "$($FileName)PageFile.csv"
			
			
		}
		catch
		{
			Write-Log -Error "Could not generate the Page File.csv file : Error $($_.Exception.Message) " -path $PathWriteLog -ErrorLogFileName $ErrorLogfileName
		}
		#EndRegion Page File
		
		
		#Check Something
		#Just to explain the color alghoritm
		try
		{
			Write-Log -Message "Checking Something ...." -path $PathWriteLog -ErrorLogFileName $ErrorLogfileName -verbose
			
			New-Object psobject -property @{
				"Checking Something Red" = 'Something Red - not good;RED'
				"Checking Something Yellow" = 'Something Yellow - not too bad;Yellow'
				"Checking Something Green" = 'Something Green - good;Green'
			} |
			Export-Csv -force -NoClobber -NoTypeInformation -Path "$($FileName)CheckSomething.csv"
			
		}
		catch
		{
			Write-Log -Error "Could not generate the CheckSomething.csv file : Error $($_.Exception.Message) " -path $PathWriteLog -ErrorLogFileName $ErrorLogfileName
			
		}
		
		
		########################################
		#
		#
		#  Your Checks Here
		#
		########################################
		
		Write-Log -Message "Gathering Finished " -path $PathWriteLog -ErrorLogFileName $ErrorLogfileName -verbose
		
		#Region Zipping Files
		$PathForOutputZipFile = "$($PathForOutputFiles)\Zip"
		if (!(Test-Path "$($PathForOutputZipFile)"))
		{
			try
			{
				New-Item -ItemType directory -Path "$($PathForOutputZipFile)" | Out-Null
			}
			catch
			{
				Write-Log -Message "Could not create the $($PathForOutputZipFile) for zip files  " -path $PathWriteLog -ErrorLogFileName $ErrorLogfileName -verbose
				
			}
		}
		try
		{
			Remove-Item -Path "$($PathForOutputZipFile)\$($csvnames)_BestPractices.zip" -ErrorAction SilentlyContinue -Force
			
			Zip-Directory -DestinationFileName "$($PathForOutputZipFile)\$($csvnames)_BestPractices.zip" -SourceDirectory "$($PathForOutputFiles)"
			Write-Log -Message "Zip File at $($FileName)BestPractices.zip" -path $PathWriteLog -ErrorLogFileName $ErrorLogfileName -verbose
			
		}
		catch
		{
			if ($_.exception -notlike "*because it is being used by another process*")
			{
				Write-Log -Message "Could not zip the files. Please  do it manually.  " -path $PathWriteLog -ErrorLogFileName $ErrorLogfileName -verbose
			}
			else
			{
				Write-Log -Message "Zip File at $($FileName)BestPractices.zip" -path $PathWriteLog -ErrorLogFileName $ErrorLogfileName -verbose
				
			}
			
		}
		
		#EndRegion Zipping Files
		
		
		
	}
	else
	{
		Write-Log -Error "Could not create the path to export the data : " -path $PathWriteLog -ErrorLogFileName $ErrorLogfileName
	}
	
}

>>>>>>> d4022b1c698892c56d61a9072b03678cdc0fa4fe
