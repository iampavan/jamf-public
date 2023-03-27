#!/bin/sh
        
# Extension attribute for IP Geo Location
# It goes against Apple’s idea of privacy
# Maybe used incase of stolen Macs

# BTW it won't be accurate because it depends on public IP it resolves to
        
myIP=`curl -L -s --max-time 10 http://checkip.dyndns.org | egrep -o -m 1 '([[:digit:]]{1,3}\.){3}[[:digit:]]{1,3}'`

# You need to register to IP stack (https://ipstack.com) to grab an api key
API_TOKEN='xxxxxxxxxxxx'

myLocationInfo=`curl -s --max-time 10 "http://api.ipstack.com/${myIP}?access_key=${API_TOKEN}&output=xml"`

myCountryCode=`echo $myLocationInfo|egrep -o '<country_code>.*</country_code>'| sed -e 's/^.*<country_code/<country_code/' | cut -f2 -d'>'| cut -f1 -d'<'`
myCity=`echo $myLocationInfo|egrep -o '<city>.*</city>'| sed -e 's/^.*<city/<city/' | cut -f2 -d'>'| cut -f1 -d'<'`
myRegionName=`echo $myLocationInfo|egrep -o '<region_name>.*</region_name>'| sed -e 's/^.*<region_name/<region_name/' | cut -f2 -d'>'| cut -f1 -d'<'`

echo "<result>$myCity, $myRegionName - $myCountryCode</result>"