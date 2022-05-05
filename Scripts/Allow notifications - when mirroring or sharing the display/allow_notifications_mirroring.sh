#!/bin/zsh

####################################################################################################
#
# THIS SCRIPT IS NOT AN OFFICIAL PRODUCT OF JAMF SOFTWARE AS SUCH IT IS
# PROVIDED WITHOUT WARRANTY OR SUPPORT
#
# BY USING THIS SCRIPT, YOU AGREE THAT JAMF SOFTWARE IS UNDER NO OBLIGATION TO
# SUPPORT, DEBUG, OR OTHERWISE MAINTAIN THIS SCRIPT
#
####################################################################################################
#
# DESCRIPTION This script will enable Allow notifications "When mirroring or
# sharing the display"(System Preferences > Notifications & Focus > Allow
# notifications "When mirroring or sharing the display")
#
# Tested on macOS Monterey 12.2.1
#
# Do Not Distrub data is stored as binary of a plist within the "dnd_prefs"
# in "com.apple.ncprefs" Reading the value :
# /usr/bin/plutil -extract dnd_prefs
#  xml1 -o - /Users/$username/Library/Preferences/com.apple.ncprefs.plist |
#  xpath -q -e 'string(//data)' | base64 -D | plutil -convert xml1 - -o -
#
# The key we are interested in is <key>dndMirrored</key> By default its set
# to "true" Setting it to "false" will enable Allow notifications "When
# mirroring or sharing the display" Setting it to "true" will disable Allow
# notifications "When mirroring or sharing the display"
#
# oneliner to enable Allow notifications "When mirroring or sharing the
# display" defaults write com.apple.ncprefs dnd_prefs -data
# 62706c6973743030d5010203040506060606065b646e644d6972726f7265645f100f646e64446973706c6179536c6565705f101e72657065617465644661636574696d6543616c6c73427265616b73444e445e646e64446973706c61794c6f636b5f10136661636574696d6543616e427265616b444e44080808080808131f3152617778797a7b0000000000000101000000000000000b0000000000000000000000000000007c;killall
# usernoted
#
# oneliner to disable Allow notifications "When mirroring or sharing the
# display" defaults write com.apple.ncprefs dnd_prefs -data
# 62706c6973743030d5010203040506070707075b646e644d6972726f7265645f100f646e64446973706c6179536c6565705f101e72657065617465644661636574696d6543616c6c73427265616b73444e445e646e64446973706c61794c6f636b5f10136661636574696d6543616e427265616b444e44090808080808131f3152617778797a7b0000000000000101000000000000000b0000000000000000000000000000007c;killall
# usernoted
#
####################################################################################################

darwin_major_version="$(uname -r | cut -d '.' -f 1)" # 17 = 10.13, 18 = 10.14,
19 = 10.15, 20 = 11.0, etc.

username=$( scutil <<< "show State:/Users/ConsoleUser" |
awk '/Name :/ && ! /loginwindow/ { print $3 }' ) uid=$(id -u $username)

if (( darwin_major_version >= 20 )); then
    # In macOS 11 Big Sur, the Do Not Distrub data is stored as binary of a
    # plist within the "dnd_prefs" of "com.apple.ncprefs":
    # https://www.reddit.com/r/osx/comments/ksbmay/big_sur_how_to_test_do_not_disturb_status_in/gjb72av/
    launchctl asuser "${uid}" sudo -u "${username}" defaults
    write 'com.apple.ncprefs' dnd_prefs -data "$(echo '<?xml version="1.0"
    encoding="UTF-8"?> <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST
    1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd"> <plist
    version="1.0"> <dict> <key>dndDisplayLock</key> <false/>
    <key>dndDisplaySleep</key> <false/> <key>dndMirrored</key> <false/>
    <key>facetimeCanBreakDND</key> <false/>
    <key>repeatedFacetimeCallsBreaksDND</key> <false/> </dict> </plist>' |
    plutil -convert binary1 - -o - | xxd -p | tr -d '
    [:space:]')" # "xxd" converts the binary data into hex, which is
    what "defaults" needs. else launchctl asuser "${uid}" sudo -u "$
    {username}" defaults -currentHost write 'com.apple.notificationcenterui'
    dndEnabledDisplayLock -bool false launchctl asuser "${uid}" sudo -u "$
    {username}" defaults -currentHost write 'com.apple.notificationcenterui'
    dndEnabledDisplaySleep -bool false launchctl asuser "${uid}" sudo -u "$
    {username}" defaults -currentHost write 'com.apple.notificationcenterui'
    dndMirroring -bool true launchctl asuser "${uid}" sudo -u "$
    {username}" defaults -currentHost write 'com.apple.notificationcenterui'
    dndEnd -float 1439 launchctl asuser "${uid}" sudo -u "$
    {username}" defaults -currentHost write 'com.apple.notificationcenterui'
    dndStart -float 0 launchctl asuser "${uid}" sudo -u "$
    {username}" defaults -currentHost write 'com.apple.notificationcenterui'
    doNotDisturb -bool false fi

killall usernoted
# killall ControlCenter
