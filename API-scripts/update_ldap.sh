#!/bin/bash

# server information
apiURL="https://instance.jamfcloud.com"
apiUser=""
apiPassword=""

apiBearerToken=$( /usr/bin/curl -X POST --silent -u "${apiUser}:${apiPassword}" "${apiURL}/api/v1/auth/token" | /usr/bin/plutil -extract token raw - )

echo "$apiBearerToken"

curl -s -H "content-type: text/xml" -H "Authorization: Bearer $apiBearerToken" "${apiURL}/JSSResource/ldapservers/id/14" -X PUT -d "<ldap_server><connection><name>abcd.org.edu</name></connection></ldap_server>"


# Invalidate the Bearer Token
apiBearerToken=$( /usr/bin/curl "${apiURL}/api/v1/auth/invalidate-token" --silent  --header "Authorization: Bearer ${apiBearerToken}" -X POST )
apiBearerToken=""