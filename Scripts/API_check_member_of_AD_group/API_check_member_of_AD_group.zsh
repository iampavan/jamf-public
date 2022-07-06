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
# Workaround for PI104479 - Directory based (LDAP, Azure) Limitations/Exclusions do not work for macOS
#
# I was able to perform a workaround using the extension attributes and API calls. 
# Basically the API call checks the member of the logged_in_user against the AD group you would like to scope and 
# assigns a True or False depending on if that person belongs to that AD group. 
#
# Here is the script I used in the Extension Attribute creation. I hope it help others who might be in my situation.
#
# Ref : CS0831916
#
####################################################################################################


#API Username and Password
username=""
password=""
url="https://company.jamfcloud.com"
loggedInUser=$(scutil <<<"show State:/Users/ConsoleUser" | awk '/Name :/ && ! /loginwindow/ { print $3 }')
echo $loggedInUser

#Variable declarations
bearerToken=""
tokenExpirationEpoch="0"
aduser="$loggedInUser@company.com"

#AD group you are checking membership against
adgroup=""

getBearerToken() {
    response=$(curl -s -u "$username":"$password" "$url"/api/v1/auth/token -X POST)
    #checks if OS is below 12
    if [[ $(/usr/bin/sw_vers -productVersion | awk -F . '{print $1}') -lt 12 ]]; then
        bearerToken=$(echo "$response" | /usr/bin/awk -F \" 'NR==2{print $4}' <<<"$bearerToken" | /usr/bin/xargs)
        tokenExpiration=$(echo "$response" | grep "expires" | awk '{ print $3 }' | sed "s/\"//g")
    else
        bearerToken=$(echo "$response" | plutil -extract token raw -o - -)
        tokenExpiration=$(echo "$response" | plutil -extract expires raw - | awk -F . '{print $1}')
    fi
}

checkTokenExpiration() {
    if (("$tokenExpirationEpoch" > "$(date +%s)")); then
        echo "Token valid until the following epoch time: " "$tokenExpirationEpoch"
    else
        echo "No valid token available, getting new token"
        getBearerToken
    fi
}

invalidateToken() {
    responseCode=$(curl -w "%{http_code}" -H "Authorization: Bearer ${bearerToken}" $url/api/v1/auth/invalidate-token -X POST -s -o /dev/null)
    if [[ ${responseCode} == 204 ]]; then
        echo "Token successfully invalidated"
        bearerToken=""
        tokenExpirationEpoch="0"
    elif [[ ${responseCode} == 401 ]]; then
        echo "Token already invalid"
    else
        echo "An unknown error occurred invalidating the token"
    fi
}

checkTokenExpiration
membership=$(curl -X POST "$url/api/v1/cloud-idp/1/test-user-membership" -H "accept: application/json" -H "Authorization: Bearer ${bearerToken}" -H "Content-Type: application/json" -d "{\"username\":\"$aduser\",\"groupname\":\"$adgroup\"}" | grep "isMember" | awk '{ print $3 }')
echo "<result>$membership</result>"

invalidateToken
