#!/bin/sh

# This script will rename the computer based on the extenstion attribute from Jamf Pro inventory.
# For instance, in this script the name of the EA is "Office Name"
# You can set the EXT_ATT_NAME variable to whatever EA you are using.

# This script can be used in conjunction with this EA -
# https://github.com/iampavan/jamf-public/tree/main/EA/LDAP_search_for_country_name_based_on_user

# Variables
jssURL="https://jamf.domain.com:8443/"
apiUser="apiuser"
apiPass="apipassword"

EXT_ATT_NAME="\"Office Name\""

SERIAL=$(ioreg -c IOPlatformExpertDevice -d 2 | awk -F\" '/IOPlatformSerialNumber/{print $(NF-1)}')
# SERIAL="C02PRAJUVM02"

EXT_ATTS=$(curl -k ${jssURL}JSSResource/computers/serialnumber/${SERIAL}/subset/extension_attributes -H "Accept: application/xml" --user "${apiUser}:${apiPass}")

EXT_ATT_RESULT=$(echo $EXT_ATTS | xpath "//extension_attribute[name=$EXT_ATT_NAME]" 2>&1 | awk -F'<value>|</value>' '{print $2}')

EXT_ATT_RESULT_SPACE_REMOVED=$(echo $EXT_ATT_RESULT | tr -d ' ')

if ( [ -z "$EXT_ATT_RESULT_SPACE_REMOVED" ] || [[ $EXT_ATT_RESULT_SPACE_REMOVED == "UsernamenotfoundinJamf" ]] || [[ $EXT_ATT_RESULT_SPACE_REMOVED == "RecordnotfoundinAD" ]] ); then # Return TRUE if $EXT_ATT_RESULT variable is Empty or if it matches with any of those 2 strings.
    COMPUTER_NAME="$SERIAL"
else
    COMPUTER_NAME=$EXT_ATT_RESULT_SPACE_REMOVED-"$SERIAL"
fi

echo "Changing name..."
jamf -setComputerName -name $COMPUTER_NAME
echo "Name change complete. ("$COMPUTER_NAME")"

# Instead of hardcoding, added an update inventory.
# jamf recon

exit 0