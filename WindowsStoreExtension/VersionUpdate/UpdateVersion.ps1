Param(
    [String]$manifestfile,
    [String]$buildid
)

  
if (-Not $manifestfile) {
    Write-Host "No manifest file"
    exit 1
}

if (-Not $buildid) {
    Write-Host "no build Id set"
    exit 1
}

  
$file = Get-Item -Path "$manifestfile"
  
$manifestXml = New-Object -TypeName System.Xml.XmlDocument
$manifestXml.Load($file.Fullname)

$currentVersion = [Version]$manifestXml.Package.Identity.Version
$updatedVersion = [Version]($currentVersion.Major.ToString() + '.' + $currentVersion.Minor + '.' + $buildid + '.' + 0)

$manifestXml.Package.Identity.Version = [String]$updatedVersion
$manifestXml.save($file.FullName)
