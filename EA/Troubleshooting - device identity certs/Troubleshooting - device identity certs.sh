#!/bin/bash

# scrapes the keychain for device identity certs.
# The EA may or may not work depending on how long the customer CA name is.

theIDs=$(security find-identity -v | awk '{print $3}' | tr -d '"' | grep -E '^[A-Za-z0-9]{8}-[A-Za-z0-9]{4}-[A-Za-z0-9]{4}-[A-Za-z0-9]{4}-[A-Za-z0-9]{12}$')

if [ -z "$theIDs" ]; then
	echo "<result>Not Found</result>"
else
	for i in $theIDs; do
		# info=$(security find-certificate -c "$i" | grep issu | awk '{print $4, $5, $6, $7, $8, $9, $10}' | tr -d '"')
        info=$(security find-certificate -c "$i" | grep issu | awk '{print $8, $9, $10, $11}' | tr -d '"')
		if [[ $info == *"JSS BUILT-IN CERTIFICATE AUTHORITY"* ]]; then
			expiry=$(security find-certificate -c "$i" -p | openssl x509 -noout -enddate | cut -f2 -d"=")
			echo "<result>Device cert: $i - Expiry: $expiry</result>"
		fi
	done
fi
