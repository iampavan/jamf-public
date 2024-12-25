#!/bin/bash

###############################################################################
# Name 	:	macOS Unified Logging Private Data Visibility Status Extension Attribute
# 
# Potential Status Results:
# - Enabled
# - Disabled
###############################################################################

export PATH=/usr/bin:/bin:/usr/sbin:/sbin:/usr/libexec

# Variables
# PrivateDataVisibilityStatus="$(sudo log config --status | grep "PRIVATE_DATA")"
PrivateDataVisibilityStatus=$(command log config --status | grep "PRIVATE_DATA")

# scriptName=$(basename "$0")
scriptName="EA - Unified Logging Private Data Visibility Status"

####################################################################################
# FUNCTIONS
####################################################################################

scriptLogging() {
    # Function for logging
    local eventTimestamp
    eventTimestamp=$(date "+%a %b %d %H:%M:%S")
    
    local localHostName
    localHostName=$(scutil --get ComputerName)
    
    local jamfPID
    jamfPID=$(pgrep -ax jamf | grep -v grep | tail -n1)
    
    if [[ -z "$jamfPID" ]]; then
    	# If jamf PID is not found, then use shell PID.
    	jamfPID=$$
    fi
    
    local jamfLog
    jamfLog="/var/log/jamf.log"
    
    # echo "${eventTimestamp}" "${localHostName}" "jamf[${jamfPID}]:" "$1" | tee -a "${jamfLog}"
    echo "${eventTimestamp}" "${localHostName}" "jamf[${jamfPID}]:" "${scriptName} -" "$1" | tee -a "${jamfLog}"
}

DetermineVisibilityStatus() {
	if [[ "$PrivateDataVisibilityStatus" ]]; then
		VisibilityStatus="Enabled"
	else 
		VisibilityStatus="Disabled"
	fi
	echo "<result>$VisibilityStatus</result>"
}

####################################################################################
# MAIN
####################################################################################

scriptLogging "Running..."

DetermineVisibilityStatus

scriptLogging "PRIVATE_DATA = $VisibilityStatus"

exit 0