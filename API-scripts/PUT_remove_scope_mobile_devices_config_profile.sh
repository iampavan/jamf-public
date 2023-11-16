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
# This script will remove the scope of mobile device config profile.
#
# Fill the variable : config_id
#
# Eg :
# config_id="9"
# 
####################################################################################################

# Server information
apiURL="https://instance.jamfcloud.com"
apiUser=""
apiPassword=""

# Get the Bearer Token
apiBearerToken=$( /usr/bin/curl -X POST --silent -u "${apiUser}:${apiPassword}" "${apiURL}/api/v1/auth/token" | /usr/bin/plutil -extract token raw - )

# -----------------------

config_id=""

xmlData="<configuration_profile>
            <scope>
                <all_mobile_devices>false</all_mobile_devices>
                <all_jss_users>false</all_jss_users>
                <mobile_device_groups/>
            </scope>
        </configuration_profile>"

/usr/bin/curl --request PUT \
--header "Authorization: Bearer $apiBearerToken" \
"${apiURL}/JSSResource/mobiledeviceconfigurationprofiles/id/$config_id" \
-H "Content-Type: application/xml" \
--data "$xmlData"

# One-liner :
#
# curl -sk --header "Authorization: Bearer $apiBearerToken" "${apiURL}/JSSResource/mobiledeviceconfigurationprofiles/id/$config_id" -H "Content-Type: application/xml" -d "<configuration_profile><scope><all_mobile_devices>false</all_mobile_devices><all_jss_users>false</all_jss_users><mobile_device_groups/></scope></configuration_profile>" -X PUT

# -----------------------

# Invalidate the Bearer Token
apiBearerToken=$( /usr/bin/curl "${apiURL}/api/v1/auth/invalidate-token" --silent  --header "Authorization: Bearer ${apiBearerToken}" -X POST )
apiBearerToken=""