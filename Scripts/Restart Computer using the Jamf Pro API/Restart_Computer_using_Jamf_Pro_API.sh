#!/bin/bash

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
# This script will send the RestartDevice MDM command.
#
# 1. This script needs to be run on the enduser device directly.
# 2. We fetch the serialNumber
# 3. We then fetch the managementId
# 4. Then send the RESTART_DEVICE command
#
# For testing, HARDCODE the variable "serialNumber"
#
# The restart command by the Jamf Pro API is documented here in the context of managing kernel extensions. 
# If you’re on macOS 11.3 or later, you can also opt in with a “notify user” flag 
# that makes the process less jarring to a user :
# 
# https://learn.jamf.com/bundle/technical-articles/page/Managing_Legacy_Kernel_Extensions_in_macOS_Using_Jamf_Pro.html#ariaid-title5
# 
####################################################################################################

jamfProUrl='https://yourserver.jamfcloud.com'
username="JAMF_PRO_USERNAME"
password='JAMF_PRO_PASSWORD'
bearerToken=''

# Fetches a fresh bearer token via the Jamf Pro API
# Or returns the existing bearer token if it's still valid
getBearerToken() {
	# Check if the bearer token is already set
  if [ -z "$bearerToken" ]; then
    # Get a new bearer token from the Jamf Pro API
    response=$(curl -s -u "$username":"$password" "$jamfProUrl/api/v1/auth/token" -X POST -H 'Accept: application/json')
    # Save the new bearer token to the bearerToken variable
    bearerToken=$(awk -F '" : "' '/token/ { print substr($2, 1, length($2)-2) }' <<<"$response")

    # Return the new bearer token
    echo "$bearerToken"
  else
    # Otherwise, just return the existing bearer token
    echo "$bearerToken"
  fi
}

# Fetches the computer ManagementID based on the ComputerID provided as input
getManagementID() {
  # Get a fresh bearer token from the function above
  apiToken=$(getBearerToken)

  # Fetch a list of all computers in Jamf Pro and their details
  response=$(curl -s --location -X GET "$jamfProUrl/api/preview/computers?page=0&page-size=2000" -H "authorization: Bearer $apiToken" -H 'Accept: application/json')

    #   # Extract the `managementId` from the response for the computer ID provided as input
    #   # Eg : /path/to/script "1234"
    #   echo -n "$response" | grep -i --color=never "\"id\" : \"$1\"" -A27 | awk -F'" : "' '/managementId/ { print $2 }' | sed 's/",$//'

  # Extract the `managementId` from the response for the computer with the ID provided as input
  managementIdValue=$(echo -n "$response" | grep -i --color=never "\"serialNumber\" : \"$serialNumber\"" -A27 | awk -F'" : "' '/managementId/ { print $2 }' | sed 's/",$//')

  echo "managementId of the device = $managementIdValue"
}

SendMDMcommand() {

    curl --location --request POST "$jamfProUrl/api/preview/mdm/commands" \
    --header "Authorization: Bearer $apiToken" \
    --header 'Content-Type: application/json' \
    --data-raw '{
        "clientData": [
            {
                "managementId": "'$managementIdValue'",
                "clientType": "COMPUTER"
            }
        ],
        "commandData": {
            "commandType": "RESTART_DEVICE",
            "rebuildKernelCache": "false",
            "notifyUser": "true"
        }
    }'
}


serialNumber=$(ioreg -c IOPlatformExpertDevice -d 2 | awk -F\" '/IOPlatformSerialNumber/{print $(NF-1)}')
# serialNumber='ZZZ0J4MPPP'

echo "Serial number of the device = $serialNumber"

getManagementID
SendMDMcommand