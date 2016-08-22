[cmdletbinding()]
param
(
   [Parameter(Mandatory=$true)][string] $serviceendpoint,
   [Parameter(Mandatory=$true)][string] $appid,
   [Parameter(Mandatory=$true)][string] $flightid,
   [Parameter(Mandatory=$true)][string] $fileurl
)


function MakeSubmission($tenantId, $clientId, $clientSecret)
{
    $postValue = "grant_type=client_credentials&client_id=$clientId&client_secret=$clientSecret&resource=https://manage.devcenter.microsoft.com"
    $token = Invoke-WebRequest -Uri https://login.microsoftonline.com/$tenantId/oauth2/token -Body $postValue -ContentType "application/x-www-form-urlencoded; charset=utf-8" -Method POST | ConvertFrom-Json

    $accessToken = $token.access_token

    Write-Host "accesstoken: $accessToken"

    $createSubmissionUrl = "https://manage.devcenter.microsoft.com/v1.0/my/applications/$appid/submissions"
    $submission = Invoke-WebRequest -Uri $createSubmissionUrl -Headers @{"Authorization" = "bearer $accessToken"} -Method POST | ConvertFrom-Json

    $submission.fileUploadUrl = $fileUrl;

    $updateSubmissionUrl = "https://manage.devcenter.microsoft.com/v1.0/my/applications/$appid/submissions/$submission.id"
    $submissionJson = ConvertTo-Json $submission 
    $submission = Invoke-WebRequest -Uri $updateSubmissionUrl -Headers @{"Authorization" = "bearer $accessToken"} -Body $submissionJson -Method PUT

    $commitSubmissionUrl = "https://manage.devcenter.microsoft.com/v1.0/my/applications/$appid/submissions/$submission.id/commit"
    $submission = Invoke-WebRequest -Uri $commitSubmissionUrl -Headers @{"Authorization" = "bearer $accessToken"} -Body $submissionJson -Method POST
}

function MakeFlightSubmission($teantId, $clientId, $clientSecret, $flightId)
{
    $postValue = "grant_type=client_credentials&client_id=$clientId&client_secret=$clientSecret&resource=https://manage.devcenter.microsoft.com"
    $token = Invoke-WebRequest -Uri https://login.microsoftonline.com/$tenantId/oauth2/token -Body $postValue -ContentType "application/x-www-form-urlencoded; charset=utf-8" -Method POST | ConvertFrom-Json

    $accessToken = $token.access_token

    Write-Host "accesstoken: $accessToken"

    $createSubmissionUrl = "https://manage.devcenter.microsoft.com/v1.0/my/applications/$appid/flights/$flightId/submissions"
    $submission = Invoke-WebRequest -Uri $createSubmissionUrl -Headers @{"Authorization" = "bearer $accessToken"} -Method POST | ConvertFrom-Json

    $submission.fileUploadUrl = $fileUrl;

    $updateSubmissionUrl = "https://manage.devcenter.microsoft.com/v1.0/my/applications/$appid/flights/$flightId/submissions/$submission.id"
    $submissionJson = ConvertTo-Json $submission 
    $submission = Invoke-WebRequest -Uri $updateSubmissionUrl -Headers @{"Authorization" = "bearer $accessToken"} -Body $submissionJson -Method PUT

    $commitSubmissionUrl = "https://manage.devcenter.microsoft.com/v1.0/my/applications/$appid/flights/$flightId/submissions/$submission.id/commit"
    $submission = Invoke-WebRequest -Uri $commitSubmissionUrl -Headers @{"Authorization" = "bearer $accessToken"} -Body $submissionJson -Method POST
}

#$fileUrl = "";
#$appid = "9wzdncrfjmb6";

#$tenantId = "baa64767-ef44-4db6-a573-9770147f3397"
#$clientId = "2efafcca-cd37-47e1-8a7e-20908e7f1dc4"
#$clientSecret = "IJodayZ/Z7E5vLQeJZH9L9lD7/jUJ9TAQNI9HrAFUno="
#$flightId = "";

#$tenantId = "baa64767-ef44-4db6-a573-9770147f3397"
#$clientId = "2efafcca-cd37-47e1-8a7e-20908e7f1dc4"
#$clientSecret = "+Cdjz+i7Nu4BUhFOip/gW8mjdPzMLWr3PlzOoykMmwM="

#tenant dave
#$tenantId = "61e615f3-161b-4bda-a67a-407317766d1f"
#$clientId = "1d913b52-16ad-411a-a5e6-f09a60d5e1ec"
#$clientSecret = "oTarctYJVHsiJCE9hk+M+gCPVrUABbb/eHLxStXko0k="

$DevCenterEndpoint = Get-ServiceEndpoint -Context $distributedTaskContext -Name $serviceendpoint
$tenantId = $DevCenterEndpoint.Authorization.Parameters.tenantid;
Write-Host "TenantId: $tenantId"

$clientid = $DevCenterEndpoint.Authorization.Parameters.clientid;
Write-Host "ClientId: $clientid"

$clientsecret = $DevCenterEndpoint.Authorization.Parameters.apitoken;
Write-Host "Client Secret: $clientsecret"



if ($flightid){
    Write-Host "Flighted Submission"
    MakeFlightSubmission $tenantid $clientid $clientsecret $flightid
}else{
    Write-Host "NonFlighted Submission"
    MakeSubmission $tenantid $clientid $clientsecret
}