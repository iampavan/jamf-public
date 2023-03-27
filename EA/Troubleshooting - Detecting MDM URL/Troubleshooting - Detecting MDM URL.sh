#!/bin/bash

profileURL=`system_profiler SPConfigurationProfileDataType | grep "ServerURL" | grep "jamfcloud.com" | cut -d'"' -f2`

# profileURL=$(/usr/sbin/system_profiler SPConfigurationProfileDataType | awk '/CheckInURL/{ print $NF }' | sed -E 's/^.*=([0-9]*)";/\1/')

if [ "$profileURL" != "" ]; then
	echo "<result>$profileURL</result>"
else
	echo "<result>Not Found</result>"
fi

exit 0