#!/bin/bash

# Searches macOS unified logging for missing client identity errors in last day.
# This will do a very basic check for Product Issue PI108400 Evidence on managed macOS Devices.
# It may be important to look closer at any devices that indicate 'MDM is broken' in the output.
# Also, Detecting for PI104712.

result=$(log show --style compact --predicate '(process CONTAINS "mdmclient")' --last 1d | grep "Unable to create MDM identity")

if [[ $result == '' ]]; then
    echo "<result>MDM is communicating</result>"
else
    echo "<result>MDM is broken</result>"
fi
