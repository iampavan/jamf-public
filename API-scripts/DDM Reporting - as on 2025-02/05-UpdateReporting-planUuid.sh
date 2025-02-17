#!/bin/bash

# set -x

# Adapted from : https://github.com/zpropheter/API-Tools/blob/main/UpdateReporting

#############################################################################

#A tool to help admins quickly see the latest update status for all devices in their fleet.
#As always, test in test servers, not in prod.
#File path for exported CSV
finalCSVOutput="/$HOME/Downloads/new.csv"

jsonFilePathTemp="/tmp/Update_Reporting/AllUpdates.json"
jsonFilePath="/tmp/Update_Reporting/AllUpdatesFinal.json"
jsonScratchpad="/tmp/Update_Reporting/scratchpad.json"
csvFilePath="/tmp/Update_Reporting/preliminaryCSV.csv"

outfile="/tmp/Update_Reporting/Individual_failures.txt"

#############################################################################
# #API Creds
# #Get these right first or you could lock yourself out as it loops through, still need to add smart logic for token, otherwise it can run for 401 pages since it sees that as the max page count
# username="username"
# password="password"
# url="https://server.jamfcloud.com"

#API Creds
username=""
password=""
url=""

#############################################################################
#Bearer Token Auth
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
		# echo "Token valid until the following epoch time: " "$tokenExpirationEpoch"
		echo ""
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

#############################################################################
#Cleanup from previous runs

rm -rf /tmp/Update_Reporting/
mkdir /tmp/Update_Reporting/

#############################################################################
#Get Bearer Token
getBearerToken 
#############################################################################
pageSize="100"
page="0"
#Pull all devices plans from newest to oldest
initialUpdatePlanCheck=$(curl -X 'GET' \
"$url/api/v1/managed-software-updates/plans?page=$page&page-size=$pageSize&sort=planUuid%3Adesc" \
-H 'accept: application/json' \
-H "Authorization: Bearer $bearerToken")

#echo $initialUpdatePlanCheck
echo $initialUpdatePlanCheck > $jsonFilePath

#JQ Filter Function on output json from API calls, Device_ID must always be first for the cursed CSV array to run. If you don't care about that then go nuts.
#the first [] sets the column headers and the second [] pulls from the json and sets under each header in order that the columns were specified. If you change this, also change line 116 to match
jq -r '["Device_ID","Computer_or_Mobile_Device","updateAction","status","Error_Reason","planUuid"], (.results[] | [.device.deviceId, .device.objectType, .updateAction, .status.state, .status.errorReasons[0], .planUuid]) | @csv' "$jsonFilePath" > $csvFilePath
jq -r '.'  "$jsonFilePath" > $jsonFilePathTemp && mv $jsonFilePathTemp $jsonFilePath

getCountOfResults=$(jq -r -c '.[]' <<< "$initialUpdatePlanCheck" | awk '{print $1}')
filterGetCountOfResults=$(awk -F, 'NR==1{print $1}' <<<"$getCountOfResults")

#Do some math to check if we need to keep going up from page size

#if pagesize/filtergetcountofresults le=1 then +1 page
#WARNING 'expr' will round to nearest whole number
realPageNumber=$(expr $page + 1)
#echo $realPageNumber
totalPossibleResults=$(expr $pageSize \* $realPageNumber)
#echo $totalPossibleResults

#Make a for loop that goes through multiple pages if found and get next page if needed
while [ $totalPossibleResults -lt $filterGetCountOfResults ]; do
	#Testing reporting, can comment out if not desired
	echo "more update results pending, fetching now"
	((page++))
	realPageNumber=$(expr $page + 1)
	#Testing reporting, can comment out if not desired, should always start at 2 since page 1 already ran
	echo "current real page number is $realPageNumber"
	totalPossibleResults=$(expr $pageSize \* $realPageNumber)
	#Testing reporting, can comment out if not desired, your page * real page should be less than this value if it's still running
	echo "total possible results are $filterGetCountOfResults"
	checkTokenExpiration 
	UpdatePlanCheck=$(curl -s -X 'GET' \
	"$url/api/v1/managed-software-updates/plans?page=$page&page-size=$pageSize&sort=planUuid%3Adesc" \
	-H 'accept: application/json' \
	-H "Authorization: Bearer $bearerToken")
	echo $UpdatePlanCheck > $jsonScratchpad
	#JQ Filter Function on output json from API calls, then adds it to the existing CSV from the first call. Updates to the JQ filter here should match line 81
	#Don't make column headers here or it'll create more entries as the CSV builds, just the data should be mimicked
	jq -r '.results[] | [.device.deviceId, .device.objectType, .updateAction, .status.state, .status.errorReasons[0], .planUuid] | @csv' "$jsonScratchpad" >> $csvFilePath
done


# #A cursed for loop where Bash edits a CSV file. There's got to be a better way to do this, but it's not something I can figure out currently.
# #Since the pages of results return by most recent to least recent, the function loops through the initial CSV and skips anything that's already been reported into it so you can just get the latest status.
# #Could be problematic if admins send multiple plans out with overlapping scope as the "existing plan in progress" could be the latest report.
# readCSVFile=$(cat "$csvFilePath")
# for line in $readCSVFile;
# do
# 	printCurrentDeviceID=$(grep -Eiow '^"[0-9]+"' <<< "${line}")
# 	checkForId=$(cat "/tmp/Update_Reporting/deviceIdList.txt")
# 	checkForIDAlreadyRan=$(grep "$printCurrentDeviceID" <<< $checkForId)
# 	if [[ $checkForIDAlreadyRan != "" ]]; then
# 		break
# 	else
# 		echo $printCurrentDeviceID >> /tmp/Update_Reporting/deviceIdList.txt
# 		echo $line >> $finalCSVOutput
# 	fi
# done


# Read the CSV file line by line, skipping the header
tail -n +2 "$csvFilePath" | while IFS=, read -r device_id type action status error_reason planUuid; do
    # Remove quotes and trim whitespace/newlines
    device_id=$(echo "$device_id" | tr -d '"')
    error_reason=$(echo "$error_reason" | tr -d '"' | xargs)  # Trim spaces/newlines
    plan_Uuid=$(echo "$planUuid" | tr -d '"' | xargs)  # Trim spaces/newlines

    # echo "Device_ID = $device_id"
    # echo "error_reason = $error_reason"

    # Check if the error reason matches exactly
    if [[ "$error_reason" == *"FAILURE_REASON_RECEIVED"* ]]; then
        echo "Device with FAILURE_REASON_RECEIVED: $device_id and planUuid = $plan_Uuid"
        checkTokenExpiration

		curl_response_2=$(curl -s -X 'GET' \
		"$url/api/v1/managed-software-updates/plans/${plan_Uuid}/events" \
		-H 'accept: application/json' \
		-H "Authorization: Bearer $bearerToken")

        failureReason=$(echo $curl_response_2 | jq '.events' | tr -d \")

        if [[ $(echo $curl_response_2 | jq '.events' | tr -d \") =~ "SUMacControllerError" ]]; then
            echo >> $outfile "deviceid = $device_id --> failureReason = $failureReason"
        fi
    fi
done

