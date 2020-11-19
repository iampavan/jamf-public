## Script

- `disable_ethernet.zsh`
- The script primarily uses the commands :
- `networksetup -listnetworkserviceorder`
- `networksetup -setnetworkserviceenabled "${networkService}" off`

## LaunchDaemon

- `com.company.disable_ethernet_interface.plist`
- You can launch the script by adding in the launchDemon :
- `<key>WatchPaths</key><string>/Library/Preferences/SystemConfiguration</string>`
- OR
- `<key>WatchPaths</key><string>/Library/Preferences/</string>`

## Packages

- Contains Installer package, preinstall and postinstall script
