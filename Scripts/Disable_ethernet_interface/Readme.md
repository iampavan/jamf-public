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

- Installer was created using *Whitebox Packages*
    - Ref : https://derflounder.wordpress.com/2019/03/20/building-an-installer-package-for-privileges-app/

- Uninstaller was created using *Payload-Free Package Creator.app*
    - Ref : https://derflounder.wordpress.com/2015/05/21/payload-free-package-creator-app-revisited/
