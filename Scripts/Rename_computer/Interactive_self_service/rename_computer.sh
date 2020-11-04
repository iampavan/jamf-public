#!/bin/sh

# Use the country names in the script parameters ($4, $5....)
# Example output = USA-C02VMTEST00

# variables
LOGGED_IN_USER=$(stat -f%Su /dev/console)
LOGGED_IN_UID=$(id -u $LOGGED_IN_USER)
JAMFHELPER="/Library/Application Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper"

SERIAL_NUMBER=$(ioreg -c IOPlatformExpertDevice -d 2 | awk -F\" '/IOPlatformSerialNumber/{print $(NF-1)}')
PREFIX=$(/bin/launchctl asuser $LOGGED_IN_UID sudo -iu $LOGGED_IN_USER << EOF
/usr/bin/osascript -e 'return choose from list {"$4", "$5", "$6", "$7", "$8", "$9"}' 2>/dev/null
EOF)
COMPUTER_NAME=$PREFIX-"$SERIAL_NUMBER"

if [ "$PREFIX" == "false" ]; then
	exit 1
fi  # Abort, if user pressed Cancel.

echo "Processing new name for this client..."
echo "Changing name..."
jamf -setComputerName -name $COMPUTER_NAME
echo "Name change complete. ("$COMPUTER_NAME")"

"$JAMFHELPER" -windowType hud -heading "Computer name :" -description "$COMPUTER_NAME" -button1 OK

# Instead of hardcoding, added an update inventory.
# jamf recon

exit 0
