#!/bin/bash

#hardcode our Jamf Pro URL for the script
jamfProURL="https://url.jamfcloud.com"

#optionally hardcode the Jamf Pro username and password
jamfProUser=""
jamfProPassword=""

#generate a Bearer Token and set it as a variable
bearerTokenFull=$(/usr/bin/curl -s -u "$jamfProUser:$jamfProPassword" "$jamfProURL"/api/v1/auth/token -X POST)

#parse the json with JavaScript to get just the token
#https://richard-purves.com/2021/12/09/jamf-pro-api-for-fun-and-profit/
bearerToken=$(/usr/bin/osascript -l 'JavaScript' -e "JSON.parse(\`$bearerTokenFull\`).token")

#read JPRO Activation Code
# curl -sk -H "authorization: Bearer ${bearerToken}" -H "content-type: text/xml" "$jamfProURL"/JSSResource/activationcode -X GET

#change JPRO Activation Code
#https://gist.github.com/talkingmoose/1533e8268b89491c1a67ef0ffbafd774
# XML data to upload
THExml="<activation_code>
  <organization_name>XXXXXXXXXXX</organization_name>
  <code>YYYY-YYYY-YYYY-YYYY</code>
</activation_code>"

#flattened XML
flatXML=$( /usr/bin/xmllint --noblanks - <<< "$THExml" )

#API submission command
curl -sk -H "authorization: Bearer ${bearerToken}" -H "content-type: text/xml" "$jamfProURL"/JSSResource/activationcode -X PUT --data "$flatXML"

exit 0