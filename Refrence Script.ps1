# Get access token for app
$response = Invoke-RestMethod 'https://accounts.google.com/o/oauth2/device/code?client_id=265341207630-7mqm6fpa9u3fvq5tucf9i105o33v3sbs.apps.googleusercontent.com&scope=https://www.googleapis.com/auth/youtube' -Method 'POST' -Headers $headers
$response #| ConvertTo-Json

#Auth prompt for user
$URI = "https://accounts.google.com/o/oauth2/token?client_id=265341207630-7mqm6fpa9u3fvq5tucf9i105o33v3sbs.apps.googleusercontent.com&client_secret=Z14UzYv5gIfJmRv890bVFm_w&code={0}&grant_type=http://oauth.net/grant_type/device/1.0" -f $DeviceCode.device_code
$response1 = Invoke-RestMethod $URI -Method 'POST' -Headers $headers
$response1 | ConvertTo-Json

# Add prompt here to open URL and have user authenticate


# Make actual API request to schedule stream
$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$AccessToken = "Bearer {0}" -f $response1.access_token
$headers.Add("Authorization", $AccessToken)
$headers.Add("Content-Type", "text/plain")

$body = "{`"snippet`":{`"scheduledStartTime`":`"2021-05-08T18:00:00`",`"title`":`"This is a test`"},`"status`":{`"privacyStatus`":`"private`"}}"

$response3 = Invoke-RestMethod 'https://youtube.googleapis.com/youtube/v3/liveBroadcasts?part=snippet&part=contentDetails&part=status' -Method 'POST' -Headers $headers -Body $body
$response3 | ConvertTo-Json

#The API returns an HTTP 401 response code (Unauthorized) if you submit a request to access a protected resource with an access token that is expired, bogus, improperly scoped, or invalid for some other reason.


#Refresh Token
$RefreshToken = $Response1.refresh_token
$response = Invoke-RestMethod "https://accounts.google.com/o/oauth2/token?client_id=265341207630-7mqm6fpa9u3fvq5tucf9i105o33v3sbs.apps.googleusercontent.com&client_secret=Z14UzYv5gIfJmRv890bVFm_w&refresh_token=$RefreshToken&grant_type=refresh_token" -Method 'POST' -Headers $headers
$response | ConvertTo-Json