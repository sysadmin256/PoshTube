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

Function Step2 
{
    <#
    Gets the initial device request code from Google's API.
    #>
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
 