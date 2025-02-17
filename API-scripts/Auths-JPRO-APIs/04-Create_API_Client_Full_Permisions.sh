#!/bin/bash

###########################################################################################
## Create an API Client ID and Client Secret with FULL permissions - use for testing only #
###########################################################################################

# Adapted from : https://github.com/matteo-bolognini/Jamf-Pro/blob/main/scripts/bash/Create_API_Client_Full_Permisions.sh
# Adapted from : https://github.com/rtrouton/rtrouton_scripts/tree/main/rtrouton_scripts/Casper_Scripts/Jamf_Pro_Webhook_Download

#---------------
# Use this to create READ-only API Role and Client :

#Add the name of the API Role
api_role_displayName="APIRole_READpermissions_2025-xx-xx"
api_client_displayName="APIClient_READpermissions_2025-xx-xx"
##Extract READ-only API privileges
# privileges=$(echo "$json" | jq -r '.privileges[]' | grep 'Read' | awk '{printf "\"%s\", ", $0}' | sed 's/, $//' )
#---------------

# ===============
# Use this to create Full API Role and Client :

##Add the name of the API Role
#api_role_displayName="APIRole_FULLpermissions_2025-xx-xx"

##Add the name of the API Client
#api_client_displayName="APIClient_FULLpermissions_2025-xx-xx"

#The access token lifetime in seconds 
lifetime="300"

# ===============

# If you're on Jamf Pro 10.34.2 or earlier, which doesn't support using Bearer Tokens
# for Classic API authentication, set the NoBearerToken variable to the following value
# as shown below:
#
# yes
#
# NoBearerToken="yes"
#
# If you're on Jamf Pro 10.35.0 or later, which does support using Bearer Tokens
# for Classic API authentication, set the NoBearerToken variable to the following value
# as shown below:
#
# NoBearerToken=""

NoBearerToken=""

GetJamfProAPIToken() {

	# This function uses Basic Authentication to get a new bearer token for API authentication.

	# Use user account's username and password credentials with Basic Authorization to request a bearer token.

	if [[ $(/usr/bin/sw_vers -productVersion | awk -F . '{print $1}') -lt 12 ]]; then
	   api_token=$(/usr/bin/curl -X POST --silent -u "${jamfpro_user}:${jamfpro_password}" "${jamfpro_url}/api/v1/auth/token" | python -c 'import sys, json; print json.load(sys.stdin)["token"]')
	else
	   api_token=$(/usr/bin/curl -X POST --silent -u "${jamfpro_user}:${jamfpro_password}" "${jamfpro_url}/api/v1/auth/token" | plutil -extract token raw -)
	fi
}

APITokenValidCheck() {

	# Verify that API authentication is using a valid token by running an API command
	# which displays the authorization details associated with the current API user. 
	# The API call will only return the HTTP status code.

	api_authentication_check=$(/usr/bin/curl --write-out %{http_code} --silent --output /dev/null "${jamfpro_url}/api/v1/auth" --request GET --header "Authorization: Bearer ${api_token}")
}

CheckAndRenewAPIToken() {

	# Verify that API authentication is using a valid token by running an API command
	# which displays the authorization details associated with the current API user. 
	# The API call will only return the HTTP status code.

	APITokenValidCheck

	# If the api_authentication_check has a value of 200, that means that the current
	# bearer token is valid and can be used to authenticate an API call.


	if [[ ${api_authentication_check} == 200 ]]; then

	# If the current bearer token is valid, it is used to connect to the keep-alive endpoint. This will
	# trigger the issuing of a new bearer token and the invalidation of the previous one.

	      if [[ $(/usr/bin/sw_vers -productVersion | awk -F . '{print $1}') -lt 12 ]]; then
	         api_token=$(/usr/bin/curl "${jamfpro_url}/api/v1/auth/keep-alive" --silent --request POST --header "Authorization: Bearer ${api_token}" | python -c 'import sys, json; print json.load(sys.stdin)["token"]')
	      else
	         api_token=$(/usr/bin/curl "${jamfpro_url}/api/v1/auth/keep-alive" --silent --request POST --header "Authorization: Bearer ${api_token}" | plutil -extract token raw -)
	      fi

	else

	# If the current bearer token is not valid, this will trigger the issuing of a new bearer token
	# using Basic Authentication.

	   GetJamfProAPIToken
	fi
}

InvalidateToken() {

	# Verify that API authentication is using a valid token by running an API command
	# which displays the authorization details associated with the current API user. 
	# The API call will only return the HTTP status code.

	APITokenValidCheck

	# If the api_authentication_check has a value of 200, that means that the current
	# bearer token is valid and can be used to authenticate an API call.

	if [[ ${api_authentication_check} == 200 ]]; then

	# If the current bearer token is valid, an API call is sent to invalidate the token.

	      authToken=$(/usr/bin/curl "${jamfpro_url}/api/v1/auth/invalidate-token" --silent  --header "Authorization: Bearer ${api_token}" -X POST)
	      
	# Explicitly set value for the api_token variable to null.

	      api_token=""

	fi
}

# If you choose to hardcode API information into the script, set one or more of the following values:
#
# The username for an account on the Jamf Pro server with sufficient API privileges
# The password for the account
# The Jamf Pro URL

# Set the Jamf Pro URL here if you want it hardcoded.
jamfpro_url=""	    

# Set the username here if you want it hardcoded.
jamfpro_user=""

# Set the password here if you want it hardcoded.
jamfpro_password=""

# If you do not want to hardcode API information into the script, you can also store
# these values in a ~/Library/Preferences/com.github.jamfpro-info.plist file.
#
# To create the file and set the values, run the following commands and substitute
# your own values where appropriate:
#
# To store the Jamf Pro URL in the plist file:
# defaults write com.github.jamfpro-info jamfpro_url https://jamf.pro.server.goes.here:port_number_goes_here
#
# To store the account username in the plist file:
# defaults write com.github.jamfpro-info jamfpro_user account_username_goes_here
#
# To store the account password in the plist file:
# defaults write com.github.jamfpro-info jamfpro_password account_password_goes_here
#
# If the com.github.jamfpro-info.plist file is available, the script will read in the
# relevant information from the plist file.

if [[ -f "$HOME/Library/Preferences/com.github.jamfpro-info.plist" ]]; then

  if [[ -z "$jamfpro_url" ]]; then
     jamfpro_url=$(defaults read $HOME/Library/Preferences/com.github.jamfpro-info jamfpro_url)
  fi     

  if [[ -z "$jamfpro_user" ]]; then
     jamfpro_user=$(defaults read $HOME/Library/Preferences/com.github.jamfpro-info jamfpro_user)
  fi
  
  if [[ -z "$jamfpro_password" ]]; then
     jamfpro_password=$(defaults read $HOME/Library/Preferences/com.github.jamfpro-info jamfpro_password)
  fi

fi

# If the Jamf Pro URL, the account username or the account password aren't available
# otherwise, you will be prompted to enter the requested URL or account credentials.

if [[ -z "$jamfpro_url" ]]; then
     read -p "Please enter your Jamf Pro server URL : " jamfpro_url
fi

if [[ -z "$jamfpro_user" ]]; then
     read -p "Please enter your Jamf Pro user account : " jamfpro_user
fi

if [[ -z "$jamfpro_password" ]]; then
     read -p "Please enter the password for the $jamfpro_user account: " -s jamfpro_password
fi

echo ""

# Remove the trailing slash from the Jamf Pro URL if needed.
jamfpro_url=${jamfpro_url%%/}

# If configured to get one, get a Jamf Pro API Bearer Token
	
if [[ -z "$NoBearerToken" ]]; then
    GetJamfProAPIToken
fi

# # ===============

#GET all the current available privileges for an API Role
json=$(curl --request GET \
--url ${jamfpro_url}/api/v1/api-role-privileges \
--header "authorization: Bearer ${api_token}" \
--header 'accept: application/json')

#Extract ALL the API privileges available
privileges=$(echo "$json" | jq -r '.privileges[]' | awk '{printf "\"%s\", ", $0}' | sed 's/, $//')

#Create API Role
response=$(curl --request POST \
--url "${jamfpro_url}/api/v1/api-roles" \
--header "authorization: Bearer ${api_token}" \
--header 'accept: application/json' \
--header 'content-type: application/json' \
--data "{
	\"displayName\": \"$api_role_displayName\",
	\"privileges\": [
		$privileges
	]
}")

#Extract displayName to use in next call
displayName=$(echo "$response" | jq -r '.displayName' | sed 's/displayName: //')

#Create API Client
response=$(curl --request POST \
--url "${jamfpro_url}/api/v1/api-integrations" \
--header "authorization: Bearer ${api_token}" \
--header 'accept: application/json' \
--header 'content-type: application/json' \
--data "{
	\"displayName\": \"$api_client_displayName\",
	\"enabled\": \"true\",
	\"accessTokenLifetimeSeconds\": \"$lifetime\",
	\"authorizationScopes\": [
		\"$displayName\"
	]
}")

#Extract id of the API Client to use in next call
Id=$(echo "$response" | jq -r '.id')

#Create API Client Secret
response=$(curl --request POST \
--url "${jamfpro_url}/api/v1/api-integrations/$Id/client-credentials" \
--header "authorization: Bearer ${api_token}" \
--header 'accept: application/json' )

#Extract the Client ID and Client Secret and print then out
clientId=$(echo "$response" | jq -r '.clientId')
clientSecret=$(echo "$response" | jq -r '.clientSecret')

echo "clientId: $clientId"
echo "clientSecret: $clientSecret"
