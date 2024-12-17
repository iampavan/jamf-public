#!/bin/bash

####################################################################################################
# 
# Description
# 
# This is to disable and re-enable RecurringCheckIn
#
####################################################################################################
#
# Acknowledgements
# 
# Jamf Migrate
# https://www.jamf.com/blog/jamf-migrate/
#
####################################################################################################

export PATH=/usr/bin:/bin:/usr/sbin:/sbin:/usr/libexec
# export PATH=/usr/bin:/bin:/usr/sbin:/sbin:/usr/libexec:/usr/local/jamf/bin

# scriptName=$(basename "$0")

readonly scriptName=$(basename "${0%.*}")
readonly scriptVersion="2025.01.001"

####################################################################################
# FUNCTIONS
####################################################################################

function scriptLogging {
    
    local eventTimestamp
    eventTimestamp=$(date "+%a %b %d %H:%M:%S")
    
    local localHostName
    localHostName=$(scutil --get ComputerName)
    
    local jamfPID
    jamfPID=$(pgrep -ax jamf | grep -v grep | tail -n1)
    
    if [[ -z "$jamfPID" ]]; then
    	# echo "jamf PID not found. Checking JamfDaemon PID..."
     	jamfPID=$(pgrep JamfDaemon)

	if [[ -z "$jamfPID" ]]; then
        	# echo "JamfDaemon PID also not found."
        	jamfPID=$$ # Using shell PID.
     	fi
    fi
    
    local jamfLog
    jamfLog="/var/log/jamf.log"
    
    # echo "${eventTimestamp}" "${localHostName}" "jamf[${jamfPID}]:" "$1" | tee -a "${jamfLog}"
    echo "${eventTimestamp}" "${localHostName}" "jamf[${jamfPID}]:" "${scriptName} -" "$1" | tee -a "${jamfLog}"
}


function disableRecurringCheckIn {

	if [[ $( launchctl list | grep com.jamfsoftware.task.E ) ]]; then
	    scriptLogging "Disabling Recurring Check-in"
	    launchctl bootout system "/Library/LaunchDaemons/com.jamfsoftware.task.1.plist"
	fi
}


function reloadCheckIn {

	if [[ ! $( launchctl list | grep com.jamfsoftware.task.E ) ]]; then
	    scriptLogging "Enabling Recurring Check-in"
	    launchctl bootstrap system "/Library/LaunchDaemons/com.jamfsoftware.task.1.plist"
	fi
}

####################################################################################
# MAIN LOGIC
####################################################################################

loggedInUser=$( /usr/bin/stat -f %Su /dev/console )

if [[ "$loggedInUser" == "root" ]]; then
    scriptLogging "No user logged in, exiting"
    exit 0
else
    disableRecurringCheckIn
fi

# ....
# ....
# ....

reloadCheckIn
