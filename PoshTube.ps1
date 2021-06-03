Function Get-YoutubeCode 
{
    <#
    Gets the initial device request code from Google's API.
    #>
    Param (
        $ClientID,
        $Scope = "scope=https://www.googleapis.com/auth/youtube"
    )
    $RequestURI = "https://accounts.google.com/o/oauth2/device/code?client_id={0}&{1}" -f $ClientID, $Scope
    $response = Invoke-RestMethod $RequestURI -Method 'POST' -Headers $headers
    Return $response 
}

Function Get-SigninCode 
{
    Param (
        $ClientID,
        $ClientSecret,
        $DeviceCode,
        $GrantType = "http://oauth.net/grant_type/device/1.0"
        
    )
    <#
    # May need logic here for refresh token.  Check response and supply refresh token if it's a valid option.
    Open browser, display code to user
    Loop here until the user authenticates
    Unauthenticated return: 
        PS C:\Admin\Repo\PoshTube> $DeviceCode
        {
            "error":  "authorization_pending",
            "error_description":  "Precondition Required"
        }
    Authenticated return: 
        PS C:\Admin\Repo\PoshTube> $DeviceCode
        {
            "access_token":  "ya29.a0AfH6SMCk69b4vjpZI1p7uDEfnqKMaP1Npxd8JD9Tv-CnwkxdT58p9n1mH612wnfxqAy2CZcNO3VArr4qPokt9HeLpbqwCCPiSLG9A4YSO4F089K8UzS9neTrjlTjgtKHbKD2AQyeeGQCRAR62ZtzA-BEzRhC",
            "expires_in":  3599,
            "refresh_token":  "1//04XQEEhlf98chCgYIARAAGAQSNwF-L9Irsw1ADS1RnM9uXIF8TAS7OO9cs55XjqoZAP8Z3UwHzc9sn7oNlRPH_o1WJpDi_QSZHUc",
            "scope":  "https://www.googleapis.com/auth/youtube",
            "token_type":  "Bearer"
        }
    Save the access token and the refresh token for later use
    #>

    #This code checks the status shown above
    $URI = "https://accounts.google.com/o/oauth2/token?client_id={0}&client_secret={1}&code={2}&grant_type={3}" -f $ClientID, $ClientSecret, $DeviceCode, $GrantType
    $response1 = Invoke-RestMethod $URI -Method 'POST' -Headers $headers
    $response1 | ConvertTo-Json
}


#Testing
$RequestCode = Get-YoutubeCode -ClientID "265341207630-7mqm6fpa9u3fvq5tucf9i105o33v3sbs.apps.googleusercontent.com"
# Start Request for device
$DeviceCode = step2 -ClientID "265341207630-7mqm6fpa9u3fvq5tucf9i105o33v3sbs.apps.googleusercontent.com" `
      -ClientSecret "Z14UzYv5gIfJmRv890bVFm_w" `
      -DeviceCode $RequestCode.device_code

 
