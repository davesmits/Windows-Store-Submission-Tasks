[cmdletbinding()]
param()
#(
#   [Parameter(Mandatory=$true)][string] $filepath,
#   [Parameter(Mandatory=$true)][string] $serviceendpoint,
#   [Parameter(Mandatory=$true)][string] $appid,
#   [Parameter(Mandatory=$false)][string] $flightname
#)


#$serviceendpoint = Get-VstsInput -Name serviceendpoint
$filepath = Get-VstsInput -Name filepath
$appid = Get-VstsInput -Name appid
$flightname = Get-VstsInput -Name flightname
$serviceendpoint = Get-VstsInput -Name serviceendpoint

$DevCenterEndpoint = Get-VstsEndpoint -Name "$serviceendpoint"

$tenantid = $DevCenterEndpoint.Auth.Parameters.tenantid;
$clientid = $DevCenterEndpoint.Auth.Parameters.clientid;
$clientsecret = $DevCenterEndpoint.Auth.Parameters.ApiToken;

#Write-Host "Tenant: $tenantid"
#Write-Host "Client: $clientid"
#Write-Host "Secret: $clientsecret"

if (-Not $flightname){
    $flightname = "-";
}

$file = Find-VstsFiles -LegacyPattern $filepath

if ($file -is [system.array] -and $file.length -gt 1)
{
    throw "More then one file found: $file"
}
if ($file -is [system.array] -and $file.length -eq 0)
{
    throw "No files found"
}
if (-Not $file)
{
    throw "No files found"
}

Write-Host "calling: .\StoreSubmission.exe ""$tenantid"" ""$clientid"" ""$clientsecret"" ""$appid"" ""$flightname"" ""$file"""
.\StoreSubmission.exe "$tenantid" "$clientid" "$clientsecret" "$appid" "$flightname" "$file"

if ($LASTEXITCODE -ne 0)
{
    throw "Error uploading package"
}