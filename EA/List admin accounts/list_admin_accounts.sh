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
# An EA to list out admin accounts
# Ref : https://community.jamf.com/t5/jamf-pro/read-out-local-administrators/m-p/252381
#
# Works on macOS 12.3.1 (21E258)
####################################################################################################

## A list of the known local admins to be excluded
known_admins="root|localadmin1|localadmin2"

## Initialize array
admin_list=()

# For all users with a userID above 500 (aka: not hidden) check if they are an admin,
# for username in $(/usr/bin/dscl . list /Users UniqueID | awk '$2 > 500 {print $1}' | egrep -v "${known_admins}"); do

# For all users (aka: including hidden) check if they are an admin
for username in $(/usr/bin/dscl . list /Users UniqueID | awk '{print $1}' | egrep -v "${known_admins}"); do
    if [[ $(/usr/sbin/dseditgroup -o checkmember -m "$username" admin | grep "^yes") ]]; then
    ## Any reported accounts are added to the array list
    	admin_list+=("${username}")
    fi
done

## Prints the array's list contents
if [[ "${admin_list[@]}" != "" ]]; then
	echo "<result>${admin_list[@]}</result>"
else
	echo "<result>[ None ]</result>"
fi