[cmdletbinding()]
param
(
   [Parameter(Mandatory=$true)][string] $serviceendpoint,
   [Parameter(Mandatory=$true)][string] $appid,
   [Parameter(Mandatory=$true)][string] $flightid,
   [Parameter(Mandatory=$true)][string] $fileurl
)

$ErrorActionPreference = "Stop"

function MakeSubmission($tenantId, $clientId, $clientSecret)
{
    $postValue = "grant_type=client_credentials&client_id=$clientId&client_secret=$clientSecret&resource=https://manage.devcenter.microsoft.com"
	$url = "https://login.microsoftonline.com/$tenantId/oauth2/token"
	$token = Invoke-RestMethod -Uri $url -Body $postValue -ContentType "application/x-www-form-urlencoded; charset=utf-8" -Method POST -UseBasicParsing

    $accessToken = $token.access_token
    
    $applicationInfoUrl = "https://manage.devcenter.microsoft.com/v1.0/my/applications/$appid"
    $application = Invoke-RestMethod -Uri $applicationInfoUrl -Headers @{"Authorization" = "bearer $accessToken"} -Method GET -UseBasicParsing

    if ([bool]($application.PSobject.Properties.name -match "pendingApplicationSubmission"))
    {
        throw "Already submission in progress"
    }

    #Write-Host "accesstoken: $accessToken"

    $createSubmissionUrl = "https://manage.devcenter.microsoft.com/v1.0/my/applications/$appid/submissions"
    $submission = Invoke-RestMethod -Uri $createSubmissionUrl -Headers @{"Authorization" = "bearer $accessToken"} -Method POST -UseBasicParsing 

	#$updateSubmissionUrl = "https://manage.devcenter.microsoft.com/v1.0/my/applications/$appid/submissions/$submission.id"
    #$submission = Invoke-RestMethod -Uri $updateSubmissionUrl -Headers @{"Authorization" = "bearer $accessToken"} -Body $submission -Method PUT -UseBasicParsing

    $uploadurl = $submission.fileUploadUrl

	$Body = [System.IO.File]::ReadAllBytes("C:\Dave\test.zip");
	$Request = [System.Net.HttpWebRequest]::CreateHttp($uploadurl);
	$Request.Method = 'PUT';
	$Request.Headers.Add('x-ms-blob-type', 'BlockBlob')

	$Request.ContentType = "application/octet-stream"
	$Stream = $Request.GetRequestStream();
	$Stream.Write($Body, 0, $Body.Length);
	$Request.GetResponse();


    #$updateSubmissionUrl = "https://manage.devcenter.microsoft.com/v1.0/my/applications/$appid/submissions/$submission.id"
    #$submission = Invoke-RestMethod -Uri $updateSubmissionUrl -Headers @{"Authorization" = "bearer $accessToken"} -Body $submission -Method PUT -UseBasicParsing

    $commitSubmissionUrl = "https://manage.devcenter.microsoft.com/v1.0/my/applications/$appid/submissions/$submission.id/commit"
    $commit = Invoke-RestMethod -Uri $commitSubmissionUrl -Headers @{"Authorization" = "bearer $accessToken"}  -Method POST -UseBasicParsing
}

function MakeFlightSubmission($teantId, $clientId, $clientSecret, $flightId)
{
    $postValue = "grant_type=client_credentials&client_id=$clientId&client_secret=$clientSecret&resource=https://manage.devcenter.microsoft.com"
	$url = "https://login.microsoftonline.com/$tenantId/oauth2/token"
	$token = Invoke-RestMethod -Uri $url -Body $postValue -ContentType "application/x-www-form-urlencoded; charset=utf-8" -Method POST -UseBasicParsing

    $accessToken = $token.access_token

    $createSubmissionUrl = "https://manage.devcenter.microsoft.com/v1.0/my/applications/$appid/flights/$flightId/submissions"
    $submission = Invoke-RestMethod -Uri $createSubmissionUrl -Headers @{"Authorization" = "bearer $accessToken"} -Method POST -UseBasicParsing 

	#$updateSubmissionUrl = "https://manage.devcenter.microsoft.com/v1.0/my/applications/$appid/flights/$flightId/submissions/$submission.id"
    #$submission = Invoke-RestMethod -Uri $updateSubmissionUrl -Headers @{"Authorization" = "bearer $accessToken"} -Body $submission -Method PUT -UseBasicParsing


    $uploadurl = $submission.fileUploadUrl

	$Body = [System.IO.File]::ReadAllBytes("C:\Dave\test.zip");
	$Request = [System.Net.HttpWebRequest]::CreateHttp($uploadurl);
	$Request.Method = 'PUT';
	$Request.Headers.Add('x-ms-blob-type', 'BlockBlob')

	$Request.ContentType = "application/octet-stream"
	$Stream = $Request.GetRequestStream();
	$Stream.Write($Body, 0, $Body.Length);
	$Request.GetResponse();

    $commitSubmissionUrl = "https://manage.devcenter.microsoft.com/v1.0/my/applications/$appid/flights/$flightId/submissions/$submission.id/commit"
    $commit = Invoke-RestMethod -Uri $commitSubmissionUrl -Headers @{"Authorization" = "bearer $accessToken"}  -Method POST -UseBasicParsing
}


$DevCenterEndpoint = Get-ServiceEndpoint -Context $distributedTaskContext -Name $serviceendpoint
$tenantId = $DevCenterEndpoint.Authorization.Parameters.tenantid;
$clientid = $DevCenterEndpoint.Authorization.Parameters.clientid;
$clientsecret = $DevCenterEndpoint.Authorization.Parameters.ApiToken;

$clientId = [System.Web.HttpUtility]::UrlEncode($clientId)
$clientSecret = [System.Web.HttpUtility]::UrlEncode($clientSecret) 

#Write-Host "TenantId: $tenantId"
#Write-Host "ClientId: $clientid"
#Write-Host "Client Secret: $clientsecret"

#Write-Host "====AUTHORIZATION OBJECT===="
#$DevCenterEndpoint.Authorization | Get-Member * | Write-Host
#Write-Host "========"

#Write-Host "====AUTHORIZATION PARAMETERS OBJECT===="
#$DevCenterEndpoint.Authorization.Parameters | Get-Member * | Write-Host
#Write-Host "========"



if ($flightid){
    Write-Host "Flighted Submission"
    MakeFlightSubmission $tenantid $clientid $clientsecret $flightid
}else{
    Write-Host "NonFlighted Submission"
    MakeSubmission $tenantid $clientid $clientsecret
}