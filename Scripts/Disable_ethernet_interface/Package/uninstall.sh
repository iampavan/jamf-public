#!/bin/sh
## uninstaller

# Unload any launch daemons
/bin/launchctl unload /Library/LaunchDaemons/com.company.disable_ethernet_interface.plist

# Remove any launch daemons
/bin/rm -rf /Library/LaunchDaemons/com.company.disable_ethernet_interface.plist

# Remove any associated files
/bin/rm -rf /Library/My_Company/disable_ethernet.zsh

# Remove package receipts
/usr/sbin/pkgutil --forget com.company.pkg.Disableethernetinterface

exit 0		## Success
