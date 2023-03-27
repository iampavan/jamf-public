#!/bin/bash

# scrapes the APNs push topic from the MDM profile.
# This value should match with Jamf Pro Settings > Global Management > Push Certificates > MDM Push Notification Certificate - Identifier

profileTopic=$(system_profiler SPConfigurationProfileDataType | grep "Topic" | awk -F '"' '{ print $2 }')

if [ "$profileTopic" != "" ]; then
    echo "<result>$profileTopic</result>"
else
    echo "<result>Not Found</result>"
fi

exit 0
