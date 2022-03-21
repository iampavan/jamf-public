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
# This script will unload the LaunchDaemon and remove it.
# This will also remove the test script : /Library/Scripts/test.sh
#
# Tested on macOS 12.3
####################################################################################################

# Unload the launch daemon
/bin/launchctl unload /Library/LaunchDaemons/com.pavan.mydaemon.plist

# Remove the launch daemon
/bin/rm /Library/LaunchDaemons/com.pavan.mydaemon.plist

# Remove test script
/bin/rm /Library/Scripts/test.sh
