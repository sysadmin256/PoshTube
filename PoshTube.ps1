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

    $URI = "https://accounts.google.com/o/oauth2/token?client_id={0}&client_secret={1}&code={2}&grant_type={3}" -f $ClientID, $ClientSecret, $DeviceCode, $GrantType
    $response1 = Invoke-RestMethod $URI -Method 'POST' -Headers $headers
    $response1 | ConvertTo-Json
}

Function Get-RefreshToken 
{
    Param (
        $ClientID,
        $ClientSecret,
        $RefreshToken,
        $GrantType = "http://oauth.net/grant_type/device/1.0"
    )

    $URI = "https://accounts.google.com/o/oauth2/token?client_id={0}&client_secret={1}&refresh_token={2}&grant_type={3}" -f $ClientID, $ClientSecret, $RefreshToken, $GrantType
    $response1 = Invoke-RestMethod $URI -Method 'POST' -Headers $headers
    $response1 | ConvertTo-Json
}

<#
#Testing
$RequestCode = Get-YoutubeCode -ClientID "265341207630-7mqm6fpa9u3fvq5tucf9i105o33v3sbs.apps.googleusercontent.com"
# Start Request for device
$DeviceCode = step2 -ClientID "265341207630-7mqm6fpa9u3fvq5tucf9i105o33v3sbs.apps.googleusercontent.com" `
      -ClientSecret "Z14UzYv5gIfJmRv890bVFm_w" `
      -DeviceCode $RequestCode.device_code
#>

Function Set-LiveStream 
{
Param (
    $Access_Token
)
    # Make actual API request to schedule stream
    $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $AccessToken = "Bearer {0}" -f $Access_token
    $headers.Add("Authorization", $AccessToken)
    $headers.Add("Content-Type", "text/plain")

    $Sunday = (get-date).AddDays($((7 - (Get-Date).DayOfWeek.value__) % 7))

    $body = @"
    "{
        "snippet":{
            "scheduledStartTime":"$($Sunday.ToString("yyyy"))-$($Sunday.ToString("MM"))-$($Sunday.ToString("dd"))T15:00:00",
            "title":"Woship Service $($Sunday.ToString("MM"))-$($Sunday.ToString("dd"))-$($Sunday.ToString("yyyy"))"
        },
        "status":{
            "privacyStatus":"public"
        }
    }"
"@

    $response3 = Invoke-RestMethod 'https://youtube.googleapis.com/youtube/v3/liveBroadcasts?part=snippet&part=contentDetails&part=status' -Method 'POST' -Headers $headers -Body $body
    $response3 
}

Function Check-Access 
{
Param (
    $ClientID,
    $ClientSecret,
    $device_code
)
    $URI = "https://accounts.google.com/o/oauth2/token?client_id={0}&client_secret={1}&code={2}&grant_type=http://oauth.net/grant_type/device/1.0" -f $ClientID, $ClientSecret, $Device_Code
    $response1 = Invoke-RestMethod $URI -Method 'POST' -Headers $headers
    $response1 
}

Function Save-AuthToken 
{
Param (
    [string]$token
)
    if (-not (test-path "C:\ProgramData\PoshTube")) {
        New-Item "C:\ProgramData\PoshTube" -ItemType Directory -Force
    }
    $Token | ConvertTo-SecureString -AsPlainText -Force | convertfrom-securestring | out-file "C:\ProgramData\PoshTube\AuthToken.json"
}

Function Get-AuthToken 
{
    $SecurePassword = Get-Content "C:\ProgramData\PoshTube\AuthToken.json" | ConvertTo-SecureString
    $UnsecurePassword = (New-Object PSCredential "user",$SecurePassword).GetNetworkCredential().Password
    return $UnsecurePassword
}