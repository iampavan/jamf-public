#!/bin/sh

# Heavily based on -
# https://www.jamf.com/jamf-nation/discussions/29746/api-call-to-get-computers-assigned-user-in-jamf-pro

# Variables
jssURL="https://jamf.domain.com:8443/"
apiUser="apiuser"
apiPass="apipassword"

# SERIAL="C02PRAJUVM02"
SERIAL=$(ioreg -c IOPlatformExpertDevice -d 2 | awk -F\" '/IOPlatformSerialNumber/{print $(NF-1)}')

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
