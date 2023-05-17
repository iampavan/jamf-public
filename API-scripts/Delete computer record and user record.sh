#!/bin/bash

apiURL="https://instance.jamfcloud.com"
apiUser=""
apiPassword=""

computer_id="3"
user_id="1"

apiBearerToken=$( /usr/bin/curl -X POST --silent -u "${apiUser}:${apiPassword}" "${apiURL}/api/v1/auth/token" | /usr/bin/plutil -extract token raw - )

# -----------------------

# Remove specified Computer record
# https://developer.jamf.com/jamf-pro/reference/delete_v1-computers-inventory-id

curl --header "Authorization: Bearer ${apiBearerToken}" \
	--request DELETE \
	--url "${apiURL}/api/v1/computers-inventory/${computer_id}" \
	--header 'accept: application/json'

# -----------------------

# Deletes a user by ID
# https://developer.jamf.com/jamf-pro/reference/deleteuserbyid

curl --header "Authorization: Bearer ${apiBearerToken}" \
	--request DELETE \
	--url "${apiURL}/JSSResource/users/id/${user_id}"

# -----------------------

# Invalidate the Bearer Token
apiBearerToken=$( /usr/bin/curl "${apiURL}/api/v1/auth/invalidate-token" --silent  --header "Authorization: Bearer ${apiBearerToken}" -X POST )
apiBearerToken=""