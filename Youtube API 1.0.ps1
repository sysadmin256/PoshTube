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
        $GrantType = "refresh_token"
    )

    $URI = "https://accounts.google.com/o/oauth2/token?client_id={0}&client_secret={1}&refresh_token={2}&grant_type={3}" -f $ClientID, $ClientSecret, $RefreshToken, $GrantType
    try {
        $response1 = Invoke-RestMethod $URI -Method 'POST' -Headers $headers -ErrorAction Stop
    }
    catch {
        $response1 = "Fail"
    }
    $response1 
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
    $headers.add("Accept", "application/json")
    $headers.Add("Content-Type", "application/json")

    $Sunday = (get-date).AddDays($((7 - (Get-Date).DayOfWeek.value__) % 7))
    #{"snippet":{"scheduledStartTime":"2021-06-20T15:00:00","title":"Woship Service 06-20-2021"},"status":{"privacyStatus":"private"}}
    $body = @"
{
    "snippet":{
        "scheduledStartTime":"$($Sunday.ToString("yyyy"))-$($Sunday.ToString("MM"))-$($Sunday.ToString("dd"))T15:00:00",
        "title":"Woship Service $($Sunday.ToString("MM"))-$($Sunday.ToString("dd"))-$($Sunday.ToString("yyyy"))"
    },
    "status":{
        "privacyStatus":"public"
    }
}
"@

    Try {     
        $response3 = Invoke-RestMethod 'https://youtube.googleapis.com/youtube/v3/liveBroadcasts?part=snippet&part=contentDetails&part=status' -Method 'POST' -Headers $headers -Body $body -ErrorAction Stop -ErrorVariable Error1
        #$response3 = Invoke-RestMethod 'https://youtube.googleapis.com/youtube/v3/liveBroadcasts?part=snippet&part=contentDetails&part=status' -Method 'POST' -Headers $headers -Body '{"snippet":{"scheduledStartTime":"2021-06-20T15:00:00","title":"Woship Service 06-20-2021"},"status":{"privacyStatus":"private"}}' -ErrorAction Stop -ErrorVariable Error1
    }
    catch {
        $response3 = "Fail"
    }
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
    if (test-path "C:\ProgramData\PoshTube\AuthToken.json") {
        $SecurePassword = Get-Content "C:\ProgramData\PoshTube\AuthToken.json" | ConvertTo-SecureString
        $UnsecurePassword = (New-Object PSCredential "user",$SecurePassword).GetNetworkCredential().Password
        return $UnsecurePassword
    } else {
        return "Fail"
    }
}

Function New-PoshTubeAuth
{
Param (
    $ClientID = "265341207630-7mqm6fpa9u3fvq5tucf9i105o33v3sbs.apps.googleusercontent.com",
    $ClientSecret = "Z14UzYv5gIfJmRv890bVFm_w"
)
    $DeviceCode = Get-YoutubeCode -ClientID $ClientID
    $DeviceCode

    start-process "chrome.exe" -ArgumentList $($DeviceCode.verification_url)

    set-clipboard $DeviceCode.User_Code

    Add-Type -AssemblyName PresentationCore,PresentationFramework
    $msgBody = "Please enter this device code: `r`n{0} `r`n`r`nIt's also on the clipboard." -f $DeviceCode.User_Code
    [System.Windows.MessageBox]::Show($msgBody)

    $Counter = 0
    do {
        start-sleep -Seconds 5
        $Counter++
        $SigninStatusjson = Get-SigninCode -ClientID $ClientID -ClientSecret $ClientSecret -DeviceCode $($DeviceCode.device_code)
        $SigninStatus = $SigninStatusjson | ConvertFrom-Json
    } while (($SigninStatus.error -eq "authorization_pending") -or ( $Counter -ge 20))

    if ($SigninStatus.error) {
        throw $SigninStatus.error
    }

    #Save Key
    Save-AuthToken -token $SigninStatusjson
    Return $SigninStatusjson
}

Function Schedule-LiveStream
{
Param (
    $ClientID = "265341207630-7mqm6fpa9u3fvq5tucf9i105o33v3sbs.apps.googleusercontent.com",
    $ClientSecret = "Z14UzYv5gIfJmRv890bVFm_w"
)
    $AuthTokenJson = Get-AuthToken
    if ($AuthTokenJson -eq "Fail") {
        $AuthTokenJson = New-PoshTubeAuth
    }
    $AuthToken = $AuthTokenJson | ConvertFrom-Json
    $SetLive = Set-LiveStream -Access_Token $AuthToken.access_token
    if ($SetLive -eq "Fail") {
        $RefreshedTokenJson = Get-RefreshToken -ClientID $ClientID -ClientSecret $ClientSecret -RefreshToken $AuthToken.refresh_token
        if ($RefreshedTokenJson -eq "Fail") {
            New-PoshTubeAuth
            $AuthToken = $AuthTokenJson | ConvertFrom-Json
            $SetLive = Set-LiveStream -Access_Token $AuthToken.access_token
        }
        else {
            Save-AuthToken -token $RefreshedTokenJson
            $AuthToken = $RefreshedTokenJson | ConvertFrom-Json
            $SetLive = Set-LiveStream -Access_Token $AuthToken.access_token 
        }
    }
    if ($SetLive -eq "Fail") {
        Throw "Unable to complete the request.  Please setup the stream manually"
    }
    Set-VideoMeta -ID $SetLive.id -Title $SetLive.snippet.title -Access_token $AuthToken.access_token 
    return $SetLive

}

Function Set-VideoMeta
{
Param (
    $ID,
    $Title,
    $Access_token,
    $ClientID = "265341207630-7mqm6fpa9u3fvq5tucf9i105o33v3sbs.apps.googleusercontent.com",
    $ClientSecret = "Z14UzYv5gIfJmRv890bVFm_w"
)

# Make actual API request to schedule stream
    $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $AccessToken = "Bearer {0}" -f $Access_token
    $headers.Add("Authorization", $AccessToken)
    $headers.add("Accept", "application/json")
    $headers.Add("Content-Type", "application/json")

        $body = @"
{
    "id":"$ID",
    "snippet":{
        "categoryId":"29",
        "title":"$Title"
    }
}
"@
#$Body = '{"id":"TCgL_XiSuZY","snippet":{"categoryId":"29","title":"Chapel Media"}}'

    Try {     
        $response = Invoke-RestMethod 'https://youtube.googleapis.com/youtube/v3/videos?part=snippet' -Method 'Put' -Headers $headers -Body $body -ErrorAction Stop -ErrorVariable Error1
    }
    catch {
        $response = "Fail"
    }
    $response

}