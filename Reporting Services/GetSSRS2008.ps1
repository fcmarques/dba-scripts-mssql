#OBTAIN CMD LINE INFO: "get-help .\GetSSRS.ps1" 
 
<# 
.SYNOPSIS 
    Update Passwords used within SQL Reporting Services 
.DESCRIPTION 
    Scans and updates Passwords in SSRS via the Web service for all: 
    -Reports 
    -Datasources 
    -Subscriptions 
 
    Limitations and Known Issues: 
    Only works for SSRS 2008/R2 at this time 
    Not tested with SSRS in SharePont Integration mode 
    Sometimes pauses at "Searching for <useraccount> for a few minutes - be patient 
    If run fails, next run receives error: "Transcription has already been started." -- Can ignore: no impact 
.EXAMPLE 
        (Run remote) 
    View: ssrs.ps1 -computer pqodtgpssrs01 -username domain\user 
    Update: ssrs.ps1 -computer pqodtgpssrs01 -username domain\user -password actualPassword 
        OR         (Run local) 
    View: ssrs.ps1 -username domain\user 
    Update: ssrs.ps1 -computer pqodtgpssrs01 -username domain\user 
#> 
 
## Input## 
Param([string]$computer=".",[parameter(mandatory=$true)][string]$username,[string]$password) 
 
##Performs a quick parameter check 
If ($computer -eq "."){ 
    write-host "No SSRS Server specified -- checking localhost" 
} 
 
##Checks for null password to determine if updates are to occur 
If ($password -eq ""){ 
    [system.Boolean]$UpdatePassword=$false 
    write-host "Performing Check -- Password will not be updated" 
} 
ELSE{ 
    [system.Boolean]$UpdatePassword=$true 
    write-host "Password specified, performing Update" 
} 
 
############# Functions ################## 
#function main([string]$computer,[string]$username,[string]$password,[string]$UpdatePassword){ 
function main{ 
    ## Default Variables ## 
    $i = new-object -TypeName System.Int32 
    $j = new-object -TypeName System.Int32 
    $Found = new-object -TypeName System.Boolean 
 
    $i=0    #initialize Counter 
    $j=0    #initialize Counter 
    $Found = $false    #initialize matching 
 
    $Application = @() 
    $SSRSURLString = @() 
    $foundURL = new-object -TypeName System.String -argumentList ("") 
 
    ################################################################ 
    # Starts log File 
 
    $dt = Get-Date -format "yyyyMMdd_hhmm" 
    $File ="SSRS_LOG_" + $dt + ".txt" 
    start-transcript -Path $File -Append #Starts logging 
    write-host "Server " -NoNewline; write-host $computer -ForegroundColor "Yellow" 
    write-host "Searching for $username" 
 
    ################################################################ 
    # Gets Web Service Instance/URL 
 
    ## Get instance name 
    $ssrsinstance = Get-WmiObject -ComputerName $computer -class __namespace -namespace "root\Microsoft\SqlServer\ReportServer" -ErrorAction SilentlyContinue 
 
    If ($ssrsinstance -eq $null){ 
        Write-Host "     ERROR: SSRS Not found" -ForegroundColor "Red" 
        stop-transcript    #Stops logging 
        (Get-Content $File) | Foreach-Object { $_ -replace '', '' } | Set-Content $File    #Fix encoding of file for Notepad 
        Exit -1 
    } 
 
    foreach ($result in $ssrsinstance){ 
        write-host "SSRS Instance: " $result.name 
        $ssrsURL = Get-WmiObject -ComputerName $computer -class MSReportServer_ConfigurationSetting -namespace "root\Microsoft\SqlServer\ReportServer\$($result.name)\v10\admin" 
 
        $urls = $ssrsURL.ListReservedUrls() | Where-Object {$_.Application -eq "ReportManager"} 
 
        ##List of ReportServerWebService and ReportManager 
        $Application = @($urls.Application) | select-string -pattern "Report" -simplematch 
 
 
        foreach ($item in $Application){ 
            $i++    #increments counter for each item found 
            #write-host "Application " $item 
            If ($item -match "WebService"){    #Finds the application that contains the Web Service reference 
                write-host " Application " $item 
                $Found = $true 
                #write-host "Found! " $i 
                break    #exits for loop so counter stops 
            } 
        } 
        #write-host "i " $i 
 
        $SSRSURLString = @($urls.urlString) | select-string -pattern "http" -simplematch 
 
 
        #Finds matching URL 
        If ($Found -eq $true){    #Checks to make sure that the web service was found before matching the URL 
            foreach ($item in $SSRSURLString){ 
                #write-host "URL " $item 
                $j++ 
                #If ($j -eq $i){ 
                #Check if URL doesn't contain + character. If not, then check to see if this is labeled as Web Service 
                If ($item -match "\+"){ 
                    #write-host "  Invalid URL" $foundURL                         
                } 
                ELSE{ 
                    #Check if listed as Web Service 
                    $foundURL = $item 
                    #$foundURL = $foundURL -replace("\+", $computer) 
                    #write-host "Replaced String: " $foundURL 
                    #Write-Host "Applications " $Application[$j] 
                    If ($Application[$j-1] -match "WebService"){ 
                        write-host "  URL" $foundURL 
                        break    #exits for loop so counter stops 
                    } 
                } 
                #write-host "j " $j " i " $i 
            } 
        } 
        #write-host "j " $j 
 
    ################################################################ 
    # Starts Web Service Call 
 
        #Gets SSRS Version 
        $SQL = Get-WmiObject -computer $computer -class MSReportServer_Instance -namespace "root\Microsoft\SqlServer\ReportServer\$($result.name)\v10" 
 
        Switch ($SQL.Version) 
        { 
            #SSRS 2008 version number starts with 10.0. 
            {$_ -match "10.0."}    { 
                        #$uri = "https://$($computer)/ReportServer/ReportService2005.asmx?WSDL" 
                        $uri = "$($foundURL)/ReportServer/ReportService2005.asmx?WSDL" 
                        #$uri = "$($foundURL)/ReportServer/ReportingService2005.asmx?WSDL" 
                        Write-Host "  SQL 2008 " $SQL.Version 
                        $SQLVersion = "2008" 
                        SQL2008($SQLVersion) 
                    } 
            #SSRS 2008R2 version number starts with 10.50. 
            {$_ -match "10.50."}    { 
                        #$uri = "https://$($computer)/ReportServer/ReportService2010.asmx?WSDL" 
                        $uri = "$($foundURL)/ReportServer/ReportService2010.asmx?WSDL" 
                        Write-Host "  SQL 2008 R2 " $SQL.Version 
                        $SQLVersion = "2008R2" 
                        SQL2008($SQLVersion) 
                    } 
            default { 
                        Write-Host "     ERROR: Undefined SQL Version " $SQL.Version -ForegroundColor "Red" 
                        stop-transcript    #Stops logging 
                        (Get-Content $File) | Foreach-Object { $_ -replace '', '' } | Set-Content $File    #Fix encoding of file for Notepad 
                        exit -1 
                    } 
        } 
    } 
    #Cleanup 
    Remove-Variable i 
    Remove-Variable j 
    Remove-Variable found 
    Remove-Variable Application 
    Remove-Variable SSRSURLString 
    Remove-Variable foundURL 
    Remove-Variable uri 
    Remove-Variable SQLVersion 
    Remove-Variable dt 
    Remove-Variable ssrsinstance 
    Remove-Variable ssrsURL 
    Remove-Variable urls 
    Remove-Variable result 
    Remove-Variable item 
    Remove-Variable SQL 
} 
 
 
function SQL2008([String]$SQLVersion){ 
    If ($UpdatePassword -eq $true){ 
        Write-Host " Updating Passwords..." 
        Write-Host 
    } 
    Else{ 
        Write-Host " Looking for usage..." 
        Write-Host 
    } 
    $Description = new-object -TypeName System.String -argumentList ("") 
    $Status = new-object -TypeName System.String -argumentList ("") 
    $EventType = new-object -TypeName System.String -argumentList ("") 
    $MatchData = new-object -TypeName System.String -argumentList ("") 
    $details = new-object -TypeName System.String -argumentList ("") 
 
    #$reporting = New-WebServiceProxy -uri $uri -UseDefaultCredential -namespace "ReportService2005" -class Reporting 
 
#$user = Get-Credential 
$user = [System.Net.CredentialCache]::DefaultCredentials 
 
    ##Determines which query to use 
    Switch ($SQLVersion) 
    { 
    #SSRS 2008 methods 
        2008{ 
            ##Creates the Web Service 
            $reporting = New-WebServiceProxy -Uri $uri -UseDefaultCredential -namespace "ReportService2005" -class Reporting 
            $reporting.url = $uri    #Makes sure URL is set correctly after call; sometimes this flips to a default URL 
            #$reporting = New-WebServiceProxy -uri $uri -UseDefaultCredential -namespace "ReportService2005" -class Reporting 
            #$reporting = New-WebServiceProxy -uri $uri -UseDefaultCredential -namespace "ReportingService2005" -class Reporting 
            ##Initialize Variable Types required for GetSubscription call 
            $ExtensionSettings = new-object -TypeName ReportService2005.ExtensionSettings 
            #$ExtensionSettings = new-object -TypeName ReportingService2005.ExtensionSettings 
            $ExtensionRow = new-object -TypeName ReportService2005.ExtensionSettings 
            #$ExtensionRow = new-object -TypeName ReportingService2005.ExtensionSettings 
            $DataRetrievalPlan = new-object -TypeName ReportService2005.DataRetrievalPlan 
            #$DataRetrievalPlan = new-object -TypeName ReportingService2005.DataRetrievalPlan 
            $Active =  new-object -TypeName ReportService2005.ActiveState 
            #$Active =  new-object -TypeName ReportingService2005.ActiveState 
            $ParametersValue = new-object -TypeName ReportService2005.ParameterValue 
            #$ParametersValue = new-object -TypeName ReportingService2005.ParameterValue 
            $subscriptions= new-object -TypeName ReportService2005.Subscription 
            #$subscriptions= new-object -TypeName ReportingService2005.Subscription 
            $subscription= new-object -TypeName ReportService2005.Subscription 
            #$subscription= new-object -TypeName ReportingService2005.Subscription 
            $ExtensionPassword = new-object -TypeName ReportService2005.ParameterValue 
            #$ExtensionPassword = new-object -TypeName ReportingService2005.ParameterValue 
            $Parameters = new-object -TypeName ReportService2005.ParameterValue 
            #$Parameters = new-object -TypeName ReportingService2005.ParameterValue 
         
            $reports = $reporting.listchildren("/", $true) | Where-Object {$_.Type -eq "Report"} 
        } 
        #SSRS 2008R2 methods 
        2008R2{ 
            ##Creates the Web Service 
            $reporting = New-WebServiceProxy -uri $uri -UseDefaultCredential -namespace "ReportingService2010" -class Reporting 
            $reporting.url = $uri    #Makes sure URL is set correctly after call; sometimes this flips to a default URL 
            ##Initialize Variable Types required for GetSubscription call 
            $ExtensionSettings = new-object -TypeName ReportingService2010.ExtensionSettings 
            $ExtensionRow = new-object -TypeName ReportingService2010.ExtensionSettings 
            $DataRetrievalPlan = new-object -TypeName ReportingService2010.DataRetrievalPlan 
            $Active =  new-object -TypeName ReportingService2010.ActiveState 
            $ParametersValue = new-object -TypeName ReportingService2010.ParameterValue 
            $subscriptions= new-object -TypeName ReportingService2010.Subscription 
            $subscription= new-object -TypeName ReportingService2010.Subscription 
            $ExtensionPassword = new-object -TypeName ReportingService2010.ParameterValue 
            $Parameters = new-object -TypeName ReportingService2010.ParameterValue 
         
            $reports = $reporting.listchildren("/", $true) | Where-Object {$_.TypeName -eq "Report"} 
        } 
        #If nothing matches, run this 
        default { 
            Write-Host "     ERROR: Undefined SQL Version " $SQL.Version -ForegroundColor "Red" 
            stop-transcript    #Stops logging 
            (Get-Content $File) | Foreach-Object { $_ -replace '', '' } | Set-Content $File    #Fix encoding of file for Notepad 
            exit -1 
        } 
    } 
    $ExtensionPassword.Name = "PASSWORD" 
    $ExtensionPassword.value = $password 
 
    ##List the datasource for all reports 
    ##Loops through for all the Reports on Report Server 
    foreach ($report in $reports){ 
 
        $dataSource = $reporting.GetItemDataSources($report.Path)[0] 
     
        If ($username -eq $dataSource.Item.UserName){ 
            Write-Host "Report: " $report.name 
            Write-Host " UserName: " $dataSource.Item.UserName 
            Write-Host 
 
            #Sets the new password 
            If ($UpdatePassword -eq $true){ 
                    $dataSource.Item.Password = $password 
                    $reporting.SetItemDataSources($report.Path, $dataSource) 
                } 
        } 
    } 
 
    ##Determines which query to use 
    Switch ($SQLVersion) 
    { 
        #SSRS 2008 methods 
        2008{ 
            $reports = $reporting.listchildren("/", $true) | Where-Object {$_.Type -eq "DataSource"} 
        } 
        #SSRS 2008R2 methods 
        2008R2{ 
            $reports = $reporting.listchildren("/", $true) | Where-Object {$_.TypeName -eq "DataSource"} 
        } 
        #If nothing matches, run this 
        default { 
            Write-Host "     ERROR: Undefined SQL Version " $SQL.Version -ForegroundColor "Red" 
            stop-transcript    #Stops logging 
            (Get-Content $File) | Foreach-Object { $_ -replace '', '' } | Set-Content $File    #Fix encoding of file for Notepad 
            exit -1 
        } 
    } 
 
    ##Loops through for all the Datasources on Report Server 
    foreach ($report in $reports){ 
        $dataSource = $reporting.GetDataSourceContents($report.Path) 
        #Write-Host "Datasource: " $report.name 
        #Write-Host " User Name: " $dataSource.UserName 
 
        #If (!($username.CompareTo($dataSource.UserName) -eq 1)){ 
        If ($username -eq $dataSource.UserName){ 
            Write-Host "Datasource: " $report.name 
            #Write-Host " Path: " $report.path 
            #Write-Host " Type: " $report.TypeName    #Report; Folder; DataSource 
 
            Write-Host "  UserName: " $dataSource.UserName 
            Write-Host 
 
            #Sets the new password 
            If ($UpdatePassword -eq $true){ 
                $dataSource.Password = $password 
                $reporting.SetDataSourceContents($report.Path, $dataSource) 
            } 
        } 
    } 
     
    ##Determines which query to use 
    Switch ($SQLVersion) 
    { 
    #SSRS 2008 methods 
        2008{ 
            $reports = $reporting.listchildren("/", $true) | Where-Object {$_.Type -eq "Report"} 
        } 
        #SSRS 2008R2 methods 
        2008R2{ 
                $reports = $reporting.listchildren("/", $true) | Where-Object {$_.TypeName -eq "Report"} 
        } 
        #If nothing matches, run this 
        default { 
            Write-Host "     ERROR: Undefined SQL Version " $SQL.Version -ForegroundColor "Red" 
            stop-transcript    #Stops logging 
            (Get-Content $File) | Foreach-Object { $_ -replace '', '' } | Set-Content $File    #Fix encoding of file for Notepad 
            exit -1 
        } 
    } 
     
    foreach ($report in $reports){ 
        ##Determines which syntax and parameters to pass 
        Switch ($SQLVersion) 
        { 
        #SSRS 2008 syntax 
            2008{ 
                ##Gets a list of subscriptions for the Report being referenced 
                $subscriptions = $reporting.ListSubscriptions($report.Path,"") 
            } 
            #SSRS 2008R2 syntax 
            2008R2{ 
                ##Gets a list of subscriptions for the Report being referenced 
                $subscriptions = $reporting.ListSubscriptions($report.Path) 
            } 
            #If nothing matches, run this 
            default { 
                Write-Host "     ERROR: Undefined SQL Version " $SQL.Version -ForegroundColor "Red" 
                stop-transcript    #Stops logging 
                (Get-Content $File) | Foreach-Object { $_ -replace '', '' } | Set-Content $File    #Fix encoding of file for Notepad 
                exit -1 
            } 
        } 
        foreach ($subscription in $subscriptions){ 
            $ReportSubscriptionID = [String]$subscription.SubscriptionID    #Sets a variable to the SubscriptionID Value 
            If ($ReportSubscriptionID){ 
                ##Looks through the extensions stored within the subscription for Username/Password 
                foreach ($ParameterValue in $subscription.DeliverySettings.ParameterValues){ 
                    If ($ParameterValue.name -eq "USERNAME"){    #Finds the username parameter 
                        If ($ParameterValue.value -eq $username){    #Checks if this is the username we are looking for 
                            Write-Host " Subscription Name: " $subscription.Report 
                            #Write-Host "   SubscriptionID: " $Subscription.SubscriptionID 
                            Write-Host "   DeliveryExtension: " $subscription.DeliverySettings.Extension 
                            write-host "      Field: " $ParameterValue.name 
                            #write-host "      Label: " $ParameterValue.label        ##Not used 
                            write-host "       Value: " $ParameterValue.value 
 
                            #Sets the new password 
                            $PasswordUpdated = $false 
                            If ($UpdatePassword -eq $true){ 
                                $details = "" 
                                #Gets the subscription Properties prior to updating the password 
                                $details = $reporting.GetSubscriptionProperties($Subscription.SubscriptionID, [REF]$ExtensionSettings, [REF]$Description, [REF]$Active, [REF]$Status, [REF]$EventType, [REF]$MatchData, [REF]$ParametersValue) 
                                 
                                $i=0    #initialize counter variable 
                                foreach ($ExtensionRow in $ExtensionSettings.ParameterValues){        #Pulls all the ExtensionSettings 
                                    #write-host "       ExtensionRow: " $ExtensionRow.name 
                                    #write-host "       ExtensionRow.Values: " $ExtensionRow.value 
                                    If ($ExtensionRow.name -eq "PASSWORD"){    #Checks to see if PASSWORD is unencrypted and available to pull 
                                        $ExtensionRow.value = $password    #Sets the value 
                                        Write-Host "!!   WARNING: Unencrypted password retrieved" -ForegroundColor "Red" 
                                        $PasswordUpdated = $true 
                                        break    #Exits for loop -- password updated, now to commit change 
                                    } 
                                    $i++    #Increments counter 
                                    If ($ExtensionSettings.ParameterValues.count -eq $i){    #Determines if this is the final iteration and whether the password field was found 
                                        $ExtensionSettings.ParameterValues += $ExtensionPassword 
                                        $PasswordUpdated = $true 
                                        break    #Exits for loop -- member group added and set 
                                        #} 
                                    } 
                                } 
 
                                #Sets the Subscription settings -- with the new Password 
                                If ($PasswordUpdated -eq $true){    #Password has actually been updated 
                                    $details = $reporting.SetSubscriptionProperties($ReportSubscriptionID, $ExtensionSettings, $Description, $EventType, $MatchData, $ParametersValue) 
                                } 
                                ELSE{ 
                                    Write-Host "     ERROR: PASSWORD NOT UPDATED" -ForegroundColor "Red" 
                                } 
                            } 
                        } 
                    } 
                } 
            } 
        } 
        #Write-Host 
    } 
    stop-transcript    #Stops logging 
    (Get-Content $File) | Foreach-Object { $_ -replace '', '' } | Set-Content $File    #Fix encoding of file for Notepad 
    Remove-Variable ExtensionSettings 
    Remove-Variable ExtensionRow 
    Remove-Variable DataRetrievalPlan 
    Remove-Variable Description 
    Remove-Variable Active 
    Remove-Variable Status 
    Remove-Variable EventType 
    Remove-Variable MatchData 
    Remove-Variable details 
    Remove-Variable ParametersValue 
    Remove-Variable Parameters 
    Remove-Variable subscriptions 
    Remove-Variable subscription 
    Remove-Variable ExtensionPassword 
} 
 
 
############# Main Code ################## 
#main($computer,$username,$password,$UpdatePassword) 
main 
 
##Cleanup 
Remove-Variable computer 
Remove-Variable password 
#Remove-Variable StackTrace 
Remove-Variable UpdatePassword 
Remove-Variable username 