#!/bin/zsh

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
#
# Workaround for PI107702 - User _mbsetupuser - runs policy after DEP Enrollment Complete
#
# We could run a script like this with Enrollment Complete trigger,
# that checks the logged in user, and if it is not _mbsetupuser then run a custom trigger
#
# Ref scripts :
#
# https://github.com/jamf/DEPNotify-Starter/blob/master/depNotify.sh
# postinstall-for-Composer-for-DEPNotify.zsh (https://gist.github.com/arekdreyer)
# 
####################################################################################################

LOG_PATH="/var/tmp/ensuring_user_at_desktop.log"

# Wait for Apple Setup Assistant to complete
SETUP_ASSISTANT_PROCESS=$(pgrep -l "Setup Assistant")
until [ "$SETUP_ASSISTANT_PROCESS" = "" ]; do
    echo "$(date "+%a %h %d %H:%M:%S"): Setup Assistant Still Running. PID $SETUP_ASSISTANT_PROCESS." >>"$LOG_PATH"
    sleep 1
    SETUP_ASSISTANT_PROCESS=$(pgrep -l "Setup Assistant")
done

# Checking to see if the Finder is running now before continuing. This can help
# in scenarios where an end user is not configuring the device.
FINDER_PROCESS=$(pgrep -l "Finder")
until [ "$FINDER_PROCESS" != "" ]; do
    echo "$(date "+%a %h %d %H:%M:%S"): Finder process not found. Assuming device is at login screen." >>"$LOG_PATH"
    sleep 1
    FINDER_PROCESS=$(pgrep -l "Finder")
done

# until [ -f /var/log/jamf.log ]; do
#     echo "Waiting for jamf log to appear"
#     sleep 1
# done
# until (/usr/bin/grep -q enrollmentComplete /var/log/jamf.log); do
#     echo "Waiting for jamf enrollment to be complete."
#     sleep 1
# done

# Grab serial_no and 
serial_no=$(ioreg -rd1 -c IOPlatformExpertDevice | awk -F'"' '/IOPlatformSerialNumber/{print $4}' | tail -c 5)
lastUser=$(defaults read /Library/Preferences/com.apple.loginwindow lastUserName)
AW_HOSTNAME="${serial_no}-${lastUser}"

# # Enter usernames in the following string that we should ignore
# if [[ "$lastUser" == admin || "$lastUser" == jamf || "$lastUser" == _mbsetupuser ]]; then
#     echo "Local user is logged in last, skipping assignment"
# else
#     echo "$AW_HOSTNAME"
# fi

echo "$(date "+%a %h %d %H:%M:%S"): Local user is logged in last." >>"$LOG_PATH"
echo "$(date "+%a %h %d %H:%M:%S"): $AW_HOSTNAME" >>"$LOG_PATH"

exit 0		## Success
exit 1		## Failure