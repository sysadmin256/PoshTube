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