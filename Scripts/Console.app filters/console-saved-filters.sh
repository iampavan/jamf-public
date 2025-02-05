#!/bin/bash

# Uncomment line below for debugging
# set -x

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
# Configures "saved searches / filters" in Console.app
# 
####################################################################################################

# Adapted from :
# - https://macadmins.slack.com/archives/C04QVP86E/p1709310398391859?thread_ts=1682553349.070919&cid=C04QVP86E
# - https://macadmins.slack.com/archives/CH8LPK7KP/p1703702567193819?thread_ts=1697555678.463919&cid=CH8LPK7KP

# Tips:
# 
# defaults read /Users/xxxxxx/Library/Preferences/com.apple.Console.plist > /tmp/before
# <Make the changes>
# defaults read /Users/xxxxxx/Library/Preferences/com.apple.Console.plist > /tmp/after
# diff /tmp/before /tmp/after
# 
# - https://emmer.dev/blog/automate-your-macos-defaults/

####################################################################################################

## defaults export "/Users/xxxxxx/Library/Preferences/com.apple.Console" - | plutil -extract userFilters raw -
# DATA_userFilters="YnBsaXN0MDDUAQIDBAUGBwpYJHZlcnNpb25ZJGFyY2hpdmVyVCR0b3BYJG9iamVjdHMSAAGGoF8QD05TS2V5ZWRBcmNoaXZlctEICVt1c2VyRmlsdGVyc4ABqgsMEhwdISkqMDNVJG51bGzSDQ4PEVpOUy5vYmplY3RzViRjbGFzc6EQgAKACNUOExQVFhcYGRobV2ZpbHRlcnNUbmFtZVxjYW5CZVJlbW92ZWRaaWRlbnRpZmllcoAJgASAAwmAAF5qYW1mIHN1YnN5c3RlbdINDh4RoR+ABYAI1A4iIyQlJicoXxAba0NTS0ZpbHRlckNvbXBhcmlzb25UeXBlS2V5XxASa0NTS0ZpbHRlclZhbHVlS2V5XxARa0NTS0ZpbHRlclR5cGVLZXmABxAAgAYQCVhjb20uamFtZtIrLC0uWiRjbGFzc25hbWVYJGNsYXNzZXNZQ1NLRmlsdGVyoi0vWE5TT2JqZWN00issMTJXTlNBcnJheaIxL9IrLDQ1XxASQ29uc29sZS5GaWx0ZXJJdGVtojYvXxASQ29uc29sZS5GaWx0ZXJJdGVtAAgAEQAaACQAKQAyADcASQBMAFgAWgBlAGsAcAB7AIIAhACGAIgAkwCbAKAArQC4ALoAvAC+AL8AwQDQANUA1wDZANsA5AECARcBKwEtAS8BMQEzATwBQQFMAVUBXwFiAWsBcAF4AXsBgAGVAZgAAAAAAAACAQAAAAAAAAA3AAAAAAAAAAAAAAAAAAABrQ=="
DATA_userFilters="YnBsaXN0MDDUAQIDBAUGBwpYJHZlcnNpb25ZJGFyY2hpdmVyVCR0b3BYJG9iamVjdHMSAAGGoF8QD05TS2V5ZWRBcmNoaXZlctEICVt1c2VyRmlsdGVyc4ABrxA4CwwaJCUpMTI4Oz9GR0tPUFdYXF9gZ2htcHF0dXx9gYSFjI2RlJWcnaKlpqmqsbK3ur6/xsfMz9JVJG51bGzSDQ4PGVpOUy5vYmplY3RzViRjbGFzc6kQERITFBUWFxiAAoAKgA+AFIAbgCCAJYAsgDKACNUOGxwdHh8gISIjV2ZpbHRlcnNUbmFtZVxjYW5CZVJlbW92ZWRaaWRlbnRpZmllcoAJgASAAwmAAF8QFENhdGVnb3J5IC0gTURNRGFlbW9u0g0OJhmhJ4AFgAjUDiorLC0uLzBfEBtrQ1NLRmlsdGVyQ29tcGFyaXNvblR5cGVLZXlfEBJrQ1NLRmlsdGVyVmFsdWVLZXlfEBFrQ1NLRmlsdGVyVHlwZUtleYAHEACABhAKWU1ETURhZW1vbtIzNDU2WiRjbGFzc25hbWVYJGNsYXNzZXNZQ1NLRmlsdGVyojU3WE5TT2JqZWN00jM0OTpXTlNBcnJheaI5N9IzNDw9XxASQ29uc29sZS5GaWx0ZXJJdGVtoj43XxASQ29uc29sZS5GaWx0ZXJJdGVt1Q4bHEAeH0JDIiNcY2FuQmVSZW1vdmVkgAmADIALCYAAXxAVamFtZiBiaW5hcnkgc3Vic3lzdGVt0g0OSBmhSYANgAjUDiorLC0uTU6AB4AOEAlfEBpjb20uamFtZi5tYW5hZ2VtZW50LmJpbmFyedUOGxxRHh9TVCIjXGNhbkJlUmVtb3ZlZIAJgBGAEAmAAFxqYW1mIHByb2Nlc3PSDQ5ZGaFagBKACNQOKissLS5eLoAHgBNUamFtZtUOGxxhHh9jZCIjXGNhbkJlUmVtb3ZlZIAJgBaAFQmAAFxNRE0gYWN0aXZpdHnSDQ5pGaJqa4AXgBmACNQOKissLS5vLoAHgBhZbWRtY2xpZW501A4qKywtLnNOgAeAGl8QF2NvbS5hcHBsZS5NYW5hZ2VkQ2xpZW501Q4bHHYeH3h5IiNcY2FuQmVSZW1vdmVkgAmAHYAcCYAAXkNhdGVnb3J5IC0gRERN0g0Ofhmhf4AegAjUDiorLC0ugzCAB4AfU0RETdUOGxyGHh+IiSIjXGNhbkJlUmVtb3ZlZIAJgCKAIQmAAF5DYXRlZ29yeSAtIE1ETdINDo4ZoY+AI4AI1A4qKywtLpMwgAeAJFNNRE3VDhsclh4fmJkiI1xjYW5CZVJlbW92ZWSACYAngCYJgABec29mdHdhcmV1cGRhdGXSDQ6eGaKfoIAogCqACNQOKissLS6kLoAHgClfEA9zb2Z0d2FyZXVwZGF0ZWTUDiorLC0uqDCAB4ArUlNV1Q4bHKseH62uIiNcY2FuQmVSZW1vdmVkgAmALoAtCYAAXxAbTURNIHVwZGF0ZS91cGdyYWRlIHByb2dyZXNz0g0OsxmitLWAL4AwgAjUDiorLC0upC6AB4Ap1A4qKywtLry9gAeAMRAFXxARUmVwb3J0ZWQgcHJvZ3Jlc3PVDhscwB4fwsMiI1xjYW5CZVJlbW92ZWSACYA0gDMJgABfEBFNRE0gcHVzaCBjb21tYW5kc9INDsgZosnKgDWANoAI1A4qKywtLnNOgAeAGtQOKissLS7RMIAHgDdYSFRUUFV0aWwACAARABoAJAApADIANwBJAEwAWABaAJUAmwCgAKsAsgC8AL4AwADCAMQAxgDIAMoAzADOANAA2wDjAOgA9QEAAQIBBAEGAQcBCQEgASUBJwEpASsBNAFSAWcBewF9AX8BgQGDAY0BkgGdAaYBsAGzAbwBwQHJAcwB0QHmAekB/gIJAhYCGAIaAhwCHQIfAjcCPAI+AkACQgJLAk0CTwJRAm4CeQKGAogCigKMAo0CjwKcAqECowKlAqcCsAKyArQCuQLEAtEC0wLVAtcC2ALaAucC7ALvAvEC8wL1Av4DAAMCAwwDFQMXAxkDMwM+A0sDTQNPA1EDUgNUA2MDaANqA2wDbgN3A3kDewN/A4oDlwOZA5sDnQOeA6ADrwO0A7YDuAO6A8MDxQPHA8sD1gPjA+UD5wPpA+oD7AP7BAAEAwQFBAcECQQSBBQEFgQoBDEEMwQ1BDgEQwRQBFIEVARWBFcEWQR3BHwEfwSBBIMEhQSOBJAEkgSbBJ0EnwShBLUEwATNBM8E0QTTBNQE1gTqBO8E8gT0BPYE+AUBBQMFBQUOBRAFEgAAAAAAAAIBAAAAAAAAANMAAAAAAAAAAAAAAAAAAAUb"

## defaults export "/Users/xxxxxx/Library/Preferences/com.apple.Console" - | plutil -extract builtInFiltersPositions raw -
# DATA_builtInFiltersPositions="YnBsaXN0MDDUAQIDBAUGBwpYJHZlcnNpb25ZJGFyY2hpdmVyVCR0b3BYJG9iamVjdHMSAAGGoF8QD05TS2V5ZWRBcmNoaXZlctEICV8QF2J1aWx0SW5GaWx0ZXJzUG9zaXRpb25zgAGnCwwXGBkaG1UkbnVsbNMNDg8QExZXTlMua2V5c1pOUy5vYmplY3RzViRjbGFzc6IREoACgAOiFBWABIAFgAZcYWxsX21lc3NhZ2VzXxAVYWxsX3Ryb3VibGVkX21lc3NhZ2VzEAAQAdIcHR4fWiRjbGFzc25hbWVYJGNsYXNzZXNcTlNEaWN0aW9uYXJ5oh4gWE5TT2JqZWN0AAgAEQAaACQAKQAyADcASQBMAGYAaABwAHYAfQCFAJAAlwCaAJwAngChAKMApQCnALQAzADOANAA1QDgAOkA9gD5AAAAAAAAAgEAAAAAAAAAIQAAAAAAAAAAAAAAAAAAAQI="
DATA_builtInFiltersPositions="YnBsaXN0MDDUAQIDBAUGBwpYJHZlcnNpb25ZJGFyY2hpdmVyVCR0b3BYJG9iamVjdHMSAAGGoF8QD05TS2V5ZWRBcmNoaXZlctEICV8QF2J1aWx0SW5GaWx0ZXJzUG9zaXRpb25zgAGnCwwXGBkaG1UkbnVsbNMNDg8QExZXTlMua2V5c1pOUy5vYmplY3RzViRjbGFzc6IREoACgAOiFBWABIAFgAZcYWxsX21lc3NhZ2VzXxAVYWxsX3Ryb3VibGVkX21lc3NhZ2VzEAAQAdIcHR4fWiRjbGFzc25hbWVYJGNsYXNzZXNcTlNEaWN0aW9uYXJ5oh4gWE5TT2JqZWN0AAgAEQAaACQAKQAyADcASQBMAGYAaABwAHYAfQCFAJAAlwCaAJwAngChAKMApQCnALQAzADOANAA1QDgAOkA9gD5AAAAAAAAAgEAAAAAAAAAIQAAAAAAAAAAAAAAAAAAAQI="

CURRENT_USER=$( echo "show State:/Users/ConsoleUser" | scutil | awk '/Name :/ && ! /loginwindow/ { print $3 }' )
# echo "CURRENT_USER = $CURRENT_USER"

# Check that current user it not empty or root
if [ "$CURRENT_USER" = "root" ] || [ "$CURRENT_USER" = "" ]; then
	echo "No current user found exit"
	exit 1
fi

TMP_FILE_1="/tmp/data_1.plist"
TMP_FILE_2="/tmp/data_2.plist"

# Remove old temp file if found
if [ -f "$TMP_FILE_1" ]; then
	echo "Old temp files found. Removing them..."
	rm "$TMP_FILE_1"
	rm "$TMP_FILE_2"
fi	

echo "Creating temp files..."
echo "$DATA_userFilters" | base64 -D | plutil -convert xml1 - -o "$TMP_FILE_1"
echo "$DATA_builtInFiltersPositions" | base64 -D | plutil -convert xml1 - -o "$TMP_FILE_2"

echo "Writing 'userFilters' status..."
DND_HEX_DATA_1=$(plutil -convert binary1 "$TMP_FILE_1" -o - | xxd -p | tr -d '\n')
sudo -u $CURRENT_USER defaults write "/Users/$CURRENT_USER/Library/Preferences/com.apple.Console.plist" userFilters -data "$DND_HEX_DATA_1"

echo "Writing 'builtInFiltersPositions' status..."
DND_HEX_DATA_2=$(plutil -convert binary1 "$TMP_FILE_2" -o - | xxd -p | tr -d '\n')
sudo -u $CURRENT_USER defaults write "/Users/$CURRENT_USER/Library/Preferences/com.apple.Console.plist" builtInFiltersPositions -data "$DND_HEX_DATA_2"

killall cfprefsd

# Remove temo file	
if [ -f "$TMP_FILE_1" ]; then
	echo "Removing temp files..."
	rm "$TMP_FILE_1"
	rm "$TMP_FILE_2"
fi

exit
