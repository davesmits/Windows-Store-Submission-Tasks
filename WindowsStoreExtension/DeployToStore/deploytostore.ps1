[cmdletbinding()]
param
(
   [Parameter(Mandatory=$true)][string] $serviceendpoint,
   [Parameter(Mandatory=$true)][string] $appid,
   [Parameter(Mandatory=$false)][string] $flightid,
   [Parameter(Mandatory=$true)][string] $filemask
)



$DevCenterEndpoint = Get-VstsEndpoint -Name $serviceendpoint
$tenantid = $DevCenterEndpoint.Authorization.Parameters.tenantid;
$clientid = $DevCenterEndpoint.Authorization.Parameters.clientid;
$clientsecret = $DevCenterEndpoint.Authorization.Parameters.ApiToken;

if (-Not $flightid){
    $flightid = "-";
}

$files = Find-VstsFiles $fileMask

if ($files.length == 0)
{
    throw "n0 files found"
    }

if ($files.length > 1)
{
    throw "too many files found"
}

$file = $files[0]
Write-Host "calling: .\StoreSubmission.exe ""$tenantid"" ""$clientid"" ""$clientsecret"" ""$appid"" ""$flightid"" ""$file"""
.\StoreSubmission.exe "$tenantid" "$clientid" "$clientsecret" "$appid" "$flightid" "$file"