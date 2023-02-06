#!/bin/bash
#
####################################################################################################
#
# Shout out to Mark Adams.
#
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
# - Script will generate computer or device records for your test instance.
#
# - We enter the number of computers or devices that we want to create, it will then create a
#	computer (picking a random model from an array), pick a random user, department and building for 
#	the 'Location' details.
#
# - When creating the record it will randomly generate things like the UDID, Macaddr, IPaddr, 
#	memorySize, osversion and buildversion and more.
# 
####################################################################################################


jssURL='https://instancename'
apiUser='apiuser'
apiPass='apipassword'

# This program with create computer or device records along with a user for your Jamf Pro test instance,
# apon creating the computer or device it will save the UDID to file file called either
# computers.txt or mobiledevices.txt to delete the created records if whished.

# 1. Things to do give the applications dynamic versions numbers so you 
# could search for different version, rather that being static versions.

# 2. Create an input selector to ask what do you want to do.

# I guess this is a niche piece of code so feel free to modifiy if required or suggested new features.

# Delete computer/device records
delete_records (){
	
	local endpoint=$1
	
	if [ -z "$endpoint" ]; then
		printf "Input is empty, we need either the value computers or mobiledevices."
	else
		if [ "$endpoint" == "computers" ] || [ "$endpoint" == "mobiledevices" ]; then
			input="/Users/Shared/"$endpoint".txt"
		fi
		
		# Read either the computers or mobiledevices file and delete the record(s)
		while IFS= read -r line
		do
			curl -su ${apiUser}:${apiPass} -X DELETE ${jssURL}/JSSResource/${endpoint}/name/"$line" --output /dev/null
			# Print something to the screen, on a single line.
			printf "\033[2K \rDeleting record %s" "${line}"
		done	< "$input"
	fi
	
	# Delete the contents of the file.
	: > "/Users/Shared/"$endpoint".txt"
}

# So I like using arrays
names=( "Ford Prefect" "Arthur Dent" "Zaphod Beeblebrox" "Slartibartfast" "Hari Seldon" "Dors Venabili" "Leonard Hofstadter" "Sheldon Cooper" "Howard Wolowitz" "Raj Koothrappali" "Amy Fowler" "Stuart Bloom" "Leslie Winkle" "Hober Mallow" "Yohan Lee" "Golan Trevize" "Meredith Grey" "Jean-Luc Picard" "Han Solo" "Luke Skywalker" "Darth Vader" "Indiana Jones" "John Connor" "Marty McFly" "Jake Peralta" "Owen Hunt" "Emmett Brown" "Alex Rogan" "John Anderton" "Judge Dredd" "Agent Smith" "John McLane" "Jason Bourne" "Peter Venkman" "Ray Stantz" "Egon Spengler" "Venatius Koth" "Johnny Mnemonic" "Ellen Ripley" "Darth Vader" "Richard Webber" "John Crichton" "Roy Batty" "Jack Harkness" "Dana Scully" "Fox Mulder" "Bernard Quatermass" "Jack O’Neill" "Luke Skywalker" "Ben Kenobi" "Samantha Carter" "William Adama" "River Tam" "Roj Blake" "Kathryn Janeway" "Gaius Baltar" "James Bond" "Dave Lister" "The Doctor" "Amy Pond" "Leia Organa" "Penny Lane" "Arnold Rimmer" "Derek Shepherd" "Raymond Holt" "Ellie Arroway" "Izzie Stevens" "Kara Thrace" "Sarah Connor" "Seven OfNine" "Groot" "James Kirk" "Peter Parker" "Bruce Banner" "Tony Stark" "Pepper Pots" "Clint Barton" "Natasha Romanoff" "Steve Rogers" "Olivia Dunham" "Katniss Everdeen" "Mark Sloan" "Cristina Yang" "George O'Malley" "Sarah Manning" "Laura Roslin" "Asuka Soryu" "Nyota Uhura" "Zoe Washburne" "Frodo Baggins" "Bilbo Baggings" "Hoshi Sato" "Zoe Heriot" "Deanna Troi" "Padme Amidala" "Elanna Torres" "Carmen Ibanez" "Beverly Crusher" "Rosa Diaz" "Terry Jeffords" "Ann McGregor" "Borg Queen" "Teyla Emmagan" "Kristine Kochanski" "Lindsey Brigman" "Jadzia Dax" "Sharon Valeri" "Wade Welles" "Wilma Deering" "Rose Tyler" "Martha Jones" "Theora Jones" "Jo Grant" "Inara Serra" "Princess Aura" "Flash Gordon" "Preston Burke" "Stephanie Speck" "Gina Linetti" "Amy Santiago" "Douglas Quaid" "Kaylee Frye" "Ro Laren" "River Song" "Maggie Beckett" "Cora Peterson" "Charles Boyle" "Gwen Cooper" "Addison Montgomery" "Boba Fett" "Harry Potter" "Malcolm Reynolds" "Willy Wonka" "Optimus Prime" "Harry Harrison" "Buck Rogers" "HAL 9000" "John Carter" "Daniel Jackson" "Garrus Vakarian" "Hermione Granger" "Master Chief" "Albus Dumbledore" "Abe Sapien" "Benjamin Sisko" "Gul Dukat" "Leonard McCoy" "Logan Five" "Montgomery Scott" "Captain Nemoy" "Jenette Vasques" "Peter Pan" "Vilos Cohaagen" "John McClane" "Hans Gruber" "Holly Gennero" "Simom Gruber" "Jack West" "Jonathan Archer" "Travis Mayweather" "Charles Tucker" "Malcolm Reed" "William Riker" "Wesley Crusher" "Miranda Bailey" )
random_name (){
		local random_index=$((RANDOM % ${#names[@]}))
		local random_element="${names[$random_index]}"
		local email_domain="hogbytes.net"
		local full_name="${names[$random_index]}"
		local lowercase_name=$(echo "${full_name}" | tr '[:upper:]' '[:lower:]' | tr ' ' '.')
		local short_name="${lowercase_name}"
		local email_address="$lowercase_name@$email_domain"
		local result=( "${email_address}" "${short_name}" )
		echo "${result[@]}"
}


# It's better that having a long xml list you could also change the calculation to randomly add only a select few apps.
appXml=( "Activity Monitor.app" "/System/Applications/Utilities/Activity Monitor.app" "10.14" "com.apple.ActivityMonitor" "AirPort Utility.app" "/System/Applications/Utilities/AirPort Utility.app" "6.3.9" "com.apple.airport.airportutility" "App Store.app" "/System/Applications/App Store.app" "3.0" "com.apple.AppStore" "Audio MIDI Setup.app" "/System/Applications/Utilities/Audio MIDI Setup.app" "3.5" "com.apple.audio.AudioMIDISetup" "Automator.app" "/System/Applications/Automator.app" "2.10" "com.apple.Automator" "Bluetooth File Exchange.app" "/System/Applications/Utilities/Bluetooth File Exchange.app" "9.0" "com.apple.BluetoothFileExchange" "Books.app" "/System/Applications/Books.app" "4.4" "com.apple.iBooksX" "Boot Camp Assistant.app" "/System/Applications/Utilities/Boot Camp Assistant.app" "6.1.0" "com.apple.bootcampassistant" "Calculator.app" "/System/Applications/Calculator.app" "10.16" "com.apple.calculator" "Calendar.app" "/System/Applications/Calendar.app" "11.0" "com.apple.iCal" "Chess.app" "/System/Applications/Chess.app" "3.18" "com.apple.Chess" "ColorSync Utility.app" "/System/Applications/Utilities/ColorSync Utility.app" "12.0.0" "com.apple.ColorSyncUtility" "Console.app" "/System/Applications/Utilities/Console.app" "1.1" "com.apple.Console" "Contacts.app" "/System/Applications/Contacts.app" "2498.5" "com.apple.AddressBook" "Dictionary.app" "/System/Applications/Dictionary.app" "2.3.0" "com.apple.Dictionary" "Digital Color Meter.app" "/System/Applications/Utilities/Digital Color Meter.app" "5.22" "com.apple.DigitalColorMeter" "Discord.app" "/Applications/Discord.app" "0.0.270" "com.hnc.Discord" "Disk Utility.app" "/System/Applications/Utilities/Disk Utility.app" "21.5" "com.apple.DiskUtility" "FaceTime.app" "/System/Applications/FaceTime.app" "5.0" "com.apple.FaceTime" "Falcon.app" "/Applications/Falcon.app" "6.14" "com.crowdstrike.falcon.App" "FindMy.app" "/System/Applications/FindMy.app" "3.0" "com.apple.findmy" "Font Book.app" "/System/Applications/Font Book.app" "10.0" "com.apple.FontBook" "GarageBand.app" "/Applications/GarageBand.app" "10.4.1" "com.apple.garageband10" "Google Chrome.app" "/Applications/Google Chrome.app" "108.0.5359.124" "com.google.Chrome" "Google Earth Pro.app" "/Applications/Google Earth Pro.app" "7.3" "com.Google.GoogleEarthPro" "Grapher.app" "/System/Applications/Utilities/Grapher.app" "2.7" "com.apple.grapher" "Home.app" "/System/Applications/Home.app" "6.0" "com.apple.Home" "Image Capture.app" "/System/Applications/Image Capture.app" "8.0" "com.apple.Image_Capture" "iMovie.app" "/Applications/iMovie.app" "10.3.5" "com.apple.iMovieApp" "Keychain Access.app" "/System/Applications/Utilities/Keychain Access.app" "11.0" "com.apple.keychainaccess" "Keynote.app" "/Applications/Keynote.app" "10.3.5" "com.apple.iWork.Keynote" "Launchpad.app" "/System/Applications/Launchpad.app" "1.0" "com.apple.launchpad.launcher" "LockDown Browser OEM.app" "/Applications/LockDown Browser OEM.app" "2.0.6" "com.Respondus.LockDownBrowserOEM" "Lunar Client.app" "/Applications/Lunar Client.app" "2.10.0" "com.moonsworth.client" "Mail.app" "/System/Applications/Mail.app" "16.0" "com.apple.mail" "Maps.app" "/System/Applications/Maps.app" "3.0" "com.apple.Maps" "Messages.app" "/System/Applications/Messages.app" "14.0" "com.apple.MobileSMS" "Microsoft Excel.app" "/Applications/Microsoft Excel.app" "16.66.22101101" "com.microsoft.Excel" "Microsoft OneNote.app" "/Applications/Microsoft OneNote.app" "16.68.22121100" "com.microsoft.onenote.mac" "Microsoft Outlook.app" "/Applications/Microsoft Outlook.app" "16.68.22121100" "com.microsoft.Outlook" "Microsoft PowerPoint.app" "/Applications/Microsoft PowerPoint.app" "16.67.22111300" "com.microsoft.Powerpoint" "Microsoft Teams.app" "/Applications/Microsoft Teams.app" "531156" "com.microsoft.teams" "Microsoft Word.app" "/Applications/Microsoft Word.app" "16.67.22111300" "com.microsoft.Word" "Migration Assistant.app" "/System/Applications/Utilities/Migration Assistant.app" "12.6" "com.apple.MigrateAssistant" "Minecraft.app" "/Applications/Minecraft.app" "1.1.32" "com.mojang.minecraftlauncher" "Mission Control.app" "/System/Applications/Mission Control.app" "1.2" "com.apple.exposelauncher" "Music.app" "/System/Applications/Music.app" "1.2.5" "com.apple.Music" "News.app" "/System/Applications/News.app" "7.3.2" "com.apple.news" "Notes.app" "/System/Applications/Notes.app" "4.9" "com.apple.Notes" "Numbers.app" "/Applications/Numbers.app" "10.3.5" "com.apple.iWork.Numbers" "OneDrive.app" "/Applications/OneDrive.app" "22.238.1114" "com.microsoft.OneDrive" "Pages.app" "/Applications/Pages.app" "10.3.5" "com.apple.iWork.Pages" "Photo Booth.app" "/System/Applications/Photo Booth.app" "12.2" "com.apple.PhotoBooth" "Photos.app" "/System/Applications/Photos.app" "7.0" "com.apple.Photos" "Podcasts.app" "/System/Applications/Podcasts.app" "1.1.0" "com.apple.podcasts" "Preview.app" "/System/Applications/Preview.app" "11.0" "com.apple.Preview" "QuickTime Player.app" "/System/Applications/QuickTime Player.app" "10.5" "com.apple.QuickTimePlayerX" "Reminders.app" "/System/Applications/Reminders.app" "7.0" "com.apple.reminders" "Safari.app" "/Applications/Safari.app" "15.6.1" "com.apple.Safari" "Screenshot.app" "/System/Applications/Utilities/Screenshot.app" "1.0" "com.apple.screenshot.launcher" "Script Editor.app" "/System/Applications/Utilities/Script Editor.app" "2.11" "com.apple.ScriptEditor2" "Self Service.app" "/Applications/Self Service.app" "10.42.0" "com.jamfsoftware.selfservice.mac" "Shortcuts.app" "/System/Applications/Shortcuts.app" "5.0" "com.apple.shortcuts" "Siri.app" "/System/Applications/Siri.app" "1.0" "com.apple.siri.launcher" "Steam.app" "/Applications/Steam.app" "4.0" "com.valvesoftware.steam" "Stickies.app" "/System/Applications/Stickies.app" "10.2" "com.apple.Stickies" "Stocks.app" "/System/Applications/Stocks.app" "4.3.2" "com.apple.stocks" "System Information.app" "/System/Applications/Utilities/System Information.app" "11.0" "com.apple.SystemProfiler" "System Preferences.app" "/System/Applications/System Preferences.app" "15.0" "com.apple.systempreferences" "Terminal.app" "/System/Applications/Utilities/Terminal.app" "2.12.7" "com.apple.Terminal" "TextEdit.app" "/System/Applications/TextEdit.app" "1.17" "com.apple.TextEdit" "Time Machine.app" "/System/Applications/Time Machine.app" "1.3" "com.apple.backup.launcher" "TV.app" "/System/Applications/TV.app" "1.2.5" "com.apple.TV" "VoiceMemos.app" "/System/Applications/VoiceMemos.app" "2.3" "com.apple.VoiceMemos" "VoiceOver Utility.app" "/System/Applications/Utilities/VoiceOver Utility.app" "10" "com.apple.VoiceOverUtility" "zoom.us.app" "/Applications/zoom.us.app" "5.7.1 (499)" "us.zoom.xos" )
create_applications (){
	for (( i=0; i<${#appXml[@]}; i+=4 )); do
		local result=( "${appXml[@]:${i}:4}" )
		local applicationXml="<application>
			<name>"${result[0]}"</name>
			<path>"${result[1]}"</path>
			<version>"${result[2]}"</version>
			<bundle_id>"${result[3]}"</bundle_id>
						</application>"
		local appsXml+="${applicationXml}"
		echo "$appsXml"
	done
}


# Current and some past versions of IOS
iosVersions=( 14.1 18A8395 14.2 18B111 14.3 18C66 14.4 18D52 14.4.1 18D61 14.4.2 18D70 14.5 18E199 14.5.1 18E212 15.4 19E241 15.5 19F77 15.6 19G71 15.7 19H12 16.1 20B82 16.2 20C65 16.3 20D47 )
generateIOSversion(){
	local seed=$(expr ${#iosVersions[@]} / 2)
	local random_number=$((RANDOM % ${seed}))
	local result=$((random_number * 2))
	echo ${iosVersions[@]:${result}:2}
}

# Current and some past versions of macOS
macOS=( 10.15.7 19H1030 11.2.3 20D91 11.3 20E232 11.3.1 20E241 12.0 21A344 12.0.1 21A559 12.1 21C52 12.2 21D49 12.2.1 21D62 12.3 21E230 12.3.1 21E258 12.4 1F2092 12.5.1 21G83 12.6 21G115 12.6.1 21G217 12.6.2 21G320 12.6.3 21G419 13.0 22A380 13.1 22C65 13.2 22D49 )
generatemacOS(){
	local seed=$(expr ${#macOS[@]} / 2)
	local random_number=$((RANDOM % ${seed}))
	local result=$((random_number * 2))
	echo ${macOS[@]:${result}:2}
}

# Memory sizes to use, won'y be realistic for the device.
memory=( 65535 262144 524288 131072 1048576 2097152 )
generateMemory(){
	local seed=$(expr ${#memory[@]} / 1)
	local random_number=$((RANDOM % ${seed}))
	local result=$((random_number * 1))
	echo ${memory[${result}]}
}

# Department creation, eel free to change to more suitable
department=( Black Brown Red Orange Yellow Green Blue Violet Grey Fjords )
generateDepartment(){
	local arrayLength=${#department[@]}
	local randomNumber=$(jot -r 1 0 ${arrayLength})
	echo ${department[${randomNumber}]}
}

# Building creation, feel free to change to more suitable locations.
building=( Sydney Melbourne Darwin Queensland Adelaide Perth Tasmania ACT Costal )
generateBuilding(){
	local arrayLength=${#building[@]}
	local randomNumber=$(jot -r 1 0 ${arrayLength})
	echo ${building[${randomNumber}]}
}

# Generate computers
computer=( iMac21,2 Apple_M1 arm64 3200 1 8 16384 iMac20,1 Intel_Core_i7 x86_64 3800 1 8 32768 iMac20,2 Intel_Core_i7 x86_64 3600 1 10 65536  iMac20,1 Intel_Core_i9 x86_64 3600 1 8 131072  iMac20,2 Intel_Core_i9 x86_64 3800 1 10 131072  MacPro7,1 Intel_Xeon_W_3223 x86_64 3500 1 28 1048576 MacPro7,1 Intel_Xeon_W_3245 x86_64 3500 1 28 1048576 MacPro7,1 Intel_Xeon_W_3223 x86_64 3500 1 28 1048576 MacPro7,1 Intel_Xeon_W_3275M x86_64 3500 1 28 1048576 Macmini8,1 Intel_Core_i7 x86_64 3600 1 6 65536 Macmini8,1 Intel_Core_i5 x86_64 3000 1 6 32768 Macmini8,1 Intel_Core_i7 x86_64 3600 1 6 65536 Macmini8,1 Intel_Core_i7 x86_64 3200 1 6 32768 Macmini9,1 Apple_M1 arm64 3200 1 8 8192 Macmini9,1 Apple_M1 arm64 3200 1 8 16384 Macmini9,1 Apple_M1 arm64 3200 1 8 16384 Macmini9,1 Apple_M1 arm64 3200 1 8 16384 )
generateComputer(){
	local macOS=( $(generatemacOS) )
	local seed=$(expr ${#computer[@]} / 7)
	local random_number=$((RANDOM % ${seed}))
	local result=$((random_number * 7))
	local result=( ${computer[@]:${result}:7} ${macOS[@]})
	echo ${result[@]}
}

# Generate IOS devices
Devices=( iPad12,1 A2602 iPad12,2 A2605 iPad14,1 A2567 iPad14,2 A2569 iPad13,16 A2588 iPad13,17 A2591 iPad13,18 A2696 iPad13,19 A2777 iPad14,3 A2759 iPad14,4 A2762 iPad14,5 A2436 iPad14,6 A2766 iPhone13,3 3547 iPhone13,1 A2399 iPhone13,4 A2411 iPhone14,5 A2633 iPhone14,4 A2628 iPhone14,2 A2638 iPhone14,3 A2643 iPhone14,6 A2783 iPhone14,7 A2882 iPhone15,2 A2890 iPhone15,3 A2894 iPhone14,8 A2886 )
generate_device(){
	local memory=( $(generateMemory) )
	local iOS=( $(generateIOSversion) )
	local seed=$(expr ${#Devices[@]} / 2)
	local random_number=$((RANDOM % ${seed}))
	local result=$((random_number * 2))
	local result=( ${Devices[@]:${result}:2} ${iOS[@]} ${memory} )
	echo ${result[@]}
}

# This is where we create the IOS device record
create_mobiledevices (){
	local number_of_devices=$1
	if [ -z "$number_of_devices" ]; then
		printf "Input is empty, we need a number from 1 to whatever so I can generate the device record(s).\n"
	else
	for ((anitem = 0 ; anitem < ${number_of_devices} ; anitem++)); do
	
	local device_name="HBIOS-"
	# Get the IOS model we are going to use for this record.
	local device=( $(generate_device) )
	# Generate a random UDID of the IOS device.
	local udid=$(openssl rand -hex 20)
	# Create a 6 digit random number of the asset tage
	local asset=$(((RND=RANDOM<<15|RANDOM)) ; echo ${RND: -6})

	local model_identifier="${device[0]}"
	local model_number="${device[1]}"
	local capacity="${device[4]}"
	local os_version="${device[2]}"
	local os_build="${device[3]}"
	
	result=$((RANDOM % 2))
	if [ $result -eq 0 ]; then
		local binary="false"
	else
		local binary="true"
	fi

	# Create name
	name=( $(random_name) )
	local email_address="${name[0]}"
	local short_name="${name[1]}"
	local full_name="${name[2]}"
	local full_name=$( echo "${short_name}" | tr . ' ' | awk '{print toupper(substr($1,1,1)) substr($1,2) " " toupper(substr($2,1,1)) substr($2,2)}' )
	
	xmlData="<mobile_device>
			<general>
				<asset_tag>"${device_name}${asset}"</asset_tag>
				<capacity>${capacity}</capacity>
				<available>118249</available>
				<percentage_used>$(jot -r 1 0 100)</percentage_used>
				<name>${device_name}${asset}</name>
				<udid>${udid}</udid>
				<os_type>iOS</os_type>
				<os_version>${os_version}</os_version>
				<os_build>${os_build}</os_build>
				<serial_number>$(echo "DMPZ"$(openssl rand -base64 32 | tr -dc 'A-Z0-9' | head -c8))</serial_number>
				<ip_address>$(echo 10.200.$((RANDOM%255)).$((RANDOM%255)))</ip_address>
				<wifi_mac_address>$(echo "E0:B5:5F:"$(jot -w%02X -s: -r 3 1 256))</wifi_mac_address>
				<bluetooth_mac_address>$(echo "E0:B5:5F:"$(jot -w%02X -s: -r 3 1 256))</bluetooth_mac_address>
				<model_identifier>"${model_identifier}"</model_identifier>
				<model_number>${model_number}</model_number>
				<device_ownership_level>Institutional</device_ownership_level>
				<enrollment_method>User-initiated - no invitation</enrollment_method>
				<managed>true</managed>
				<supervised>true</supervised>
				<battery_level>$(jot -r 1 0 100)</battery_level>
			</general>
	<location>
		<username>"${short_name}"</username>
		<realname>"${full_name}"</realname>
		<real_name>"${full_name}"</real_name>
		<email_address>"${email_address}"</email_address>
		<position>$(generateDepartment)</position>
		<phone>555 44444 555</phone>
		<phone_number>555 44444 555</phone_number>
		<department>$(generateDepartment)</department>
		<building>$(generateBuilding)</building>
		<room>$((RANDOM%255))</room>
	</location>
		<security>
	<data_protection>false</data_protection>
	<block_level_encryption_capable>true</block_level_encryption_capable>
	<file_level_encryption_capable>true</file_level_encryption_capable>
	<passcode_present>"$binary"</passcode_present>
	<passcode_compliant>"$binary"</passcode_compliant>
	<passcode_compliant_with_profile>"$binary"</passcode_compliant_with_profile>
	<passcode_lock_grace_period_enforced>Immediate</passcode_lock_grace_period_enforced>
	<hardware_encryption>3</hardware_encryption>
	<activation_lock_enabled>"$binary"</activation_lock_enabled>
	<jailbreak_detected>Normal</jailbreak_detected>
	<lost_mode_enabled>"$binary"</lost_mode_enabled>
	<lost_mode_enforced>"$binary"</lost_mode_enforced>
	</security>
</mobile_device>" 
	
	# Send the IOS device record to your Jamf Pro instance
	curl -su ${apiUser}:${apiPass} \
	-X POST	-H "content-type: application/xml" \
	${jssURL}/JSSResource/mobiledevices/id/0 \
	-d "${xmlData}" --output /dev/null # <-- remove '--output' if you want to see whats going on.

	# Output something to the screen, print on the same line.
	printf "\033[2K \rCreating mobile device ${device_name}${asset} 1 of $(expr "${anitem}" + 1)"
	
	# Send UDIDs to a text file so we can use it later to delete all the create devices if needed.
	echo "${device_name}${asset}" >> /Users/Shared/mobiledevices.txt
	
	done
	fi
}            # $(expr $num1 + $num2)

# This is where we create the computer record.
create_computers (){
	local number_of_computers=$1
	if [ -z "$number_of_computers" ]; then
		printf "Input is empty, we need a number from 1 to whatever so I can generate the computer record(s).\n"
	else
	for ((counter = 0 ; counter < ${number_of_computers} ; counter++)); do

	computer_name="HBCMP-"
	
	# Get the computer model we are going to use for this record.
	computer=( $(generateComputer) )
	udid=$(uuidgen)
	asset=$(((RND=RANDOM<<15|RANDOM)) ; echo ${RND: -6})
	
		applicationsXml=$(create_applications)
	
	local model_identifier="${computer[0]}"
	local processor_type="${computer[1]}"
	local processor_architecture="${computer[2]}"
	local processor_speed="${computer[3]}"
	local number_processors="${computer[4]}"
	local number_cores="${computer[5]}"
	local total_ram="${computer[6]}"
	local os_version="${computer[7]}"
	local os_build="${computer[8]}"

	# Create name
	name=( $(random_name) )
	local email_address="${name[0]}"
	local short_name="${name[1]}"
	local full_name="${name[2]}"
	local full_name=$( echo "${short_name}" | tr . ' ' | awk '{print toupper(substr($1,1,1)) substr($1,2) " " toupper(substr($2,1,1)) substr($2,2)}' )


	xmlData="<computer>
<general>
<name>$computer_name$asset</name>
<network_adapter_type>IEEE80211</network_adapter_type>
<mac_address>$(echo "F4:EA:"$(jot -w%02X -s: -r 4 1 256))</mac_address>
<alt_network_adapter_type>Ethernet</alt_network_adapter_type>
<alt_mac_address>$(echo "82:80:"$(jot -w%02X -s: -r 4 1 256))</alt_mac_address>
<ip_address>$(echo 49.3.$((RANDOM%255)).$((RANDOM%255)))</ip_address>
<last_reported_ip>$(echo 10.200.$((RANDOM%255)).$((RANDOM%255)))</last_reported_ip>
<serial_number>$(echo "FVFC"$(openssl rand -base64 32 | tr -dc 'A-Z0-9' | head -c8))</serial_number>
<udid>${udid}</udid>
<jamf_version>10.$(echo $((36 + RANDOM % 8)))</jamf_version>
<platform>Mac</platform>
<asset_tag>"${computer_name}${asset}"</asset_tag>
<remote_management>
<managed>true</managed>
<management_username>_jssadmin</management_username>
<management_password>jamf1234</management_password>
</remote_management>
<supervised>false</supervised>
<mdm_capable>true</mdm_capable>
<mdm_capable_users>
<mdm_capable_user>"${short_name}"</mdm_capable_user>
</mdm_capable_users>
<report_date>2021-05-12 09:30:24</report_date>
<report_date_epoch>1620811824437</report_date_epoch>
<report_date_utc>2021-05-12T09:30:24.437+0000</report_date_utc>
<last_contact_time>2021-05-16 01:11:22</last_contact_time>
<last_contact_time_epoch>1621127482655</last_contact_time_epoch>
<last_contact_time_utc>2021-05-16T01:11:22.655+0000</last_contact_time_utc>
<initial_entry_date>2020-05-10</initial_entry_date>
<initial_entry_date_epoch>1589094997225</initial_entry_date_epoch>
<initial_entry_date_utc>2020-05-10T07:16:37.225+0000</initial_entry_date_utc>
<last_cloud_backup_date_epoch>0</last_cloud_backup_date_epoch>
<last_cloud_backup_date_utc/>
<last_enrolled_date_epoch>1589095031763</last_enrolled_date_epoch>
<last_enrolled_date_utc>2020-05-10T07:17:11.763+0000</last_enrolled_date_utc>
<mdm_profile_expiration_epoch>1746861412000</mdm_profile_expiration_epoch>
<mdm_profile_expiration_utc>2025-05-10T07:16:52.000+0000</mdm_profile_expiration_utc>
</general>
	<location>
		<username>"${short_name}"</username>
		<realname>"${full_name}"</realname>
		<real_name>"${full_name}"</real_name>
		<email_address>"${email_address}"</email_address>
		<position>$(generateDepartment)</position>
		<phone>555 44444 555</phone>
		<phone_number>555 44444 555</phone_number>
				<department>$(generateDepartment)</department>
				<building>$(generateBuilding)</building>
		<room>$((RANDOM%255))</room>
	</location>
<hardware>
		<make>Apple</make>
		<model_identifier>$model_identifier</model_identifier>
		<os_name>macOS</os_name>
		<os_version>$macOS</os_version>
		<os_build>$buildNumber</os_build>
		<software_update_device_id>J313AP</software_update_device_id>
		<active_directory_status>Not Bound</active_directory_status>
		<processor_type>"$processor_type"</processor_type>
		<is_apple_silicon>Yes</is_apple_silicon>
		<processor_architecture>"$processor_architecture"</processor_architecture>
		<processor_speed>"$processor_speed"</processor_speed>
		<processor_speed_mhz>"$processor_speed"</processor_speed_mhz>
		<number_processors>"$number_processors"</number_processors>
		<number_cores>"$number_cores"</number_cores>
		<total_ram>$total_ram</total_ram>
		<total_ram_mb>$total_ram</total_ram_mb>
		<boot_rom>7459.141.1</boot_rom>
		<bus_speed>0</bus_speed>
		<bus_speed_mhz>0</bus_speed_mhz>
		<battery_capacity>2</battery_capacity>
		<cache_size>0</cache_size>
		<cache_size_kb>0</cache_size_kb>
		<available_ram_slots>0</available_ram_slots>
		<nic_speed>n/a</nic_speed>
		<ble_capable>false</ble_capable>
		<supports_ios_app_installs>true</supports_ios_app_installs>
		<sip_status>Enabled</sip_status>
		<gatekeeper_status>App Store and identified developers</gatekeeper_status>
		<xprotect_version>2165</xprotect_version>
		<institutional_recovery_key>Not Present</institutional_recovery_key>
		<disk_encryption_configuration/>
		<filevault2_users>
			<user>ladmin</user>
			<user>"${short_name}"</user>
		</filevault2_users>
	<storage>
			<device>
				<disk>disk0</disk>
				<model>APPLE SSD AP0512Q</model>
				<revision>387.140.</revision>
				<serial_number>0ba0111281b82e11</serial_number>
				<size>500277</size>
				<drive_capacity_mb>500277</drive_capacity_mb>
				<connection_type>NO</connection_type>
				<smart_status>Verified</smart_status>
				<partitions>
					<partition>
						<name>xarts</name>
						<size>524</size>
						<type>other</type>
						<partition_capacity_mb>524</partition_capacity_mb>
						<percentage_full>2</percentage_full>
						<available_mb>505</available_mb>
						<filevault_status>Not Encrypted</filevault_status>
						<filevault_percent>0</filevault_percent>
						<filevault2_status>Not Encrypted</filevault2_status>
						<filevault2_percent>0</filevault2_percent>
					</partition>
					<partition>
						<name>Data</name>
						<size>494384</size>
						<type>other</type>
						<partition_capacity_mb>494384</partition_capacity_mb>
						<percentage_full>55</percentage_full>
						<available_mb>215508</available_mb>
						<filevault_status>Not Encrypted</filevault_status>
						<filevault_percent>0</filevault_percent>
						<filevault2_status>Not Encrypted</filevault2_status>
						<filevault2_percent>0</filevault2_percent>
					</partition>
					<partition>
						<name>Macintosh SSD (Boot Partition)</name>
						<size>494384</size>
						<type>boot</type>
						<partition_capacity_mb>494384</partition_capacity_mb>
						<percentage_full>7</percentage_full>
						<available_mb>215508</available_mb>
						<filevault_status>Not Encrypted</filevault_status>
						<filevault_percent>0</filevault_percent>
						<filevault2_status>Not Encrypted</filevault2_status>
						<filevault2_percent>0</filevault2_percent>
						<boot_drive_available_mb>215508</boot_drive_available_mb>
						<lvgUUID/>
						<lvUUID/>
						<pvUUID/>
					</partition>
					<partition>
						<name>Hardware</name>
						<size>524</size>
						<type>other</type>
						<partition_capacity_mb>524</partition_capacity_mb>
						<percentage_full>1</percentage_full>
						<available_mb>505</available_mb>
						<filevault_status>Not Encrypted</filevault_status>
						<filevault_percent>0</filevault_percent>
						<filevault2_status>Not Encrypted</filevault2_status>
						<filevault2_percent>0</filevault2_percent>
					</partition>
					<partition>
						<name>Update</name>
						<size>494384</size>
						<type>other</type>
						<partition_capacity_mb>494384</partition_capacity_mb>
						<percentage_full>1</percentage_full>
						<available_mb>215508</available_mb>
						<filevault_status>Not Encrypted</filevault_status>
						<filevault_percent>0</filevault_percent>
						<filevault2_status>Not Encrypted</filevault2_status>
						<filevault2_percent>0</filevault2_percent>
					</partition>
					<partition>
						<name>Preboot</name>
						<size>494384</size>
						<type>other</type>
						<partition_capacity_mb>494384</partition_capacity_mb>
						<percentage_full>1</percentage_full>
						<available_mb>215508</available_mb>
						<filevault_status>Not Encrypted</filevault_status>
						<filevault_percent>0</filevault_percent>
						<filevault2_status>Not Encrypted</filevault2_status>
						<filevault2_percent>0</filevault2_percent>
					</partition>
					<partition>
						<name>VM</name>
						<size>494384</size>
						<type>other</type>
						<partition_capacity_mb>494384</partition_capacity_mb>
						<percentage_full>3</percentage_full>
						<available_mb>215508</available_mb>
						<filevault_status>Encrypted</filevault_status>
						<filevault_percent>0</filevault_percent>
						<filevault2_status>Not Encrypted</filevault2_status>
						<filevault2_percent>0</filevault2_percent>
					</partition>
					<partition>
						<name>iSCPreboot</name>
						<size>524</size>
						<type>other</type>
						<partition_capacity_mb>524</partition_capacity_mb>
						<percentage_full>2</percentage_full>
						<available_mb>505</available_mb>
						<filevault_status>Not Encrypted</filevault_status>
						<filevault_percent>0</filevault_percent>
						<filevault2_status>Not Encrypted</filevault2_status>
						<filevault2_percent>0</filevault2_percent>
					</partition>
				</partitions>
			</device>
		</storage>
	</hardware>
<software>
<applications>
"${applicationsXml}"
</applications>
</software>
</computer>"

	# Send the computer record to your Jamf Pro instance
	curl -sku ${apiUser}:${apiPass} \
	-X POST	-H "content-type: application/xml" \
	${jssURL}/JSSResource/computers/id/0 \
	-d "${xmlData}" --output /dev/null   # <-- remove '--output' if you want to see whats going on.
	
	# Print something to the screen, on the same line.
	printf "\033[2K \rCreating computer ${computer_name}${asset} 1 of $(expr "${counter}" + 1)"
	# Send name to a text file so we can use them later to delete all the create devices if needed.
	echo "${computer_name}${asset}" >> /Users/Shared/computers.txt

	done
	fi
}
	
		
# Input can be either 'mobiledevices' or 'computers'
delete_records computers

# create IOS device/computer XX, XX being the number of devices to create.
#create_mobiledevices 10
#create_computers 10
