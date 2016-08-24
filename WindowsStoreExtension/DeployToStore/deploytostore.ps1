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