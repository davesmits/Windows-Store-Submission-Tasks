[cmdletbinding()]
param
(
   [Parameter(Mandatory=$true)][string] $filemask,
   [Parameter(Mandatory=$true)][string] $serviceendpoint,
   [Parameter(Mandatory=$true)][string] $appid,
   [Parameter(Mandatory=$false)][string] $flightid 
)



$DevCenterEndpoint = Get-VstsEndpoint -Name $serviceendpoint
$tenantid = $DevCenterEndpoint.Authorization.Parameters.tenantid;
$clientid = $DevCenterEndpoint.Authorization.Parameters.clientid;
$clientsecret = $DevCenterEndpoint.Authorization.Parameters.ApiToken;

if (-Not $flightid){
    $flightid = "-";
}

$file = Find-VstsFiles -LegacyPattern $fileMask

if ($file -is [system.array] -and $file.length -gt 1)
{
    throw "More then one file found"
}
if ($file -is [system.array] -and $file.length -eq 0)
{
    throw "No files found"
}

Write-Host "calling: .\StoreSubmission.exe ""$tenantid"" ""$clientid"" ""$clientsecret"" ""$appid"" ""$flightid"" ""$file"""
.\StoreSubmission.exe "$tenantid" "$clientid" "$clientsecret" "$appid" "$flightid" "$file"