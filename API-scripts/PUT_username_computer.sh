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
# This script updates an "username" for a computer record.
#
# Fill the variables : computer_id, username
#
# Eg :
# computer_id="9"
# username="max"
# 
####################################################################################################

# Server information
apiURL="https://instance.jamfcloud.com"
apiUser=""
apiPassword=""

# Get the Bearer Token
apiBearerToken=$( /usr/bin/curl -X POST --silent -u "${apiUser}:${apiPassword}" "${apiURL}/api/v1/auth/token" | /usr/bin/plutil -extract token raw - )

# -----------------------

computer_id=""
username=""

# -----------------------

xmlData="<computer>
            <location>
                <username>$username</username>
                <realname/>
                <real_name/>
                <email_address/>
                <position/>
                <phone/>
                <phone_number/>
                <department/>
                <building/>
                <room/>
            </location>
        </computer>"

/usr/bin/curl --request PUT \
--header "Accept: text/xml" \
--header "Authorization: Bearer $apiBearerToken" \
"${apiURL}/JSSResource/computers/id/${computer_id}" \
-H "Content-Type: application/xml" \
-H "Accept: application/xml" \
--data "$xmlData"

# -----------------------

# Invalidate the Bearer Token
apiBearerToken=$( /usr/bin/curl "${apiURL}/api/v1/auth/invalidate-token" --silent  --header "Authorization: Bearer ${apiBearerToken}" -X POST )
apiBearerToken=""