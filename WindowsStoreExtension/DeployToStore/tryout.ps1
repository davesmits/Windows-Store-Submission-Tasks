Import-Module .\ps_modules\VstsTaskSdk
$file = Find-VstsFiles -LegacyPattern 'c:\dave\*.appxupload'

if (-Not $file)
{
    Write-Host "No File Found"
}