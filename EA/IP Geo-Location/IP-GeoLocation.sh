#!/bin/bash

# Here's one that accurately reports the Geo-Location based on the External IP address and requires no API key or sign-up as it's using the API from https://ip-api.com

# Get the machine's external IP address
externalIP=$(curl -Ls --max-time 10 'https://api.ipify.org')

# Get the location information from `ip-api.com` based on the IP address above
# More info on what `fields` can be included: https://ip-api.com/docs/api:xml
locationXML=$(curl -s --max-time 10 "http://ip-api.com/xml/${externalIP}?fields=status,message,countryCode,regionName,city,lat,lon")

# Extract the `status` field to check that it was successful
queryStatus=$(xmllint --xpath 'query/status/text()' - <<<"$locationXML")

# Check to make sure the query was successful
if [[ "$queryStatus" = "fail" ]]; then
  # Extract the message and set that as the extension attribute output
  queryMessage=$(xmllint --xpath 'query/message/text()' - <<<"$locationXML")

  output="$queryMessage"
else
  # Extract the City, State, and Country Code from the results
  city=$(xmllint --xpath 'query/city/text()' - <<<"$locationXML")
  regionName=$(xmllint --xpath 'query/regionName/text()' - <<<"$locationXML")
  countryCode=$(xmllint --xpath 'query/countryCode/text()' - <<<"$locationXML")

  # Extract the Latitude and Longitude as well
  latitude=$(xmllint --xpath 'query/lat/text()' - <<<"$locationXML")
  longitude=$(xmllint --xpath 'query/lon/text()' - <<<"$locationXML")

  output="$city, $regionName - $countryCode
  $latitude, $longitude"
fi

# Output the result for the extension attribute
echo "<result>$output</result>"