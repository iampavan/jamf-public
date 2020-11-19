#!/bin/sh
## postinstall

/bin/launchctl load /Library/LaunchDaemons/com.company.disable_ethernet_interface.plist

exit 0		## Success