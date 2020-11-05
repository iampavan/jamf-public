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
# This is an EA that performs an LDAP search based on the username that's assigned to the computer in Jamf Pro,
# and the search can be filtered out based on any LDAP attribute.
#
# EA name : Office Name (It can be called whatever.)
#
####################################################################################################
# Variables
jssURL="https://jamf.domain.com:8443/"
apiUser="apiuser"
apiPass="apipassword"

LDAP_SERVER="ldap://domain.com"
LDAP_USER="first.last@domain.com"
LDAP_PASS="password_goes_here"

SERIAL=$(ioreg -c IOPlatformExpertDevice -d 2 | awk -F\" '/IOPlatformSerialNumber/{print $(NF-1)}')
# SERIAL="C02PRAJUVM02"

USERINFO=$(curl -k ${jssURL}JSSResource/computers/serialnumber/${SERIAL}/subset/location -H "Accept: application/xml" --user "${apiUser}:${apiPass}")

USERNAME=$(echo $USERINFO | /usr/bin/awk -F'<username>|</username>' '{print $2}' | tr [A-Z] [a-z])

if [ -z "$USERNAME" ]; then # Return TRUE if $USERNAME variable is Empty.
    RESULT="Username not found in Jamf"
else
    LDAP_QUERY=`ldapsearch -x -H $LDAP_SERVER -b 'DC=domain,DC=com' -D $LDAP_USER -w $LDAP_PASS "(sAMAccountName=$USERNAME)" "physicalDeliveryOfficeName" | grep physicalDeliveryOfficeName: | cut -d " " -f2-3`

    if [ -z "$LDAP_QUERY" ]; then # Return TRUE if $LDAP_QUERY variable is Empty.
        RESULT="Record not found in AD"
    else
        RESULT=$LDAP_QUERY
    fi
fi

printf "<result>%s</result>" "${RESULT}"
