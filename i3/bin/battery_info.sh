#!/usr/bin/env bash
##!/bin/sh

# # If ACPI was not installed, this probably is a battery-less computer.
# ACPI_RES=$(acpi -b)
# ACPI_CODE=$?
# if [ $ACPI_CODE -eq 0 ]
# then
#     # Get essential information. Due to som bug with some versions of acpi it is
#     # worth filtering the ACPI result from all lines containing "unavailable".
#     BAT_LEVEL_ALL=$(echo "$ACPI_RES" | grep -v "unavailable" | grep -E -o "[0-9][0-9]?[0-9]?%")
#     BAT_LEVEL=$(echo "$BAT_LEVEL_ALL" | awk -F"%" 'BEGIN{tot=0;i=0} {i++; tot+=$1} END{printf("%d%%\n", tot/i)}')
#     TIME_LEFT=$(echo "$ACPI_RES" | grep -v "unavailable" | grep -E -o "[0-9]{2}:[0-9]{2}:[0-9]{2}")
#     IS_CHARGING=$(echo "$ACPI_RES" | grep -v "unavailable" | awk '{ printf("%s\n", substr($3, 0, length($3)-1) ) }')

#     # If there is no 'time left' information (when almost fully charged) we 
#     # provide information ourselvs.
#     if [ -z "$TIME_LEFT" ]
#     then
#         TIME_LEFT="00:00:00"
#     fi

#     # Print full text. The charging data.
#     TIME_LEFT=$(echo $TIME_LEFT | awk '{ printf("%s\n", substr($1, 0, 5)) }')
#     echo "🔋$BAT_LEVEL ⏳$TIME_LEFT "

#     # Print the short text.
#     echo "BAT: $BAT_LEVEL"
    
#     # Change the font color, depending on the situation.
#     if [ "$IS_CHARGING" = "Charging" ]
#     then
#         # Charging yellow color.
#         echo "#D0D000"
#     else
#         if [ "${BAT_LEVEL%?}" -le 15 ]
#         then
#             # Battery very low. Red color.
#             echo "#FA1E44"
#         else
#             # Battery not charging but at decent level. Green color.
#             echo "#007872"
#         fi
#     fi
# fi
# Prints all batteries, their percentage remaining and an emoji corresponding
# to charge status (🔌 for plugged up, 🔋 for discharging on battery, etc.).

case $BLOCK_BUTTON in
	1) notify-send -u low "Battery status" "$(acpi | cut -d ' ' -f5-)" ;;
	3) notify-send -u low -i none "🔋 Battery module" "🔋: discharging
🛑: not charging
♻: stagnant charge
🔌: charging
⚡: charged
❗: battery very low!
- Scroll to change adjust xbacklight." ;;
	4) sudo xbacklight -inc 5 ;;
	5) sudo xbacklight -dec 5 ;;
	6) "$TERMINAL" -e "$EDITOR" "$0" ;;
esac

#acpi alternative
#acpi | sed "s/Battery [0-9]: //;s/[Dd]ischarging, / /;s/[Nn]ot charging, /🛑 /;s/[Cc]harging, / /;s/[Uu]nknown, /♻️ /;s/[Ff]ull, / /;s/ \(remaining\|until charged\)//"; exit

# Check if battery directories are detected
[ ! -e /sys/class/power_supply/BAT?* ] && echo "No battery found" && exit 1

# Loop through all attached batteries and format the info
for battery in /sys/class/power_supply/BAT?*
do
	# Sets up the status and capacity
	status=$(cat "$battery/status")
	case "$status" in
		"Full") status=" " ;;
		"Discharging") status=" " ;;
		"Charging") status=" " ;;
		"Not charging") status=" " ;;
		"Unknown") status=" " ;;
	esac
	capacity=$(cat "$battery/capacity")
	# Will make a warn variable if discharging and low
	[ "$status" = " " ] && [ "$capacity" -le 20 ] && warn='❗'
	# Prints the info
	printf "%s%s%d%%\n" "$warn" "$status" "$capacity"; unset warn
done && return 0
