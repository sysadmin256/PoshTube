Function New-PoshTubeAuth
{
    $ClientID = "265341207630-7mqm6fpa9u3fvq5tucf9i105o33v3sbs.apps.googleusercontent.com"
    $ClientSecret = "Z14UzYv5gIfJmRv890bVFm_w"

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

}