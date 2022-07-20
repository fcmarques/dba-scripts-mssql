################################################################################################################################
#
# Script Name : ScriptAllobjectsOnAllDatabasesToFiles2.ps1
# Version     : 1.0
# Author      : Fabio Marques
# Purpose     :
#			  This script generates one SQL script per database object including Stored Procedures,Tables,Views, 
#			  User Defined Functions and User Defined Table Types. Useful for versionining a databsae in a CVS.
#
# Usage       : 
#			  Set variables at the top of the script then execute.
#
# Note        :
#			  Only tested on SQL Server 2008r2
#                 
################################################################################################################################
$date_ 				= (date -f yyyyMMdd)
$ServerName 		= "RIACHU_FIN" #If you have a named instance, you should put the name.
$path 				= "C:\Temp\SMO\"

[System.Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.SMO')
$serverInstance = New-Object ("Microsoft.SqlServer.Management.Smo.Server") $ServerName
$scripter 		= New-Object ("Microsoft.SqlServer.Management.SMO.Scripter") $ServerName
$tbl 			= New-Object ("Microsoft.SqlServer.Management.SMO.Table")

$dbs=$serverInstance.Databases | Where-object { -not $_.IsSystemObject } #["SistemasFinanceiros"] #you can change this variable for a query for filter yours databases.
foreach ($db in $dbs)
{
	$dbname 			= "$db".replace("[","").replace("]","")
	$output_path 		= $path+"$date_"+"\"+$dbname
	$table_path 		= "$output_path\Table\"
	$storedProcs_path 	= "$output_path\StoredProcedure\"
	$triggers_path 		= "$output_path\Triggers\"
	$views_path 		= "$output_path\View\"
	$udfs_path 			= "$output_path\UserDefinedFunction\"
	$textCatalog_path 	= "$output_path\FullTextCatalog\"
	$udtts_path 		= "$output_path\UserDefinedTableTypes\"
	$tbl		 		= $db.tables | Where-object { -not $_.IsSystemObject } 
	$storedProcs		= $db.StoredProcedures | Where-object { -not $_.IsSystemObject } 
	$triggers			= $db.Triggers + ($tbl | % { $_.Triggers })
	$views 		 		= $db.Views  | Where-object { -not $_.IsSystemObject } 
	$udfs		 		= $db.UserDefinedFunctions | Where-object { -not $_.IsSystemObject } 
	$catlog		 		= $db.FullTextCatalogs
	$udtts		 		= $db.UserDefinedTableTypes
		
	# Set scripter options to ensure only data is scripted
	$scripter.Options.ScriptSchema 							= $true;
	$scripter.Options.ScriptData 							= $false;
	$scripter.Options.NoCommandTerminator 					= $false; #Exclude GOs after every line
	$scripter.Options.ToFileOnly 							= $true
	$scripter.Options.AllowSystemObjects 					= $false
	$scripter.Options.Permissions 							= $true
	$scripter.Options.DriAllConstraints 					= $true
	$scripter.Options.SchemaQualify 						= $true
	$scripter.Options.AnsiFile 								= $true
	$scripter.Options.SchemaQualifyForeignKeysReferences 	= $true
	$scripter.Options.Indexes 								= $true
	$scripter.Options.DriIndexes 							= $true
	$scripter.Options.DriClustered 							= $true
	$scripter.Options.DriNonClustered 						= $true
	$scripter.Options.NonClusteredIndexes 					= $true
	$scripter.Options.ClusteredIndexes 						= $true
	$scripter.Options.FullTextIndexes 						= $true
	$scripter.Options.EnforceScriptingOptions 				= $true

	function CopyObjectsToFiles($objects, $outDir) {
		
		if (-not (Test-Path $outDir)) {
			[System.IO.Directory]::CreateDirectory($outDir)
		}
		
		foreach ($o in $objects) { 
		
			if ($o -ne $null) {
				
				$schemaPrefix = ""
				
				if ($o.Schema -ne $null -and $o.Schema -ne "") {
					$schemaPrefix = $o.Schema + "."
				}
			
				$scripter.Options.FileName = $outDir + $schemaPrefix + $o.Name + ".sql"
				Write-Host "Writing " $scripter.Options.FileName
				$scripter.EnumScript($o)
			}
		}
	}

	# Output the scripts
	CopyObjectsToFiles $tbl $table_path
	CopyObjectsToFiles $storedProcs $storedProcs_path
	CopyObjectsToFiles $triggers $triggers_path
	CopyObjectsToFiles $views $views_path
	CopyObjectsToFiles $catlog $textCatalog_path
	CopyObjectsToFiles $udtts $udtts_path
	CopyObjectsToFiles $udfs $udfs_path

	Write-Host "Finished database at" (Get-Date)
}
Write-Host "Finished backup at" (Get-Date)