#!/bin/bash
# set -x

# This script imports a list of Jamf Pro ID numbers from a plaintext file 
# and uses that information to generate a report about the matching computers serial numbers.

url="https://yourserver.jamfcloud.com"
username="yourUsername"
password="yourPassword"

deviceList="/Users/praju16/Downloads/DMZ-bbVPNdevices.txt"

outfile="/tmp/macStaticgroupAPI.txt"

#Check if file exists. If it does, remove it, we'll remake a new one later
if [ -f "/tmp/macStaticgroupAPI.txt" ]; then
	rm /tmp/macStaticgroupAPI.txt
fi

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


#Read CSV into array
IFS=$'\n' read -d '' -r -a deviceIDs < $deviceList

length=${#deviceIDs[@]}

for ((i=0; i<$length;i++));
do
	deviceid=$(echo "${deviceIDs[$i]}" | sed 's/,//g' | tr -d '\r\n')
	# echo "deviceid = $deviceid"
	# ComputerRecord=$(/usr/bin/curl -sfu "$username:$password" "${url}/JSSResource/computers/id/$deviceid" -H "Accept: application/xml" 2>/dev/null)
	ComputerRecord=$(/usr/bin/curl -sf --header "Authorization: Bearer ${bearerToken}" "${url}/JSSResource/computers/id/$deviceid" -H "Accept: application/xml" 2>/dev/null)
	SerialNumber=$(echo "$ComputerRecord" | xmllint --xpath '//computer/general/serial_number/text()' - 2>/dev/null)
	echo "$deviceid - $SerialNumber"
	echo >> $outfile "$deviceid - $SerialNumber"
done


checkTokenExpiration
invalidateToken
