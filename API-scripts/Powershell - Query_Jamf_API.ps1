#################
#
# Query_Jamf_API.ps1
#
# Use this PowerShell script to get the "Device Names" & "Hardware Model" from a mobiledevice smartgroup
#
#################
#
# Inspired from : https://macadmins.slack.com/archives/C0EP2SNJX/p1679885073887889
#
#################
#
# To run the script :
# cd "C:\Users\some_user\Desktop\"
# .\Query_Jamf_API.ps1
#
#################
#
# Tip :
# open Powershell as an Admin, then run this command :
# powershell Set-ExecutionPolicy RemoteSigned
#
#################

$jssUser = "xxxxxxxx"
$jssPass = "xxxxxxxx"
$jssUrl = "https://yourserver.yourdomain.com:8443"

# Replace this with the ID number of the smart/static mobile device group 
$mobileDeviceGroupID = 1
$exportPath = "C:\DeviceNames.csv"

# Valid values are "SilentlyContinue" or "Continue", use the latter to turn on verbose output
$verbosePreference = "Continue"

if ($verbosePreference -eq "Continue") {
    Write-Verbose "Hey listen! Verbose mode is on."
    Write-Verbose "If you have thousands of Mobile Devices in your JPRO; you're potentially about to see thousands of verbose web requests using the Jamf API."
    Write-Verbose "Don't freakout!"
    Sleep 10
}

# Function will get a token so that you can use the Jamf API; if one doesn't already exist or the current one has expired or will expire within the next five minutes
function checkAuthToken {
 # https://stackoverflow.com/questions/24672760/powershells-invoke-restmethod-equivalent-of-curl-u-basic-authentication
 # I added the the -or date -ge statement here, previously, if you ran the script in ISE, and didn't run the script again in the 5 mins leading up to token expiry (jamf api 30 min token validity), it wouldn't attempt to get a new token. -BK
 if (!$authTokenData -or $(Get-Date) -ge $authTokenExpireDate) {
  Write-Host 'Getting new authorization token... ' -NoNewline
  $base64creds = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes("${jssUser}:${jssPass}"))
  $script:authTokenData = Invoke-RestMethod -Uri "$jssUrl/api/v1/auth/token" -Headers @{Authorization=("Basic $base64creds")} -Method Post
  $script:authToken = $authTokenData.token
  $script:authTokenExpireDate = Get-Date "$($authTokenData.expires)"
  Write-Host 'Done.'
 }else {
  # Update token if it expires in 5 minutes or less
  if ($(Get-Date).AddMinutes(5) -gt $authTokenExpireDate) {
   Write-Host 'Renewing authorization token... ' -NoNewline
   $script:authTokenData = Invoke-RestMethod -Uri "$jssUrl/api/v1/auth/keep-alive" -Headers $jssApiHeaders -Method Post
   $script:authToken = $authTokenData.token
   $script:authTokenExpireDate = Get-Date "$($authTokenData.expires)"
   Write-Host 'Done.'
  }
 }

 $script:jssApiHeaders = @{
  Authorization="Bearer $authToken"
  Accept="application/json"
 }
}

# Function queries your JSS for Mobile Device's "Hardware Model" data & exports it as csv
function QueryJssMobileDevicesData(){
  $headers = @{
    Authorization = "Bearer $authToken"
    Accept = "text/xml"
  }
  # Get all Mobile Devices
  $script:mobileDeviceGroupUrl = "$jssUrl/JSSResource/mobiledevicegroups/id/$mobileDeviceGroupID"
  $script:mobileDeviceGroup = Invoke-RestMethod -Method Get -Uri $mobileDeviceGroupUrl -Headers $headers
  $script:mobileDeviceIDs = $mobileDeviceGroup.mobile_device_group.mobile_devices.mobile_device.id
   
  # Create an empty array to store the Hardware Model
  $script:hardwarePropertiesArray = @()
   
  foreach ($mobileDevice in $mobileDeviceIDs) {
    $script:mobileDeviceUrl = "$jssUrl/JSSResource/mobiledevices/id/$mobileDevice"
    $script:mobileDeviceFull = Invoke-RestMethod -Method Get -Uri $mobileDeviceUrl -Headers $headers
     
    # Append the hardware properties to the array
    $script:hardwarePropertiesArray += [pscustomobject]@{"Device Name"=$mobileDeviceFull.mobile_device.general.name;"Hardware Model"=$mobileDeviceFull.mobile_device.general.model_display}
  }
  # Export to csv file
  $hardwarePropertiesArray | Export-Csv -Path $exportPath -NoTypeInformation
   
}

# Trigger the function to check token & either get new token or keep-alive a current bearer token from JSS
checkAuthToken

# Trigger the function to request the info & save to CSV
QueryJssMobileDevicesData