#!/bin/bash

# Use case :
# Let's say Jamf Policy contains a package + script 
# If Package installation fails (for whatever reason), the script should not execute

export PATH=/usr/bin:/bin:/usr/sbin:/sbin:/usr/libexec:/usr/local/jamf/bin

scriptName=$(basename "$0")

####################################################################################
# FUNCTIONS
####################################################################################

function scriptLogging {
    
    local eventTimestamp
    eventTimestamp=$(date "+%a %b %d %H:%M:%S")
    
    local localHostName
    localHostName=$(scutil --get ComputerName)
    
    local jamfPID
    jamfPID=$(pgrep -ax jamf | grep -v grep | tail -n1)
    
    if [[ -z "$jamfPID" ]]; then
    	# echo "jamf PID not found. Checking JamfDaemon PID..."
     	jamfPID=$(pgrep JamfDaemon)

	if [[ -z "$jamfPID" ]]; then
        	# echo "JamfDaemon PID also not found."
        	jamfPID=$$ # Using shell PID.
     	fi
    fi
    
    local jamfLog
    jamfLog="/var/log/jamf.log"
    
    # echo "${eventTimestamp}" "${localHostName}" "jamf[${jamfPID}]:" "$1" | tee -a "${jamfLog}"
    echo "${eventTimestamp}" "${localHostName}" "jamf[${jamfPID}]:" "${scriptName} -" "$1" | tee -a "${jamfLog}"
}

####################################################################################
# MAIN LOGIC
####################################################################################

## Method 1 - Check presense of file/directory
BUNDLE_PATH="/Library/Security/SecurityAgentPlugins/Escrow Buddy.bundle"
if [ -f "$BUNDLE_PATH/Contents/Info.plist" ]; then
    scriptLogging "App is installed. Proceeding.."
else
    scriptLogging "App is missing. Exiting"
    exit 1
fi

####################################################################################

## Method 2 - Check package receipt

# Verify package installation
echo "Verifying installation..."
if /usr/sbin/pkgutil --pkg-info sh.brew.homebrew; then
  echo "Package receipt found"
else
  err "Installation failed. No package receipt found"
  exit 1
fi

####################################################################################

## Method 3 - Check package receipt (another way)
# https://github.com/kandji-inc/support/blob/main/Scripts/xcode-cli-tools-installer/xcode_cli_tools_installer.zsh

# current pkg bundleid
bundle_id="com.company.euc.EscrowBuddy"

########
# After the package installation, you can use pkgutil command to determine .
# For example:
# pkgutil --pkgs | grep com.company
# pkgutil --pkgs="com.company.euc.EscrowBuddy"
# pkgutil --pkg-info="com.company.euc.EscrowBuddy"
########

if /usr/sbin/pkgutil --pkgs="$bundle_id" >/dev/null; then
    # If the pkg bundle is found, get the version

    installed_version=$(/usr/sbin/pkgutil --pkg-info="$bundle_id" |
        /usr/bin/awk '/version:/ {print $2}' |
        /usr/bin/awk -F "." '{print $1"."$2}')

    /bin/echo "Installed CLI tools version is \"$installed_version\""

else
    /bin/echo "Unable to determine installed CLI tools version from \"$bundle_id\"."
fi

####################################################################################

## Method 4 - Check package receipt (another way)
# https://github.com/SecondSonConsulting/macOS-Scripts/blob/main/installGenericPKG.sh

# Package Identifier and Expected Version. If the device already has a receipt for this package ID for the specified version, script will exit
expectedPackageID=""

expectedPackageVersion=""

# Check if the specified expectedPackageID and version have already run on this machine
function check_package_receipt(){
    # If the expectedPackageID variable is not empty
    if [ ! -z "$expectedPackageID" ] || [ ! -z "$expectedPackageVersion" ];then
        # Verify a version has also been included. Otherwise, exit with an error (this is a misconfiguration)
        if [ -z "$expectedPackageID" ] || [ -z "$expectedPackageVersion" ]; then
            cleanup_and_exit 1 "ERROR: Misconfiguration. Both expectedPackageID and expectedPackageVersion are required if using that feature."
        fi
        # Check the receipts and get the version if it exists
        installedPackageVersion=$(/usr/libexec/PlistBuddy -c 'Print :pkg-version' /dev/stdin <<< "$(pkgutil --pkg-info-plist "$expectedPackageID" 2> /dev/null)" 2> /dev/null)
        # Check if the install is not needed
        if [[ "$installedPackageVersion" == "$expectedPackageVersion" ]]; then
            echo "$scriptName - $scriptVersion"
            echo "$(date '+%Y%m%dT%H%M%S%z'): "
            echo "Package ID $expectedPackageID is already on $expectedPackageVersion no action needed"
            cleanup_and_exit 0 "Success"
        else
            echo "No receipt for $expectedPackageID $expectedPackageVersion - Proceeding with install"
        fi
    else
        echo "No Package ID defined"
    fi
}

# Check whether this package has already been successfully installed
check_package_receipt
