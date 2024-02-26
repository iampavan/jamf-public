#!/bin/bash

# sample code for interacting with the API via Bearer Token :
# https://developer.jamf.com/jamf-pro/docs/jamf-pro-api-overview

url="https://yourserver.jamfcloud.com"
username="yourUsername"
password="yourPassword"

#Variable declarations
bearerToken=""
tokenExpirationEpoch="0"

getBearerToken() {
	response=$(curl -s -u "$username":"$password" "$url"/api/v1/auth/token -X POST)
	bearerToken=$(echo "$response" | plutil -extract token raw -)
	tokenExpiration=$(echo "$response" | plutil -extract expires raw - | awk -F . '{print $1}')
	tokenExpirationEpoch=$(date -j -f "%Y-%m-%dT%T" "$tokenExpiration" +"%s")
}

checkTokenExpiration() {
    nowEpochUTC=$(date -j -f "%Y-%m-%dT%T" "$(date -u +"%Y-%m-%dT%T")" +"%s")
    if [[ tokenExpirationEpoch -gt nowEpochUTC ]]
    then
        echo "Token valid until the following epoch time: " "$tokenExpirationEpoch"
    else
        echo "No valid token available, getting new token"
        getBearerToken
    fi
}

invalidateToken() {
	responseCode=$(curl -w "%{http_code}" -H "Authorization: Bearer ${bearerToken}" $url/api/v1/auth/invalidate-token -X POST -s -o /dev/null)
	if [[ ${responseCode} == 204 ]]
	then
		echo "Token successfully invalidated"
		bearerToken=""
		tokenExpirationEpoch="0"
	elif [[ ${responseCode} == 401 ]]
	then
		echo "Token already invalid"
	else
		echo "An unknown error occurred invalidating the token"
	fi
}

checkTokenExpiration
curl -s -H "Authorization: Bearer ${bearerToken}" $url/api/v1/jamf-pro-version -X GET
checkTokenExpiration
invalidateToken
curl -s -H "Authorization: Bearer ${bearerToken}" $url/api/v1/jamf-pro-version -X GET


# Output :

# No valid token available, getting new token
# {
#   "version" : "11.2.1-t1707143529"
# }Token valid until the following epoch time:  1708981098
# Token successfully invalidated
# {
#   "httpStatus" : 401,
#   "errors" : [ ]
# }