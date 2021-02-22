#!/bin/bash
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
# This script updates an EA of a mobiledevice. Provide csv file as an input.
#
# EA name : JP - Database version (It can be called whatever)
#
# Ref : https://www.jamf.com/jamf-nation/discussions/14880/jss-api-experts-command-help-needed#responseChild91184
#
####################################################################################################
#
# OUTPUT SAMPLE :
#
# /Users/demo/Desktop/update_EA_mobile_device.sh
# Mobileqty=  4
#
# Attempting to update EA value for DDDDDDDDDD
# DDDDDDDDDD -----> 123
# <?xml version="1.0" encoding="UTF-8"?><mobile_device><id>16</id></mobile_device>
#
# Attempting to update EA value for DDDDDDDDDD
# DDDDDDDDDD -----> 456
# <?xml version="1.0" encoding="UTF-8"?><mobile_device><id>19</id></mobile_device>
#
# Attempting to update EA value for DDDDDDDDDD
# DDDDDDDDDD -----> 789
# <?xml version="1.0" encoding="UTF-8"?><mobile_device><id>20</id></mobile_device>
#
# The following mobile devices could not be updated:
# []
####################################################################################################


# server information
jamfURL="https://url.jamfcloud.com/JSSResource"
jamfUser="apiuser"
jamfPassword="apipassword"

# The filename should not contain spaces
file="/Users/demo/Desktop/sample_mobile-devices.csv"

# information required
# ------------------------
# For String EA
# ------------------------
# eaID="1" #set EA ID in parameter 6
# extAttName="\"Jamf-Setup-Role\""
# eaName="Jamf-Setup-Role" #set EA Name in parameter 7
# eaValue="Personal use" #set "Personal use" or "In-flight"
# ------------------------
# For Integer EA
# ------------------------
extAttName="\"JP - Database version\""
eaID="5" # Extension Attribute ID
eaName="JP - Database version"
# ------------------------

function xpath() {
    # the xpath tool changes in Big Sur 
    if [[ $(sw_vers -buildVersion) > "20A" ]]; then
        /usr/bin/xpath -e "$@"
    else
        /usr/bin/xpath "$@"
    fi
}

function get_EA_value() {
    apiData=$( /usr/bin/curl --insecure --user "$jamfUser":"$jamfPassword" \
    --header "Accept: text/xml" \
    --request GET \
    $jamfURL/mobiledevices/serialnumber/${SERIAL} )

    eaName=$(echo $apiData | xpath "/mobile_device/extension_attributes/extension_attribute[name=$extAttName]" 2>&1 | awk -F'<value>|</value>' '{print $2}')

    echo $eaName

    # # -------Show attributes-----------
    # echo $apiData | xmllint --format - | xpath "/mobile_device/extension_attributes/extension_attribute"
    # # ---------------------------------
}

function put_EA__string_value() {
    /usr/bin/curl --insecure --user "$jamfUser":"$jamfPassword" \
    --header "Accept: text/xml" \
    --request PUT \
    $jamfURL/mobiledevices/serialnumber/${SERIAL} \
        -H "Content-Type: application/xml" \
        -H "Accept: application/xml" \
        -d "<mobile_device><extension_attributes><extension_attribute><id>$eaID</id><name>$eaName</name><type>String</type><multi_value>false</multi_value><value>$eaValue</value></extension_attribute></extension_attributes></mobile_device>"
}

function put_EA__int_value() {
    /usr/bin/curl --insecure --user "$jamfUser":"$jamfPassword" \
    --header "Accept: text/xml" \
    --request PUT \
    $jamfURL/mobiledevices/serialnumber/${SERIAL} \
        -H "Content-Type: application/xml" \
        -H "Accept: application/xml" \
        -d "<mobile_device><extension_attributes><extension_attribute><id>$eaID</id><name>$eaName</name><type>Number</type><multi_value>false</multi_value><value>$eaValue</value></extension_attribute></extension_attributes></mobile_device>"
}


#Verify we can read the file
data=`cat $file`
if [[ "$data" == "" ]]; then
    echo "Unable to read the file path specified"
    echo "Ensure there are no spaces and that the path is correct"
    exit 1
fi

#Find how many mobiledevices are in CSV file (including the header)
mobileqty=`awk -F, 'END {printf "%s\n", NR}' $file`
echo "Mobileqty= " $mobileqty
#Set a counter for the loop (Since header is present, ignore line 1. So start with 1)
counter="1"

duplicates=[]

id=$((id+1))

#Loop through the CSV and submit data to the API
while [ $counter -lt $mobileqty ]
do
    counter=$[$counter+1]
    line=`echo "$data" | head -n $counter | tail -n 1`
    SERIAL=`echo "$line" | awk -F , '{print $4}'`
    eaValue=`echo "$line" | awk -F , '{print $7}'`

    echo -e "\n\nAttempting to update EA value for $SERIAL"

    echo $SERIAL "----->" $eaValue
    
    # Call the API PUT function
    # put_EA__int_value

    output="$(put_EA__int_value)"

    #Error Checking
    error=""
    error=`echo $output | grep "not found"`
    if [[ $error != "" ]]; then
        duplicates+=($SERIAL)
    fi
    #Increment the ID variable for the next user
    id=$((id+1))
done

echo -e "\n\nThe following mobile devices could not be updated:"
printf -- '%s\n' "${duplicates[@]}"


exit 0