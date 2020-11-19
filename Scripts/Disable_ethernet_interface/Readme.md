## Script

- The script primarily uses the commands :
- `networksetup -listnetworkserviceorder`
- `networksetup -setnetworkserviceenabled "${networkService}" off`

## LaunchDaemon

- You can launch the script by adding in the launchDemon :
- `<key>WatchPaths</key><string>/Library/Preferences/SystemConfiguration</string>`
OR
- `<key>WatchPaths</key><string>/Library/Preferences/</string>`

