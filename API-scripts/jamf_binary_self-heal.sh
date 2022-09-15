#!/bin/bash
#
####################################################################################################
#
# THIS SCRIPT IS NOT AN OFFICIAL PRODUCT OF JAMF SOFTWARE
# AS SUCH IT IS PROVIDED WITHOUT WARRANTY OR SUPPORT
#
# BY USING THIS SCRIPT, YOU AGREE THAT JAMF SOFTWARE
# IS UNDER NO OBLIGATION TO SUPPORT, DEBUG, OR OTHERWISE
# MAINTAIN THIS SCRIPT
#
####################################################################################################
#
# DESCRIPTION
#
# Redeploy Jamf Management Framework

# This method assumes the problematic computer is still has a funtioning MDM framework.
#
# https://developer.jamf.com/jamf-pro/reference/post_v1-jamf-management-framework-redeploy-id
#
# https://snelson.us/2022/08/jamf-binary-self-heal-via-terminal/
# https://www.modtitan.com/2022/02/jamf-binary-self-heal-with-jamf-api.html
#
####################################################################################################

# server information
apiURL="https://url.jamfcloud.com"

# API user authenticaiton
apiUser="apiuser"

salt="xxxxxxxxxxx"
passPhrase="xxxxxxxxxxx"

function DecryptString() {
    # Usage: ~$ DecryptString "Encrypted String" "Salt" "Passphrase"
    echo "${1}" | /usr/bin/openssl enc -aes256 -d -a -A -S "${2}" -k "${3}"
}

apiPassword=$(DecryptString "${4}" "$salt" "$passPhrase")

# Ref : https://github.com/iampavan/Encrypted-Script-Parameters

####################################################################################################

# Obtain Jamf Pro Bearer Token via Basic Authentication
apiBearerToken=$( /usr/bin/curl -X POST --silent -u "${apiUser}:${apiPassword}" "${apiURL}/api/v1/auth/token" | /usr/bin/plutil -extract token raw - )

# Find the UUID of the device
# This command works on macOS Monterey 12.6
udid=$( /usr/sbin/system_profiler SPHardwareDataType | grep "Hardware UUID" | cut -c22-57 )

# Determine the computer's Jamf Pro Computer ID via the computer's UUID (Apple calls it) / UDID (Jamf calls it)
jssID=$( /usr/bin/curl -H "Authorization: Bearer ${apiBearerToken}" -s "${apiURL}"/JSSResource/computers/udid/"${udid}" | xpath -e "/computer/general/id/text()" )

generalComputerInfo=$( /usr/bin/curl -H "Authorization: Bearer ${apiBearerToken}" -H "Accept: text/xml" -sfk "${apiURL}"/JSSResource/computers/id/"${jssID}/subset/General" -X GET )

computerName=$( echo ${generalComputerInfo} | xpath -q -e "/computer/general/name/text()" )
computerSerialNumber=$( echo ${generalComputerInfo} | xpath -q -e "/computer/general/serial_number/text()" ) 

printf "\nSelf-healing the Jamf binary for:\n"
printf "• Name: $computerName\n"
printf "• Serial Number: $computerSerialNumber\n"

printf "Via MDM:\n"
printf "• Server: ${apiURL}\n"
printf "• Computer ID: ${jssID}\n\n"

# Brute-force clear all failed MDM Commands
printf "Brute-force clear all failed MDM Commands …\n"
/usr/bin/curl -H "Authorization: Bearer ${apiBearerToken}" --progress-bar --fail-with-body "${apiURL}/JSSResource/commandflush/computers/id/${jssID}/status/Failed" -X DELETE

# Redeploy Jamf binary
printf "\n\nRedeploy Jamf binary …\n"
/usr/bin/curl -H "Authorization: Bearer ${apiBearerToken}" -H "accept: application/json" --progress-bar --fail-with-body "${apiURL}"/api/v1/jamf-management-framework/redeploy/"${jssID}" -X POST

# Invalidate the Bearer Token
apiBearerToken=$( /usr/bin/curl "${apiURL}/api/v1/auth/invalidate-token" --silent  --header "Authorization: Bearer ${apiBearerToken}" -X POST )
apiBearerToken=""