#!/bin/sh
## unload and remove

# Unload any launch daemons
/bin/launchctl unload /Library/LaunchDaemons/com.pavan.mydaemon.plist

# Remove any launch daemons
/bin/rm /Library/LaunchDaemons/com.pavan.mydaemon.plist

# Remove test script
/bin/rm /Library/Scripts/test.sh
