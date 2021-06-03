$ClientID = "265341207630-7mqm6fpa9u3fvq5tucf9i105o33v3sbs.apps.googleusercontent.com"
$ClientSecret = "Z14UzYv5gIfJmRv890bVFm_w"

$DeviceCode = Get-YoutubeCode -ClientID $ClientID
$DeviceCode
$Counter = 0
do {
    start-sleep -Seconds 5
    $Counter++
    $SigninStatus = Get-SigninCode -ClientID $ClientID -ClientSecret $ClientSecret -DeviceCode $($DeviceCode.device_code)
    $SigninStatus | ConvertFrom-Json
} while ((($SigninStatus | ConvertFrom-Json).error -eq "authorization_pending") -or ( $Counter -ge 20))


