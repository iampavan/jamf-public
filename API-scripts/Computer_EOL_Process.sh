#!/bin/bash

####################################################################################################

# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#        * Redistributions of source code must retain the above copyright
#         notice, this list of conditions and the following disclaimer.
#      * Redistributions in binary form must reproduce the above copyright
#           notice, this list of conditions and the following disclaimer in the
#           documentation and/or other materials provided with the distribution.
#         * Neither the name of the JAMF Software, LLC nor the
#           names of its contributors may be used to endorse or promote products
#           derived from this software without specific prior written permission.
# THIS SOFTWARE IS PROVIDED BY JAMF SOFTWARE, LLC "AS IS" AND ANY
# EXPRESSED OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL JAMF SOFTWARE, LLC BE LIABLE FOR ANY
# DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
# ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

####################################################################################################

# Free up licenses in your environment and cleanup ABM devices with this API script
# that will unmanage and disown devices in a smart group.
# 
# Set the variables for your environment then, when prompted, select the option to unmanage, 
# disown, or unmanage and disown each device in the smart group.
#
# Ref : https://github.com/zpropheter/API-Tools/blob/main/Computer_EOL_Process.sh

####################################################################################################


# Your custom variables
url="https://yourserver.jamfcloud.com"
username="username"
password="password"
computerGroupIDNumber="smartgroupID"
output=$HOME/Desktop/output.txt

####################################################################################################
# Get bearer token for authentication
getBearerToken() {
	response=$(curl -s -u "$username":"$password" "$url"/api/v1/auth/token -X POST 2>/dev/null)
	bearerToken=$(echo "$response" | plutil -extract token raw -)
	tokenExpiration=$(echo "$response" | plutil -extract expires raw - | awk -F . '{print $1}')
	tokenExpirationEpoch=$(date -j -f "%Y-%m-%dT%T" "$tokenExpiration" +"%s")
}

####################################################################################################
#API BEARER TOKEN Expiration check

checkTokenExpiration() {
	nowEpochUTC=$(date -j -f "%Y-%m-%dT%T" "$(date -u +"%Y-%m-%dT%T")" +"%s")
	if [[ tokenExpirationEpoch -gt nowEpochUTC ]]
	then
		:
	else
		(echo "No valid token available, getting new token")
		getBearerToken
	fi
}

#Variable declarations
bearerToken=""
tokenExpirationEpoch="0"

####################################################################################################
# Get Enrollment Count to make sure disown works
getEnrollmentCount() {
	deviceEnrollments=$(curl -X 'GET' \
	"$url/api//v1/device-enrollments?page=0&page-size=100&sort=id%3Aasc" 2>/dev/null \
	-H 'accept: application/json' \
	-H "Authorization: Bearer $bearerToken")
	#echo "$deviceEnrollments"
	enrollmentCount=$(/usr/bin/plutil -extract totalCount raw -o - - <<< "$deviceEnrollments")
	#echo "Total Enrollments: $enrollmentCount" 
	enrollmentId=$(/usr/bin/plutil -extract "results".0."id" raw -o - - <<< "$deviceEnrollments")
	#echo "Enrollment ID: $enrollmentId" 
	if [[ $enrollmentCount == 1 ]]; then
		continueReset=0
	else
		continueReset=1
	fi
}

####################################################################################################
# Disown the device using serialnumber
disownDevice() {
	deviceDisowning=$(curl -X 'POST' \
	"$url/api/v1/device-enrollments/$enrollmentId/disown" 2>/dev/null \
	-H "accept: application/json" \
	-H "Authorization: Bearer $bearerToken" \
	-H "Content-Type: application/json" \
	-d '{
	"devices": [
		"'$serialnumber'"
	]
}')
	#echo "$deviceDisowning"
	successCode=$(/usr/bin/plutil -extract devices.$serialnumber raw -o - - <<< "$deviceDisowning")
	disownResult=$(echo "$successCode" | grep "NOT_ACCESSIBLE")
	echo "Result of disown command for $computerID is $successCode"
}

####################################################################################################
# Pull the serial number and device ID from the smart group

unmanageComputerGroup() {
	computerGroupCheck=$(curl -X 'GET' \
	"$url/JSSResource/computergroups/id/$computerGroupIDNumber" 2>/dev/null \
	-H 'accept: application/xml' \
	-H "Authorization: Bearer $bearerToken")
	computerIDsInGroup=$(echo "$computerGroupCheck" | xmllint --xpath '/computer_group/computers/computer/id/text()' -)
	serialnumber=$(echo "$computerGroupCheck" | xmllint --xpath '/computer_group/computers/computer/serial_number/text()' -)
	echo "Computer IDs found in Smart Group ID: $computerGroupIDNumber are: $computerIDsInGroup"
	#echo "$serialnumber"
}

####################################################################################################
# Send a command to unmanage the device and if possible, remove the device from ABM/ASM

unManageandDisown() {
	for computerID in $computerIDsInGroup; do
		echo "Removing management from computer ID: $computerID"
		computerDetails=$(curl -H "Authorization: Bearer $bearerToken" -H "Accept: application/xml" -H "Content-type: text/xml" -X POST "$url/JSSResource/computercommands/command/UnmanageDevice/id/$computerID" 2>/dev/null) 
		unmanageResult=$(echo "$computerDetails" | xmllint --xpath '/computer_command/command/name/text()' -)
		unmanageResult2=$(echo "$unmanageResult" | grep "UnmanageDevice")
		if [[ $unmanageResult2 == "UnmanageDevice" ]]; then
			echo "Successfully removed management from  computer ID: $computerID"
			sleep 1
			case $continueReset in
				0)
					disownDevice
					checkTokenExpiration 
				;;
				1)
					echo "Exiting Disown"
				;;
			esac
		else
			echo "Unable to remove management from computer ID: $computerID"
			sleep 1
		fi
	done
}

####################################################################################################
# Just Disown the device

disownArray() {
	for computerID in $computerIDsInGroup; do
		echo "Disowning computer ID: $computerID"
		disownDevice 
  		sleep 1
	done
}

####################################################################################################
# Just UnManage the device

unManageOnly() {
	for computerID in $computerIDsInGroup; do
		echo "Removing management from computer ID: $computerID"
		computerDetails=$(curl -H "Authorization: Bearer $bearerToken" -H "Accept: application/xml" -H "Content-type: text/xml" -X POST "$url/JSSResource/computercommands/command/UnmanageDevice/id/$computerID" 2>/dev/null) 
		unmanageResult=$(echo "$computerDetails" | xmllint --xpath '/computer_command/command/name/text()' -)
		unmanageResult2=$(echo "$unmanageResult" | grep "UnmanageDevice")
		if [[ $unmanageResult2 == "UnmanageDevice" ]]; then
			echo "Successfully removed management from  computer ID: $computerID"
			checkTokenExpiration 
   			sleep 1
		else
			echo "Unable to remove management from computer ID: $computerID"
			checkTokenExpiration 
   			sleep 1
		fi
	done
}





getBearerToken
echo -e "Welcome to the Computer End of Life script.\nPlease select from the options listed below by typing the correlating number:\n1.Unmanage and Disown\n2.Disown Only\n3.Unmanage Only"
read -p "Type your selection here: " userselection
case $userselection in
	1)
		getEnrollmentCount
		unmanageComputerGroup 
		unManageandDisown 
	;;
	2)
		getEnrollmentCount 
		unmanageComputerGroup 
		disownArray
	;;
	3)
		unmanageComputerGroup
		unManageOnly 
	;;
esac















#if [[ $enrollmentCount != 1 ]]; then
#	echo "You have more than one Device Enrollment token configured, this tool does not support Disown for such environments"
#else
#	disownDevice
#	echo "You've been disowned"
#fi

#getComputerManagementId() {
#	computerdevicerecord=$(curl -X 'GET' \
#	"$url/api/v1/computers-inventory-detail/$deviceid" \
#	-H 'accept: application/json' \
#	-H "Authorization: Bearer $bearerToken")
#	computermanagementId=$(/usr/bin/plutil -extract "general"."managementId" raw -o - - <<< "$computerdevicerecord")
#	echo "Management ID: $computermanagementId"
#}
#
#getComputerManagementId 
