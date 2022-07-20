$date_ = (date -f yyyyMMdd)
$ServerName = "RIACHU_FIN" #If you have a named instance, you should put the name. 
$path = "C:\Temp\SMO\"+"$date_"
 
[System.Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.SMO')
$serverInstance = New-Object ('Microsoft.SqlServer.Management.Smo.Server') $ServerName

$IncludeTypes = @("Tables","StoredProcedures","Views","UserDefinedFunctions", "Triggers") #object you want do backup. 
$ExcludeSchemas = @("sys","Information_Schema")

$so = new-object ('Microsoft.SqlServer.Management.Smo.ScriptingOptions')
$so.IncludeIfNotExists = 0
$so.SchemaQualify = 1
$so.AllowSystemObjects = 0
$so.ScriptDrops = 0 #Script Drop Objects
$so.ExtendedProperties= 1 # yes, we want these
$so.DRIAll= 1 # and all the constraints 
$so.Indexes= 1 # Yup, these would be nice
$so.Triggers= 1 # This should be included when scripting a database
$so.ScriptBatchTerminator = 1 # this only goes to the file
$so.IncludeHeaders = 1; # of course
$so.ToFileOnly = 1 #no need of string output as well

$dbs=$serverInstance.Databases["Sicc"] #you can change this variable for a query for filter yours databases.
foreach ($db in $dbs)
{
       $dbname = "$db".replace("[","").replace("]","")
       $dbpath = "$path"+ "\"+"$dbname" + "\"
    if ( !(Test-Path $dbpath))
           {$null=new-item -type directory -name "$dbname"-path "$path"}
 
       foreach ($Type in $IncludeTypes)
       {
              $objpath = "$dbpath" + "$Type" + "\"
         if ( !(Test-Path $objpath))
           {$null=new-item -type directory -name "$Type"-path "$dbpath"}
              foreach ($objs in $db.$Type)
              {
                     If ($ExcludeSchemas -notcontains $objs.Schema ) 
                      {
                           $ObjName = "$objs".replace("[","").replace("]","")                  
                           $OutFile = "$objpath" + "$ObjName" + ".sql"
						   Write-Host "Writing " + $objpath + $ObjName + ".sql"
                           $objs.Script($so)+"GO" | out-File $OutFile
                      }
              }
       }     
}