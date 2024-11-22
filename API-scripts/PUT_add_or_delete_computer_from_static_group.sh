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
# 
# Add or remove a computer from a static group
#
# Classic API endpoint:
# - /JSSResource/computergroups/id/{id}
# https://developer.jamf.com/jamf-pro/reference/updatecomputergroupbyid
#       OR
# - /JSSResource/computergroups/name/{name}
# https://developer.jamf.com/jamf-pro/reference/updatecomputergroupbyname
# 
# privileges required to interact with an endpoint
# https://developer.jamf.com/jamf-pro/docs/privileges-and-deprecations
# 
####################################################################################################
# 
# Another example: https://github.com/robjschroeder/Jamf-API-Scripts/blob/main/api-AddComputerToStaticGroup.sh
# 
####################################################################################################

# url="$4"              # Parameter 4 - JPRO URL
# client_id="$5"        # Parameter 5 - API Client
# client_secret="$6"    # Parameter 6 - API Secret
# static_group_id="$7"  # Parameter 7 - Static Group ID

url="https://yourserver.jamfcloud.com"
client_id="your-client-id"
client_secret="yourClientSecret"

static_group_id="GroupID#Here" # JPRO Static Group Information

api_endpoint="JSSResource/computergroups/id"

serial_number=$(ioreg -c IOPlatformExpertDevice -d 2 | awk -F\" '/IOPlatformSerialNumber/{print $(NF-1)}')

getAccessToken() {
    response=$(curl --silent --location --request POST "${url}/api/oauth/token" \
        --header "Content-Type: application/x-www-form-urlencoded" \
        --data-urlencode "client_id=${client_id}" \
        --data-urlencode "grant_type=client_credentials" \
        --data-urlencode "client_secret=${client_secret}")
    access_token=$(echo "$response" | plutil -extract access_token raw -)
    token_expires_in=$(echo "$response" | plutil -extract expires_in raw -)
    token_expiration_epoch=$(($current_epoch + $token_expires_in - 1))
}

checkTokenExpiration() {
    current_epoch=$(date +%s)
    if [[ token_expiration_epoch -ge current_epoch ]]
    then
        echo "Token valid until the following epoch time: " "$token_expiration_epoch"
    else
        echo "No valid token available, getting new token"
        getAccessToken
    fi
}

invalidateToken() {
    responseCode=$(curl -w "%{http_code}" -H "Authorization: Bearer ${access_token}" $url/api/v1/auth/invalidate-token -X POST -s -o /dev/null)
    if [[ ${responseCode} == 204 ]]
    then
        echo "Token successfully invalidated"
        access_token=""
        token_expiration_epoch="0"
    elif [[ ${responseCode} == 401 ]]
    then
        echo "Token already invalid"
    else
        echo "An unknown error occurred invalidating the token"
    fi
}

checkTokenExpiration

# Add computer to a group
xmlData="<computer_group>
          <computer_additions>
            <computer>
              <serial_number>${serial_number}</serial_number>
            </computer>
          </computer_additions>
        </computer_group>"

/usr/bin/curl --request PUT \
    --header "Authorization: Bearer $access_token" \
    "${url}/${api_endpoint}/${static_group_id}" \
    --header "Content-Type: application/xml" \
    --data "$xmlData"

# # Delete computer from a group
# xmlData="<computer_group>
#           <computer_deletions>
#             <computer>
#               <serial_number>${serial_number}</serial_number>
#             </computer>
#           </computer_deletions>
#         </computer_group>"

# /usr/bin/curl --request PUT \
#     --header "Authorization: Bearer $access_token" \
#     "${url}/${api_endpoint}/${static_group_id}" \
#     --header "Content-Type: application/xml" \
#     --data "$xmlData"

invalidateToken

exit 0
