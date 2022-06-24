#!/bin/bash

#hardcode our Jamf Pro URL for the script
jamfProURL="https://url.jamfcloud.com"

#optionally hardcode the Jamf Pro username and password
jamfProUser=""
jamfProPassword=""

#if we didn't hardcode the Jamf Pro username, prompt the user for the Jamf Pro username
if [[ -z $jamfProUser ]]; then
	read -p "Please enter your Jamf Pro user account : " jamfProUser
fi

#if we didn't hardcode the Jamf Pro password, prompt the user for the Jamf Pro password
if [[ -z $jamfProPassword ]]; then
	read -p "Please enter your Jamf Pro password : " -s jamfProPassword
fi

#generate a Bearer Token and set it as a variable
bearerTokenFull=$(/usr/bin/curl -s -u "$jamfProUser:$jamfProPassword" "$jamfProURL"/api/v1/auth/token -X POST)

#parse the json with JavaScript to get just the token
#https://richard-purves.com/2021/12/09/jamf-pro-api-for-fun-and-profit/
bearerToken=$(/usr/bin/osascript -l 'JavaScript' -e "JSON.parse(\`$bearerTokenFull\`).token")

echo "$bearerToken"

# Example usage
#curl -sk -H "authorization: Bearer ${bearerToken}" -H "content-type: text/xml" "$jamfProURL"/JSSResource/activationcode -X GET