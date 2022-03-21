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
# This script will create a new LaunchDaemon and load it.
# This will also create a test script : /Library/Scripts/test.sh
#
# Tested on macOS 12.3
####################################################################################################

cat << EOF > /Library/LaunchDaemons/com.pavan.mydaemon.plist
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
   <key>Label</key>
   <string>com.pavan.mydaemon</string>
   <key>ProgramArguments</key>
   <array>
   	<string>/Library/Scripts/test.sh</string>
   </array>
   <key>RunAtLoad</key>
   <true/>
</dict>
</plist>
EOF

/bin/cat << EOF > "/Library/Scripts/test.sh"
#!/bin/bash
"/Library/Application Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper" -windowType utility -description "Hello, World!" -button1 "OK" -button2 "Cancel"
EOF

# Make the test script executable
chmod 755 /Library/Scripts/test.sh

chmod 644 /Library/LaunchDaemons/com.pavan.mydaemon.plist
chown root:wheel /Library/LaunchDaemons/com.pavan.mydaemon.plist

/bin/launchctl load /Library/LaunchDaemons/com.pavan.mydaemon.plist