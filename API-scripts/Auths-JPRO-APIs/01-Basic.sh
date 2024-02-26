#!/bin/bash

url="https://yourserver.jamfcloud.com"
username="yourUsername"
password="yourPassword"

# Finds all categories
# https://developer.jamf.com/jamf-pro/reference/findcategories
/usr/bin/curl -s "$url/JSSResource/categories" \
    --user "$username":"$password" \
    --header 'accept: application/json' \
    --request GET


# Output :

# {"categories":[{"id":61,"name":"3rd Party Apps plugins"},{"id":45,"name":"Adobe"},.......,{"id":125,"name":"Zoom"}]}