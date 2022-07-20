<<<<<<< HEAD
# add path for SQLPackage.exe
IF (-not ($env:Path).Contains( "C:\program files\microsoft sql server\160\DAC\bin\"))
{ $env:path = $env:path + ";C:\program files\microsoft sql server\160\DAC\bin\;" }

sqlpackage /a:extract /of:true /scs:"server=10.0.0.9;database=UOF_IN_MEMORY;User Id=fabio.marques;Password=y7NCN1F6g;" /tf:"c:\temp\db_source.dacpac";

sqlpackage.exe /a:deployreport /op:"c:\temp\report.xml" /of:True /sf:"c:\temp\db_source.dacpac" /tcs:"server=10.10.0.24; database=SportsBook;User Id=DBAdmin;Password=jr0dkYk2e0HL3SXD2Bmy;" 
sqlpackage.exe /a:script /op:"c:\temp\change.sql" /of:True /sf:"C:\temp\db_source.dacpac" /tcs:"server=10.10.0.24; database=SportsBook;User Id=DBAdmin;Password=jr0dkYk2e0HL3SXD2Bmy;" /p:BlockOnPossibleDataLoss=false

[xml]$x = gc -Path "c:\temp\report.xml";
$x.DeploymentReport.Operations.Operation |
=======
# add path for SQLPackage.exe
IF (-not ($env:Path).Contains( "C:\program files\microsoft sql server\160\DAC\bin\"))
{ $env:path = $env:path + ";C:\program files\microsoft sql server\160\DAC\bin\;" }

sqlpackage /a:extract /of:true /scs:"server=10.0.0.9;database=UOF_IN_MEMORY;User Id=fabio.marques;Password=y7NCN1F6g;" /tf:"c:\temp\db_source.dacpac";

sqlpackage.exe /a:deployreport /op:"c:\temp\report.xml" /of:True /sf:"c:\temp\db_source.dacpac" /tcs:"server=10.10.0.24; database=SportsBook;User Id=DBAdmin;Password=jr0dkYk2e0HL3SXD2Bmy;" 
sqlpackage.exe /a:script /op:"c:\temp\change.sql" /of:True /sf:"C:\temp\db_source.dacpac" /tcs:"server=10.10.0.24; database=SportsBook;User Id=DBAdmin;Password=jr0dkYk2e0HL3SXD2Bmy;" /p:BlockOnPossibleDataLoss=false

[xml]$x = gc -Path "c:\temp\report.xml";
$x.DeploymentReport.Operations.Operation |
>>>>>>> d4022b1c698892c56d61a9072b03678cdc0fa4fe
% -Begin {$a=@();} -process {$name = $_.name; $_.Item | %  {$r = New-Object PSObject -Property @{Operation=$name; Value = $_.Value; Type = $_.Type} ; $a += $r;} }  -End {$a}