<#
.DESCRIPTION
This is a script for finding old snaps and trash them
#>
#================================================================================
#
#          FILE: prune_old_snaps.ps1
# 
#         USAGE: ./prune_old_snaps.ps1 
# 
#   DESCRIPTION: With this script you can find old snapshots on a Cmode filer and trash them
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: This needs dataontap module
#        AUTHOR: Masoud Fereidonian
#  ORGANIZATION: -
#       CREATED: 11/10/2017 
#===============================================================================
[cmdletbinding()]
param(
    [string]$controller,
    [string]$volumes,
    [string]$snapshots,
    [string]$vserver,
    [string]$cred,
    [string]$userName ="admin"
)


function show-error ([string]$Message, [int]$ExitStatus=1) {
    
    Write-Host -ForegroundColor red "`n$Message"
    Write-Host -ForegroundColor White "`nHow to use this script :"
    exit $ExitStatus
}

#Import Ontap Module
if (!(Get-Module Dataontap)) {
    Write-Host "`nWe do not have DataOntap Module!"
    Write-Host "`nImporting the module ..."
    Import-Module Dataontap
    if (get-module Dataontap) {
        Write-Host "`nSuccessfully installed Dataontap module"
    }
    else {
        Write-host "Can't import the module ... exiting "
        exit 1
        
    }

}


#Connect to controller
Write-Host -NoNewline "What is the controller name/IP : "
$controller = $null


while ($true){
    $controller=  Read-Host
    if ($controller -ne "" ) {break}    
        Write-Host -NoNewline "You need to provide Strorage name/IP : "
}




if (!(Test-Connection -ComputerName $controller -Quiet -Count 1 -BufferSize 16)) {
    Write-Host "Can't find the controller , make sure your Host Name/IP is correct !!!"
    Exit 1
}

#Need to use a try/catch here
Connect-NcController $controller -Credential $userName 
Write-Host

#Check volume snapshot
Write-Host -NoNewline "Is there any specific volume that you wanna check, put astrisk * for all volumes : "
$tmpvolumes = Read-Host

$volumes = Get-NcVol $tmpvolumes | Where-Object { ($_.name -notlike "*KEEP*") -and ($_.name -ne "vol0") -and ($_.name -ne "*svm*root*")} 

#Retrive volume(s) Snaps
$snapshots = Get-NcSnapshot -Volume $volumes

#Find snaps older than 3 months and replace $snapshot 
$time = (Get-Date).AddMonths(-3).ToString('MM/dd/yyyy')
$snapshots1 = $snapshots | Where-Object { $_.created -lt $time }

$snapdel = $snapshots1
#Show the snaps and volume names to the user and ask for validation
Clear-Host
Write-Host "Bellow is the name of volumes with snapshots older than 3 months :"
$snapshots1 | Select-Object volume,name,created
Write-Host
Write-Host -NoNewline "Are you sure that you want to trash these snapshots ??? **THIS IS NOT REVERSIBLE AND ALL THE SNAPSHOTS WILL DELETED FROM STORAGE**(Y/N) : "
$answer = Read-Host
if ($answer -eq "y")
    {
        Write-Host $answer
        $snapdel | Remove-NcSnapshot
    }
else
    {
        Write-Host "no"
    }


 









