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
# Script to update macOS (using API for Apple Silicon devices) from Jamf Self-Service
#
####################################################################################################

# Variables

# $4 = API Username
# $5 = API Password
# $6 = JSS URL

Notify=/Library/Application\ Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper

processor=$(uname -m)

# Run software update

"$Notify" \
-windowType hud \
-lockHUD \
-title "macOS Updates" \
-heading "macOS Update installing" \
-description "macOS updates are now being installed.
This process can take up to one hour, so please do not turn off your device during this time.
Your device will reboot by itself once completed." \
-icon /System/Library/PreferencePanes/SoftwareUpdate.prefPane/Contents/Resources/SoftwareUpdate.icns &

if [[ $processor == arm64 ]]; then
    echo "Mac is M1"
    serial=$(system_profiler SPHardwareDataType | awk '/Serial Number/{print $4}')
    ID=$(curl -u $4:$5 -X GET "https://$6/JSSResource/computers/serialnumber/$serial" | tr '<' '\n' | grep -m 1 id | tr -d 'id>')
    curl -u $4:$5 -X POST "https://$6/JSSResource/computercommands/command/ScheduleOSUpdate/action/install/id/$ID"
else
    echo "Mac is Intel"
    sudo softwareupdate -i -r --restart --agree-to-license
    exit 0
fi