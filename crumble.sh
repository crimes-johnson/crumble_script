#!/bin/bash

#Codename Crumble (Apple)
#The following bash script should be used to examine and get various bits of information about MacBooks.
#Created on macOS 12.1, works on Catalina and Big Sur. Anything lower than OSX will probably break.
#Information gathered is output to a txt file in the same directory that the script is in.

#Set filename and time stamp
DATE=$(date +%d%b%Y)
TS=$(date)
echo "Please enter the Scan ID of the unit you are testing."
read FILE
touch "$FILE"_"$DATE.txt"

#Getting all specs including hardware lock status, serial, chipset, etc.
SPECS=$(system_profiler SPHardwareDataType | awk -F "\t" '/Serial Number|Model|Cores|Firmware|Activation/')

#CPU
CPU=$(sysctl -a | grep brand | awk -F ':' 'NR==1{print $2}')

#GPU Specs for intel 15.4/16" models or Desktops
GPU=$(system_profiler SPDisplaysDataType | grep "Chipset Model")

#RAM specs, separated from SPECS for readable format
RAM=$(system_profiler SPHardwareDataType | grep "Memory")

#Battery status more complete information on health
BCC=$(system_profiler SPPowerDataType | awk '/Cycle Count|Condition|Maximum Capacity/')

#Drive capacity human readable
DRIVE=$(system_profiler SPNVMeDataType | grep "Capacity" | awk -F ':' 'NR==1{print $0}')

#This isn't working properly yet
DIAGS=$(system_profiler SPDiagnosticsDataType | grep Result)

#Last reboot time stamp
LSRB=$(last reboot | head -1)

#Camera "diagnostics", checking to see if the hardware is detected
CAM=$(system_profiler SPCameraDataType | awk -F ':' '{print $2}')

#Ease of access for the S/N during warranty check
SERIAL=$(system_profiler SPHardwareDataType | grep "Serial Number")

#This section covers the selection menu that divides up the testing components.
echo "Read and select one of the following options to complete the testing process."
echo "-----------------------------------------"
PS3='Select option: '
options=("Specifications Check" "Network Quality Control" "Audio Quality Control" "Open Testing Applications" "Quit Program")
select opt in "${options[@]}"
do
    case $opt in
        "Specifications Check")
            #Outputs the above vars in stdout and outputs to defined file
            echo "-----------------------------------------" && echo "-----------------------------------------" >> "$FILE"_"$DATE.txt"
            echo "MacOS Testing Script 1.13" && echo "MacOS Testing Script 1.13" >> "$FILE"_"$DATE.txt"
            echo "Scan ID: " $FILE && echo "Scan ID: " $FILE >> "$FILE"_"$DATE.txt"
            echo "Start Time:" $TS && echo "Start Time:" $TS >> "$FILE"_"$DATE.txt"
            echo $CPU && echo $CPU >> "$FILE"_"$DATE.txt"
            echo $GPU && echo $GPU >> "$FILE"_"$DATE.txt"
            echo $DRIVE && echo $DRIVE >> "$FILE"_"$DATE.txt"
            echo "$RAM" && echo "$RAM" >> "$FILE"_"$DATE.txt"
            echo "$SPECS" && echo "$SPECS" >> "$FILE"_"$DATE.txt"
            echo "-----------------------------------------" && echo "-----------------------------------------" >> "$FILE"_"$DATE.txt"
            echo "$BCC" && echo "$BCC" >> "$FILE"_"$DATE.txt"
            echo "-----------------------------------------" && echo "-----------------------------------------" >> "$FILE"_"$DATE.txt"
            echo "Last Boot Diagnostic" $DIAGS && echo "Last Boot Diagnostic" $DIAGS >> "$FILE"_"$DATE.txt"
            echo "Last" $LSRB && echo "Last" $LSRB >> "$FILE"_"$DATE.txt"
            echo -e "Unique camera information\n" $CAM && echo -e "Unique camera information\n" $CAM >> "$FILE"_"$DATE.txt"
            ;;
        "Network Quality Control")
            #Basic ping out to check for network connection. macOS 12+ has networkQuality which is better
            echo "-----------------------------------------"
            ping -c 4 8.8.8.8
            echo -n "QC Pass? [Y/n] "
            read INPUT
            if [[ $INPUT == "Y" || $INPUT == "y" ]]; then
                echo "Network QC PASSED." >> "$FILE"_"$DATE.txt"
            else
                echo "Network QC FAILED." >> "$FILE"_"$DATE.txt"
            fi
            ;;
        "Audio Quality Control")
            #Plays sounds and outputs user input to file, requires chmod to play properly
            echo "-----------------------------------------"
            say "Please stand by for audio quality test"
            afplay TicLeftRightLow.mp3
            afplay /System/Library/Sounds/Submarine.aiff
            echo "Audio QC Pass? [Y/n] "
            read INPUT
            if [[ $INPUT == "Y" || $INPUT == "y" ]]; then
                echo "Audio QC PASSED." >> "$FILE"_"$DATE.txt"
            else
                echo "Audio QC FAILED." >> "$FILE"_"$DATE.txt"
            fi
            ;;
        "Open Testing Applications")
            #Opens safari to web testing pages and also handles warranty information
            echo "-----------------------------------------"
            echo "Opening testing applications in 10 seconds, please hold."
            echo "Keyboard, microphone, and camera tested." >> "$FILE"_"$DATE.txt"
            sleep 3
            open -a Safari https://www.keyboardtester.com/tester.html
            open -a Safari https://mictests.com/
            open -a Safari https://checkcoverage.apple.com/
            open -a "Photo Booth"
            echo $SERIAL
            echo "Please enter the warranty date: "
            read INPUT
            echo "Warranty date: " $INPUT >> "$FILE"_"$DATE.txt"
            ;;
        "Quit Program")
            break
            ;;
        *) echo "invalid option $REPLY";;
    esac
done

#changelog
#42922 - Made the spec data more reader friendly, reduced sleep state as its unecessary
