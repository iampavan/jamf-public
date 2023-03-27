#!/bin/bash

# Description: Checks for errors with the com.apple.ManagedClient subsystem within the last day
# Returns only the last 3 lines of errors 

results=$(log show --last 1d --predicate 'subsystem == "com.apple.ManagedClient"' |\
 awk '/\[ERROR\]/ && !/The Internet connection appears to be offline/ && !/returned error: <No response>/' |\
 tail -n 3)

if [ "$results" != "" ]; then
    echo "<result>$results</result>"
else
    echo "<result>No errors in last 1 day</result>"
fi

exit 0