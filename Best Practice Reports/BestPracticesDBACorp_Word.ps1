Set-StrictMode   -Version 2.0



#region Functions
Function Get-LastServicePack {
	param(
	[string]$versionstring
	)

	$page = Invoke-WebRequest "http://sqlserverbuilds.blogspot.com.br/" -Verbose:$false
	$html = $page.parsedHTML
	
	$products = $html.body.getElementsByTagName("TR")
	$headers = @()
	$Output = @()
	foreach($product in $products)
	{
	    $colID = 0;
	    $hRow = $false
	    $returnObject = New-Object psObject
	    foreach($child in $product.children)
	    {   
	        if ($child.tagName -eq "TH")
	        {
	            $headers += @($child.outerText)
	            $hRow = $true
	        }

	        if ($child.tagName -eq "TD")
	        {
	            if ($headers[$colID].length -ne 1) {
	              $returnObject | Add-Member NoteProperty ([string]$headers[$colID].substring(0,3)) $child.outerText 
	            } else {
	               $returnObject | Add-Member NoteProperty "SQL" $child.outerText
	            }
	        }
	        $colID++

	    }
	    if (-not $hRow) { 
			if ($returnObject."SQL" -notlike " SQL Server*" ) { 
		    	break
			} else {
				$Output += $returnObject

			}
		}
	}
	$Found = ($Output | 
			Where-Object {$_ -like "*$($versionstring)*"} ) 
	
	if (!($found)) {
		$VersionString = ($versionstring -split ".")[0]
		$Found = ($Output | 
			Where-Object {$_ -like "*$($VersionString)*"} ) 
	}
	if ($found) {
		
		if ($found.RTM -like "*$($versionstring)*") {
			$Return = "RTM"
		}
		if ($found.SP1 -eq $null -or $found.SP1 -eq "" -or $found.SP1 -eq " ") {
			$last = "RTM"
		} elseif ($found.SP2 -eq $null -or $found.SP2 -eq "" -or $found.SP2 -eq " ") {
			$last = "SP1"
		} elseif ($found.SP3 -eq $null -or $found.SP3 -eq "" -or $found.SP3 -eq " ") {
			$last = "SP2"
		} elseif ($found.SP4 -eq $null -or $found.SP4 -eq "" -or $found.SP4 -eq " ") {
			$last = "SP3"
		} else {
			$last = "SP4"
		}
		if ($found.RTM -like "*$($versionstring)*") {
			$actual = "RTM"
		}
		
		if ($found.SP1 -like "*$($versionstring)*") {
			$actual = "SP1"
		}
		if ($Output.SP2 -like "*$($versionstring)*") {
			$actual = "SP2"
		}
		if ($found.SP3 -like "*$($versionstring)*") {
			$actual = "SP3"
		}
		if ($found.SP4 -like "*$($versionstring)*") {
			$actual = "SP4"
		}
		
		$Property  =  @{	"SQL Server" = $found.SQL
							"CurrentServicePack" = $actual
							"LastServicePack"= $last
						}

	} else {
	  	$property  = @{	"SQL Server" = "Not found.Please Check Manually"
						"CurrentServicePack" = "Not found.Please Check Manually"
						"LastServicePack"= "Not found.Please Check Manually"
						}
	
	

	}
	New-object psobject -Property $property
}



Function  Remove-MSWordDocumentSession {
	param(
		[Parameter(Position=0,Mandatory = $true)] 
		[String]$ParamWordfileName
	)
	Try {
		$ExitCode = 0
		$Message = ""
		$wdFormatDocument =  0
		$Script:doc.SaveAs([REF]$ParamWordfileName,[ref]$wdFormatDocument) 
		$script:doc.Close()
		$script:word.Quit()
	
	} catch {
		$ExitCode = 1
		$Message = $_.exception 
	} Finally {
		$Output = New-Object -Type PSObject -Prop @{  'ExitCode' = $ExitCode
		  											  'Message'= $Message
													}
		Write-Output $Output
	
	}
}

Function  Add-MSWordText {

	[CmdletBinding()]
    param(

	[Parameter(Position=0,mandatory = $true)] 
		[String]$text,
	[Parameter(Position=1)] 
    	[Microsoft.Office.Interop.Word.WdColor]$Color,
	[Parameter(Position=2)] 	
        [String]$FontName,
	[Parameter(Position=3)] 	
        [Int]$Size,
	[Parameter(Position=4)] 	
        [Switch]$Bold,
	[Parameter(Position=5)] 	
        [Switch]$Italic
	)

	try {
		$ExitCode = 0
		$Message = ""
		$FontPropOldName = $Script:doc.Application.Selection.font.name
		$FontPropOldColor = $Script:doc.Application.Selection.font.Color
		$FontPropOldSize = $Script:doc.Application.Selection.font.Size
		$FontPropOldIsBold = $Script:doc.Application.Selection.font.BoldBi
		$FontPropOldIsItalic= $Script:doc.Application.Selection.font.Italic
		
		if ($PSBoundParameters.ContainsKey('Color')) {
			$Script:doc.Application.Selection.font.Color = $color
		}
		
		if ($PSBoundParameters.ContainsKey('FontName')) {
			$Script:doc.Application.Selection.font.name = $FontName
		}
		
		if ($PSBoundParameters.ContainsKey('Size')) {
			$Script:doc.Application.Selection.font.size = $Size
		}
		
		if ($PSBoundParameters.ContainsKey('Bold')) {
			$Script:doc.Application.Selection.font.Bold = if ($Bold) { 1 } else {0}
		}
		
		if ($PSBoundParameters.ContainsKey('Italic')) {
			$Script:doc.Application.Selection.font.Italic = if ($Italic) { 1 } else {0}
		}
		
		$Script:doc.Application.Selection.TypeText("$($Text)")	
		
		
		$Script:doc.Application.Selection.font.name = $FontPropOldName
		$Script:doc.Application.Selection.font.Color = $FontPropOldColor
		$Script:doc.Application.Selection.font.Size = $FontPropOldSize
		$Script:doc.Application.Selection.font.Bold = $FontPropOldIsBold
		$Script:doc.Application.Selection.font.Italic = $FontPropOldIsItalic

		$Script:doc.Application.Selection.TypeParagraph() 
	} catch {
		Write-Warning "Could not Add the Text :$($_.exception.message)"
	}

		
}

Function Add-MSWordTOC {
	try {
	
		$useHeadingStyles = $true
		$upperHeadingLevel = 1                            # <-- Heading1 or Title
		$lowerHeadingLevel = 2                         # <-- Heading2 or Subtitle
		$useFields = $false
		$tableID = $null
		$rightAlignPageNumbers = $true
		$includePageNumbers = $true
		# to include any other style set in the document add them here
		$addedStyles = $null
		$useHyperlinks = $true
		$hidePageNumbersInWeb = $true
		$useOutlineLevels = $true
		$Selection = $Script:Word.Selection
		$range = $Selection.Range
		$toc = $Script:Doc.TablesOfContents.Add(	$range, $useHeadingStyles,
													   $upperHeadingLevel, $lowerHeadingLevel, $useFields, $tableID,
													   $rightAlignPageNumbers, $includePageNumbers, $addedStyles,
													   $useHyperlinks, $hidePageNumbersInWeb, $useOutlineLevels
									  				)
		$Script:Word.Selection.EndKey(6) > $Null
		$Selection.TypeParagraph()
	} catch {
		Write-Warning "Could not Add The TOC Error:$($_.exception.message)"
	}
}

Function Update-MSWordTOC {
	try {
		$Script:Doc.Fields | 
		ForEach-Object{ 
			$_.Update() >> $null
		}
	} catch {
		Write-Warning "Could not Update The TOC Error:$($_.exception.message)"
	}
}

Function  Add-MSWordParagraph {

	[CmdletBinding()]
    param(

	[Parameter(Position=0)] 
		[String]$text,
	[Parameter(Position=1)] 
		[Microsoft.Office.Interop.Word.WdBuiltinStyle]$Style 
	)

	try {
		$Selection = $Script:Word.Selection
		$Selection.Style = $style
		$Selection.TypeText($text)
		$Script:Word.Selection.EndKey(6) > $null
		$Selection.TypeParagraph()
	} catch {
		Write-Warning "Could not Add the Paragraph Error:$($_.exception.message)"
	}	
}




Function Start-MSWordDocumentSession {
	[CmdletBinding()]
    param(

	[Parameter(Position=0)] 
		[switch]$Visible,


	[Parameter(Position=1)] 
		[ValidateScript({Test-Path $_ })] 
        [string] 
        $TemplatePath 
	)
	$ExitCode = 0
	$Message = ""
	try {
		$script:word = New-Object -ComObject "Word.application" 
		$script:word.visible = $Visible       
        if ($TemplatePath)  {
            $script:doc = $script:word.Documents.Add($TemplatePath)
        } else {  
     
		    $script:doc = $script:word.Documents.Add()  
        }          
		$script:doc.Activate()
	} catch {
		$ExitCode = 1
		$Message = $_.exception 
	} Finally {
		$Output = New-Object -Type PSObject -Prop @{  'ExitCode' = $ExitCode
		  											  'Message'= $Message
													}
		Write-Output $Output
	
	}
}

Function Add-MSWordTable {
	[CmdletBinding()]
    param(

	[Parameter(Position=0, Mandatory=$true)] 
	[psobject]$Object,
	[Parameter(Position=1)] 
	[int]$Size=11	
    )
		
   
	try {
		$TableRange = $script:doc.application.selection.range
		$Columns = @($Object | Get-Member -MemberType Property,NoteProperty).count
		$Rows = @($Object).count +1
			
		if ($rows -eq 1) {
			$Rows = 2
		}	
		$Table = $script:doc.Tables.Add($TableRange, $Rows, $Columns) 
		$Table.AllowAutoFit = $true
		$table.AutoFitBehavior(1)
		$table.Borders.InsideLineStyle = 1
		$table.Borders.OutsideLineStyle = 1
		$xRow = 1
		$XCol = 1
		$PropertyNames = @()
		if ($Object -is [Array]) {
			$HeaderNames = $Object[0].psobject.properties | % {$_.Name}
		} else {
			$HeaderNames = $Object.psobject.properties | % {$_.Name}
		}

		if ($Size -eq 11 -and $Columns -gt 5) {
			$Size = 8
		}
		for ($c=0; $c -le $Columns -1; $c++) {
		
			$Table.Cell($xRow,$XCol).Range.Font.Bold = $True
			$Table.Cell($xRow,$XCol).Range.Font.Size= [int]$Size
	        $PropertyNames += $HeaderNames[$c]
	        $Table.Cell($xRow,$XCol).Range.Text = $HeaderNames[$c]
			$Xcol++
		}	

		$xRow = 2
		$Object |
		ForEach-Object {
			$XCol = 1
			for ($c=0; $c -le $Columns -1; $c++) {
				$Split = (invoke-expression -Command  "`$_.'$($PropertyNames[$c])'") -split ";"
				$Table.Cell($xRow,$XCol).Range.Font.Size= [int]$size

				switch ($Split[1]) {
					'Red' {$Table.Cell($xRow,$XCol).Range.Shading.BackgroundPatternColor = [Microsoft.Office.Interop.Word.WdColor]::wdColorRed}
					'Yellow' {$Table.Cell($xRow,$XCol).Range.Shading.BackgroundPatternColor = [Microsoft.Office.Interop.Word.WdColor]::wdColorYellow} 
					'Aqua' {$Table.Cell($xRow,$XCol).Range.Shading.BackgroundPatternColor = [Microsoft.Office.Interop.Word.WdColor]::wdColorAqua} 
					'Green' {$Table.Cell($xRow,$XCol).Range.Shading.BackgroundPatternColor = [Microsoft.Office.Interop.Word.WdColor]::wdColorGreen} 
				default {$Table.Cell($xRow,$XCol).Range.Shading.BackgroundPatternColor = [Microsoft.Office.Interop.Word.WdColor]::wdColorAutomatic}

				}
		    	$Table.Cell($xRow,$XCol).Range.Text = $Split[0]
				$XCol++
			}	
			$xRow++
		}
		
		$selection = $script:doc.application.selection
		[Void]$selection.goto([Microsoft.Office.Interop.Word.WdGoToItem]::wdGoToBookmark,$null,$null,"\EndOfDoc")
		$Script:doc.Application.Selection.TypeParagraph() 
	} 	 catch {
		Write-Warning "Could not add the Table Error:$($_.exception.message)"
	}
	
}

#EndRegion Functions


#Region Variables

$InternetConnection = (Test-Connection -ComputerName google.com -Count 1 -Quiet)
$ProductVersion = $null


$WordNamestoShow = @()

$ErrorActionPreference = "Stop"
#EndRegion Variables 

$PowerShell30 = ($PSVersionTable.PSVersion.major -ge 3)
$VerbosePreference = 'Continue'

$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Definition
$PSScriptRoot = $scriptRoot
$PathInputCSV = $PSScriptRoot
dir "$($PathInputCSV)\*InstanceName.csv" -Recurse  |
ForEach-Object {

	Write-Verbose "Generating the word documment. Please wait..." 
	$script:word=$null
	$script:doc=$null
	$Directory = $_.directoryName
	
	$Split = $_.name -split "_"
	If ($Split[2]) {
		$FullPath = "$($Directory)\$($Split[0])_$($Split[1])_"
		$WordFileName ="$($Split[0])_$($Split[1])_BestPracticesReport.doc" 
	} else {
		$FullPath = "$($Directory)\$($Split[0])_"
		$WordFileName ="$($Split[0])_BestPracticesReport.doc"
	}	
	
	$WordFileNameToSave = "$($PathInputCSV)\$WordFileName"

	
	$WordDocument = Start-MSWordDocumentSession  -verbose:$false -templatepath "D:\Cloud\Dropbox\Scripts\SQL Server\Best Practice Reports\DBACorp_Modelo.dot"
	if (($WordDocument.ExitCode) -eq 1 ) {
		Write-Warning -Message "Could not create the word document. Error : $($WordDocument.Message)"
		Write-Error $WordDocument.Message
		Return
	}

	Add-MSwordToc

	$Object  = Import-Csv "$($FullPath)InstanceName.csv"

	if ($Object) {
		
		Add-MSWordParagraph  -text "Initial Review Report - INSTANCE NAME: $($Object.InstanceName)" -Style wdStyleHeading1
	}

	$FullInstanceName = $($Object.InstanceName)
	

	Write-Verbose -Message "Writing the SQL Edition for $FullInstanceName"
	Add-MSWordParagraph  -text "YOUR COMPANY NAME" -Style wdStyleHeading1
	

	#Region Section Server Properties

		Try {
			$Object  = Import-Csv "$($FullPath)SQLEdition.csv"

			if ($Object) {
			
			
				if($InternetConnection -and $PowerShell30) {
					$ProductVersion = ($Object."Product Version" -split ";")[0]
					$ObjectPlus = (	Get-LastServicePack -versionstring $ProductVersion |
									Select 	@{N="Current Service Pack";E={$_."CurrentServicePack"}} ,
											@{N="Last Service Pack";E={if($_."LastServicePack" -ne $_."CurrentServicePack" ) {"$($_.'LastServicePack');Red"} else { $_."LastServicePack" }} })
				} else {
					$ObjectPlus  = 	 New-Object psobject  @{	"Current Service Pack" = $($Object."Product Version")
																"Last Service Pack"= "Please Check Manually"
															} |
											Select 	@{N="Current Service Pack";E={$_."Current Service Pack"}} ,
													@{N="Last Service Pack";E={"$($_.'Last Service Pack');Yellow"}} 
				}
		
			
				[Void]($Object | 	Add-Member -MemberType noteProperty -Name  "Current Service Pack" -Value $ObjectPlus."Current Service Pack"-PassThru -Force |
				 					Add-Member -Name "Last Service Pack" -MemberType noteProperty  -Value $ObjectPlus."Last Service Pack" -PassThru -Force)

				
				#Add-MSWordText -Color wdColorRed -Size 14 -Bold -text "Server Properties"
				Add-MSWordParagraph -text "Server Properties" -style wdStyleHeading1
				Add-MSWordText  -text "Write whatever you want here"
				Add-MSWordText   -text "nonononononono"
				Add-MSWordText  -text "nonononoononno"
				Add-MSWordTable -Object $Object 
			}
		} catch {	
			Write-Warning "Could not create the Server Properties Section  - SQL Edition  : Error $($_.Exception.message)"
		}

		#End SQL Server Editon
		
		

		
		# Power Plan
		
			Write-Verbose -Message "Writing the Power Plan for $FullInstanceName"

		
	
		
	
		#XPMSVER
		
		Write-Verbose -Message "Writing the XP_MSVER for $FullInstanceName"


		Try {
			$Object = Import-Csv "$($FullPath)xpmsver.csv"
			if ($Object) {
				Add-MSWordParagraph  -text "Output of xp_msver" -Style wdStyleHeading2
				Add-MSWordTable -Object $Object
			}
		} Catch {
			Write-Warning  "Could not create the XP_MSVER Section : Error $($_.Exception.message)"
		}


		#XPMSVER

	#EndRegion Section Server Properties


			
	#Region SQL Server Configuration
		Write-Verbose -Message "Writing the SQL Server Configuration for $FullInstanceName"


		Try {
			$Object = Import-Csv "$($FullPath)ServerConfiguration.csv"
			if($Object) {
				Add-MSWordParagraph -text "Server Configuration"  -Style wdStyleHeading1
				Add-MSWordTable -Object $Object
			}
		} Catch {
			Write-Warning "Could not create the SQL Server Configuration Section : Error $($_.Exception.message)"
		}

	#EndRegion SQL Server Configuration

	
	#Region PageFile
		Try {
	  
			Write-Verbose -Message "Writing thePage File  for $FullInstanceName"
			$Object = Import-Csv "$($FullPath)PageFile.csv"
			IF($Object) {
				Add-MSWordParagraph  -text "Page File Settings "  -Style wdStyleHeading1
				Add-MSWordTable -Object $Object
			}
		} Catch {
			Write-Warning  "Could not create the Page File Section : Error $($_.Exception.message)"
		}


	#EndRegion PageFile

		
	
	#Check Something
		
	Write-Verbose -Message "Writing the Check Something for $FullInstanceName"


	Try {
		$Object = Import-Csv "$($FullPath)CheckSomething.csv"
		if ($Object) {
			Add-MSWordParagraph  -text "Output of Check Something" -Style wdStyleHeading1
			Add-MSWordText -text "Write anything you want....."
			Add-MSWordTable -Object $Object
		}
	} Catch {
		Write-Warning  "Could not create the Check Something Section : Error $($_.Exception.message)"
	}


	#EndRegion Check Something

	#Check VersãoDoBancoDeDados
		
	Write-Verbose -Message "Writing the VersãoDoBancoDeDados for $FullInstanceName"


	Try {
		$Object = Import-Csv "$($FullPath)VersãoDoBancoDeDados.csv"
		if ($Object) {
			Add-MSWordParagraph  -text "Output of Check VersãoDoBancoDeDados" -Style wdStyleHeading1
			Add-MSWordText -text "Write anything you want....."
			Add-MSWordTable -Object $Object
		}
	} Catch {
		Write-Warning  "Could not create the Check Something Section : Error $($_.Exception.message)"
	}


	#EndRegion Check VersãoDoBancoDeDados

	Write-Verbose -Message "Updating TOC"
	Update-MSWordTOC

	Write-Verbose -Message "Saving the document at $($WordFileNameToSave)"
	$save = Remove-MSWordDocumentSession -ParamWordfileName $WordFileNameToSave 
	if($Save.ExitCode -eq 0) {
		Write-Verbose -Message "**************************************************************************"	
		Write-Verbose -Message "**************************************************************************"	

		Write-Verbose -Message "Document $($WordFileName) saved at $($WordFileNameToSave )"	

		Write-Verbose -Message "**************************************************************************"	
		Write-Verbose -Message "**************************************************************************"	
		$WordNamestoShow += $WordFileNameToSave
		
	} else {
		Write-Warning "An Error ocurred trying to save the document $($WordFileName). Please Run again Error : $($Save.Message)"
	}
	
}
Write-Verbose "Script Finished. You can close the PowerShell Session"
Write-Verbose "Word Documents saved at :"
$WordNamestoShow | 
ForEach-Object {
	Write-Verbose $_
}
Start-Sleep -Seconds 100000


