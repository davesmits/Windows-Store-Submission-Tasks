[cmdletbinding()]
param
(
   [Parameter(Mandatory=$true)][string] $serviceendpoint,
   [Parameter(Mandatory=$true)][string] $appid,
   [Parameter(Mandatory=$true)][string] $flightid,
   [Parameter(Mandatory=$true)][string] $file
)

$ErrorActionPreference = "Stop"

Add-Type -AssemblyName System.Web     

function MakeSubmission($tenantId, $clientId, $clientSecret)
{
    $accessToken = GetAccessToken $clientId $clientSecret
    
    $applicationInfoUrl = "https://manage.devcenter.microsoft.com/v1.0/my/applications/$appid"
    $application = Invoke-RestMethod -Uri $applicationInfoUrl -Headers @{"Authorization" = "bearer $accessToken"} -Method GET -UseBasicParsing

    if ([bool]($application.PSobject.Properties.name -match "pendingApplicationSubmission"))
    {
        throw "Already submission in progress"
    }

    $createSubmissionUrl = "https://manage.devcenter.microsoft.com/v1.0/my/applications/$appid/submissions"
    $submission = Invoke-RestMethod -Uri $createSubmissionUrl -Headers @{"Authorization" = "bearer $accessToken"} -Method POST -UseBasicParsing
    
    $newPackageVersion = AnalyzeAppxBundle $file
    $oldPackageVersion = ""; 

	#$updateSubmissionUrl = "https://manage.devcenter.microsoft.com/v1.0/my/applications/$appid/submissions/$submission.id"
    #$submission = Invoke-RestMethod -Uri $updateSubmissionUrl -Headers @{"Authorization" = "bearer $accessToken"} -Body $submission -Method PUT -UseBasicParsing

    UploadFile $file $submission.fileUploadUrl

    #$commitSubmissionUrl = "https://manage.devcenter.microsoft.com/v1.0/my/applications/$appid/submissions/$submission.id/commit"
    #$commit = Invoke-RestMethod -Uri $commitSubmissionUrl -Headers @{"Authorization" = "bearer $accessToken"}  -Method POST -UseBasicParsing
}

function MakeFlightSubmission($tenantId, $clientId, $clientSecret, $flightId)
{
    $accessToken = GetAccessToken $clientId $clientSecret
    
    $createSubmissionUrl = "https://manage.devcenter.microsoft.com/v1.0/my/applications/$appid/flights/$flightId/submissions"
    $submission = Invoke-RestMethod -Uri $createSubmissionUrl -Headers @{"Authorization" = "bearer $accessToken"} -Method POST -UseBasicParsing
    
    $newPackageVersion = AnalyzeAppxBundle $file
    $oldPackageVersion = ""; 

	#$updateSubmissionUrl = "https://manage.devcenter.microsoft.com/v1.0/my/applications/$appid/flights/$flightId/submissions/$submission.id"
    #$submission = Invoke-RestMethod -Uri $updateSubmissionUrl -Headers @{"Authorization" = "bearer $accessToken"} -Body $submission -Method PUT -UseBasicParsing

    UploadFile $file $submission.fileUploadUrl

    $commitSubmissionUrl = "https://manage.devcenter.microsoft.com/v1.0/my/applications/$appid/flights/$flightId/submissions/$submission.id/commit"
    $commit = Invoke-RestMethod -Uri $commitSubmissionUrl -Headers @{"Authorization" = "bearer $accessToken"}  -Method POST -UseBasicParsing
}

function GetAccessToken($clientId, $clientSecret)
{
    $postValue = "grant_type=client_credentials&client_id=$clientId&client_secret=$clientSecret&resource=https://manage.devcenter.microsoft.com"
	$url = "https://login.microsoftonline.com/$tenantId/oauth2/token"
	$token = Invoke-RestMethod -Uri $url -Body $postValue -ContentType "application/x-www-form-urlencoded; charset=utf-8" -Method POST -UseBasicParsing
    $accessToken = $token.access_token
    return $accessToken;
}

function UploadFile($file, $url)
{
    
    $tempdir =  Split-Path $file | Join-Path -ChildPath "upload"
    New-Item $tempdir -type directory
    Copy-Item $file $tempdir

    $destination = Split-Path $file | Join-Path -ChildPath "upload.zip"

    Add-Type -assembly "system.io.compression.filesystem"
    [io.compression.zipfile]::CreateFromDirectory($tempdir, $destination) 
    
    #Prepare zip
    Add-Type -assembly "system.io.compression.filesystem"
    [io.compression.zipfile]::CreateFromDirectory($Source, $destination) 
    Try
    {
        #Send request
        $Body = [System.IO.File]::ReadAllBytes($file);
        $Request = [System.Net.HttpWebRequest]::CreateHttp($url);
        $Request.Method = 'PUT';
        $Request.Headers.Add('x-ms-blob-type', 'BlockBlob')

        $Request.ContentType = "application/octet-stream"
        $Stream = $Request.GetRequestStream();
        $Stream.Write($Body, 0, $Body.Length);
        $Request.GetResponse();
    } 
    Finally
    {
        Remove-Item $tempdir -Recurse
        Remove-Item $destination
    }
}

function AnalyzeAppxUpload($appxUpload)
{
    $tempfile = [System.IO.Path]::GetTempPath()| Join-Path -ChildPath ([System.Guid]::NewGuid())
    Try
    {
        Add-Type -assembly "system.io.compression.filesystem"
        [System.IO.Compression.ZipFile]::ExtractToDirectory($appxUpload, $tempfile)

        $result = Get-ChildItem $tempfile | where {$_.Extension -eq ".appxbundle" }
        $version;
        foreach($path in $result)
        {
            $newVersion = AnalyzeAppxBundle $path.FullName
            
            if (!$version)
            {
                $version = $newVersion
            }
            else
            {
                if ((CompareVersion $version $newVersion) -eq -1)
                {
                    $version = $newVersion
                }
            }   
        }
        return $version;
    }
    Finally
    {
        Remove-Item $tempfile -Recurse
    }
}

function AnalyzeAppxBundle($appxBundle)
{
    
    $tempfile = [System.IO.Path]::GetTempPath()| Join-Path -ChildPath ([System.Guid]::NewGuid())
    Try
    {
        Add-Type -assembly "system.io.compression.filesystem"
        [System.IO.Compression.ZipFile]::ExtractToDirectory($appxBundle, $tempfile)
        
        $result = Get-ChildItem $tempfile -Recurse | where {$_.Extension -eq ".appx" }
        $version;
        foreach($path in $result)
        {
            $newVersion = AnalyzeAppx $path.FullName
            
            if (!$version)
            {
                $version = $newVersion
            }
            else
            {
                if ((CompareVersion $version $newVersion) -eq -1)
                {
                    $version = $newVersion
                }
            }   
        }
        return $version;
    }
    Finally
    {
        Remove-Item $tempfile -Recurse
    }
}

function AnalyzeAppx($appx)
{
    $tempfile = [System.IO.Path]::GetTempPath() | Join-Path -ChildPath ([System.Guid]::NewGuid())
    Try
    {
        Add-Type -assembly "system.io.compression.filesystem"
        [System.IO.Compression.ZipFile]::ExtractToDirectory($appx, $tempfile)

        $result = Get-ChildItem $tempfile -Recurse | where {$_.Name -eq "AppxManifest.xml" }
        [xml]$appxManifestXml = Get-Content -Path $result.FullName

        return $appxManifestXml.Package.Dependencies.TargetDeviceFamily.MinVersion
    }
    Finally
    {
        Remove-Item $tempfile -Recurse
    }
}

function CompareVersion($version1, $version2)
{
    $oldVersionIndex = $version1.Split("{.}")
    $newVersionIndex = $version2.Split("{.}")

    $index = 0;
    do
    {
        $num1 = [convert]::ToInt32($oldVersionIndex[$index])
        $num2 = [convert]::ToInt32($newVersionIndex[$index])

        $result = $num1.CompareTo($num2);

        $index++
    }
    while($result -eq 0 -and $index -lt 4)
    return $result
}


$DevCenterEndpoint = Get-ServiceEndpoint -Context $distributedTaskContext -Name $serviceendpoint
$tenantid = $DevCenterEndpoint.Authorization.Parameters.tenantid;
$clientid = $DevCenterEndpoint.Authorization.Parameters.clientid;
$clientsecret = $DevCenterEndpoint.Authorization.Parameters.ApiToken;

$clientid = [System.Web.HttpUtility]::UrlEncode($clientId)
$clientsecret = [System.Web.HttpUtility]::UrlEncode($clientSecret) 



if ($flightid){
    Write-Host "Flighted Submission"
    MakeFlightSubmission $tenantid $clientid $clientsecret $flightid
}else{
    Write-Host "NonFlighted Submission"
    MakeSubmission $tenantid $clientid $clientsecret
}