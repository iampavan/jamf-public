#!/bin/sh

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
# Force quit all non-essential applications
# 
####################################################################################################


declare -a killPIDs
killPIDs=$(ps axww -o pid,command | grep -v bash | grep [A]pplications/ | grep -v /bin/sh | grep -v [C]asper | grep -v [J]amf | grep -v [S]elf\ Service | grep -v [M]cAfee | grep -v [V]ZAccess* | grep -v grep | awk '{print $1}')

#Kill said processes.

for i in ${killPIDs[@]}
do
    echo "Killing PID $i"
    kill -9 $i
done

exit 0