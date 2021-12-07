################################### GET-HELP #############################################
<#
.SYNOPSIS
 	Pull all creadentials from a Safe and save the output to a .csv
 
.EXAMPLE
 	./Export-BlukPW.ps1
 
.INPUTS  
	None via command line.
	
.OUTPUTS
	Export.csv
	
.NOTES
	AUTHOR:  
	Randy Brown

	VERSION HISTORY:
	0.1 12/07/2021 - Initial release
#>
##########################################################################################

######################## IMPORT MODULES/ASSEMBLY LOADING #################################

if (!(Get-Module "psPAS")) {
    Import-Module "psPAS"
}

##########################################################################################
######################### GLOBAL VARIABLE DECLARATIONS ###################################

$baseURL = "https://pvwa.cyberlab.com"
$safeName = "Servers"
$firstRun = $true
$outputFile = "Export.csv"

########################## START FUNCTIONS ###############################################



########################## END FUNCTIONS #################################################

########################## MAIN SCRIPT BLOCK #############################################

New-PASSession -type RADIUS -BaseURI $baseURL

Write-Host "Pulling Accounts from" $safeName`... -NoNewLine
$accounts = Get-PASAccount -safeName $safeName
Write-Host "Done!" -ForegroundColor Green

foreach ($account in $accounts) {
    $date = Get-Date -Format yyyy-MM-dd

    Write-Host "Getting current password for" $account.name`... -NoNewLine
    $currentPW = Get-PASAccountPassword -AccountID $account.id
    Write-Host "Done!" -ForegroundColor Green

    $outputCSV = New-Object -TypeName PSobject -Property @{
        DatePulled = $date
        Safe = $account.safeName
        ObjectID = $account.name
        UserName = $account.userName
        Password = $currentPW.Password
    }

    if ($firstRun -ne $false) {
        $outputCSV | Select-Object -Property DatePulled,Safe,ObjectID,UserName,Password | ConvertTo-Csv -NoTypeInformation |`
        Add-Content $outputFile
    } else {
        $outputCSV | Select-Object -Property DatePulled,Safe,ObjectID,UserName,Password | ConvertTo-Csv -NoTypeInformation |`
        Select-Object -Skip 1 | Add-Content $outputFile
    }

    $firstRun = $false
}

Close-PASSession

########################### END SCRIPT ###################################################