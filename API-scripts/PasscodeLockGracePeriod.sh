#!/bin/bash

apiURL="https://instance.jamfcloud.com"
apiUser=""
apiPassword=""

ID=(25 33 35 58)
# Make sure the numbers are space separated an not comma separated.

apiBearerToken=$( /usr/bin/curl -X POST --silent -u "${apiUser}:${apiPassword}" "${apiURL}/api/v1/auth/token" | /usr/bin/plutil -extract token raw - )

for i in "${ID[@]}"; do
	xmlData="<mobile_device_command>
            <general>
                <command>PasscodeLockGracePeriod</command>
                <passcode_lock_grace_period>14400</passcode_lock_grace_period>
            </general>
            <mobile_devices>
                <mobile_device>
                    <id>$i</id>
                </mobile_device>
            </mobile_devices>
        </mobile_device_command>"
    printf "\nSending PasscodeLockGracePeriod Command to Device ID: $i...\n"

	/usr/bin/curl -H "Authorization: Bearer ${apiBearerToken}" \
	--header "Content-Type: text/xml" \
	--request POST \
	--data "$xmlData" \
	"${apiURL}/JSSResource/mobiledevicecommands/command"
done

# Invalidate the Bearer Token
apiBearerToken=$( /usr/bin/curl "${apiURL}/api/v1/auth/invalidate-token" --silent  --header "Authorization: Bearer ${apiBearerToken}" -X POST )
apiBearerToken=""