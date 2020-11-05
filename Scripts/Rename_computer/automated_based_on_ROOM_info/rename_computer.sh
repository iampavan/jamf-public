#!/bin/sh
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
# This script will rename the computer based on the assigned user's "ROOM" info from Jamf Pro inventory.

# Heavily based on -
# https://www.jamf.com/jamf-nation/discussions/29746/api-call-to-get-computers-assigned-user-in-jamf-pro
#
####################################################################################################
# Variables
jssURL="https://jamf.domain.com:8443/"
apiUser="apiuser"
apiPass="apipassword"

SERIAL=$(ioreg -c IOPlatformExpertDevice -d 2 | awk -F\" '/IOPlatformSerialNumber/{print $(NF-1)}')
# SERIAL="C02PRAJUVM02"

USERINFO=$(curl -k ${jssURL}JSSResource/computers/serialnumber/${SERIAL}/subset/location -H "Accept: application/xml" --user "${apiUser}:${apiPass}")

ROOM=$(echo $USERINFO | /usr/bin/awk -F'<room>|</room>' '{print $2}')

if [ -z "$ROOM" ]; then # Return TRUE if $ROOM variable is Empty.
    COMPUTER_NAME="$SERIAL"
else
    COMPUTER_NAME=$ROOM-"$SERIAL"
fi

echo "Changing name..."
jamf -setComputerName -name $COMPUTER_NAME
echo "Name change complete. ("$COMPUTER_NAME")"

# Instead of hardcoding, added an update inventory.
# jamf recon

exit 0
