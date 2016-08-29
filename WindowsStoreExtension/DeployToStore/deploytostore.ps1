[cmdletbinding()]
param()
#(
#   [Parameter(Mandatory=$true)][string] $filepath,
#   [Parameter(Mandatory=$true)][string] $serviceendpoint,
#   [Parameter(Mandatory=$true)][string] $appid,
#   [Parameter(Mandatory=$false)][string] $flightid 
#)


#$serviceendpoint = Get-VstsInput -Name serviceendpoint
$filepath = Get-VstsInput -Name filepath
$appid = Get-VstsInput -Name appid
$flightid = Get-VstsInput -Name flightid



$DevCenterEndpoint = Get-VstsEndpoint -Name "serviceendpoint"

$DevCenterEndpoint | Format-List *

#$DevCenterEndpoint =  Get-ServiceEndpoint -Context $distributedTaskContext -Name $serviceendpoint
$tenantid = $DevCenterEndpoint.Auth.Parameters.tenantid;
$clientid = $DevCenterEndpoint.Auth.Parameters.clientid;
$clientsecret = $DevCenterEndpoint.Auth.Parameters.ApiToken;

if (-Not $flightid){
    $flightid = "-";
}

$file = Find-VstsFiles -LegacyPattern $filepath

if ($file -is [system.array] -and $file.length -gt 1)
{
    throw "More then one file found: $file"
}
if ($file -is [system.array] -and $file.length -eq 0)
{
    throw "No files found: $file"
}

Write-Host "calling: .\StoreSubmission.exe ""$tenantid"" ""$clientid"" ""$clientsecret"" ""$appid"" ""$flightid"" ""$file"""
.\StoreSubmission.exe "$tenantid" "$clientid" "$clientsecret" "$appid" "$flightid" "$file"