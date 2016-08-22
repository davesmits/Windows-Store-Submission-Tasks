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
    $token = Invoke-WebRequest -Uri https://login.microsoftonline.com/$tenantId/oauth2/token -Body $postValue -ContentType "application/x-www-form-urlencoded; charset=utf-8" -Method POST -UseBasicParsing | ConvertFrom-Json
 
    $accessToken = $token.access_token

    #Write-Host "accesstoken: $accessToken"

    $createSubmissionUrl = "https://manage.devcenter.microsoft.com/v1.0/my/applications/$appid/submissions"
    $submission = Invoke-WebRequest -Uri $createSubmissionUrl -Headers @{"Authorization" = "bearer $accessToken"} -Method POST -UseBasicParsing | ConvertFrom-Json

    $submission.fileUploadUrl = $fileUrl;

    $updateSubmissionUrl = "https://manage.devcenter.microsoft.com/v1.0/my/applications/$appid/submissions/$submission.id"
    $submissionJson = ConvertTo-Json $submission 
    $submission = Invoke-WebRequest -Uri $updateSubmissionUrl -Headers @{"Authorization" = "bearer $accessToken"} -Body $submissionJson -Method PUT -UseBasicParsing

    $commitSubmissionUrl = "https://manage.devcenter.microsoft.com/v1.0/my/applications/$appid/submissions/$submission.id/commit"
    $submission = Invoke-WebRequest -Uri $commitSubmissionUrl -Headers @{"Authorization" = "bearer $accessToken"} -Body $submissionJson -Method POST -UseBasicParsing
}

function MakeFlightSubmission($teantId, $clientId, $clientSecret, $flightId)
{
    $postValue = "grant_type=client_credentials&client_id=$clientId&client_secret=$clientSecret&resource=https://manage.devcenter.microsoft.com"
    $token = Invoke-WebRequest -Uri https://login.microsoftonline.com/$tenantId/oauth2/token -Body $postValue -ContentType "application/x-www-form-urlencoded; charset=utf-8" -Method POST -UseBasicParsing | ConvertFrom-Json

    $accessToken = $token.access_token

    #Write-Host "accesstoken: $accessToken"

    $createSubmissionUrl = "https://manage.devcenter.microsoft.com/v1.0/my/applications/$appid/flights/$flightId/submissions"
    $submission = Invoke-WebRequest -Uri $createSubmissionUrl -Headers @{"Authorization" = "bearer $accessToken"} -Method POST -UseBasicParsing | ConvertFrom-Json

    $submission.fileUploadUrl = $fileUrl;

    $updateSubmissionUrl = "https://manage.devcenter.microsoft.com/v1.0/my/applications/$appid/flights/$flightId/submissions/$submission.id"
    $submissionJson = ConvertTo-Json $submission 
    $submission = Invoke-WebRequest -Uri $updateSubmissionUrl -Headers @{"Authorization" = "bearer $accessToken"} -Body $submissionJson -Method PUT -UseBasicParsing

    $commitSubmissionUrl = "https://manage.devcenter.microsoft.com/v1.0/my/applications/$appid/flights/$flightId/submissions/$submission.id/commit"
    $submission = Invoke-WebRequest -Uri $commitSubmissionUrl -Headers @{"Authorization" = "bearer $accessToken"} -Body $submissionJson -Method POST -UseBasicParsing
}


$DevCenterEndpoint = Get-ServiceEndpoint -Context $distributedTaskContext -Name $serviceendpoint
$tenantId = $DevCenterEndpoint.Authorization.Parameters.tenantid;
$clientid = $DevCenterEndpoint.Authorization.Parameters.clientid;
$clientsecret = $DevCenterEndpoint.Authorization.Parameters.ApiToken;

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