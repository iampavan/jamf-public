#!/bin/bash

mdmProfile=$(/usr/libexec/mdmclient QueryInstalledProfiles | grep "00000000-0000-0000-A000-4A414D460003")

if [[ $mdmProfile == "" ]]; then
	result="MDM Profile Not Installed"
else
	result="MDM Profile Installed"
fi

echo "<result>$result</result>"