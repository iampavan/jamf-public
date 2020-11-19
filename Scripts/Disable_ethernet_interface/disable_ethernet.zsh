#!/bin/zsh
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
# This script will make all the Network Interfaces Inactive except for Wi-Fi.
#
# Tested on macOS 10.15.6, 11.0.1
####################################################################################################

while read networkService; do
	if ! [[ ${networkService} =~ .*Wi-Fi.* ]]; then
		networksetup -setnetworkserviceenabled "${networkService}" off
	fi
done < <( networksetup -listnetworkserviceorder | awk '/^\([0-9]/{$1 ="";gsub("^ ","");print}' )

# Then add that in a script, and launch the script by adding
# <key>WatchPaths</key><string>/Library/Preferences/SystemConfiguration</string>
# in the launchDemon



